library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use hdl4fpga.std.all;

entity mii_iob is
	port (
		mii_rxc  : in  std_logic := '-';
		mii_rxdv : out std_logic;
		mii_rxd  : out nibble;

		iob_rxdv : in  std_logic := '-';
		iob_rxd  : in  nibble := (others => '-');

		mii_txc  : in  std_logic;
		mii_txen : in std_logic;
		mii_txd  : in nibble;

		iob_txen : out std_logic;
		iob_txd  : out nibble);
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

end;
