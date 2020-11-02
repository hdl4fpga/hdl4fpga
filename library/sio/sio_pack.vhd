library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity sio_pack is
	port (
		sio_clk   : in  std_logic;
		sio_frm   : in  std_logic;
		rid       : in  std_logic_vector(8-1 downto 0);
		data      : in  std_logic_vector
		si_irdy   : in  std_logic;
		si_trdy   : out std_logic;
		si_data   : out std_logic_vector;
		so_irdy   : in  std_logic;
		so_trdy   : out std_logic;
		so_data   : out std_logic_vector;
end;

architecture beh of sio_pack is
begin

	assert s1_data'length=so_data'length
	report "si_data not equal so_data"
	severity FAILURE;

	port (
		desser_clk : in  std_logic;

		des_frm    => sio_frm,
		des_irdy   => so_trdy,
		des_trdy   : out std_logic;
		des_data   => data,

		ser_irdy   : out std_logic;
		ser_trdy   : in  std_logic := '1';
		ser_data   : out std_logic_vector);
	end;

	lat_e : entity hdl4fpga.sio_latency
	generic map (
		latency => sio_pfix'length)
	port map (
		sio_clk => sio_clk,
		sio_frm => sio_frm,
		si_irdy => si_irdy,
		si_trdy => si
		si_data => si_data
		so_irdy => so_irdy,
		so_trdy => so_trdy,
		so_data => lat_data);

	mii_txd  <= wirebus(mux_txd & lat_txd, mux_txen & lat_txen);
	mii_txen <= mux_txen or lat_txen;
end;
