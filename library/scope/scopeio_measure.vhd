library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_measure is
	generic (
		frac  : natural;
	port (
		clk   : in  std_logic;
		measr : in  std_logic_vector;
		mgntd : in  std_logic_vector(0 to 2-1);
		mult  : in  std_logic_vector(0 to 2-1);
		bcd   : out std_logic_vector);
end;

architecture def of scopeio_measure is
	constant x1  : std_logic_vector := "00";    -- x 2.0
	constant x2  : std_logic_vector := "01";    -- x 2.0
	constant x2h : std_logic_vector := "10";    -- x 2.5 
	constant x5  : std_logic_vector := "11";    -- x 5.0

	signal value : std_logic_vector(0 to measr'length-1+3);

begin

	mult_p : process (clk)
		variable temp : unsigned(value'range);
	begin
		if rising_edge(clk) then
			case mgntd is
			when "00" =>
				temp := resize(unsigned(measr), temp'length);
			when "01" =>
				temp := resize(unsigned(measr), temp'length) sll 1;;
			when "10" =>
				temp := resize(unsigned(measr), temp'length);
				temp := (temp sll 1) + (temp srl 1);
			when "11" =>
				temp := resize(unsigned(measr), temp'length);
				temp := (temp sll 2) + temp;
			when others =>
				temp <= (others => '-');
			end case;
			value <= std_logic_vector(temp);
		end if;
	end process;

	ftod_e : entity hdl4fpga.ftod
	generic map (
		fracbin_size => frac,
		fracbcd_size => 4);
	port (
		clk  => clk,
		bin  => value,
		bcd  => );

	latency_e : entity hdl4fpga.align
	generic map (
		n => mgntd'length,
		d => (mgntd'range => 3))
	port map (
		clk => clk,
		di  => mgntd,
		do  => );
end;
