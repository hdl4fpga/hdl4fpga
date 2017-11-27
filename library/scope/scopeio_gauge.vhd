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
		scale : in  std_logic_vector(0 to 4-1);
		value : in  std_logic_vector;
		fmtds : out std_logic_vector);
end;

architecture def of scopeio_gauge is
	signal isign : std_logic_vector(0 to 4-1);
	signal ifrac : std_logic_vector(0 to 4*dec-1);
	signal iint  : std_logic_vector(0 to fmtds'length-4*(dec+1)-1);
	signal bcd_sign : std_logic_vector(0 to 4-1);
	signal bcd_frac : std_logic_vector(0 to 4*dec-1);
	signal bcd_int  : std_logic_vector(0 to fmtds'length-4*(dec+1)-1);
	signal fix      : std_logic_vector(signed_num_bits(5*2**(value'length-1))-1 downto 0);
	signal order    : std_logic_vector(0 to 2-1);
	signal mult     : std_logic_vector(0 to 2-1);
begin

	order <= scale(0 to 2-1);
	mult <= scale(2 to 4-1);

	process (value, mult)
		variable aux : signed(fix'range);
	begin
		aux := resize(signed(value), aux'length);
		aux := aux + shift_left(aux, 2);
		case mult is
		when "00" =>
			fix <= std_logic_vector(resize(signed(value), aux'length));
		when "01" =>
			fix <= std_logic_vector(shift_right(aux,1));
		when "10" =>
			fix <= std_logic_vector(aux);
		when others =>
			fix <= (others => '-');
		end case;
	end process;

	fix2bcd : entity hdl4fpga.fix2bcd 
	generic map (
		frac => frac,
		spce => false)
	port map (
		fix      => fix,
		bcd_sign => isign,
		bcd_frac => ifrac,
		bcd_int  => iint);
		
			bcd_sign <= isign;
			bcd_frac <= ifrac;
			bcd_int  <= iint;
	
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
			if (i-1)<to_integer(unsigned(order)) then
				auxs := auxs rol auxd1'length;
			elsif (i-1)=to_integer(unsigned(order)) then
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
		auxs := auxs ror auxd1'length;
		if auxs(auxd1'range)=unsigned'("1110") then
			auxs(auxd1'range) := unsigned'("1111");
		end if;
		auxs := auxs rol auxd1'length;

		fmtds <= std_logic_vector(auxs);

	end process;

end;
