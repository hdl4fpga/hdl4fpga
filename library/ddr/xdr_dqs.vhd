library ieee;
use ieee.std_logic_1164.all;

entity xdr_io_dqs is
	generic (
		data_phases : natural := 2;
		data_edges  : natural := 2);
	port (
		sys_dclk : in  std_logic;
		sys_dqso : in  std_logic;
		sys_zclk : in  std_logic;
		sys_dqsz : in  std_logic;
		xdr_dqsz : out std_logic;
		xdr_dqso : out std_logic);
end;

architecture std of xdr_io_dqs is
begin

	oxdrt_i : entity hdl4fpga.oddrt
	port map (
		clk => sys_zclk,
		d   => sys_dqsz,
		q   => xdr_dqsz);

	oxdr_i : entity hdl4fpga.oddr
	port map (
		clk => sys_dclk,
		d   => df,
		q   => xdr_dqso);

end;
