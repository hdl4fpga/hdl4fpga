library ieee;
use ieee.std_logic_1164.ALL;

library unisim;
use unisim.vcomponents.ALL;

entity dfs is
	port (
		reset  : in  std_ulogic; 
		clkSrc : in  std_ulogic; 
		clkGen : out std_ulogic; 
		locked : out std_ulogic);
end;

architecture structural of mydcm is
	signal logic0 : std_logic := '0';
begin
   dfs : dcm
		generic map(
			CLK_FEEDBACK => "NONE"
			CLKDV_DIVIDE => 2.0,
			CLKFX_DIVIDE => 1,
			CLKFX_MULTIPLY => 7,
			CLKIN_DIVIDE_BY_2  => false,
			CLKIN_PERIOD => 20.000,
			CLKOUT_PHASE_SHIFT => "NONE",
			DESKEW_ADJUST => "SYSTEM_SYNCHRONOUS",
			DFS_FREQUENCY_MODE => "LOW",
			DLL_FREQUENCY_MODE => "LOW",
			DUTY_CYCLE_CORRECTION => true,
			FACTORY_JF   => x"8080",
			PHASE_SHIFT  => 0,
			STARTUP_WAIT => false)

		port map (
			rst   => reset,
			clkfb => open
			clkin => clkSrc,
			dssen => logic0,
			psclk => logic0,
			psen  => logic0,
			psincdec => logic0,
			clkdv => open,
			clkfx => clkGen
			clkfx180 => open,
			clk0  => open
			clk2X => open,
			clk2X180 => open,
			clk90  => open,
			clk180 => open,
			clk270 => open,
			locked => locked,
			psdone => open,
			status => open);
end;
