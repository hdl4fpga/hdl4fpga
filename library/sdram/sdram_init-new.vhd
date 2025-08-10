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

		sdram_refi_rdy : in  std_logic := '-';
		sdram_refi_req : out std_logic := '0';
		sdram_init_clk : in  std_logic := '-';
		sdram_init_wlrdy : in  std_logic := '-';
		sdram_init_wlreq : buffer std_logic;
		sdram_init_req : in  std_logic := '0';
		sdram_init_rdy : buffer std_logic := '1';
		sdram_init_rst : out std_logic;
		sdram_init_cke : out std_logic;
		sdram_init_cs  : out std_logic;
		sdram_init_ras : out std_logic;
		sdram_init_cas : out std_logic;
		sdram_init_we  : out std_logic;
		sdram_init_a   : out std_logic_vector;
		sdram_init_b   : out std_logic_vector;
		sdram_init_odt : out std_logic);

	attribute fsm_encoding : string;
	attribute fsm_encoding of sdram_init : entity is "compact";


end;

architecture def of sdram_init is

	signal timer_rdy : std_ulogic := '0';
	signal timer_req : std_ulogic := '0';

	constant mr  : string := "{mr0 :'000', mr1:'001', mr2:'010', mr3:'011'}";
	constant cmd : string := "{nop :'111', mrs:'000', pre:'010', ref:'001', zqc:'110'}";

	constant sdr_init_seq : string := "{"                       &
		"sdr:["                                                 &
			"{nop, PreRST,  {cs:0, cke:0}},"                    &
			"{pre, RP,      {cs:0, cke:1}},"                    &
			"{ref, RFC,     {cs:0, cke:1}},"                    &
			"{ref, RFC,     {cs:0, cke:1}},"                    &
			"{mrs, MRD,     {cs:0, cke:1}, mr0},"               &
			"{nop, REFi,    {cs:0, cke:1}}],"                   &
		"ddr:["                                                 &
			"{nop, PreRST,  {cs:0, cke:0}},"                    &
			"{nop, XPR,     {cs:0, cke:1}},"                    &
			"{pre, RP,      {cs:0, cke:1}},"                    &
			"{mrs, MRD,     {cs:0, cke:1}, mr1},"               &
			"{mrs, MRD,     {cs:0, cke:1}, mr0},"               &
			"{pre, RPA,     {cs:0, cke:1}},"                    &
			"{ref, RFC,     {cs:0, cke:1}},"                    &
			"{ref, RFC,     {cs:0, cke:1}},"                    &
			"{mrs, MRD,     {cs:0, cke:1}, mr0},"               &
			"{nop, DLL,     {cs:0, cke:1}},"                    &
			"{nop, REFi,    {cs:0, cke:1}}],"                   &
		"ddr2:["                                                &
			"{nop, PreRST,  {cs:0, cke:0, odt:0}},"             &
			"{nop, XPR,     {cs:1, cke:1, odt:0}},"             &
			"{pre, RPA,     {cs:1, cke:1, odt:0}},"             &
			"{mrs, MRD,     {cs:1, cke:1, odt:0}, mr2},"        &
			"{mrs, MRD,     {cs:1, cke:1, odt:0}, mr3},"        &
			"{mrs, MRD,     {cs:1, cke:1, odt:0}, mr1},"        &
			"{mrs, MRD,     {cs:1, cke:1, odt:0}, mr0},"        &
			"{pre, RPA,     {cs:1, cke:1, odt:0}},"             &
			"{ref, RFC,     {cs:1, cke:1, odt:0}},"             &
			"{ref, RFC,     {cs:1, cke:1, odt:0}},"             &
			"{mrs, MRD,     {cs:1, cke:1, odt:0}, mr0},"        &
			"{mrs, MRD,     {cs:1, cke:1, odt:0}, mr1},"        &
			"{mrs, MRD,     {cs:1, cke:1, odt:0}, mr1},"        &
			"{pre, RPA,     {cs:1, cke:1, odt:0}},"             &
			"{nop, REFi,    {cs:1, cke:1, odt:1}}],"            &
		"ddr3:["                                                &
			"{nop, PreRST,  {cs:0, cke:0, odt:0, rst:0}},"      &
			"{nop, PstRST,  {cs:0, cke:0, odt:0, rst:1}},"      &
			"{nop, XPR,     {cs:0, cke:1, odt:0, rst:1}},"      &
			"{mrs, MRD,     {cs:0, cke:1, odt:0, rst:1}, mr2}," &
			"{mrs, MRD,     {cs:0, cke:1, odt:0, rst:1}, mr3}," &
			"{mrs, MRD,     {cs:0, cke:1, odt:0, rst:1}, mr1}," &
			"{mrs, MRD,     {cs:0, cke:1, odt:0, rst:1}, mr0}," &
			"{zqc, ZQINIT,  {cs:0, cke:1, odt:0, rst:1}},"      &
			"{mrs, MODu,    {cs:0, cke:1, odt:0, rst:1}, mr1}," &
			"{nop, WLDQSEN, {cs:0, cke:1, odt:1, rst:1}},"      &
			"{mrs, MODu,    {cs:0, cke:1, odt:0, rst:1}, mr1}," &
			"{nop, DLL,     {cs:0, cke:1, odt:0, rst:1}},"      &
			"{nop, REFi,    {cs:0, cke:1, odt:0, rst:1}}]}";

	constant wrl      : natural          := natural(ceil(real'(hdo(sdramtmng_data)**".tWR")/ctlr_tcp))*gear;
	constant init_wr  : std_logic_vector := hdo(generation_data)**(".wrl['"&natural'image(wrl)&"']='000'");
	constant init_seq : string           := hdo(sdr_init_seq)**('.'&generation&"=[]");
	constant init_seq_length : natural   := hdl4fpga.hdo.length(init_seq);

	signal timer_sel  : std_logic_vector(unsigned_num_bits(init_seq_length-1)-1 downto 0) := (others => '0');

begin

	seq_b : block
		function xxx(
			constant obj : string)
			return string is
			constant rcw : string := escaped(hdo(cmd)**('.'&hdo(obj)**0));
			constant yyy : string := hdo(obj)**0;

		begin
			return "{" &
				"ras:" & rcw(1) & ',' &
				"cas:" & rcw(2) & ',' &
				"we:"  & rcw(3) & ',' &
				"xxx:" & string'(hdo(obj)**2) &
				"}";
		end;
	begin
		process (sdram_init_clk)
			variable step : natural range 0 to init_seq_length-1;
			type states is (s_init, s_run);
			variable state : states;
		begin
			if rising_edge(sdram_init_clk) then
				if (timer_req xor timer_rdy)='0' then
					if (sdram_init_rdy xor sdram_init_req)='1' then
						case state is
						when s_init =>
							step  := 0;
							state := s_run;
						when s_run =>
							report hdo(xxx(init_seq**step))**".ras";
							if step < init_seq_length-1 then
								step := step + 1;
							else
								sdram_init_rdy <= sdram_init_req;
							end if;
						end case;
					else
						state := s_init;
					end if;
					sdram_init_rst <= hdo(xxx(init_seq**step))**".xxx.rst='-";
					sdram_init_cs  <= hdo(xxx(init_seq**step))**".xxx.cs";
					sdram_init_cke <= hdo(xxx(init_seq**step))**".xxx.cke";
					sdram_init_ras <= hdo(xxx(init_seq**step))**".ras";
					sdram_init_cas <= hdo(xxx(init_seq**step))**".cas";
					sdram_init_we  <= hdo(xxx(init_seq**step))**".we";
					sdram_init_odt <= hdo(xxx(init_seq**step))**".xxx.odt='-'";
					timer_sel <= std_logic_vector(to_unsigned(step, timer_sel'length));
					timer_req <= not timer_rdy;
				else
					sdram_init_ras <= mpu_nop(0);
					sdram_init_cas <= mpu_nop(1);
					sdram_init_we  <= mpu_nop(2);
				end if;
			end if;
		end process;


	end block;

	-----------------
	--- SDR_TIMERs --
	-----------------

	sdram_timer_b : block

		constant gentmng_data : string := hdo(generation_data)**".tmng";

		constant PreRST    : natural := natural(ceil(real'(hdo(gentmng_data)**".tPreRST=0")/ctlr_tcp));
		constant RP        : natural := natural(ceil(real'(hdo(sdramtmng_data)**".tRP=0")/ctlr_tcp));
		constant PstRST    : natural := natural(ceil(real'(hdo(gentmng_data)**".tPstRST=0")/ctlr_tcp));
		constant cDLL      : natural := hdo(gentmng_data)**".cDLL=0";
		constant RPA       : natural := natural(ceil(real'(hdo(gentmng_data)**".tRPA=0")/ctlr_tcp));
		constant ZQINIT    : natural := hdo(gentmng_data)**".ZQINIT=0.";
		constant MRD       : natural := natural(ceil(real'(hdo(sdramtmng_data)**".tMRD=0")/ctlr_tcp));
		constant MODu      : natural := hdo(gentmng_data)**".MODu=0";
		constant XPR       : natural := hdo(gentmng_data)**".XPR=0";
		constant WLDQSEN   : natural := hdo(gentmng_data)**".WLDQSEN=0";
		constant REFi      : natural := natural(ceil(real'(hdo(sdramtmng_data)**".tREFI")/ctlr_tcp));
		constant RFC       : natural := natural(ceil(real'(hdo(sdramtmng_data)**".tRFC")/ctlr_tcp));

		function get_timers (
			constant init_seq : string)
			return natural_vector is

			function get_timer (
				constant id : string)
				return natural is

			begin
				report "get_timer() : id => " & '"' & id & '"';
				if id="PreRST" then 
					return PreRST;
				end if;
				if id="RP" then 
					return RP;
				end if;
				if id="PstRST" then 
					return PstRST;
				end if;
				if id="cDLL" then 
					return cDLL;
				end if;
				if id="RPA" then 
					return RPA;
				end if;
				if id="ZQINIT" then 
					return ZQINIT;
				end if;
				if id="MRD" then 
					return MRD;
				end if;
				if id="MODu" then 
					return MODu;
				end if;
				if id="XPR" then 
					return XPR;
				end if;
				if id="WLDQSEN" then 
					return WLDQSEN;
				end if;
				if id="REFi" then 
					return REFi;
				end if;
				if id="RFC" then 
					return RFC;
				end if;
				assert id'length /= 0
					report "get_timer() : id => "&'"'& id & '"' & " invalid id"
					severity failure;
				return 0;
			end;
			variable timers : natural_vector(0 to 32-1);
			variable n : natural;
		begin
			n := 0;
			for i in init_seq'range loop
				assert n < timers'length
					report "get_timers () : n => " & natural'image(n) & " greater than timers length " & natural'image(timers'length)
					severity failure;
				timers(n) := get_timer(hdo(hdo(init_seq)**n)**1);
				exit when timers(n)=0;
				n := n + 1;
			end loop;
			assert n/=0 
				report "get_timers() : init_seq => "&'"'& init_seq & '"' & " invalid init_seq"
				severity failure;
			return timers(0 to n-1);
		end;

		constant timers     : natural_vector := get_timers(init_seq);
		signal xxxx : natural_vector(timers'range) := timers;
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
		report LF &
			"sdram_init : PreRST  : " & natural'image(PreRST)&LF&
			"sdram_init : RP      : " & natural'image(RP)&LF&
			"sdram_init : PstRST  : " & natural'image(PstRST)&LF&
			"sdram_init : cDLL    : " & natural'image(cDLL)&LF&
			"sdram_init : RPA     : " & natural'image(RPA)&LF&
			"sdram_init : ZQINIT  : " & natural'image(ZQINIT)&LF&
			"sdram_init : MRD     : " & natural'image(MRD)&LF&
			"sdram_init : MODu    : " & natural'image(MODu)&LF&
			"sdram_init : XPR     : " & natural'image(XPR)&LF&
			"sdram_init : WLDQSEN : " & natural'image(WLDQSEN)&LF&
			"sdram_init : REFi    : " & natural'image(REFi)&LF&
			"sdram_init : RFC     : " & natural'image(RFC)&LF
		severity note;

		assert false
			report LF & "timer_size is value " & natural'image(timer_size)
			severity note;

		assert false
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
