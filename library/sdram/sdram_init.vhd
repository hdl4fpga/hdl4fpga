-- Copyright (c) 2015 Miguel Angel Sagreras                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library hdl4fpga;
use hdl4fpga.hdo.all;
use hdl4fpga.base.all;
use hdl4fpga.sdrampkg.all;

entity sdram_init is
	generic (
		debug           : boolean;
		ctlr_tcp        : real;
		sdramtmng_data  : string;
		gear            : natural;
		generation      : string;
		generation_data : string);
	port (

		init_rst         : in  std_logic := '0';
		sdram_init_clk   : in  std_logic := '-';
		init_cfg         : buffer std_logic := '0';
		sdram_refi_rdy   : in  std_logic := '0';
		sdram_refi_req   : buffer std_logic := '0';
		sdram_init_wlrdy : in  std_logic := '0';
		sdram_init_wlreq : buffer std_logic := '0';

		sdram_init_bl   : in  std_logic_vector(3-1 downto 0) := (others => '0');
		sdram_init_bt   : in  std_logic := '0';
		sdram_init_cl   : in  std_logic_vector(4-1 downto 0) := (others => '0');
		sdram_init_ods  : in  std_logic_vector(2-1 downto 0) := (others => '0');

		sdram_init_wb   : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdram_init_al   : in  std_logic_vector(3-1 downto 0) := (others => '0');
		sdram_init_asr  : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdram_init_cwl  : in  std_logic_vector(3-1 downto 0) := (others => '0');
		sdram_init_drtt : in  std_logic_vector(2-1 downto 0) := (others => '0');
		sdram_init_edll : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdram_init_mpr  : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdram_init_mprrf : in std_logic_vector(2-1 downto 0) := (others => '0');
		sdram_init_qoff : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdram_init_rtt  : in  std_logic_vector(3-1 downto 0) := (others => '0');
		sdram_init_srt  : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdram_init_tdqs : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdram_init_wl   : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdram_init_ddqs : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdram_init_rdqs : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdram_init_pd   : in  std_logic_vector(1-1 downto 0) := (others => '0');

		sdram_init_rst : out  std_logic := '0';
		sdram_init_cke : out std_logic;
		sdram_init_cs  : out std_logic;
		sdram_init_cmd : out std_logic_vector(0 to 3-1);
		sdram_init_a   : out std_logic_vector;
		sdram_init_b   : out std_logic_vector;
		sdram_init_odt : out std_logic);

	attribute fsm_encoding : string;
	attribute fsm_encoding of sdram_init : entity is "compact";

end;

architecture def of sdram_init is

	constant init_data       : string  := hdo(sdr_init_data)**('.'&generation&"={}");
	constant init_seq        : string  := hdo(init_data)**".seq=[]";
	constant init_seq_length : natural := length(init_seq);

	signal timer_sel : std_logic_vector(unsigned_num_bits(init_seq_length-1)-1 downto 0) := (others => '0');
	signal timer_rdy : std_ulogic := '0';
	signal timer_req : std_ulogic := '0';

begin

	process (init_rst, sdram_init_clk)
		constant wrl : natural := natural(ceil(real'(hdo(sdramtmng_data)**".tWR")/ctlr_tcp))*gear;
		constant sdram_init_wr : std_logic_vector := hdo(generation_data)**(".wrl['"&natural'image(wrl)&"']='000'");

		variable step : natural range 0 to init_seq_length;
	begin
		if init_rst='1' then
			init_cfg  <= '0';
			timer_req <= timer_rdy;
			step      := 0;
		elsif rising_edge(sdram_init_clk) then
			if (timer_req xor timer_rdy)='0' then
				if init_cfg='0' then
					sdram_init_cmd <= (others => '-');
					sdram_init_rst <= '-';
					sdram_init_cs  <= '-';
					sdram_init_cke <= '-';
					sdram_init_odt <= '-';
					sdram_init_b   <= (sdram_init_b'range => '-');
					sdram_init_a   <= (sdram_init_a'range => '-');
					init_cfg <= not init_rst;
					for i in 0 to init_seq_length-1 loop -- Latticesemi Diamond work around
						if i=step then
							sdram_init_cmd <= hdo(cmd)**('.'&string'(hdo(init_seq**i)**".cmd"));
							sdram_init_rst <= hdo(init_seq)**("["&natural'image(i)&"].data.rst='-'");
							sdram_init_cs  <= hdo(init_seq)**("["&natural'image(i)&"].data.cs");
							sdram_init_cke <= hdo(init_seq)**("["&natural'image(i)&"].data.cke");
							sdram_init_odt <= hdo(init_seq)**("["&natural'image(i)&"].data.odt='0'");
							mr (
								generation => generation,
								row   => init_seq**i,
								al    => sdram_init_al,
								asr   => sdram_init_asr,
								bl    => sdram_init_bl,
								bt    => sdram_init_bt,
								cl    => sdram_init_cl,
								cwl   => sdram_init_cwl,
								drtt  => sdram_init_drtt,
								mpr   => sdram_init_mpr,
								mprrf => sdram_init_mprrf,
								ods   => sdram_init_ods,
								pd    => sdram_init_pd,
								rdqs  => sdram_init_rdqs,
								rtt   => sdram_init_rtt,
								tdqs  => sdram_init_tdqs,
								wr    => sdram_init_wr,
								b     => sdram_init_b,
								a     => sdram_init_a);
							timer_sel <= std_logic_vector(to_unsigned(i, timer_sel'length));
							init_cfg  <= init_rst;
							step := step + 1;
							exit;
						end if;
					end loop;
				elsif (sdram_refi_req xor sdram_refi_rdy)='0' then
					sdram_refi_req <= not sdram_refi_rdy;
				end if;
			else
				sdram_init_cmd <= hdo(cmd)**".nop";
			end if;
			timer_req <= not timer_rdy;
		end if;
	end process;

	sdram_timer_b : block
		constant gentmng_data : string := hdo(generation_data)**".tmng";

		constant PreRST  : natural := max(natural(real'(hdo(gentmng_data)**".tPreRST=0")/ctlr_tcp),1);
		constant RP      : natural := max(natural(real'(hdo(sdramtmng_data)**".tRP=0")/ctlr_tcp),1);
		constant PstRST  : natural := max(natural(real'(hdo(gentmng_data)**".tPstRST=0")/ctlr_tcp),1);
		constant RPA     : natural := max(natural(real'(hdo(gentmng_data)**".tRPA=0")/ctlr_tcp),1);
		constant MRD     : natural := max(natural(real'(hdo(sdramtmng_data)**".tMRD=0")/ctlr_tcp),1);
		constant REFi    : natural := max(natural(real'(hdo(sdramtmng_data)**".tREFI")/ctlr_tcp),1);
		constant RFC     : natural := max(natural(real'(hdo(sdramtmng_data)**".tRFC")/ctlr_tcp),1);
		constant cDLL    : natural := hdo(gentmng_data)**".cDLL=1";
		constant ZQINIT  : natural := hdo(gentmng_data)**".ZQINIT=1";
		constant MODu    : natural := hdo(gentmng_data)**".MODu=1";
		constant XPR     : natural := max(natural((real'(hdo(sdramtmng_data)**".tRFC")+10.0e-9)/ctlr_tcp),hdo(gentmng_data)**".XPR=1");
		constant WLDQSEN : natural := hdo(gentmng_data)**".WLDQSEN=1";

		constant sdram_timers : string := '{' &
			"PreRST  : " & natural'image(PreRST) & ',' &
			"RP      : " & natural'image(RP)     & ',' &
			"PstRST  : " & natural'image(PstRST) & ',' &
			"cDLL    : " & natural'image(cDLL)   & ',' &
			"RPA     : " & natural'image(RPA)    & ',' &
			"ZQINIT  : " & natural'image(ZQINIT) & ',' &
			"MRD     : " & natural'image(MRD)    & ',' &
			"MODu    : " & natural'image(MODu)   & ',' &
			"XPR     : " & natural'image(XPR)    & ',' &
			"WLDQSEN : " & natural'image(WLDQSEN)& ',' &
			"REFi    : " & natural'image(REFi)   & ',' &
			"RFC     : " & natural'image(RFC)    & '}';

		function get_timers (
			constant init_seq : string)
			return natural_vector is

			variable timers : natural_vector(0 to 32-1);
			variable n      : natural;
		begin
			n := 0;
			for i in 0 to init_seq_length-1 loop
				assert n < timers'length
					report "get_timers () : n => " & natural'image(n) & " greater than timers length " & natural'image(timers'length)
					severity failure;
				assert not true --debug
					report  "get_timers () : timer id => " & string'(hdo(init_seq)**('['&natural'image(n)&"].timer"))
					severity note;
				report  "get_timers () : timer id => " & string'(hdo(init_seq)**('['&natural'image(n)&"].timer"));
				timers(n) := hdo(sdram_timers)**('.' & string'(hdo(init_seq)**('['&natural'image(n)&"].timer")));
				n := n + 1;
			end loop;
			assert n/=0 
				report "get_timers() : init_seq => "&'"'& init_seq & '"' & " invalid init_seq"
				severity failure;
			return timers(0 to n-1);
		end;

		constant timers     : natural_vector := get_timers(init_seq);
		constant stages     : natural := unsigned_num_bits(max(timers))/4;
		constant timer_size : natural := unsigned_num_bits(max(timers))+stages;
	
		function slices
			return natural_vector is
			variable val : natural_vector(stages downto 0);
			variable quo : natural := timer_size mod stages;
		begin
			val(0) := 0;
			for i in 1 to stages loop
				val(i) := timer_size/stages + val(i-1);
				if i*quo >= stages then
					val(i) := val(i) + 1;
					quo := quo - 1;
				end if;

			end loop;
			return val;
		end;

		function timerbits 
			return std_logic_vector is
			variable size   : natural;
			variable value  : std_logic_vector(timer_size-1 downto 0);
			variable timer  : natural;
			variable retval : std_logic_vector(0 to timer_size*timers'length-1);
		begin
			for i in timers'range loop
				value  := (others => '-');
				timer  := timers(i);
				if timer < stages then
					timer := stages;
				end if;
				for j in stages-1 downto 0 loop
					size := slices(j+1)-slices(j);
					value := std_logic_vector(unsigned(value) sll size);
					value(size-1 downto 0) := std_logic_vector(to_unsigned(((2**size-1)+((timer-stages)/2**(slices(j)-j)) mod 2**(size-1)) mod 2**size, size));
				end loop;
				retval(timer_size*i to timer_size*(i+1)-1) := value;
			end loop;
			return retval;
		end;

		signal value : std_logic_vector(timer_size-1 downto 0);
	begin

	assert false
		report LF 
			& "sdram_init : PreRST  : " & natural'image(PreRST)  & LF 
			& "sdram_init : RP      : " & natural'image(RP)      & LF 
			& "sdram_init : PstRST  : " & natural'image(PstRST)  & LF 
			& "sdram_init : cDLL    : " & natural'image(cDLL)    & LF 
			& "sdram_init : RPA     : " & natural'image(RPA)     & LF 
			& "sdram_init : ZQINIT  : " & natural'image(ZQINIT)  & LF 
			& "sdram_init : MRD     : " & natural'image(MRD)     & LF 
			& "sdram_init : MODu    : " & natural'image(MODu)    & LF 
			& "sdram_init : XPR     : " & natural'image(XPR)     & LF 
			& "sdram_init : WLDQSEN : " & natural'image(WLDQSEN) & LF 
			& "sdram_init : REFi    : " & natural'image(REFi)    & LF 
			& "sdram_init : RFC     : " & natural'image(RFC)     & LF 
		severity note;

		assert not debug
			report LF & "timer_size is value " & natural'image(timer_size)
			severity note;

		assert not debug
			report LF & "stages is value " & natural'image(stages)
			severity note;

		mem_e : entity hdl4fpga.rom
		generic map (
			bitrom  => timerbits,
			latency => 0)
		port map (
			clk  => sdram_init_clk,
			addr => timer_sel,
			data => value);
	
		timer_e : entity hdl4fpga.timer
		generic map (
			slices => slices(stages downto 1))
		port map (
			data => value,
			clk => sdram_init_clk,
			req => timer_req,
			rdy => timer_rdy);

	end block;
end;
