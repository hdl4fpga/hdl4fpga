library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity mii_sio is
	port (
		mii_txc   : in  std_logic;
		sio_pfix  : in  std_logic_vector;
		mii_rxdv  : in  std_logic;
		mii_rxd   : in  std_logic_vector;
		mii_txen  : out std_logic;
		mii_txd   : out std_logic_vector);
end;

architecture beh of mii_sio is
	signal mux_txdv : std_logic;
	signal mux_txen : std_logic;
	signal mux_txd  : std_logic_vector(mii_txd'range);
	signal lat_txen : std_logic;
	signal lat_txd  : std_logic_vector(mii_txd'range);
begin

	assert mii_txd'length=mii_rxd'length
	report "mii_txd not equal mii_rxd"
	severity FAILURE;

	process (mii_rxdv, lat_txen, mii_txc)
		variable txen : std_logic := '0';
	begin
		if rising_edge(mii_txc) then
			if mii_rxdv='1' then
				txen := '1';
			elsif txen='1' then
				if lat_txen='1' then
					txen := '0';
				end if;
			end if;
		end if;
		mux_txdv <= mii_rxdv or txen;
	end process;


	miimux_e : entity hdl4fpga.mii_mux
	port map (
		mux_data  => sio_pfix,
		mii_txc   => mii_txc,
		mii_txdv  => mux_txdv,
		mii_txen  => mux_txen,
		mii_txd   => mux_txd);

	miilat_e : entity hdl4fpga.mii_latency
	generic map (
		latency => sio_pfix'length)
	port map (
		mii_txc  => mii_txc,
		lat_txen => mii_rxdv,
		lat_txd  => mii_rxd,
		mii_txen => lat_txen,
		mii_txd  => lat_txd);

	mii_txd  <= wirebus(mux_txd & lat_txd, mux_txen & lat_txen);
	mii_txen <= mux_txen or lat_txen;
end;
