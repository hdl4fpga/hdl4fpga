--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                         --
--    Miguel Angel Sagreras                                                   --
--                                                                            --
-- This source file may be used and distributed without restriction provided  --
-- that this copyright statement is not removed from the file and that any    --
-- derivative work contains  the original copyright notice and the associated --
-- disclaimer.                                                                --
--                                                                            --
-- This source file is free software; you can redistribute it and/or modify   --
-- it under the terms of the GNU General Public License as published by the   --
-- Free Software Foundation, either version 3 of the License, or (at your     --
-- option) any later version.                                                 --
--                                                                            --
-- This source is distributed in the hope that it will be useful, but WITHOUT --
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      --
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   --
-- more details at http://www.gnu.org/licenses/.                              --
--                                                                            --

library hdl4fpga;
use hdl4fpga.std.all;

architecture s3estarter_graphics of testbench is
	constant ddr_period : time := 6 ns;
	constant bank_bits  : natural := 2;
	constant addr_bits  : natural := 13;
	constant cols_bits  : natural := 9;
	constant data_bytes : natural := 2;
	constant byte_bits  : natural := 8;
	constant timer_dll  : natural := 9;
	constant timer_200u : natural := 9;
	constant data_bits  : natural := byte_bits*data_bytes;

	signal rst   : std_logic;
	signal clk   : std_logic := '0';
	signal led7  : std_logic;

	signal dq    : std_logic_vector (data_bits - 1 downto 0) := (others => 'Z');
	signal dqs   : std_logic_vector (1 downto 0) := "00";
	signal addr  : std_logic_vector (addr_bits - 1 downto 0);
	signal ba    : std_logic_vector (1 downto 0);
	signal clk_p : std_logic := '0';
	signal clk_n : std_logic := '0';
	signal cke   : std_logic := '1';
	signal cs_n  : std_logic := '1';
	signal ras_n : std_logic;
	signal cas_n : std_logic;
	signal we_n  : std_logic;
	signal dm    : std_logic_vector(1 downto 0);

	signal mii_refclk : std_logic := '0';
	signal mii_req  : std_logic := '0';
	signal mii_req1 : std_logic := '0';
	signal rep_req  : std_logic := '0';
	signal ping_req : std_logic := '0';
	signal mii_rxdv : std_logic;
	signal mii_rxd  : std_logic_vector(0 to 4-1);
	signal mii_txd  : std_logic_vector(0 to 4-1);
	signal mii_txc  : std_logic;
	signal mii_rxc  : std_logic;
	signal mii_txen : std_logic;

	component s3estarter is
		generic (
			debug : boolean);
		port (
			xtal       : in std_logic := '0';
			sw0        : in std_logic := '1';
			btn_west   : in std_logic := '1';

			--------------
			-- switches --

			led0 : out std_logic := '0';
			led1 : out std_logic := '0';
			led2 : out std_logic := '0';
			led3 : out std_logic := '0';
			led4 : out std_logic := '0';
			led5 : out std_logic := '0';
			led6 : out std_logic := '0';
			led7 : out std_logic := '0';

			------------------------------
			-- MII ethernet Transceiver --

			e_txd  	 : out std_logic_vector(0 to 3) := (others => 'Z');
			e_txen   : out std_logic := 'Z';
			e_txd_4  : out std_logic;

			e_tx_clk : in  std_logic := 'Z';

			e_rxd    : in std_logic_vector(0 to 4-1) := (others => 'Z');
			e_rx_dv  : in std_logic := 'Z';
			e_rx_er  : in std_logic := 'Z';
			e_rx_clk : in std_logic := 'Z';

			e_crs    : in std_logic := 'Z';
			e_col    : in std_logic := 'Z';

			e_mdc    : out std_logic := 'Z';
			e_mdio   : inout std_logic := 'Z';

			---------
			-- VGA --
		
			vga_red   : out std_logic;
			vga_green : out std_logic;
			vga_blue  : out std_logic;
			vga_hsync : out std_logic;
			vga_vsync : out std_logic;

			---------
			-- SPI --

			spi_sck  : out std_logic;
			spi_miso : in  std_logic;
			spi_mosi : out std_logic;

			---------
			-- AMP --

			amp_cs   : out std_logic := '0';
			amp_shdn : out std_logic := '0';
			amp_dout : in  std_logic;

			---------
			-- ADC --

			ad_conv  : out std_logic;


			-------------
			-- DDR RAM --

			sd_a          : out std_logic_vector(13-1 downto 0) := (13-1 downto 0 => '0');
			sd_dq         : inout std_logic_vector(16-1 downto 0);
			sd_ba         : out std_logic_vector(2-1  downto 0) := (2-1  downto 0 => '0');
			sd_ras        : out std_logic := '1';
			sd_cas        : out std_logic := '1';
			sd_we         : out std_logic := '0';
			sd_dm         : inout std_logic_vector(2-1 downto 0);
			sd_dqs        : inout std_logic_vector(2-1 downto 0);
			sd_cs         : out std_logic := '1';
			sd_cke        : out std_logic := '1';
			sd_ck_n       : out std_logic := '0';
			sd_ck_p       : out std_logic := '1';
			sd_ck_fb      : in std_logic := '0');

	end component;

	component ddr_model is
		port (
			clk   : in std_logic;
			clk_n : in std_logic;
			cke   : in std_logic;
			cs_n  : in std_logic;
			ras_n : in std_logic;
			cas_n : in std_logic;
			we_n  : in std_logic;
			ba    : in std_logic_vector(1 downto 0);
			addr  : in std_logic_vector(addr_bits - 1 downto 0);
			dm    : in std_logic_vector(data_bytes - 1 downto 0);
			dq    : inout std_logic_vector(data_bits - 1 downto 0);
			dqs   : inout std_logic_vector(data_bytes - 1 downto 0));
	end component;


	constant baudrate : natural := 1000000;

	signal uart_clk : std_logic := '0';
	signal uart_sin : std_logic;

	signal datarx_null :  std_logic_vector(mii_rxd'range);

begin

	clk      <= not clk after 10 ns;
	uart_clk <= not uart_clk after (1 sec / baudrate / 2);

	rst <= '0', '1' after 300 ns;

--	mii_req  <= '0', '1' after 200 us, '0' after 206 us, '0' after 244 us; --, '0' after 219 us, '1' after 220 us;
	mii_req  <= '0', '1' after 10 us,  '0' after 240 us; --, '0' after 244 us; --, '0' after 219 us, '1' after 220 us;
	mii_req1 <= '0', '1' after 360 us; -- '0' after 19.0 us; --, '1' after 19.5 us; --, '0' after 219 us, '1' after 220 us;
	process
		variable x : natural := 0;
	begin
		wait for 100 us;
		loop
			if rep_req='1' then
				if x > 4 then
					wait;
				end if;
				rep_req <= '0' after 6 us;
	wait;
				x := x + 1;
			else
				rep_req <= '1' after 80 ns;
			end if;
		wait on rep_req;
		end loop;
	end process;
--	mii_req1  <= '0'; --rep_req;
	ping_req <= '0';

	htb_e : entity hdl4fpga.eth_tb
	generic map (
		debug =>false)
	port map (
		mii_data4 =>
		x"01007e" &
		x"18ff"   &
		x"03020100_07060504_0b0a0908_0f0e0d0c_13121110_17161514_1b1a1918_1f1e1d1c" &
		x"23222120_27262524_2b2a2928_2f2e2d2c_33323130_37363534_3b3a3938_3f3e3d3c" &
		x"43424140_47464544_4b4a4948_4f4e4d4c_53525150_57565554_5b5a5958_5f5e5d5c" &
		x"63626160_67666564_6b6a6968_6f6e6d6c_73727170_77767574_7b7a7978_7f7e7d7c" &
		x"83828180_87868584_8b8a8988_8f8e8d8c_93929190_97969594_9b9a9998_9f9e9d9c" &
		x"a3a2a1a0_a7a6a5a4_abaaa9a8_afaeadac_b3b2b1b0_b7b6b5b4_bbbab9b8_bfbebdbc" &
		x"c3c2c1c0_c7c6c5c4_cbcac9c8_cfcecdcc_d3d2d1d0_d7d6d5d4_dbdad9d8_dfdedddc" &
		x"e3e2e1e0_e7e6e5e4_ebeae9e8_efeeedec_f3f2f1f0_f7f6f5f4_fbfaf9f8_fffefdfc" &
		x"1702_0000ff_1603_0000_0000",
		mii_data5 => x"0100" & x"00" & x"1702_0000ff_1603_8000_0000",
		mii_frm1 => '0',
		mii_frm2 => ping_req,
		mii_frm3 => '0',
		mii_frm4 => mii_req,
		mii_frm5 => mii_req1,

		mii_txc  => mii_rxc,
		mii_txen => mii_rxdv,
		mii_txd  => mii_rxd);


	mii_refclk <= not mii_refclk after 50 ns;
	mii_rxc <= mii_refclk;
	mii_txc <= mii_refclk;
	du_e : s3estarter
	generic map (
		debug => true)
	port map (
		xtal => clk,
		btn_west  => rst,

		spi_miso => '-',
		amp_dout => '-',
		e_tx_clk => mii_rxc,
		e_rx_clk => mii_rxc,
		e_rx_dv => mii_rxdv,
		e_rxd => mii_rxd,
		e_txen => mii_txen,
		-------------
		-- DDR RAM --

		sd_ck_p => clk_p,
		sd_ck_n => clk_n,
		sd_cke => cke,
		sd_cs  => cs_n,
		sd_ras => ras_n,
		sd_cas => cas_n,
		sd_we  => we_n,
		sd_ba  => ba,
		sd_a   => addr,
		sd_dm  => dm,
		sd_dqs => dqs,
		sd_dq  => dq);

	ddr_model_g: ddr_model
	port map (
		Clk   => clk_p,
		Clk_n => clk_n,
		Cke   => cke,
		Cs_n  => cs_n,
		Ras_n => ras_n,
		Cas_n => cas_n,
		We_n  => we_n,
		Ba    => ba,
		Addr  => addr,
		Dm    => dm,
		Dq    => dq,
		Dqs   => dqs);

end;

library micron;

configuration s3estarter_structure_md of testbench is
	for s3estarter_graphics
		for all : s3estarter
			use entity work.s3estarter(structure);
		end for;
		for all: ddr_model
			use entity micron.ddr_model
			port map (
				Clk   => clk_p,
				Clk_n => clk_n,
				Cke   => cke,
				Cs_n  => cs_n,
				Ras_n => ras_n,
				Cas_n => cas_n,
				We_n  => we_n,
				Ba    => ba,
				Addr  => addr,
				Dm    => dm,
				Dq    => dq,
				Dqs   => dqs);
		end for;
	end for;
end;

library micron;

configuration s3estarter_graphics_md of testbench is
	for s3estarter_graphics
		for all : s3estarter 
			use entity work.s3estarter(graphics);
		end for;
			for all : ddr_model 
			use entity micron.ddr_model
			port map (
				Clk   => clk_p,
				Clk_n => clk_n,
				Cke   => cke,
				Cs_n  => cs_n,
				Ras_n => ras_n,
				Cas_n => cas_n,
				We_n  => we_n,
				Ba    => ba,
				Addr  => addr,
				Dm    => dm,
				Dq    => dq,
				Dqs   => dqs);

		end for;
	end for;
end;
