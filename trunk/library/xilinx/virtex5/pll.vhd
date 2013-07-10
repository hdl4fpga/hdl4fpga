library ieee;
use ieee.std_logic_1164.all;

entity pll is
	generic (
		pll_per : real);
	port ( 
		pll_rst : in std_logic; 
		pll_clkin : in std_logic; 
		pll_clk  : out std_logic; 
		pll_lckd : out std_logic);
end;

library unisim;
use unisim.vcomponents.all;

architecture def of pll is
	signal pll_clk : std_logic;
	signal pll_clkfb  : std_logic;
	signal pll_lckd  : std_logic;

begin

   pll_i : pll_adv
   generic map(
		bandwidth => "OPTIMIZED",
		clkin1_period  => pll_per,
		clkin2_period  => pll_per,
		clkout0_divide => 1,
		clkout0_phase  => 0.000,
		clkout0_duty_cycle => 0.500,
		compensation   => "PLL2DCM",
		divclk_divide  => 2,
		clkfbout_mult  => 11,
		clkfbout_phase => 0.0,
		ref_jitter => 0.005000)
	port map (
		rst => plldcm_rst,
		den => '0',
		di  => (others => '0'),
		dwe => '0',
		rel => '0',
		dclk  => '0',
		daddr => (others => '0'),
		clkinsel => '1',
		clkin1   => plldcm_clk,
		clkin2   => '0',
		clkfbin  => pll_clkfb,
		clkfbdcm => pll_clkfb,
		clkoutdcm0 => dcm_clkin,
		locked   => pll_lckd);
   
	process (plldcm_rst, pll_clk)
		variable srl16 : std_logic_vector(0 to 16-1);
	begin
		if plldcm_rst='1' then
			dcm_rst <= '1';
		elsif rising_edge(pll_clk) then
			srl16 := srl16(1 to srl16'right) & not pll_lckd;
			dcm_rst <= srl16(0) or not pll_lckd;
		end if;
	end process;

	pll_clk <= pll_clkfb;
end;
