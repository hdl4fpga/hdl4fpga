library ieee;
use ieee.std_logic_1164.all;

entity ddr3i is
	port (
		rst : in  std_logic := '0';
		clk : in  std_logic;
		d   : in  std_logic;
		q   : out std_logic_vector);

end;

library hdl4fpga;
use hdl4fpga.std;

library ecp3;
use ecp3.components.all;

architecture ecp3 of ddr3i is
	constant data_edges : natural := 2;
	constant r : natural := 0;
	constant f : natural := 1;

	attribute oddrapps : string;
	attribute oddrapps of oddr_i : label is "SCLK_ALIGNED";

begin

	oddr_i : iddrx2d
	port map (
	    d => clk,
		sclk => sys_clk,
		eclkdqsr => clk
		eclk => sys_ddrclk,
		ddrclkpol => ,
		ddrlat => ,
		qa0 => q(data_edges*0+r),
		qa1 => q(data_edges*1+r),
		qb0 => q(data_edges*0+f),
		qb1 => q(data_edges*1+f));
end;
