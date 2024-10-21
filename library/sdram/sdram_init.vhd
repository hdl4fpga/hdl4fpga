--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                         --
--    Miguel Angel Sagreras                                                   --
--                                                                            --
-- This source file may be used and distributed without restriction provided  --
-- that this copyright statement is not removed from the file and that any    --
-- derivative work contains  the original copyright notice and the associated --
-- disclaimer.                                                                --
--                                                                            --
-- This source file is free software; you can redistribute it and/or modify   --
-- it under the terms of the GNU General Public License as published by the   --
-- Free Software Foundation, either version 3 of the License, or (at your     --
-- option) any later version.                                                 --
--                                                                            --
-- This source is distributed in the hope that it will be useful, but WITHOUT --
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      --
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   --
-- more details at http://www.gnu.org/licenses/.                              --
--                                                                            --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.hdo.all;
use hdl4fpga.sdram_db.all;

entity sdram_init is
	generic (
		debug : boolean;
		tcp   : real;
		chiptmmg_data : string;
		fmly  : string;
		fmlytmng_data : string);
	port (
		sdram_init_bl   : in  std_logic_vector;
		sdram_init_bt   : in  std_logic_vector;
		sdram_init_cl   : in  std_logic_vector;
		sdram_init_ods  : in  std_logic_vector;

		sdram_init_wb   : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdram_init_al   : in  std_logic_vector(3-1 downto 0) := (others => '0');
		sdram_init_asr  : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdram_init_cwl  : in  std_logic_vector(3-1 downto 0) := (others => '0');
		sdram_init_drtt : in  std_logic_vector(2-1 downto 0) := (others => '0');
		sdram_init_edll : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdram_init_mpr  : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdram_init_mprrf : in std_logic_vector(2-1 downto 0) := (others => '0');
		sdram_init_qoff : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdram_init_rtt  : in  std_logic_vector;
		sdram_init_srt  : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdram_init_tdqs : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdram_init_wl   : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdram_init_wr   : in  std_logic_vector(3-1 downto 0) := (others => '0');
		sdram_init_ddqs : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdram_init_rdqs : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdram_init_ocd  : in  std_logic_vector(3-1 downto 0) := (others => '1');
		sdram_init_pd   : in  std_logic_vector(1-1 downto 0) := (others => '0');

		sdram_refi_rdy : in  std_logic;
		sdram_refi_req : out std_logic;
		sdram_init_clk : in  std_logic;
		sdram_init_wlrdy : in  std_logic;
		sdram_init_wlreq : out std_logic;
		sdram_init_req : in  std_logic;
		sdram_init_rdy : buffer std_logic;
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

	constant PreRST    : natural := natural(ceil(hdo(fmlytmng_data)**".tPreRST=0."/tcp));
	constant RP        : natural := natural(ceil(hdo(chiptmmg_data)**".tRP=0."/tcp));
	constant PstRST    : natural := natural(ceil(hdo(fmlytmng_data)**".tPstRST=0."/tcp));
	constant cDLL      : natural := hdo(fmlytmng_data)**".cDLL=0.";
	constant RPA       : natural := natural(ceil(hdo(fmlytmng_data)**".tRPA=0."/tcp));
	constant ZQINIT    : natural := hdo(fmlytmng_data)**".ZQINIT=0.";
	constant MRD       : natural := hdo(fmlytmng_data)**".MRD=0.";
	constant MODu      : natural := hdo(fmlytmng_data)**".MODu=0.";
	constant XPR       : natural := hdo(fmlytmng_data)**".XPR=0.";
	constant WLDQSEN   : natural := hdo(fmlytmng_data)**".WLDQSEN=0.";
	constant REFi      : natural := natural(ceil(hdo(chiptmmg_data)**".tREFI"/tcp));
	constant RFC       : natural := natural(ceil(hdo(chiptmmg_data)**".tRFC"/tcp));

end;

architecture def of sdram_init is

	constant PreRST_id  : std_logic_vector := x"0"; -- "0000";
	constant XPR_id     : std_logic_vector := x"1"; -- "0001";
	constant RFC_id     : std_logic_vector := x"2"; -- "0010";
	constant MRD_id     : std_logic_vector := x"3"; -- "0011";
	constant REFi_id    : std_logic_vector := x"4"; -- "0100";
	constant RP_id      : std_logic_vector := x"5"; -- "0101";
	constant RPA_id     : std_logic_vector := x"6"; -- "0110";
	constant DLL_id     : std_logic_vector := x"7"; -- "0111";
	constant PstRST_id  : std_logic_vector := x"8"; -- "1000";
	constant ZQINIT_id  : std_logic_vector := x"9"; -- "1001";
	constant MODu_id    : std_logic_vector := x"a"; -- "1010";
	constant WLDQSEN_id : std_logic_vector := x"b"; -- "1011";

	signal timer_rdy : std_logic;
	signal timer_req : std_logic;

	signal input     : std_logic_vector(0 to 0);

	signal timer_sel : std_logic_vector(0 to  4-1);
begin

	input(0) <= sdram_init_wlrdy;

	-----------------
	-- DDR PROGRAM --
	-----------------

	init_b : block
		constant mr0 : std_logic_vector := "000";
		constant mr1 : std_logic_vector := "001";
		constant mr2 : std_logic_vector := "010";
		constant mr3 : std_logic_vector := "011";
		constant mrx : std_logic_vector := "---";

		constant nop : std_logic_vector := "111";
		constant mrs : std_logic_vector := "000";
		constant pre : std_logic_vector := "010";
		constant ref : std_logic_vector := "001";
		constant zqc : std_logic_vector := "110";


			--     +------< rst
			--     |+-----< cke
			--     ||+----< rdy
			--     |||+---< wlq
			--     ||||+--< odt
			--     |||||
			--     vvvvv
		constant sdram_init_data : std_logic_vector := 
		--	1     3     6         1     3
			nop & mrx & "11000" & "0" & XPR_id  &
			pre & mrx & "11000" & "0" & RP_id   &
			ref & mrx & "11000" & "0" & RFC_id  &
			ref & mrx & "11000" & "0" & RFC_id  &
			mrs & mr0 & "11001" & "0" & MRD_id  &
			nop & mrx & "11110" & "0" & REFi_id &
			nop & mrx & "11110" & "0" & REFi_id;
	
		constant ddr_init_data : std_logic_vector := 
			nop & mrx & "11000" & "0" & XPR_id  &
			pre & mrx & "11000" & "0" & RP_id   &
			mrs & mr1 & "11000" & "0" & MRD_id  &
			mrs & mr0 & "11000" & "0" & MRD_id  &
			pre & mrx & "11000" & "0" & RPA_id  &
			ref & mrx & "11000" & "0" & RFC_id  &
			ref & mrx & "11000" & "0" & RFC_id  &
			mrs & mr0 & "11001" & "0" & MRD_id  &
			nop & mrx & "11010" & "0" & DLL_id  &
			nop & mrx & "11110" & "0" & REFi_id &
			nop & mrx & "11110" & "0" & REFi_id;
	
		constant ddr2_init_data : std_logic_vector := 
			nop & mrx & "11000" & "0" & XPR_id  &
			pre & mrx & "11000" & "0" & RPA_id  &
			mrs & mr2 & "11000" & "0" & MRD_id  &
			mrs & mr3 & "11000" & "0" & MRD_id  &
			mrs & mr1 & "11000" & "0" & MRD_id  &
			mrs & mr0 & "11000" & "0" & MRD_id  &
			pre & mrx & "11000" & "0" & RPA_id  &
			ref & mrx & "11000" & "0" & RFC_id  &
			ref & mrx & "11000" & "0" & RFC_id  &
			mrs & mr0 & "11000" & "0" & MRD_id  &
			mrs & mr1 & "11000" & "0" & MRD_id  &
			mrs & mr1 & "11000" & "0" & MRD_id  &
			nop & mrx & "11000" & "0" & DLL_id  &
			nop & mrx & "11111" & "0" & REFi_id &
			nop & mrx & "11100" & "0" & REFi_id;
	
		constant ddr3_init_data : std_logic_vector := 
			nop & mrx & "10000" & "0" & PstRST_id  &
			nop & mrx & "11000" & "0" & XPR_id     &
			mrs & mr2 & "11000" & "0" & MRD_id     &
			mrs & mr3 & "11000" & "0" & MRD_id     &
			mrs & mr1 & "11000" & "0" & MRD_id     &
			mrs & mr0 & "11000" & "0" & MRD_id     &
			zqc & mrx & "11000" & "0" & ZQINIT_id  &
			mrs & mr1 & "11000" & "0" & MODu_id    &
			nop & mrx & "11001" & "0" & WLDQSEN_id &
			nop & mrx & "11011" & "0" & MODu_id    &
			nop & mrx & "11011" & "1" & MODu_id    &
			nop & mrx & "11010" & "1" & MRD_id     &
			mrs & mr1 & "11010" & "0" & MODu_id    &
			nop & mrx & "11110" & "0" & DLL_id     &
			nop & mrx & "11110" & "0" & REFi_id    &
			nop & mrx & "11110" & "0" & REFi_id;
	begin

		process(sdram_init_clk)
			variable cntr : natural range 0 to 2**4-1;
			variable line : unsigned(0 to nop'length+mrx'length+6+1+4-1);
			variable mask : std_logic;
			variable mr_data : std_logic_vector(sdram_init_a'range);
			variable dll : std_logic;
			variable dll_ena : std_logic;
			variable mr : std_logic_vector(0 to 1);
		begin
			-- sdram 
			-- resize(unsigned(sdram_init_cl(3-1 downto 0) "0" & sdram_init_bl(3-1 downto 0)), mr_data'length);
			-- ddr
			mr_data := multiplex (std_logic_vector(
				resize(unsigned(dll & "0" & sdram_init_cl(3-1 downto 0) & "0" & sdram_init_bl(3-1 downto 0)), mr_data'length) &
				resize(unsigned'(0 => dll_ena), mr_data'length)),
				mr,
				mr_data'length);
			-- ddr2
			mr_data := multiplex (std_logic_vector(
				resize(unsigned(sdram_init_wr & dll & "0" & sdram_init_cl(3-1 downto 0) & "0" & sdram_init_bl(3-1 downto 0)), mr_data'length) &
				resize(unsigned(sdram_init_rdqs & sdram_init_ddqs & sdram_init_ocd & sdram_init_rtt(1) & sdram_init_al & sdram_init_rtt(0) & sdram_init_ods(0) & dll_ena), mr_data'length) &
				resize(unsigned(sdram_init_srt & b"00_0000"), mr_data'length) &
				unsigned'(mr_data'range => '0')),
				mr,
				mr_data'length);
			-- ddr3
			mr_data := multiplex (std_logic_vector(
				resize(unsigned(sdram_init_pd   & sdram_init_wr   & dll & "0" & sdram_init_cl(4-1 downto 1) & "0" & sdram_init_cl(0) & sdram_init_bl(2-1 downto 0)), mr_data'length) &
				resize(unsigned(sdram_init_rdqs & sdram_init_tdqs & "0" & sdram_init_rtt(2) & "0" & sdram_init_wl & sdram_init_rtt(1) & sdram_init_ods(1) & sdram_init_al(2-1 downto 0) & sdram_init_rtt(0) & sdram_init_ods(0) & dll_ena), mr_data'length) &
				resize(unsigned(sdram_init_drtt & sdram_init_srt  & sdram_init_asr & sdram_init_cwl & b"000"), mr_data'length) &
				resize(unsigned(sdram_init_mpr  & sdram_init_mprrf), mr_data'length)),
				mr,
				mr_data'length);

				---- A10 Precharge all
			if rising_edge(sdram_init_clk) then
				if sdram_init_req='1' then
					cntr := 0;
				elsif sdram_init_rdy='0' then
					if timer_rdy='1' then
						cntr := cntr + 1;
					end if;
				end if;

				if fmly="sdr" then
					line := unsigned(multiplex(sdram_init_data, cntr, line'length));
				elsif fmly="ddr" then
					line := unsigned(multiplex(ddr_init_data,   cntr, line'length));
				elsif fmly="ddr2" then
					line := unsigned(multiplex(ddr2_init_data,  cntr, line'length));
				elsif fmly="ddr3" then
					line := unsigned(multiplex(ddr3_init_data,  cntr, line'length));
				else
					line := (others => '-');
				end if;

				if timer_rdy='0' then
					line(nop'range) := unsigned(nop);
				end if;
				(sdram_init_ras, sdram_init_cas, sdram_init_we) <= std_logic_vector(line(0 to 3-1));
				line := line sll 3;
				(sdram_init_rst, sdram_init_rdy, sdram_init_cke, sdram_init_wlreq, sdram_init_odt) <= std_logic_vector(line(0 to 5-1));
				line := line sll 5;
				sdram_init_b <= std_logic_vector(resize(line(mrx'range), sdram_init_b'length));
				line := line sll 3;
				mask := line(0);
				line := line sll 1;
				timer_sel <= std_logic_vector(line(0 to 4-1));
				line := line sll 3;

			end if;
		end process;
	end block;

	timer_req <=
		'1' when sdram_init_req='1' else
		'1' when timer_rdy='1' else
		'0';

	-----------------
	--- SDR_TIMERs --
	-----------------

	sdram_timer_b : block

		constant timers : natural_vector := (
			 0 => PreRST,
			 1 => XPR,
			 2 => RFC,
			 3 => MRD,
			 4 => REFi,
			 5 => RP,
			 6 => RPA,
			 7 => cDLL,
			 8 => PstRST,
			 9 => ZQINIT,
			10 => MODu,
			11 => WLDQSEN);

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

		signal value : std_logic_vector(timer_size-1 downto 0);

	begin

		assert false
		report 
			"timer_size is value " & natural'image(timer_size)
		severity note;

		assert false
		report 
			"stages      is value " & natural'image(stages)
		severity note;


		process (sdram_init_clk)
			variable timer : natural; 
			variable size  : natural;
			variable data  : std_logic_vector(value'range);
		begin
			if rising_edge(sdram_init_clk) then
				data  := (others => '-');
				timer := timers(to_integer(unsigned(timer_sel)));
				for j in stages-1 downto 0 loop
					size := slices(j+1)-slices(j);
					data := std_logic_vector(unsigned(data) sll size);
					data(size-1 downto 0) := std_logic_vector(to_unsigned(((2**size-1)+((timer-stages)/2**(slices(j)-j)) mod 2**(size-1)) mod 2**size, size));
				end loop;
				value <= data;
			end if;
		end process;
	
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
