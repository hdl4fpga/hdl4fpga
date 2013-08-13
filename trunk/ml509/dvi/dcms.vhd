library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity dcms is
	generic (
		sys_per : real := 10.0);
	port (
		sys_rst   : in  std_logic;
		sys_clk   : in  std_logic;
		video_clk : out std_logic;
		video_clk90 : out std_logic;
		dcm_lckd  : out std_logic);
end;

architecture def of dcms is

	---------------------------------------
	-- Frequency   -- 166 Mhz -- 450 Mhz --
	-- Multiply by --   5     --   9     --
	-- Divide by   --   3     --   2     --
	---------------------------------------

	signal dcm_rst : std_logic;
	signal sclk_bufg : std_logic;

	signal video_lckd : std_logic;
begin

	clkin_ibufg : ibufg
	port map (
		I => sys_clk,
		O => sclk_bufg);

	video_dcm_e : entity hdl4fpga.dfsdcm
	generic map (
		dcm_per => sys_per,
		dfs_mul => 3,
		dfs_div => 2)
	port map (
		dfsdcm_rst => dcm_rst,
		dfsdcm_clkin => sclk_bufg,
		dfsdcm_clk0  => video_clk,
		dfsdcm_clk90 => video_clk90,
		dfsdcm_lckd => video_lckd);

	process (sys_rst, sclk_bufg)
	begin
		if sys_rst='1' then
			dcm_rst  <= '1';
			dcm_lckd <= '0';
		elsif rising_edge(sclk_bufg) then
			if dcm_rst='0' then
				dcm_lckd <= video_lckd;
			end if;
			dcm_rst <= '0';
		end if;
	end process;
end;
