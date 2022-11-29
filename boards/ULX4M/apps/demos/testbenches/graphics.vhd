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
use hdl4fpga.base.all;
use hdl4fpga.ipoepkg.all;

architecture ulx4mld_graphics of testbench is

	constant debug      : boolean := false;

	constant bank_bits  : natural := 3;
	constant addr_bits  : natural := 15;
	constant cols_bits  : natural := 9;
	constant data_bytes : natural := 2;
	constant byte_bits  : natural := 8;
	constant data_bits  : natural := byte_bits*data_bytes;

	signal rst         : std_logic;
	signal xtal        : std_logic := '0';

	component ulx4m_ld is
		generic (
			debug          : boolean := debug);
		port (
			clk_25mhz      : in    std_logic;
			btn            : in    std_logic_vector(1 to 3) := (others => '-');
			led            : out   std_logic_vector(0 to 8-1) := (others => 'Z');

			sd_clk         : in    std_logic := '-';
			sd_cmd         : out   std_logic; 
			sd_d           : inout std_logic_vector(4-1 downto 0) := (others => '-');
			sd_wp          : in    std_logic := '-';
			sd_cdn         : in    std_logic := '-';

			usb_fpga_dp    : inout std_logic := '-';
			usb_fpga_dn    : inout std_logic := '-';
			usb_fpga_bd_dp : inout std_logic := '-';
			usb_fpga_bd_dn : inout std_logic := '-';
			usb_fpga_pu_dp : inout std_logic := '-';
			usb_fpga_pu_dn : inout std_logic := '-';
			usb_fpga_otg_dp : inout std_logic := 'Z';
			usb_fpga_otg_dn : inout std_logic := 'Z';
			n_extrst        : inout std_logic := 'Z';

			eth_reset      : out   std_logic;
--			rgmii_ref_clk  : in    std_logic;
			eth_mdio       : inout std_logic := '-';
			eth_mdc        : out   std_logic;
	
			rgmii_tx_clk   : out    std_logic := '-';
			rgmii_tx_en    : buffer std_logic;
			rgmii_txd      : buffer std_logic_vector(0 to 4-1);
			rgmii_rx_clk   : in    std_logic := '-';
			rgmii_rx_dv    : in    std_logic := '-';
			rgmii_rxd      : in    std_logic_vector(0 to 4-1) := (others => '-');

			ddram_clk      : inout std_logic;
			ddram_reset_n  : out   std_logic;
			ddram_cke      : out   std_logic;
			ddram_cs_n     : out   std_logic;
			ddram_ras_n    : out   std_logic;
			ddram_cas_n    : out   std_logic;
			ddram_we_n     : out   std_logic;
			ddram_odt      : out   std_logic;
			ddram_a        : out   std_logic_vector(15-1 downto 0);
			ddram_ba       : out   std_logic_vector( 3-1 downto 0);
			ddram_dm       : inout std_logic_vector( 2-1 downto 0) := (others => 'Z');
			ddram_dq       : inout std_logic_vector(16-1 downto 0) := (others => 'Z');
			ddram_dqs      : inout std_logic_vector( 2-1 downto 0) := (others => 'Z');

			gpio6          : inout std_logic := 'Z'; 
			gpio7          : inout std_logic := 'Z'; 
			gpio8          : inout std_logic := 'Z'; 
			gpio9          : inout std_logic := 'Z'; 
			gpio10         : inout std_logic := 'Z'; 
			gpio11         : inout std_logic := 'Z'; 
			gpio13         : inout std_logic := 'Z'; 
			gpio17         : inout std_logic := 'Z'; 
			gpio19         : inout std_logic := 'Z'; 
			gpio22         : inout std_logic := 'Z'; 
			gpio23         : inout std_logic := 'Z'; 
			gpio24         : inout std_logic := 'Z'; 
			gpio25         : inout std_logic := 'Z'; 

			fpdi_clk       :  out std_logic; 
			fpdi_d0        :  out std_logic;
			fpdi_d1        :  out std_logic;
			fpdi_d2        :  out std_logic;

			user_programn  : out   std_logic := '1';
			shutdown       : out   std_logic := '0');
	end component;

	constant snd_data : std_logic_vector := 
		x"01007e" &
		x"18ff"   &
		x"000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f" &
		x"202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f" &
		x"404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f" &
		x"606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f" &
		x"808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9f" &
		x"a0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebf" &
		x"c0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedf" &
		x"e0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff" &
		x"1702_0000ff_1603_0007_3000";
	constant req_data : std_logic_vector := x"010000_1702_00001f_1603_8007_3000";

	signal rst_n     : std_logic;
	signal cke       : std_logic;
	signal ddr_clk   : std_logic;
	signal ddr_clk_p : std_logic;
	signal ddr_clk_n : std_logic;
	signal cs_n      : std_logic;
	signal ras_n     : std_logic;
	signal cas_n     : std_logic;
	signal we_n      : std_logic;
	signal ba        : std_logic_vector(bank_bits-1 downto 0);
	signal addr      : std_logic_vector(addr_bits-1 downto 0) := (others => '0');
	signal dq        : std_logic_vector(data_bytes*byte_bits-1 downto 0) := (others => 'Z');
	signal dqs       : std_logic_vector(data_bytes-1 downto 0) := (others => 'Z');
	signal dqs_n     : std_logic_vector(dqs'range) := (others => 'Z');
	signal dm        : std_logic_vector(data_bytes-1 downto 0);
	signal odt       : std_logic;
	signal scl       : std_logic;
	signal sda       : std_logic;
	signal tdqs_n    : std_logic_vector(dqs'range);

	component ddr3_model is
		port (
			rst_n   : in std_logic;
			ck      : in std_logic;
			ck_n    : in std_logic;
			cke     : in std_logic;
			cs_n    : in std_logic;
			ras_n   : in std_logic;
			cas_n   : in std_logic;
			we_n    : in std_logic;
			ba      : in std_logic_vector(3-1 downto 0);
			addr    : in std_logic_vector(15-1 downto 0);
			dm_tdqs : in std_logic_vector(2-1 downto 0);
			dq      : inout std_logic_vector(16-1 downto 0);
			dqs     : inout std_logic_vector(2-1 downto 0);
			dqs_n   : inout std_logic_vector(2-1 downto 0);
			tdqs_n  : inout std_logic_vector(2-1 downto 0);
			odt     : in std_logic);
	end component;

	signal mii_req    : std_logic := '0';
	signal mii_req1   : std_logic := '0';
	signal ping_req   : std_logic := '0';
	signal rep_req    : std_logic := '0';
	signal mii_rxdv   : std_logic;
	signal mii_rxd    : std_logic_vector(0 to 8-1);
	signal mii_txd    : std_logic_vector(0 to 8-1);
	signal mii_txc    : std_logic;
	signal mii_rxc    : std_logic;
	signal mii_txen   : std_logic;

	alias rgmii_rxc   : std_logic is mii_rxc;
	alias rgmii_rxdv  : std_logic is mii_rxdv;
	signal rgmii_rxd  : std_logic_vector(0 to 4-1);

	alias rgmii_txc   : std_logic is mii_txc;
	signal rgmii_txen : std_logic;
	signal rgmii_txd  : std_logic_vector(0 to 4-1);

	signal datarx_null :  std_logic_vector(mii_rxd'range);

	signal ftdi_txd    : std_logic;
	signal ftdi_rxd    : std_logic;

	signal uart_clk : std_logic := '0';
begin

	rst      <= '1', '0' after 17 us when debug else '1', '0' after 4 us;
	xtal     <= not xtal after 20 ns;
	uart_clk <= not uart_clk after 0.1 ns /2 when debug else not uart_clk after 12.5 ns;

	hdlc_b : block

		generic (
			baudrate  : natural := 3e6;
			uart_xtal : real := 40.0e6;
			xxx : natural_vector;
			payload   : std_logic_vector);
		generic map (
			xxx => (0 => snd_data'length, 1 => req_data'length),
			payload   => snd_data & req_data);

		port (
			rst       : in  std_logic;
			uart_clk  : in  std_logic;
			uart_sout : out std_logic);
		port map (
			rst       => rst,
			uart_clk  => uart_clk,
			uart_sout => ftdi_txd);

		signal uart_trdy   : std_logic;
		signal uart_irdy   : std_logic;
		signal uart_txd    : std_logic_vector(0 to 8-1);

		signal uartrx_trdy   : std_logic;
		signal uartrx_irdy   : std_logic;
		signal uartrx_data   : std_logic_vector(0 to 8-1);

		signal hdlctx_frm  : std_logic;
		signal hdlctx_end  : std_logic;
		signal hdlctx_trdy : std_logic;
		signal hdlctx_data : std_logic_vector(0 to 8-1);

		signal hdlcrx_frm  : std_logic;
		signal hdlcrx_end  : std_logic;
		signal hdlcrx_trdy : std_logic;
		signal hdlcrx_irdy : std_logic;
		signal hdlcrx_data : std_logic_vector(0 to 8-1);
		signal hdlcfcsrx_sb : std_logic;
		signal hdlcfcsrx_vld : std_logic;

		signal nrst : std_logic;
	begin

		nrst <= not rst;
		process 
			variable i     : natural;
			variable total : natural;
			variable addr  : natural;
		begin
			if rst='1' then
				hdlctx_frm <= '0';
				hdlctx_end <= '0';
				addr       := 0;
				total      := 0;
				i          := 0;
			elsif rising_edge(uart_clk) then
				if addr < total then
					hdlctx_data <= reverse(payload(addr to addr+8-1));
					if hdlctx_trdy='1' then
						addr := addr + 8;
					end if;
					if addr < total then
						hdlctx_frm <= '1';
						hdlctx_end <= '0';
					else
						hdlctx_frm <= '1';
						hdlctx_end <= '1';
					end if;
				elsif i < xxx'length then
					if i > 0 then
						if debug then
							wait for 5 us;
						else
							wait for 100 us;
						end if;
						hdlctx_frm <= '0';
						hdlctx_end <= '0';
					end if;
					total := total + xxx(i);
					i     := i + 1;
				else
					hdlctx_data <= (others => '-');
				end if;

			end if;
			wait on rst, uart_clk;
		end process;

		hdlcdll_tx_e : entity hdl4fpga.hdlcdll_tx
		port map (
			hdlctx_frm  => hdlctx_frm,
			hdlctx_irdy => '1',
			hdlctx_trdy => hdlctx_trdy,
			hdlctx_end  => hdlctx_end,
			hdlctx_data => hdlctx_data,

			uart_clk    => uart_clk,
			uart_irdy   => uart_irdy,
			uart_trdy   => uart_trdy,
			uart_data   => uart_txd);

		uarttx_e : entity hdl4fpga.uart_tx
		generic map (
			baudrate  => baudrate,
			clk_rate  => uart_xtal)
		port map (
			uart_frm  => nrst,
			uart_txc  => uart_clk,
			uart_sout => uart_sout,
			uart_trdy => uart_trdy,
			uart_irdy => uart_irdy,
			uart_data => uart_txd);

		uartrx_e : entity hdl4fpga.uart_rx
		generic map (
			baudrate  => baudrate,
			clk_rate  => uart_xtal)
		port map (
			uart_rxc  => uart_clk,
			uart_sin  => ftdi_rxd,
			uart_irdy => uartrx_irdy,
			uart_data => uartrx_data);

		hdlcdll_rx_e : entity hdl4fpga.hdlcdll_rx
		port map (
			uart_clk    => uart_clk,
			uartrx_irdy => uartrx_irdy,
			uartrx_data => uartrx_data,

			hdlcrx_frm  => hdlcrx_frm,
			hdlcrx_irdy => hdlcrx_irdy,
			hdlcrx_data => hdlcrx_data,
			hdlcrx_end  => hdlcrx_end,
			fcs_sb      => hdlcfcsrx_sb,
			fcs_vld     => hdlcfcsrx_vld);

	end block;

	ipoe_b : block

		signal eth_txen  : std_logic;
		signal eth_txd   : std_logic_vector(mii_txd'range);

		signal pl_trdy    : std_logic;
		signal pl_end     : std_logic;
		signal pl_data    : std_logic_vector(mii_txd'range);

		signal miirx_frm  : std_logic;
		signal miirx_end  : std_logic;
		signal miirx_irdy : std_logic;
		signal miirx_trdy : std_logic;
		signal miirx_data : std_logic_vector(pl_data'range);

		signal miitx_frm  : std_logic;
		signal miitx_irdy : std_logic;
		signal miitx_trdy : std_logic;
		signal miitx_end  : std_logic;
		signal miitx_data : std_logic_vector(pl_data'range);

		signal llc_data   : std_logic_vector(0 to 2*48+16-1);
		signal hwllc_irdy : std_logic;
		signal hwllc_trdy : std_logic;
		signal hwllc_end  : std_logic;
		signal hwllc_data : std_logic_vector(pl_data'range);
		signal datarx_null :  std_logic_vector(mii_rxd'range);

	begin

		mii_req  <= '0', '1' after 20 us, '0' after 22 us; --, '0' after 244 us; --, '0' after 219 us, '1' after 220 us;
	--	mii_req1 <= '0', '1' after 14.5 us, '0' after 55 us, '1' after 55.02 us; --, '0' after 219 us, '1' after 220 us;

		process
		begin
			wait for 23 us;
			loop
				if rep_req='1' then
					wait;
					rep_req <= '0' after 5.8 us;
				else
					rep_req <= '1' after 250 ns;
				end if;
				wait on rep_req;
			end loop;
		end process;
		mii_req1 <= rep_req;
	
		rgmii_rxd <= multiplex(mii_rxd, not rgmii_rxc);

		htb_e : entity hdl4fpga.eth_tb
		generic map (
			debug => false)
		port map (
			mii_data4 => snd_data,
			mii_data5 => req_data,
			mii_frm1 => '0',
			mii_frm2 => '0', --ping_req,
			mii_frm3 => '0',
			mii_frm4 => mii_req,
			mii_frm5 => mii_req1,
	
			mii_txc  => mii_rxc,
			mii_txen => mii_rxdv,
			mii_txd  => mii_rxd);

		ethrx_e : entity hdl4fpga.eth_rx
		port map (
			dll_data   => datarx_null,
			mii_clk    => mii_rxc,
			mii_frm    => mii_rxdv,
			mii_irdy   => mii_rxdv,
			mii_data   => mii_rxd);

	end block;

	du_e : ulx4m_ld
	generic map (
		debug => debug)
	port map (
		clk_25mhz    => xtal,
		btn(1)       => '0',
		btn(2 to 3)  => (others => '-'),

		eth_reset    => open,
		eth_mdc      => open,
		rgmii_tx_clk => rgmii_txc,
		rgmii_tx_en  => rgmii_txen,
		rgmii_txd    => rgmii_txd,
		rgmii_rx_clk => '0', --rgmii_rxc,
		rgmii_rx_dv  => rgmii_rxdv,
		rgmii_rxd    => rgmii_rxd,

		gpio23       => ftdi_txd,
		gpio24       => ftdi_rxd,
		ddram_reset_n => rst_n,
		ddram_clk    => ddr_clk,
		ddram_cke    => cke,
		ddram_cs_n   => cs_n,
		ddram_ras_n  => ras_n,
		ddram_cas_n  => cas_n,
		ddram_we_n   => we_n,
		ddram_ba     => ba,
		ddram_a      => addr,
		ddram_dqs    => dqs,
		ddram_dq     => dq,
		ddram_dm     => dm,
		ddram_odt    => odt);

	process (rgmii_txc)
		variable en : std_logic;
	begin
		if rising_edge(rgmii_txc) then
			mii_txen <= en;
			en := rgmii_txen;
			mii_txd(0 to 4-1) <= rgmii_txd;
		elsif rising_edge(rgmii_txc) then
			mii_txd(4 to 8-1) <= rgmii_txd;
		end if;
	end process;

	ethrx_e : entity hdl4fpga.eth_rx
	port map (
		dll_data => datarx_null,
		mii_clk  => mii_txc,
		mii_frm  => mii_txen,
		mii_irdy => mii_txen,
		mii_data => mii_txd);

	ddr_clk_p <= ddr_clk;
	ddr_clk_n <= not ddr_clk;
	dqs_n <= not dqs;

	mt_u : ddr3_model
	port map (
		rst_n => rst_n,
		Ck    => ddr_clk_p,
		Ck_n  => ddr_clk_n,
		Cke   => cke,
		Cs_n  => cs_n,
		Ras_n => ras_n,
		Cas_n => cas_n,
		We_n  => we_n,
		Ba    => ba,
		Addr  => addr,
		Dm_tdqs => dm,
		Dq    => dq,
		Dqs   => dqs,
		Dqs_n => dqs_n,
		tdqs_n => tdqs_n,
		Odt   => odt);

end;

library micron;

configuration ulx4mld_graphics_structure_md of testbench is
	for ulx4mld_graphics
		for all : ulx4m_ld
			use entity work.ulx4m_ld(structure);
		end for;
		for all: ddr3_model
			use entity micron.ddr3
			port map (
				rst_n => rst_n,
				Ck    => ck,
				Ck_n  => ck_n,
				Cke   => cke,
				Cs_n  => cs_n,
				Ras_n => ras_n,
				Cas_n => cas_n,
				We_n  => we_n,
				Ba    => ba,
				Addr  => addr,
				Dm_tdqs  => dm,
				Dq    => dq,
				Dqs   => dqs,
				Dqs_n => dqs_n,
				tdqs_n => tdqs_n,
				Odt   => odt);
		end for;
	end for;
end;

library micron;

configuration ulx4mld_graphics_md of testbench is
	for ulx4mld_graphics
		for all : ulx4m_ld
			use entity work.ulx4m_ld(graphics);
		end for;
		for all: ddr3_model
			use entity micron.ddr3
			port map (
				rst_n => rst_n,
				Ck    => ck,
				Ck_n  => ck_n,
				Cke   => cke,
				Cs_n  => cs_n,
				Ras_n => ras_n,
				Cas_n => cas_n,
				We_n  => we_n,
				Ba    => ba,
				Addr  => addr,
				Dm_tdqs  => dm,
				Dq    => dq,
				Dqs   => dqs,
				Dqs_n => dqs_n,
				tdqs_n => tdqs_n,
				Odt   => odt);
		end for;
	end for;
end;
