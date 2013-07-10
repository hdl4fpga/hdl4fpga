library ieee;
use ieee.std_logic_1164.all;

entity ddrdcm is
	generic (
		sys_per : real;
		dfs_div : natural;
		dfs_mul : natural);
	port ( 
		sys_rst : in std_logic; 
		sys_clk : in std_logic; 
		ddrdcm_clk0  : out std_logic; 
		ddrdcm_clk90 : out std_logic; 
		ddrdcm_lckd : out std_logic);
end;

library unisim;
use unisim.vcomponents.all;

architecture def of ddrdcm is
	signal clkfb : std_logic;
	signal clk0  : std_logic;
	signal clk90 : std_logic;
begin

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
		rst   => sys_rst,
		clkin => sys_clk,
		clkfb => clkfb,
		daddr => (others => '0'),
		dclk  => '0',
		den   => '0',
		di    => (others => '0'),
		dwe   => '0',
		psclk => '0',
		psen  => '0',
		psincdec => '0',
		clk0  => clk0,
		clk90 => clk90,
		locked => ddrdcm_lck);
   
	plldcmclk90_bufg_i : bufg
	port map (
		i => clk90,
		o => ddrdcm_clk90);

	ddrdcm_clk0 <= clkfb;
end;
