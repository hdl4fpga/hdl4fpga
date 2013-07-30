library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.cgafont.all;

entity dcms is
	generic (
		ddr_mul : natural := 25;
		ddr_div : natural := 9;
		sys_per : real := 50.0);
	port (
		sys_rst   : in  std_logic;
		sys_clk   : in  std_logic;
		input_clk : out std_logic;
		ddr_clk0  : out std_logic;
		ddr_clk90 : out std_logic;
		video_clk : out std_logic;
		mii_clk   : out std_logic;
		dcm_lckd  : out std_logic);
end;

architecture def of dcms is

	-------------------------------------------------------------------------
	-- Frequency   -- 133 Mhz -- 166 Mhz -- 180 Mhz -- 193 Mhz -- 200 Mhz  --
	-- Multiply by --  20     --  25     --   9     --  29     --  10      --
	-- Divide by   --   3     --   3     --   1     --   3     --   1      --
	-------------------------------------------------------------------------

	signal dcm_rst : std_logic;
	signal sclk_bufg : std_logic;

	signal video_lckd : std_logic;
	signal ddr_lckd : std_logic;
	signal input_lckd : std_logic;
	signal mii_lckd : std_logic;
begin

	clkin_ibufg : ibufg
	port map (
		I => sys_clk,
		O => sclk_bufg);

	videodcm_e : entity hdl4fpga.dfs
	generic map (
		dcm_per => sys_per,
		dfs_mul => 15,
		dfs_div => 2)
	port map(
		dcm_rst => dcm_rst,
		dcm_clk => sclk_bufg,
		dfs_clk => video_clk,
		dcm_lck => video_lckd);

	ddrdcm_e : entity hdl4fpga.dfsdcm
	generic map (
		dcm_per => sys_per,
		dfs_mul => ddr_mul,
		dfs_div => ddr_div)
	port map (
		dfsdcm_rst => dcm_rst,
		dfsdcm_clkin => sclk_bufg,
		dfsdcm_clk0  => ddr_clk0,
		dfsdcm_clk90 => ddr_clk90,
		dfsdcm_lckd => ddr_lckd);

	inputdcm_e : entity hdl4fpga.dfs
	generic map (
		dcm_per => sys_per,
		dfs_mul => 2,
		dfs_div => 2)
	port map (
		dcm_rst => dcm_rst,
		dcm_clk => sclk_bufg,
		dfs_clk => input_clk,
		dcm_lck => input_lckd);

	mii_dfs_e : entity hdl4fpga.dfs
	generic map (
		dcm_per => sys_per,
		dfs_mul => 5,
		dfs_div => 4)
	port map (
		dcm_rst => dcm_rst,
		dcm_clk => sclk_bufg,
		dfs_clk => mii_clk,
		dcm_lck => mii_lckd);

	process (sys_rst, sclk_bufg)
	begin
		if sys_rst='1' then
			dcm_rst  <= '1';
			dcm_lckd <= '0';
		elsif rising_edge(sclk_bufg) then
			if dcm_rst='0' then
				dcm_lckd <= video_lckd and ddr_lckd and input_lckd and mii_lckd;
			end if;
			dcm_rst <= '0';
		end if;
	end process;
end;
