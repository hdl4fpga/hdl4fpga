library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;

entity dcms is
	generic (
		ddr_mul : natural := 10;
		ddr_div : natural := 3;
		sys_per : real := 10.0);
	port (
		sys_rst  : in  std_logic;
		sys_clk  : in  std_logic;
		input_clk  : out std_logic;

		ddr_eclkph : in std_logic_vector(3 downto 0);
		ddr_sclk2x : out std_logic;
		ddr_eclk : out std_logic;
		ddr_sclk : out std_logic;

		video_clk0  : out std_logic;
		video_clk90 : out std_logic;

		dcms_lckd  : out std_logic);
end;

library ecp3;
use ecp3.components.all;

architecture ecp3 of dcms is

	---------------------------------------
	-- Frequency   -- 166 Mhz -- 450 Mhz --
	-- Multiply by --   5     --   9     --
	-- Divide by   --   3     --   2     --
	---------------------------------------

	signal dcm_rst : std_logic;

	signal ddr_lckd : std_logic := '1';
	signal video_lckd : std_logic := '1';

begin

	input_clk <= sys_clk;

	process (sys_rst, sys_clk)
	begin
		if sys_rst='1' then
			dcm_rst  <= '1';
			dcms_lckd <= '0';
		elsif rising_edge(sys_clk) then
			if dcm_rst='0' then
				dcms_lckd <= ddr_lckd;-- and video_lckd;
			end if;
			dcm_rst <= '0';
		end if;
	end process;

	video_b : block
		port (
			sys_rst  : in  std_logic;
			sys_clk  : in  std_logic;
			video_clk0 : out std_logic;
			video_clk90 : out std_logic;
			video_lckd : out std_logic);
		port map (
			sys_rst => sys_rst,
			sys_clk => sys_clk,
			video_clk0 =>  video_clk0,
			video_clk90 => video_clk90,
			video_lckd => video_lckd);
			
		attribute frequency_pin_clkop : string; 
		attribute frequency_pin_clkos : string; 
		attribute frequency_pin_clki  : string; 
		attribute frequency_pin_clkok : string; 
		attribute frequency_pin_clkop of pll_i : label is "125.000000";
		attribute frequency_pin_clkos of pll_i : label is "125.000000";
		attribute frequency_pin_clki  of pll_i : label is "100.000000";

		signal pll_clkos : std_logic;
		signal pll_clkfb : std_logic;
		signal eclk_stop : std_logic;
		signal eclk : std_logic;
		signal sclk : std_logic;
		signal rst  : std_logic;
	begin
		pll_i : ehxpllf
		generic map (
			feedbk_path => "INTERNAL",
			clkos_trim_delay => 0, clkos_trim_pol => "RISING", 
			clkop_trim_delay => 0, clkop_trim_pol => "RISING", 
			delay_pwd => "DISABLED",
			delay_val => 0, 
			duty => 8,
			phase_delay_cntl => "STATIC",
			phaseadj => "90.0", 
			clkok_div => 2,
			clkop_div => 8,
			clkfb_div => 5,
			clki_div  => 4,
			fin => "100.000000")
		port map (
			rst   => '0', 
			rstk  => '0',
			clki  => sys_clk,
			wrdel => '0',
			drpai3 => '0', drpai2 => '0', drpai1 => '0', drpai0 => '0', 
			dfpai3 => '0', dfpai2 => '0', dfpai1 => '0', dfpai0 => '0', 
			fda3   => '0', fda2   => '0', fda1   => '0', fda0   => '0', 
			clkintfb => pll_clkfb,
			clkfb => pll_clkfb,
			clkop => video_clk0, 
			clkos => video_clk90,
			clkok => open,
			clkok2 => open,

			lock  => video_lckd);
	end block;

	ddr3_b : block
		port (
			sys_rst  : in  std_logic;
			sys_clk  : in  std_logic;
			ddr_sclk : out std_logic;
			ddr_eclk : out std_logic;
			ddr_sclk2x : out std_logic;
			ddr_lckd : out std_logic);
		port map (
			sys_rst => sys_rst,
			sys_clk => sys_clk,
			ddr_sclk => ddr_sclk,
			ddr_sclk2x => ddr_sclk2x,
			ddr_eclk => ddr_eclk,
			ddr_lckd => ddr_lckd);
			
		attribute frequency_pin_clkop : string; 
		attribute frequency_pin_clkos : string; 
		attribute frequency_pin_clki  : string; 
		attribute frequency_pin_clkok : string; 
		attribute frequency_pin_clkop of pll_i : label is "400.000000";
		attribute frequency_pin_clkos of pll_i : label is "400.000000";
		attribute frequency_pin_clki  of pll_i : label is "100.000000";
		attribute frequency_pin_clkok of pll_i : label is "200.000000";

		signal pll_clkfb : std_logic;
		signal pll_lck   : std_logic;
		signal eclk_stop : std_logic;
		signal oclk : std_logic;
		signal eclk : std_logic;
		signal sclk : std_logic;
		signal drpa : std_logic_vector(3 downto 0);
		signal dfpa : std_logic_vector(3 downto 0);
	begin
		drpa <= ddr_eclkph;
		dfpa <= not ddr_eclkph(3) & ddr_eclkph(2 downto 0);
		pll_i : ehxpllf
		generic map (
			CLKOS_TRIM_DELAY => 0,
			CLKOS_TRIM_POL => "RISING", 
			CLKOS_BYPASS => "DISABLED", 
			CLKOP_TRIM_DELAY => 0,
			CLKOP_TRIM_POL => "RISING", 
			CLKOP_BYPASS => "DISABLED", 
			CLKOK_INPUT => "CLKOP",
			CLKOK_BYPASS => "DISABLED", 
			DELAY_PWD => "DISABLED",
			DELAY_VAL => 0, 
			DUTY => 8,
			PHASE_DELAY_CNTL => "DYNAMIC",
			PHASEADJ => "0.0", 
			CLKOK_DIV => 2,
			CLKOP_DIV => 2,
			CLKFB_DIV => 4,
			CLKI_DIV  => 1,
			FEEDBK_PATH => "INTERNAL",
			FIN => "100.000000")
		port map (
			rst   => '0', 
			rstk  => '0',
			clki  => sys_clk,
			drpai3 => drpa(3), drpai2 => drpa(2), drpai1 => drpa(1), drpai0 => drpa(0), 
			dfpai3 => dfpa(3), dfpai2 => dfpa(2), dfpai1 => dfpa(1), dfpai0 => dfpa(0), 
			fda3   => '0', fda2   => '0', fda1   => '0', fda0   => '0', 
			wrdel => '0',
			clkintfb => pll_clkfb,
			clkfb => pll_clkfb,
			clkop => ddr_sclk2x, 
			clkos => eclk,
			clkok => sclk,
			clkok2 => open,

			lock  => pll_lck);

		ddr_lckd <= pll_lck;
		ddr_sclk <= sclk;
		ddr_eclk <= eclk;
	end block;

end;
