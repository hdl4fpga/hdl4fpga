library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

library unisim;
use unisim.vcomponents.ALL;

use work.std.all;

entity dfsdcm is
	generic (
		dcm_per : real;
		dfs_div : natural;
		dfs_mul : natural);
	port ( 
		dcm_rst : in std_logic; 
		dcm_clk : in std_logic; 
		dfsdcm_clk0  : out std_logic; 
		dfsdcm_clk90 : out std_logic; 
		dcm_lck : out std_logic);
end;

architecture mix of dfsdcm is
	signal dfs_clkfx : std_logic;
	signal dfs_locked : std_logic;
    signal dfs_clk0  : std_logic;
	signal dfs_clkfb : std_logic;

	signal dll_rst : std_logic;
	signal dll_clkin : std_logic;
	signal dll_clkfb : std_logic;
	signal dll_clk0  : std_logic;
	signal dll_clk90 : std_logic;
	signal dll_locked : std_logic;

	signal qq : std_logic;
begin

--	dfs_clkfb_bufg : bufg
--	port map (
--		i => dfs_clk0,
--		o => dfs_clkfb);

	dfs_clkfb <= dfs_clk0;
	dfs_dcm : dcm_sp
	generic map(
		clk_feedback => "1X",
		clkin_period => dcm_per,
		clkdv_divide => 2.0,
		clkin_divide_by_2 => false,
		clkfx_divide => dfs_div,
		clkfx_multiply => dfs_mul,
		clkout_phase_shift => "NONE",
		deskew_adjust => "SYSTEM_SYNCHRONOUS",
		dfs_frequency_mode => "LOW",
		dll_frequency_mode => "LOW",
		duty_cycle_correction => true,
		factory_jf   => x"C080",
		phase_shift  => 0,
		startup_wait => false)
	port map (
		dssen => '0',
		psclk => '0',
		psen  => '0',
		psincdec => '0',

		rst => dcm_rst,
		clkin => dcm_clk,
		clkfb => dfs_clkfb,
		clk0  => dfs_clk0,
		clkfx => dfs_clkfx,
		locked => dfs_locked);


	ppppp : fdcpe 
	generic map(
		init => '0')

	port map (
		clr => dcm_rst,
		pre => dfs_locked,
		ce => '0',
		d  => '0',
		c  => '1',
		q => qq);
	process (dfs_clkfx)
		variable q : std_logic_vector(0 to 4) := (others => '0');
	begin
		if rising_edge(dfs_clkfx) then
			dll_rst <= not q(0);
			q := q(1 to 4) & qq;
		end if;
	end process;
--	dll_clkin_bufg : BUFG
--	port map (
--		i => dfs_clkfx,
--		o => dll_clkin);

	dll_clkin <= dfs_clkfx;

	dll_clkfb_bufg : BUFG
	port map (
		i => dll_clk0,
		o => dll_clkfb);

	dcm : dcm_sp
	generic map(
		clk_feedback => "1X",
		clkdv_divide => 2.0,
		clkfx_divide => 1,
		clkfx_multiply => 2,
		clkin_divide_by_2 => FALSE,
		clkin_period => (dcm_per*real(dfs_div))/real(dfs_mul),
		clkout_phase_shift => "NONE",
		deskew_adjust => "SYSTEM_SYNCHRONOUS",
		dfs_frequency_mode => "LOW",
		dll_frequency_mode => "LOW",
		duty_cycle_correction => TRUE,
		factory_jf => x"C080",
		phase_shift => 0,
		startup_wait => FALSE)
	port map (
		dssen => '0',
		psclk => '0',
		psen  => '0',
		psincdec => '0',

		rst   => dll_rst,
		clkin => dll_clkin,
		clkfb => dll_clkfb,
		clk0  => dll_clk0,
		clk90 => dll_clk90,
		locked => dll_locked);

--	dll_clk0_bufg : BUFG
--	port map (
--		i => dll_clk0,
--		o => clk0);

	dfsdcm_clk0 <= dll_clkfb;
	dll_clk90_bufg : BUFG
	port map (
		i => dll_clk90,
		o => dfsdcm_clk90);

	dcm_lck <= not dcm_rst and dll_locked and dfs_locked;
end;


