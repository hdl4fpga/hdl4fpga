library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

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

library unisim;
use unisim.vcomponents.ALL;

library hdl4fpga;
use hdl4fpga.std.all;

architecture spartan3 dfsdcm is
	signal dfs_clkfx : std_logic;
	signal dfs_locked : std_logic;
    signal dfs_clk0  : std_logic;

	signal dll_rst : std_logic;
	signal dll_clkin : std_logic;
	signal dll_clkfb : std_logic;
	signal dll_clk0  : std_logic;
	signal dll_clk90 : std_logic;
	signal dll_locked : std_logic;

begin

	dfs_dcm : dcm_sp
	generic map(
		clk_feedback => "1X",
		clkin_period => dcm_per,
		clkdv_divide => 2.0,
		clkin_divide_by_2 => FALSE,
		clkfx_divide => dfs_div,
		clkfx_multiply => dfs_mul,
		clkout_phase_shift => "NONE",
		deskew_adjust => "SYSTEM_SYNCHRONOUS",
		dfs_frequency_mode => "LOW",
		dll_frequency_mode => "LOW",
		duty_cycle_correction => TRUE,
		factory_jf   => X"C080",
		phase_shift  => 0,
		startup_wait => FALSE)
	port map (
		dssen => '0',
		psclk => '0',
		psen  => '0',
		psincdec => '0',

		rst => dcm_rst,
		clkin => dcm_clk,
		clkfb => dfs_clk0,
		clk0  => dfs_clk0,
		clkfx => dfs_clkfx,
		locked => dfs_locked);


	process (dcm_rst, dcm_clk)
		variable q : std_logic_vector(0 to 16-1);
	begin
		if dcm_rst='1' then
			dll_rst <= '1';
			dcm_lckd;
		elsif rising_edge(dcm_clk) then
			q := q(1 to q'right) & not dfs_locked;
			dll_rst := q(0) or not dfs_locked;
			dcm_lckd <= not dll_rst and dll_locked;
		end if;
	end process;

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

end;


