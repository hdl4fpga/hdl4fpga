library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_gauge is
	generic (
		frac  : natural;
		dec   : natural);
	port (
		order : in  std_logic_vector(0 to 2-1);
		mult  : in  std_logic_vector(0 to 2-1);
		value : in  std_logic_vector;
		fmtds : out std_logic_vector);
end;

architecture def of scopeio_gauge is
	signal bcd_sign : std_logic_vector(0 to 4-1);
	signal bcd_frac : std_logic_vector(0 to 4*dec-1);
	signal bcd_int  : std_logic_vector(0 to fmtds'length-4*(dec+1)-1);
	signal fix      : std_logic_vector(signed_num_bits(5*2**(value'length-1))-1 downto 0);
begin

	scale_p : process (mult , value)
	begin
		case mult  is
		when "00"   =>
			fix <= std_logic_vector(shift_right(resize(signed(value), fix'length), 1));
		when "10"   =>
			fix <= std_logic_vector(shift_left(resize(signed(value),  fix'length), 1));
		when others =>
			fix <= std_logic_vector(resize(signed(value), fix'length));
		end case;
	end process;

	fix2bcd : entity hdl4fpga.fix2bcd 
	generic map (
		frac => frac,
		spce => false)
	port map (
		fix      => fix,
		bcd_sign => bcd_sign,
		bcd_frac => bcd_frac,
		bcd_int  => bcd_int);

	fmt_p : process (order, bcd_int, bcd_frac, bcd_sign)
		variable auxs  : unsigned(0 to fmtds'length-1);
		variable auxd1 : unsigned(0 to 4-1);
		variable auxd2 : unsigned(0 to 4-1);
	begin
		fmtds <= (fmtds'range => '-');

		auxd1 := (others => '-');
		auxd2 := (others => '-');
		auxs  := (others => '0');
		auxs(0 to auxs'length-auxd1'length-1) := unsigned(std_logic_vector'(bcd_int & bcd_frac));
		fmtds <= std_logic_vector(auxs);
		for i in 0 to auxs'length/auxd1'length-1 loop
			if i<to_integer(unsigned(order)) then
				auxs := auxs rol auxd1'length;
			elsif i=to_integer(unsigned(order)) then
				auxd1 := auxs(auxd1'range);
				auxs(auxd1'range) := unsigned'("1110");
			else
				auxs  := auxs rol auxd1'length;
				auxd2 := auxs(auxd1'range);
				auxs(auxd1'range) := auxd1;
				auxd1 := auxd2;
			end if;
		end loop;
		auxs  := auxs rol auxd1'length;
		for i in 0 to auxs'length/auxd1'length-1 loop
			if auxs(auxd1'range)=(auxd1'range => '0') then
				auxs(auxd1'range) := unsigned'("1111");
			elsif auxs(auxd1'range)= unsigned'("1110") then
				auxs := auxs ror auxd1'length;
				auxs(auxd1'range) := unsigned'("0000");
				auxs := auxs ror auxd1'length;
				auxs(auxd1'range) := unsigned(bcd_sign);
				if i > 2 then
					auxs := auxs ror (auxd1'length*(i-2));
				end if;
				exit;
			else
				auxs := auxs ror auxd1'length;
				auxs(auxd1'range) := unsigned(bcd_sign);
				if i > 1 then
					auxs := auxs ror (auxd1'length*(i-1));
				end if;
				exit;
			end if;
			auxs := auxs rol auxd1'length;
		end loop;
		fmtds <= std_logic_vector(auxs);

	end process;

end;
