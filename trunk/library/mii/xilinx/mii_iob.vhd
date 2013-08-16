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

library unisim;
use unisim.vcomponents.all;

architecture def of mii_iob is
begin

	--------
	-- rx --
	--------

	rxdv_e : fdrse
	port map (
		s  => '0',
		r  => '0',
		c  => mii_rxc,
		ce => '1',
		d  => iob_rxdv,
		q  => mii_rxdv);

	rxd_e : for i in mii_rxd'range generate
		ffd_e : fdrse
		port map (
			s  => '0',
			r  => '0',
			c  => mii_rxc,
			ce => '1',
			d  => iob_rxd(i),
			q  => mii_rxd(i));
	end generate;

	--------
	-- tx --
	--------

	txen_e : fdrse
	port map (
		s  => '0',
		r  => '0',
		c  => mii_txc,
		ce => '1',
		d  => mii_txen,
		q  => iob_txen);

	txd_e : for i in mii_txd'range generate
		ffd_e : fdrse
		port map (
			s  => '0',
			r  => '0',
			c  => mii_txc,
			ce => '1',
			d  => mii_txd(i),
			q  => iob_txd(i));
	end generate;

	gtx_clk_i : oddr
	port map (
		r => '0',
		s => '0',
		c => mii_txc,
		ce => '1',
		d1 => '0',
		d2 => '1',
		q => iob_gtxclk);

end;
