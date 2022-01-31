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

use std.textio.all;

library hdl4fpga;
use hdl4fpga.std.all;

library ieee;
use ieee.std_logic_textio.all;

architecture arty_graphics of testbench is
	constant ddr_std  : positive := 1;

	constant ddr_period : time := 6 ns;
	constant bank_bits  : natural := 3;
	constant addr_bits  : natural := 14;
	constant cols_bits  : natural := 10;
	constant data_bytes : natural := 2;
	constant byte_bits  : natural := 8;
	constant timer_dll  : natural := 9;
	constant timer_200u : natural := 9;
	constant data_bits  : natural := byte_bits*data_bytes;

	signal reset_n : std_logic;
	signal rst   : std_logic;
	signal led7  : std_logic;

	signal dq    : std_logic_vector (data_bytes*byte_bits-1 downto 0) := (others => 'Z');
	signal dqs_p : std_logic_vector (data_bytes-1 downto 0) := (others => 'Z');
	signal dqs_n : std_logic_vector (data_bytes-1 downto 0) := (others => 'Z');
	signal addr  : std_logic_vector (addr_bits-1 downto 0) := (others => '0');
	signal ba    : std_logic_vector (bank_bits-1 downto 0);
	signal ddr_clk_p : std_logic;
	signal ddr_clk_n : std_logic;
	signal cke   : std_logic;
	signal rst_n : std_logic;
	signal cs_n  : std_logic;
	signal ras_n : std_logic;
	signal cas_n : std_logic;
	signal we_n  : std_logic;
	signal dm    : std_logic_vector(data_bytes-1 downto 0);
	signal odt   : std_logic;
	signal scl   : std_logic;
	signal sda   : std_logic;
	signal tdqs_n : std_logic_vector(dqs_p'range);

	signal mii_refclk : std_logic;
	signal mii_req : std_logic := '0';
	signal mii_req1 : std_logic := '0';
	signal ping_req : std_logic := '0';
	signal mii_rxdv : std_logic;
	signal mii_rxd  : std_logic_vector(0 to 4-1);
	signal mii_txd  : std_logic_vector(0 to 4-1);
	signal mii_txc  : std_logic;
	signal mii_rxc  : std_logic;
	signal mii_txen : std_logic;

	component arty is
		generic (
			debug : boolean := false);
		port (
			btn : in std_logic_vector(4-1 downto 0) := (others => '-');
			sw  : in std_logic_vector(4-1 downto 0) := (others => '-');
			led : out std_logic_vector(8-1 downto 4);
			RGBled : out std_logic_vector(4*3-1 downto 0);

			gclk100   : in std_logic;
			eth_rstn  : out std_logic;
			eth_ref_clk : out std_logic;
			eth_mdio  : inout std_logic;
			eth_mdc   : out std_logic;
			eth_crs   : in std_logic;
			eth_col   : in std_logic;
			eth_tx_clk  : in std_logic;
			eth_tx_en : out std_logic;
			eth_txd   : out std_logic_vector(0 to 4-1);
			eth_rx_clk  : in std_logic;
			eth_rxerr : in std_logic;
			eth_rx_dv : in std_logic;
			eth_rxd   : in std_logic_vector(0 to 4-1);

			ddr3_reset : out std_logic := '0';
			ddr3_clk_p : out std_logic := '0';
			ddr3_clk_n : out std_logic := '0';
			ddr3_cke : out std_logic := '0';
			ddr3_cs  : out std_logic := '1';
			ddr3_ras : out std_logic := '1';
			ddr3_cas : out std_logic := '1';
			ddr3_we  : out std_logic := '1';
			ddr3_ba  : out std_logic_vector( 3-1 downto 0) := (others => '1');
			ddr3_a   : out std_logic_vector(14-1 downto 0) := (others => '1');
			ddr3_dm  : inout std_logic_vector(2-1 downto 0) := (others => 'Z');
			ddr3_dqs_p : inout std_logic_vector(2-1 downto 0) := (others => 'Z');
			ddr3_dqs_n : inout std_logic_vector(2-1 downto 0) := (others => 'Z');
			ddr3_dq  : inout std_logic_vector(16-1 downto 0) := (others => 'Z');
			ddr3_odt : out std_logic := '1');

	end component;

	component ddr3_model is
		port (
			rst_n : in std_logic;
			ck    : in std_logic;
			ck_n  : in std_logic;
			cke   : in std_logic;
			cs_n  : in std_logic;
			ras_n : in std_logic;
			cas_n : in std_logic;
			we_n  : in std_logic;
			ba    : in std_logic_vector(3-1 downto 0);
			addr  : in std_logic_vector(13-1 downto 0);
			dm_tdqs : in std_logic_vector(2-1 downto 0);
			dq    : inout std_logic_vector(16-1 downto 0);
			dqs   : inout std_logic_vector(2-1 downto 0);
			dqs_n : inout std_logic_vector(2-1 downto 0);
			tdqs_n : inout std_logic_vector(2-1 downto 0);
			odt   : in std_logic);
	end component;

	constant delay : time := 1 ns;

	signal xtal   : std_logic := '0';
	signal xtal_n : std_logic := '0';
	signal xtal_p : std_logic := '0';

begin

	rst   <= '1', '0' after 1.1 us;
	reset_n <= not rst;

	xtal   <= not xtal after 5 ns;
	xtal_p <= not xtal after 5 ns;
	xtal_n <=     xtal after 5 ns;

	mii_rxc <= mii_refclk;
	mii_txc <= mii_refclk;


	mii_req  <= '0', '1' after 21 us, '0' after 110 us; --, '0' after 244 us; --, '0' after 219 us, '1' after 220 us;
	mii_req1 <= '0', '1' after 161 us; --, '0' after 110 us; --, '0' after 244 us; --, '0' after 219 us, '1' after 220 us;
--	process
--	begin
--		wait for 206 us;
--		loop
--			if ping_req='1' then
--				ping_req <= '0' after 5.8 us;
--			else
--				ping_req <= '1' after 250 ns;
--			end if;
--			wait on ping_req;
--		end loop;
--	end process;

	htb_e : entity hdl4fpga.eth_tb
	generic map (
		debug =>false)
	port map (
		mii_data4 =>
		x"01007e" &
		x"18ff"   &
		x"0000000100020003000400050006000700080009000a000b000c000d000e000f" &
		x"0010001100120013001400150016001700180019001a001b001c001d001e001f" &
		x"0020002100220023002400250026002700280029002a002b002c002d002e002f" &
		x"0030003100320033003400350036003700380039003a003b003c003d003e003f" &
		x"0040004100420043004400450046004700480049004a004b004c004d004e004f" &
		x"0050005100520053005400550056005700580059005a005b005c005d005e005f" &
		x"0060006100620063006400650066006700680069006a006b006c006d006e006f" &
		x"0070007100720073007400750076007700780079007a007b007c007d007e007f" &
		x"18ff" &
		x"0080008100820083008400850086008700880089008a008b008c008d008e008f" &
		x"0090009100920093009400950096009700980099009a009b009c009d009e009f" &
		x"00a000a100a200a300a400a500a600a700a800a900aa00ab00ac00ad00ae00af" &
		x"00b000b100b200b300b400b500b600b700b800b900ba00bb00bc00bd00be00bf" &
		x"00c000c100c200c300c400c500c600c700c800c900ca00cb00cc00cd00ce00cf" &
		x"00e000e100e200e300e400e500e600e700e800e900ea00eb00ec00ed00ee00ef" &
		x"00d000d100d200d300d400d500d600d700d800d900da00db00dc00dd00de00df" &
		x"00f000f100f200f300f400f500f600f700f800f900fa00fb00fc00fd00fe00ff" &
		x"18ff" &
		x"0100010101020103010401050106010701080109010a010b010c010d010e010f" &
		x"0110011101120113011401150116011701180119011a011b011c011d011e011f" &
		x"0120012101220123012401250126012701280129012a012b012c012d012e012f" &
		x"0130013101320133013401350136013701380139013a013b013c013d013e013f" &
		x"0140014101420143014401450146014701480149014a014b014c014d014e014f" &
		x"0150015101520153015401550156015701580159015a015b015c015d015e015f" &
		x"0160016101620163016401650166016701680169016a016b016c016d016e016f" &
		x"0170017101720173017401750176017701780179017a017b017c017d017e017f" &
		x"18ff" &
		x"0180018101820183018401850186018701880189018a018b018c018d018e108f" &
		x"0190019101920193019401950196019701980199019a019b019c019d019e109f" &
		x"01a001a101a201a301a401a501a601a701a801a901aa01ab01ac01ad01ae10af" &
		x"01b001b101b201b301b401b501b601b701b801b901ba01bb01bc01bd01be10bf" &
		x"01c001c101c201c301c401c501c601c701c801c901ca01cb01cc01cd01ce10cf" &
		x"01e001e101e201e301e401e501e601e701e801e901ea01eb01ec01ed01ee10ef" &
		x"01d001d101d201d301d401d501d601d701d801d901da01db01dc01dd01de10df" &
		x"01f001f101f201f301f401f501f601f701f801f901fa01fb01fc01fd01fe10ff" &
		x"1702_0003ff_1603_0000_0000",
		mii_data5 => x"010000_1702_0003ff_1603_80000000",
--		mii_data4 => x"01007e_1702_000030_1603_8000_07d0",
		mii_frm1 => '0',
		mii_frm2 => '0', --ping_req,
		mii_frm3 => '0',
		mii_frm4 => mii_req,
		mii_frm5 => mii_req1,

		mii_txc  => mii_rxc,
		mii_txen => mii_rxdv,
		mii_txd  => mii_rxd);

	du_e : arty
	generic map (
		debug => true)
	port map (
		btn(0) => rst,
		btn(4-1 downto 1) => (1 to 3 => '-'),

		gclk100     => xtal,
		eth_rstn    => open,
		eth_ref_clk => mii_refclk,
		eth_mdc     => open,
		eth_crs     => '-',
		eth_col     => '-',
		eth_tx_clk  => mii_rxc,
		eth_tx_en   => mii_txen,
		eth_txd     => open,
		eth_rx_clk  => mii_rxc,
		eth_rxerr   => '-',
		eth_rx_dv   => mii_rxdv,
		eth_rxd     => mii_rxd,

		-- DDR RAM --

		ddr3_reset => rst_n,
		ddr3_clk_p => ddr_clk_p,
		ddr3_clk_n => ddr_clk_n,
		ddr3_cke   => cke,
		ddr3_cs    => cs_n,
		ddr3_ras   => ras_n,
		ddr3_cas   => cas_n,
		ddr3_we    => we_n,
		ddr3_ba    => ba,
		ddr3_a     => addr,
		ddr3_dqs_p => dqs_p,
		ddr3_dqs_n => dqs_n,
		ddr3_dq    => dq,
		ddr3_dm    => dm,
		ddr3_odt   => odt);


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
		Addr  => addr(13-1 downto 0),
		Dm_tdqs  => dm,
		Dq    => dq,
		Dqs   => dqs_p,
		Dqs_n => dqs_n,
		tdqs_n => tdqs_n,
		Odt   => odt);
end;

library micron;

configuration arty_structure_md of testbench is
	for arty_graphics
		for all: arty
			use entity work.arty(structure);
		end for;

		for all : ddr3_model
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
				Addr  => addr(13-1 downto 0),
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

configuration arty_graphics_md of testbench is
	for arty_graphics
		for all: arty
			use entity work.arty(graphics);
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
