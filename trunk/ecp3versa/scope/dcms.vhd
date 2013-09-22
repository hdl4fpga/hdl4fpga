library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;

entity dcms is
	generic (
		ddr_mul : natural := 10;
		ddr_div : natural := 3;
		sys_per : real := 10.0);
	port (
		sys_rst   : in  std_logic;
		sys_clk   : in  std_logic;
		input_clk : out std_logic;
		ddr_clk0  : out std_logic;
		ddr_clk90 : out std_logic;
		video_clk : out std_logic := '-';
		video_clk90 : out std_logic;
		dcm_lckd  : out std_logic);
end;

architecture ecp3 of dcms is

	---------------------------------------
	-- Frequency   -- 166 Mhz -- 450 Mhz --
	-- Multiply by --   5     --   9     --
	-- Divide by   --   3     --   2     --
	---------------------------------------

	signal dcm_rst : std_logic;

	signal video_lckd : std_logic := '1';
	signal ddr_lckd : std_logic;
	signal input_lckd : std_logic;
	signal gtx_lckd : std_logic;
begin
	process (sys_rst, sys_clk)
	begin
		if sys_rst='1' then
			dcm_rst  <= '1';
			dcm_lckd <= '0';
		elsif rising_edge(sys_clk) then
			if dcm_rst='0' then
				dcm_lckd <= video_lckd and ddr_lckd and input_lckd and gtx_lckd;
			end if;
			dcm_rst <= '0';
		end if;
	end process;

--	video_dcm_e : entity hdl4fpga.dfs
--	generic map (
--		dcm_per => sys_per,
--		div_op => 4,
--		div_fb => 3,
--		div_i  => 2)
--	port map (
--		dcm_rst => dcm_rst,
--		dcm_clk => sys_clk,
--		dfs_clk => video_clk,
--		dcm_lkd => video_lckd);

--	ddrdcm_e : entity hdl4fpga.pllddr
--	generic map (
--		dcm_per => sys_per)
--	port map (
--		pllddr_rst   => dcm_rst,
--		pllddr_clki => sys_clk,
--		pllddr_clk0  => ddr_clk0,
--		pllddr_clk90 => ddr_clk90,
--		pllddr_lkd  => ddr_lckd);
--
--	inputdcm_e : entity hdl4fpga.dfs
--	generic map (
--		dcm_per => sys_per,
--		div_op => 8,
--		div_fb => 1,
--		div_i  => 1)
--	port map (
--		dcm_rst => dcm_rst,
--		dcm_clk => sys_clk,
--		dfs_clk => input_clk,
--		dcm_lkd => input_lckd);
end;
