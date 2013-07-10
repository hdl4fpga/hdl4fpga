library ieee;
use ieee.std_logic_1164.all;

entity dcms is
	generic (
		sys_per : real);
	port ( 
		sys_rst : in std_logic; 
		sys_clk : in std_logic; 
		ddr_clk0  : out std_logic; 
		ddr_clk90 : out std_logic; 
		input_clk : out std_logic;
		video_clk : out std_logic;
		dcms_lckd : out std_logic);
end;

library unisim;
use unisim.vcomponents.all;

architecture def of dcms is
	signal dcms_rst  : std_logic;

	signal ddr_lckd : std_logic;
	signal input_lckd : std_logic;
	signal video_lckd : std_logic;

begin

	pll_i : entity hdl4fpga.pll
	generic map (
		pll_per => sys_per)
	port map (
		pll_rst => sys_rst,
		pll_clkin => sys_clk
		pll_clk => pll_clk,
		pll_lckd => pll_lckd);

	process (dcms_rst, pll_clk)
		variable srl16 : std_logic_vector(0 to 16-1);
	begin
		if plldcm_rst='1' then
			dcms_rst <= '1';
			dcms_lckd <= '0';
		elsif rising_edge(pll_clk) then
			srl16 := srl16(1 to srl16'right) & not pll_lckd;
			dcms_rst <= srl16(0) or not pll_lckd;
			dcms_lckd <= input_lckd and video_lckd and ddr_lckd;
		end if;
	end process;

	ddrdcm_e : entity hdl4fpga.ddrdcm
	generic map (
		sys_per =>
		dfs_div => 9,
		dfs_mul => 2)
	port map (
		sys_rst => dcms_rst,
		sys_clk => pll_clk,
		ddrdcm_clk0  => ddr_clk0,
		ddrdcm_clk90 => ddr_clk90,
		ddrdcm_lckd  => ddr_lckd);
end;
