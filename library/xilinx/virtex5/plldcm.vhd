library ieee;
use ieee.std_logic_1164.all;

entity plldcm is
	generic (
		pll_per : real;
		dfs_div : natural;
		dfs_mul : natural);
	port ( 
		plldcm_rst : in std_logic; 
		plldcm_clk : in std_logic; 
		plldcm_clk0  : out std_logic; 
		plldcm_clk90 : out std_logic; 
		plldcm_lck : out std_logic);
end;

library unisim;
use unisim.vcomponents.all;

architecture def of plldcm is
	signal pll_clk : std_logic;
	signal pll_clkfb  : std_logic;
	signal pll_lckd  : std_logic;

	signal dcm_rst : std_logic;
	signal dcm_clkin : std_logic;
	signal dcm_clkfb : std_logic;
	signal dcm_clk0  : std_logic;
	signal dcm_clk90 : std_logic;
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

	clk0_bufg_i : bufg
	port map (
		i => dcm_clk0,
		o => dcm_clkfb);
   
	dcm_i : dcm_adv
	generic map (
		clk_feedback => "1x",
		clkin_divide_by_2 => FALSE,
		clkin_period => pll_per,
		clkdv_divide => 2.0,
		clkfx_divide => dfs_div,
		clkfx_multiply => dfs_mul,
		clkout_phase_shift   => "NONE",
		dcm_autocalibration  => TRUE,
		dcm_performance_mode => "MAX_SPEED",
		deskew_adjust => "SYSTEM_SYNCHRONOUS",
		dfs_frequency_mode => "LOW",
		dll_frequency_mode => "HIGH",
		duty_cycle_correction => TRUE,
		factory_jf   => X"F0F0",
		phase_shift  => 0,
		startup_wait => FALSE,
		sim_device   => "VIRTEX5")
	port map (
		rst   => dcm_rst,
		clkin => dcm_clkin,
		clkfb => dcm_clkfb,
		daddr => (others => '0'),
		dclk  => '0',
		den   => '0',
		di    => (others => '0'),
		dwe   => '0',
		psclk => '0',
		psen  => '0',
		psincdec => '0',
		clk0  => dcm_clk0,
		clk90 => dcm_clk90,
		locked => plldcm_lck);
   
	plldcmclk90_bufg_i : bufg
	port map (
		i => dcm_clk90,
		o => plldcm_clk90);

	plldcm_clk0 <= dcm_clkfb;
end;
