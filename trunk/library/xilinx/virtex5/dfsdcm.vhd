library ieee;
use ieee.std_logic_1164.all;

entity dfsdcm is
	generic (
		dcm_per : real;
		dfs_div : natural;
		dfs_mul : natural);
	port ( 
		dfsdcm_rst : in std_logic; 
		dfsdcm_clkin : in std_logic; 
		dfsdcm_clk0  : out std_logic; 
		dfsdcm_clk90 : out std_logic; 
		dfsdcm_lckd : out std_logic);
end;

library unisim;
use unisim.vcomponents.all;

architecture def of dfsdcm is
	signal dfs_clkfb  : std_logic;
	signal dfs_lckd  : std_logic;

	signal dcm_rst : std_logic;
	signal dcm_clkin : std_logic;
	signal dcm_clkfb : std_logic;
	signal dcm_clk0  : std_logic;
	signal dcm_clk90 : std_logic;
begin

	dfs_i : dcm_adv
	generic map (
		clk_feedback => "1X",
		clkdv_divide => 2.0,
		clkfx_divide => dfs_div,
		clkfx_multiply => dfs_mul,
		clkin_period => dcm_per,
		clkin_divide_by_2 => FALSE,
		clkout_phase_shift => "NONE",
		deskew_adjust => "SYSTEM_SYNCHRONOUS",
		dfs_frequency_mode => "HIGH",
		dll_frequency_mode => "LOW",
		duty_cycle_correction => TRUE,
		factory_jf   => X"C080",
		phase_shift  => 0,
		startup_wait => FALSE)
	port map (
		rst   => dfsdcm_rst,
		psclk => '0',
		psen  => '0',
		psincdec => '0',
		clkfb => dfs_clkfb,
		clkin => dfsdcm_clkin,
		clk0  => dfs_clkfb,
		clkfx => dcm_clkin,
		locked => dfs_lckd);
   
	process (dfsdcm_rst, dfsdcm_clkin)
		variable srl16 : std_logic_vector(0 to 16-1);
	begin
		if dfsdcm_rst='1' then
			dcm_rst <= '1';
		elsif rising_edge(dfsdcm_clkin) then
			srl16 := srl16(1 to srl16'right) & not dfs_lckd;
			dcm_rst <= srl16(0) or not dfs_lckd;
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
		clkin_period => (real(dfs_div)*dcm_per)/real(dfs_mul),
		clkdv_divide => 2.0,
		clkfx_divide => 1,
		clkfx_multiply => 4,
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
		locked => dfsdcm_lckd);
   
	dfsdcmclk90_bufg_i : bufg
	port map (
		i => dcm_clk90,
		o => dfsdcm_clk90);

	dfsdcm_clk0 <= dcm_clkfb;
end;
