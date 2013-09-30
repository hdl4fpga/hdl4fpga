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

		ddr_clk2 : out std_logic;
		ddr_clk0 : out std_logic;
		ddr_clk90 : out std_logic;

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
				dcms_lckd <= ddr_lckd and video_lckd;
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
			ddr_eclk90 : out std_logic;
			ddr_lckd : out std_logic);
		port map (
			sys_rst => sys_rst,
			sys_clk => sys_clk,
			ddr_sclk => ddr_clk2,
			ddr_eclk => ddr_clk0,
			ddr_eclk90 => ddr_clk90,
			ddr_lckd => ddr_lckd);
			
		attribute frequency_pin_clkop : string; 
		attribute frequency_pin_clkos : string; 
		attribute frequency_pin_clki  : string; 
		attribute frequency_pin_clkok : string; 
		attribute frequency_pin_clkop of pll_i : label is "400.000000";
		attribute frequency_pin_clkos of pll_i : label is "400.000000";
		attribute frequency_pin_clki  of pll_i : label is "100.000000";
		attribute frequency_pin_clkok of pll_i : label is "200.000000";

		signal pll_clkos : std_logic;
		signal pll_clkfb : std_logic;
		signal pll_lck   : std_logic;
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
			clkop_div => 2,
			clkfb_div => 4,
			clki_div  => 1,
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
			clkop => pll_clkos, 
			clkos => ddr_eclk90,
			clkok => open,
			clkok2 => open,

			lock  => pll_lck);

		rst <= sys_rst;
		process (rst, sclk)
			variable q : std_logic_vector(0 to 1);
		begin
			if rst='1' then
				q := (others => '0');
			elsif rising_edge(sclk) then
				q := q(1) & '1';
			end if;
			eclk_stop <= q(0);
		end process;

		eclksynca_i : eclksynca
		port map (
			stop  => eclk_stop,
			eclki => pll_clkos,
			eclko => eclk);

		clkdiv_i : clkdivb
		port map (
			release => eclk_stop,
			rst  => rst,
			clki => eclk,
			cdiv1 => open,
			cdiv2 => ddr_sclk,
			cdiv4 => open,
			cdiv8 => open);

	end block;

end;
