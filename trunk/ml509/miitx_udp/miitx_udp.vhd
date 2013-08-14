library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;

architecture miitx_udp of ml509 is

	signal rst  : std_logic;
	signal txen : std_logic;
	signal dcm_lckd : std_logic;
	signal mii_req  : std_logic;

	signal sys_addr : std_logic_vector(0 to 9-1);
	signal sys_data : std_logic_vector(0 to 32-1);
begin

	rst <= gpio_sw_c;

	process (phy_txclk)
		variable edge : std_logic;
		variable sent : std_logic;
	begin
		if rising_edge(phy_txclk) then
			if rst='1' then
				mii_req <= '0';
				sent := '0';
				edge := '0';
			elsif sent='0' then
				mii_req <= '1';
				if txen='0' then
					if edge='1' then
						mii_req <= '0';
						sent := '1';
					end if;
				end if;
			end if;
			edge := txen;
		end if;
	end process;


	bram_e : entity hdl4fpga.dpram
	generic map (
		data_size => sys_data'length,
		address_size => sys_addr'length)
	port map (
		rd_clk => phy_txclk,
		rd_address => sys_addr,
		rd_data => sys_data);

	mii_dfs_e : entity hdl4fpga.dfs
	generic map (
		dcm_per => 10.0,
		dfs_mul => 5,
		dfs_div => 4)
	port map (
		dcm_rst => '0',
		dcm_clk => user_clk,
		dfs_clk => phy_txc_gtxclk,
		dcm_lck => dcm_lckd);

	miitx_udp_e : entity hdl4fpga.miitx_udp
	port map (
		sys_addr => sys_addr,
		sys_data => sys_data,
		mii_treq => mii_req,
		mii_txc  => phy_txclk,
		mii_txen => txen,
		mii_txd  => phy_txd);
	phy_txctl_txen <= txen;
	phy_reset <= '1';
	phy_txer <= '0';

	dvi_gpio1 <= '1';
	bus_error <= (others => 'Z');
	gpio_led <= (others => '0');
	gpio_led_c <= dcm_lckd;
	gpio_led_e <= '0';
	gpio_led_n <= '0';
	gpio_led_s <= '0';
	gpio_led_w <= '0';
	fpga_diff_clk_out_p <= 'Z';
	fpga_diff_clk_out_n <= 'Z';
	ddr2_cs <= (others => '1');
  	ddr2_cke <= (others => '0');
   	ddr2_odt <= (others => 'Z');
	ddr2_dm <= (others => 'Z');
	ddr2_d <= (others => 'Z');
	ddr2_a <= (others => 'Z');
	ddr2_ba <= (others => 'Z');
	ddr2_cas <= 'Z';
	ddr2_ras <= 'Z';
	ddr2_we <= 'Z';
	ddr2_dqs_p <= (others => 'Z');
	ddr2_dqs_n <= (others => 'Z');
	ddr2_clk_n <= (others => 'Z');
	ddr2_clk_p <= (others => 'Z');

	dvi_xclk_p <= 'Z';
	dvi_xclk_n <= 'Z';
	dvi_v <= 'Z';
	dvi_h <= 'Z';
	dvi_de <= 'Z';
	dvi_d <= (others => 'Z');

end;
