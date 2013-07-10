library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

library unisim;
use unisim.vcomponents.ALL;

entity dfs is
	generic (
		dcm_per : real := 20.0;
		dfs_div : natural := 3;
		dfs_mul : natural := 10);
	port (
        dcm_rst : in  std_logic; 
		dcm_clk : in  std_logic; 
		dfs_clk : out std_logic; 
		dcm_lck : out std_logic);
end;

architecture spartan3 of dfs is
   signal dfs_clkbuf : std_logic;
   signal dcm_clkfb  : std_logic;
   signal dcm_clk0   : std_logic;
begin
	dfsbuf_g : bufg
	port map (
		i => dfs_clkbuf,
		o => dfs_clk);

	dcmclk_g : bufg
	port map (
		I => dcm_clk0,
		O => dcm_clkfb);
   
	dfs_i : dcm_sp
	generic map(
		clk_feedback => "1x",
		clkdv_divide => 2.0,
		clkfx_divide => dfs_div,
		clkfx_multiply => dfs_mul,
		clkin_divide_by_2 => false,
		clkin_period => dcm_per,
		clkout_phase_shift => "none",
		deskew_adjust => "system_synchronous",
		dfs_frequency_mode => "low",
		dll_frequency_mode => "low",
		duty_cycle_correction => true,
		factory_jf   => x"c080",
		phase_shift  => 0,
		startup_wait => false)
	port map (
		rst   => dcm_rst,
		dssen => '0',
		psclk => '0',
		psen  => '0',
		psincdec => '0',
		clkfb => dcm_clkfb,
		clkin => dcm_clk,
		clkfx => dfs_clkbuf,
		clkfx180 => open,
		clk0  => dcm_clk0,
		locked => dcm_lck,
		psdone => open,
		status => open);
end;
