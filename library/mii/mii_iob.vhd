library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity mii_iob is
	generic (
		xd_len : natural);
	port (
		mii_rxc  : in  std_logic := '-';
		mii_rxdv : out std_logic;
		mii_rxd  : out std_logic_vector(0 to xd_len-1);

		iob_rxdv : in  std_logic := '-';
		iob_rxd  : in  std_logic_vector(0 to xd_len-1) := (others => '-');

		mii_txc  : in  std_logic;
		mii_txen : in std_logic;
		mii_txd  : in std_logic_vector(0 to xd_len-1);

		iob_gtxclk : out std_logic;
		iob_txen : out std_logic;
		iob_txd  : out std_logic_vector(0 to xd_len-1));
end;

architecture def of mii_iob is
begin

	--------
	-- rx --
	--------

	rxdv_e : entity hdl4fpga.ff
	port map (
		clk => mii_rxc,
		d => iob_rxdv,
		q => mii_rxdv);

	rxd_e : for i in mii_rxd'range generate
		ffd_e : entity hdl4fpga.ff
		port map (
			clk => mii_rxc,
			d => iob_rxd(i),
			q => mii_rxd(i));
	end generate;

	--------
	-- tx --
	--------

	txen_e : entity hdl4fpga.ff
	port map (
		clk  => mii_txc,
		d => mii_txen,
		q => iob_txen);

	txd_e : for i in mii_txd'range generate
		ffd_e : entity hdl4fpga.ff
		port map (
			clk => mii_txc,
			d => mii_txd(i),
			q => iob_txd(i));
	end generate;

	gtx_clk_i : entity hdl4fpga.ddro
	port map (
		clk => mii_txc,
		dr => '0',
		df => '1',
		q => iob_gtxclk);
end;
