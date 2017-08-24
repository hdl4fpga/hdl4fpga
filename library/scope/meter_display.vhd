library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity meter_display is
	generic (
		frac  : natural;
		dec   : natural;
		int   : natural);
	port (
		scale : in  std_logic_vector;
		value : in  std_logic_vector;
		fmtds : out std_logic_vector);
end;

architecture def of meter_display is
	signal bcd_sign : std_logic_vector(0 to 4-1);
	signal bcd_frac : std_logic_vector(0 to 4*dec-1);
	signal bcd_int  : std_logic_vector(0 to 4*int-1);
	signal fix      : std_logic_vector(signed_num_bits(5*2**(value'length-1))-1 downto 0);
	constant pp : integer := -1;
begin

	fix2bcd : entity hdl4fpga.fix2bcd 
	generic map (
		frac => frac,
		spce => false)
	port map (
		fix      => fix,
		bcd_sign => bcd_sign,
		bcd_frac => bcd_frac,
		bcd_int  => bcd_int);

	scale_p : process (scale, value)
		variable aux : signed(fix'range);
	begin
		aux := resize(signed(value), aux'length);
		for i in 0 to 2**scale'length-1 loop
			if i=to_integer(unsigned(scale)) then
				case i mod 3 is
				when 1 => 
					aux := aux sll 1;
				when 2 =>
					aux := (aux sll 2) + (aux sll 0);
				when others => 
				end case;
			end if;
		end loop;
		fix <= std_logic_vector(aux);
	end process;

	fmt_p : process (scale, bcd_int, bcd_frac, bcd_sign)
		variable auxi : unsigned(0 to bcd_int'length-1);
		variable auxf : unsigned(0 to bcd_frac'length-1);
		variable auxs : unsigned(fmtds'length-1 downto 0);
		constant i : natural := 2;
	begin
		fmtds <= (fmtds'range => '-');
		for i in 0 to 2**scale'length-1 loop
			auxs := (others => '0');
			auxi := resize(unsigned(bcd_int), auxi'length);
			auxf := unsigned(bcd_frac);

			for j in 0 to int+dec loop
				auxs := auxs rol 4;
				if j=int+pp then
					auxs(4-1 downto 0) := unsigned'("1110");
				else
					if (j < int-pp  and pp < 0) or (j < int and pp >=0) then
						auxs(4-1 downto 0) := auxi(0 to 4-1);
						auxi := auxi rol 4;
					else 
						auxs(4-1 downto 0) := auxf(0 to 4-1);
						auxf := auxf rol 4;
					end if;
				end if;
			end loop;

			for j in 1 to int+pp loop
				if j /= int+pp then
					auxs := auxs rol 4;
					if auxs(4-1 downto 0)="0000" then
						auxs(4-1 downto 0) := "1111";
					else
--						auxs := auxs ror 4;
--						auxs(4-1 downto 0) := unsigned(bcd_sign);
--						auxs := auxs rol (4*(int+dec+1-(j-1)));
						exit;
					end if;
				else
					auxs(4-1 downto 0) := unsigned(bcd_sign);
					auxs := auxs rol (4*(int+dec+1+pp-(j-1)));
				end if;
			end loop;
------			auxs := auxs rol 4*((auxs'length-1-int)-((i mod 9)/3));
			if i=to_integer(unsigned(scale)) then
				fmtds <= std_logic_vector(auxs);
			end if;
		end loop;
	end process;

end;
