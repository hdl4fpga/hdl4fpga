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
		sdram_refi_req : buffer std_logic := '0';
		sdram_init_clk : in  std_logic := '-';
		sdram_init_wlrdy : in  std_logic := '-';
		sdram_init_wlreq : buffer std_logic;
		sdram_init_req : in  std_logic := '0';
		sdram_init_rdy : buffer std_logic := '1';
		sdram_init_rst : out std_logic;
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

	signal timer_rdy : std_ulogic := '0';
	signal timer_req : std_ulogic := '0';

	constant cmd : string := "{nop :'111', mrs:'000', pre:'010', ref:'001', zqc:'110'}";

	constant sdr_init_data : string := "{"                         &
		"sdr:{"                                                    &
			"seq:["                                                &
				"{nop, PreRST,  {cs:1, cke:0}},"                   &
				"{nop, XPR,     {cs:0, cke:1}},"                   &
				"{pre, RP,      {cs:0, cke:1}},"                   &
				"{ref, RFC,     {cs:0, cke:1}},"                   &
				"{ref, RFC,     {cs:0, cke:1}},"                   &
				"{mrs, MRD,     {cs:0, cke:1, a:mr0}},"            &
				"{nop, REFi,    {cs:0, cke:1}}]},"                 &
		"ddr:{"                                                    &
			"seq:["                                                &
				"{nop, PreRST,  {cs:0, cke:0}},"                   &
				"{nop, XPR,     {cs:0, cke:1}},"                   &
				"{pre, RP,      {cs:0, cke:1}},"                   &
				"{mrs, MRD,     {cs:0, cke:1, a:mr1}},"            &
				"{mrs, MRD,     {cs:0, cke:1, a:rst_dll}},"        &
				"{pre, RPA,     {cs:0, cke:1}},"                   &
				"{ref, RFC,     {cs:0, cke:1}},"                   &
				"{ref, RFC,     {cs:0, cke:1}},"                   &
				"{mrs, MRD,     {cs:0, cke:1, a:mr0}},"            &
				"{nop, cDLL,    {cs:0, cke:1}},"                   &
				"{nop, REFi,    {cs:0, cke:1}}]},"                 &
		"ddr2:{"                                                   &
			"seq:["                                                &
				"{nop, PreRST,  {cs:0, cke:0}},"                   &
				"{nop, XPR,     {cs:1, cke:1}},"                   &
				"{pre, RPA,     {cs:1, cke:1}},"                   &
				"{mrs, MRD,     {cs:1, cke:1, a:mr2}},"            &
				"{mrs, MRD,     {cs:1, cke:1, a:mr3}},"            &
				"{mrs, MRD,     {cs:1, cke:1, a:ena_dll}},"        &
				"{mrs, MRD,     {cs:1, cke:1, a:rst_dll}},"        &
				"{pre, RPA,     {cs:1, cke:1}},"                   &
				"{ref, RFC,     {cs:1, cke:1}},"                   &
				"{ref, RFC,     {cs:1, cke:1}},"                   &
				"{mrs, MRD,     {cs:1, cke:1, a:mr0}},"            &
				"{mrs, MRD,     {cs:1, cke:1, a:ena_ocd}},"        &
				"{mrs, MRD,     {cs:1, cke:1, a:mr1}},"            &
				"{pre, RPA,     {cs:1, cke:1}},"                   &
				"{nop, REFi,    {cs:1, cke:1}}]},"                 &
		"ddr3:{"                                                   &
			"seq:["                                                &
				"{nop, PreRST,  {cs:1, cke:0, rst:0}},"            &
				"{nop, PstRST,  {cs:1, cke:0, rst:1}},"            &
				"{nop, XPR,     {cs:0, cke:1, rst:1}},"            &
				"{mrs, MRD,     {cs:0, cke:1, rst:1, a:mr2}},"     &
				"{mrs, MRD,     {cs:0, cke:1, rst:1, a:mr3}},"     &
				"{mrs, MRD,     {cs:0, cke:1, rst:1, a:dll_dis}}," &
				"{mrs, MRD,     {cs:0, cke:1, rst:1, a:mr0}},"     &
				"{zqc, ZQINIT,  {cs:0, cke:1, rst:1}},"            &
				"{mrs, MODu,    {cs:0, cke:1, rst:1, a:wl_on}},"   &
				"{nop, WLDQSEN, {cs:0, cke:1, rst:1}},"            &
				"{mrs, MODu,    {cs:0, cke:1, rst:1, a:wl_off}},"  &
				"{nop, cDLL,    {cs:0, cke:1, rst:1}},"            &
				"{nop, REFi,    {cs:0, cke:1, rst:1}}]}}";

	constant init_data       : string  := hdo(sdr_init_data)**('.'&generation&"={}");
	constant init_seq        : string  := hdo(init_data)**".seq=[]";
	constant init_seq_length : natural := length(init_seq);

	signal timer_sel  : std_logic_vector(unsigned_num_bits(init_seq_length-1)-1 downto 0) := (others => '0');

begin

	seq_b : block
		constant wrl      : natural          := natural(ceil(real'(hdo(sdramtmng_data)**".tWR")/ctlr_tcp))*gear;
		constant init_wr  : std_logic_vector := hdo(generation_data)**(".wrl['"&natural'image(wrl)&"']='000'");

		type ba_record is record
			b : std_logic_vector(sdram_init_b'range);
			a : std_logic_vector(sdram_init_a'range);
		end record;

		impure function sdr_mr (
			constant row : in string)
			return ba_record is
			constant mr  : string := "{mr0 :'00'}";
			constant op  : string := hdo(row)**0;
			constant reg : string := hdo(hdo(row)**2)**".a";
			variable b   : std_logic_vector(sdram_init_b'range);
			variable a   : std_logic_vector(sdram_init_a'range);
		begin
			b := (others => '-');
			a := (others => '-');
			if op ="pre" then
				a(10) := '1';
			elsif reg'length > 0  then
				if reg="mr0" then 
					b := hdo(mr)**".mr0";
					a := (others => '0');
					a(2 downto 0) := sdram_init_bl(3-1 downto 0);
					a(3)          := sdram_init_bt;
					a(6 downto 4) := sdram_init_cl(3-1 downto 0);
					a(8 downto 7) := "00";
					a(9)          := '0';
				else
					assert false
						report "sdr_mr () : row => " & row & " invalid register"
						severity failure;
				end if;
			end if;
			return (b, a);
		end;

		impure function ddr_mr(
			constant row : in string)
			return ba_record is
			constant mr  : string := "{mr0 :'000', mr1:'001'}";
			constant op  : string := hdo(row)**0;
			constant reg : string := hdo(hdo(row)**2)**".a";
			variable b : std_logic_vector(sdram_init_b'range);
			variable a : std_logic_vector(sdram_init_a'range);
		begin
			b := (others => '-');
			a := (others => '-');
			if op ="pre" then
				a(10) := '1';
			elsif reg'length > 0  then
				if reg="rst_dll" then
					b := hdo(mr)**".mr0";
					a := (others => '0');
					a(2 downto 0) := sdram_init_bl(3-1 downto 0);
					a(3)          := sdram_init_bt;
					a(6 downto 4) := sdram_init_cl(3-1 downto 0);
					a(8)          := '1';
				elsif reg="mr0" then
					b := hdo(mr)**".mr0";
					a := (others => '0');
					a(2 downto 0) := sdram_init_bl(3-1 downto 0);
					a(3)          := sdram_init_bt;
					a(6 downto 4) := sdram_init_cl(3-1 downto 0);
					a(8)          := '0';
				elsif reg="mr1" then
					b := hdo(mr)**".mr1";
					a := (others =>'0');
				else
					assert false
						report "ddr_mr () : row => " & row & " invalid register"
						severity failure;
				end if;
			end if;
			return (b, a);
		end;

		impure function ddr2_mr(
			constant row : in string)
			return ba_record is
			constant mr  : string := "{mr0 :'000', mr1:'001', mr2:'010', mr3:'011'}";
			constant op  : string := hdo(row)**0;
			constant reg : string := hdo(hdo(row)**2)**".a";
			variable b : std_logic_vector(sdram_init_b'range);
			variable a : std_logic_vector(sdram_init_a'range);
		begin
			b := (others => '-');
			a := (others => '-');
			if op ="pre" then
				a(10) := '1';
			elsif reg'length > 0  then
				report reg;
				if reg="ena_dll" then
					b := hdo(mr)**".mr1";
					a := (others => '0');
				elsif reg="rst_dll" then
					b := hdo(mr)**".mr0";
					a := (others => '0');
					a(8) := '1';
				elsif reg="ena_ocd" then
					b := hdo(mr)**".mr1";
					a := (others => '0');
					a(0)  := '0';
					a(1)  := sdram_init_ods(0);
					a(2)  := sdram_init_rtt(0);
					a(5 downto 3) := sdram_init_al(3-1 downto 0);
					a(6)  := sdram_init_rtt(1);
					a(9 downto 7) := "111";
					a(10) := sdram_init_tdqs(0);
					a(11) := sdram_init_rdqs(0);
					a(12) := '0';
				elsif reg="mr0" then
					b := hdo(mr)**".mr0";
					a := (others => '0');
					a( 2 downto 0) := sdram_init_bl(3-1 downto 0);
					a(3)  := sdram_init_bt;
					a( 6 downto 4) := sdram_init_cl(3-1 downto 0);
					a(7)  := '0';
					a(8)  := '0';
					a(11 downto 9) := init_wr;
					a(12) := sdram_init_pd(0);
				elsif reg="mr1" then
					b := hdo(mr)**".mr1";
					a := (others => '0');
					a(0)  := '0';
					a(1)  := sdram_init_ods(0);
					a(2)  := sdram_init_rtt(0);
					a(5 downto 3) := sdram_init_al(3-1 downto 0);
					a(6)  := sdram_init_rtt(1);
					a(9 downto 7) := "000";
					a(10) := sdram_init_tdqs(0);
					a(11) := sdram_init_rdqs(0);
					a(12) := '0';
				elsif reg="mr2" then
					b := hdo(mr)**".mr2";
					a := (others => '0');
					a(7) := '1';
				elsif reg="mr3" then
					b := hdo(mr)**".mr3";
					a := (others => '0');
				else
					assert false
						report "ddr2_mr () : row => " & row & " invalid register"
						severity failure;
				end if;
			end if;
			return (b,a);
		end;

		impure function ddr3_mr(
			constant row : in string)
			return ba_record is
			constant mr  : string := "{mr0 :'000', mr1:'001', mr2:'010', mr3:'011'}";
			constant op  : string := hdo(row)**0;
			constant reg : string := hdo(hdo(row)**2)**".a";
			variable b : std_logic_vector(sdram_init_b'range);
			variable a : std_logic_vector(sdram_init_a'range);
		begin
			b := (others => '-');
			a := (others => '-');
			if op ="pre" then
				a(10) := '1';
			elsif op ="zqc" then
				a(10) := '1';
			elsif reg'length > 0  then
				if reg="mr0" then
					b := hdo(mr)**".mr0";
					a := (others => '0');
					a(1 downto 0)  := sdram_init_bl(2-1 downto 0);
					a(2)  := sdram_init_cl(0);
					a(3)  := sdram_init_bt;
					a(6 downto 4)  := sdram_init_cl(4-1 downto 1);
					a(7)  := '0';
					a(8)  := '1'; -- DLL reset
					a(11 downto 9) := init_wr;
					a(12) := sdram_init_pd(0);
				elsif reg="dll_dis" then
					b := hdo(mr)**".mr1";
					a := (others => '0');
					a(0)  := '1';
					a(1)  := sdram_init_ods(0);
					a(2)  := sdram_init_rtt(0);
					a(4 downto 3) := sdram_init_al(2-1 downto 0);
					a(5)  := sdram_init_ods(1);
					a(6)  := sdram_init_rtt(1);
					a(7)  := '0';
					a(8)  := '0';
					a(9)  := sdram_init_rtt(2);
					a(10) := '0';
					a(11) := sdram_init_tdqs(0);
					a(12) := sdram_init_rdqs(0);
				elsif reg="wl_on" then
					b := hdo(mr)**".mr1";
					a := (others => '0');
					a(0)  := '0';
					a(1)  := sdram_init_ods(0);
					a(2)  := sdram_init_rtt(0);
					a(4 downto 3) := sdram_init_al(2-1 downto 0);
					a(5)  := sdram_init_ods(1);
					a(6)  := sdram_init_rtt(1);
					a(7)  := '1';
					a(8)  := '0';
					a(9)  := sdram_init_rtt(2);
					a(10) := '0';
					a(11) := sdram_init_tdqs(0);
					a(12) := sdram_init_rdqs(0);
				elsif reg="wl_off" then
					b := hdo(mr)**".mr1";
					a := (others => '0');
					a(0)  := '0';
					a(1)  := sdram_init_ods(0);
					a(2)  := sdram_init_rtt(0);
					a(4 downto 3) := sdram_init_al(2-1 downto 0);
					a(5)  := sdram_init_ods(1);
					a(6)  := sdram_init_rtt(1);
					a(7)  := '0';
					a(8)  := '0';
					a(9)  := sdram_init_rtt(2);
					a(10) := '0';
					a(11) := sdram_init_tdqs(0);
					a(12) := sdram_init_rdqs(0);
				elsif reg="mr2" then
					b := hdo(mr)**".mr2";
					a := (others => '0');
					a(2 downto 0) := "000";
					a(5 downto 3) := sdram_init_cwl;
					a(6) := sdram_init_asr(0);
					a(7) := '0'; -- self refresh temperature
					a(8) := '0';
					a(10 downto 9) := sdram_init_drtt;
				elsif reg="mr3" then
					b := hdo(mr)**".mr3";
					a := (others => '0');
					a(1 downto 0) := sdram_init_mprrf;
					a(2) := sdram_init_mpr(0);
				else
					assert false
						report "ddr3_mr () : row => " & '"' & row & '"' & " invalid register"
						severity failure;
				end if;
			end if;
			return (b, a);
		end;

	begin

		process (sdram_init_clk)
			variable step : natural range 0 to init_seq_length-1;
			type states is (s_init, s_run);
			variable state : states;
			variable sdram_init_ba : ba_record;
		begin
			if rising_edge(sdram_init_clk) then
				if (timer_req xor timer_rdy)='0' then
					if (sdram_init_rdy xor sdram_init_req)='1' then
						case state is
						when s_init =>
							step  := 0;
							state := s_run;
						when s_run =>
							if step < init_seq_length-1 then
								step := step + 1;
							else
								sdram_init_rdy <= sdram_init_req;
							end if;
						end case;
					else
						if (sdram_refi_req xor sdram_refi_rdy)='0' then
							sdram_refi_req <= not to_stdulogic(to_bit(sdram_refi_rdy));
						end if;
						state := s_init;
					end if;
					for i in 0 to init_seq_length-1 loop -- Latticesemi Diamond work around
						if i=step then
							sdram_init_cmd <= hdo(cmd)**('.'&hdo(init_seq**i)**0);
							sdram_init_rst <= hdo(hdo(init_seq**i)**2)**".rst='-'";
							sdram_init_cs  <= hdo(hdo(init_seq**i)**2)**".cs";
							sdram_init_cke <= hdo(hdo(init_seq**i)**2)**".cke";
							sdram_init_odt <= hdo(hdo(init_seq**i)**2)**".odt='0'";
							if generation="sdr" then
								(sdram_init_b, sdram_init_a)  <= sdr_mr(init_seq**i);
							elsif generation="ddr" then
								(sdram_init_b, sdram_init_a)  <= ddr_mr(init_seq**i);
							elsif generation="ddr2" then
								(sdram_init_b, sdram_init_a)  <= ddr2_mr(init_seq**i);
							elsif generation="ddr3" then
								(sdram_init_b, sdram_init_a)  <= ddr3_mr(init_seq**i);
							else
								assert false
									report "sdram_init : generation => " & '"' & generation & '"' & " invalid"
									severity failure;
							end if;
							timer_sel <= std_logic_vector(to_unsigned(i, timer_sel'length));
							exit;
						end if;
					end loop;
					timer_req <= not timer_rdy;
				else
					sdram_init_cmd <= hdo(cmd)**".nop";
				end if;
			end if;
		end process;


	end block;

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
		constant XPR     : natural := hdo(gentmng_data)**".XPR=1";
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
			for i in init_seq'range loop
				assert n < timers'length
					report "get_timers () : n => " & natural'image(n) & " greater than timers length " & natural'image(timers'length)
					severity failure;
				assert not debug
					report  "get_timers () : timer id => " & string'((hdo(init_seq)**('['&natural'image(n)&"]=[]"))**"[1]=none")
					severity note;
				timers(n) := hdo(sdram_timers)**('.' & string'((hdo(init_seq)**('['&natural'image(n)&"]=[]"))**"[1]=none"));
				exit when timers(n)=0;
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
