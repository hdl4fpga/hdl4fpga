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
		gtx_clk   : out std_logic;
		dcm_lckd  : out std_logic);
end;

architecture ecp3 of dcms is

	---------------------------------------
	-- Frequency   -- 166 Mhz -- 450 Mhz --
	-- Multiply by --   5     --   9     --
	-- Divide by   --   3     --   2     --
	---------------------------------------

	signal dcm_rst : std_logic;

	signal ddr_lck   : std_logic := '1';
	signal gtx_lck   : std_logic := '1';

begin

	input_clk <= sys_clk;

	process (sys_rst, sys_clk)
	begin
		if sys_rst='1' then
			dcm_rst  <= '1';
			dcm_lckd <= '0';
		elsif rising_edge(sys_clk) then
			if dcm_rst='0' then
				dcm_lckd <= ddr_lckd and gtx_lckd;
			end if;
			dcm_rst <= '0';
		end if;
	end process;

	ddr3_b : block
		port (
			sys_rst  : in  std_logic;
			sys_clk  : in  std_logic;
			ddr_eclk : out std_logic;
			dcm_lck : out std_logic);
		port map (
			sys_clk => sys_clk,
			dfs_clk => ddr_clk,
			dcm_lck => ddr_lck);
			
		signal pll_clkos : std_logic;
		signal pll_clkfb  : std_logic;
	begin
		pll_i : ehxpllf
		generic map (
			feedbk_path => "INTERNAL",
			clkos_trim_delay => 0, clkos_trim_pol => "RISING", 
			clkop_trim_delay => 0, clkop_trim_pol => "RISING", 
			delay_pwd => "DISABLED",
			delay_val => 0, 
			duty => 8,
			phase_delay_cntl => "STATIC",
			phaseadj => "0.0", 
			clkok_div => 2,
			clkop_div => div_op,
			clkfb_div => div_fb,
			clki_div  => div_i,
			fin => "100.000000")
		port map (
			rst   => '0', 
			rstk  => '0',
			clki  => sys_clk,
			wrdel => '0',
			drpai3 => '0', drpai2 => '0', drpai1 => '0', drpai0 => '0', 
			dfpai3 => '0', dfpai2 => '0', dfpai1 => '0', dfpai0 => '0', 
			fda3   => '0', fda2   => '0', fda1   => '0', fda0   => '0', 
			clkintfb => pll_clkfb,
			clkfb => pll_clkfb,
			clkop => sclk2, 
			clkos => pll_clkos,
			clkok => sclk,
			clkok2 => open,

			lock  => dcm_lck);
		eclk <= pll_clkop;

		process (rst, sclk)
			variable q : std_logic_vector(0 to 1);
		begin
			if rst='1' then
				q := (others => '0');
			elsif rising_edge(sclk) then
				q := q(1) & 1;
			end if;
			eclk_stop <= q(0);
		end process;

		eclksynca_i : eclksynca
		port map (
			stop  => eclk_stop,
			eclk  => pll_clkos,
			eclko => eclk);

		dqsdllb_i : dqsdllb
		port map (
			clk => pll_clkop,
			dqsdel => dqsdel,
			lock => open);
		
	end block;

end;
