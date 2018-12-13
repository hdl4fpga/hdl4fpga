library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity align is
	generic (
		space : std_logic_vector(4-1 downto 0) := x"f");
	port (
		clk   : in  std_logic := '-';
		rst   : in  std_logic := '1';
		msb   : in  std_logic;
		left  : in  std_logic := '1';
		code  : in  std_logic_vector;
		field : out std_logic_vector);
end;
		
architecture def of align is

	signal aligned : std_logic_vector(field'length-1 downto 0);

begin

	process (rst, msb, left, code, clk)
		variable cod : unsigned(code'length-1 downto 0);
		variable fld : unsigned(align'length-1 downto 0);
	begin

		cod := unsigned(code);
		if rst='1' then
			fld := (others => '-');
			for i in 0 to fld'length/space'length-1 loop
				fld(space'range) := cod;
				fld := fld rol 4;
			end loop;
		else
			fld := unsigned(aligned);
		end if;

		if msb='0' then
			-- left sided
			for i in 0 to cod'length/space'length-1 loop
				if cod(space'range)/=space then
					fld(cod'length-1 downto 0) := cod(space'range);
					fld := fld ror space'length;
				end if;
				cod := cod ror space'length;
			end loop;
		else
			-- right sided
			for i in 0 to cod'length/space'length-1 loop
				cod := cod ror space'length;
				if cod(space'range)/=space then
					fld := fld rol space'length;
					fld(cod'length-1 downto 0) := cod(space'range);
				end if;
			end loop;
		end if;

		if rising_edge(clk) then
			aligned <= std_logic_vector(fld);
		end if;

		if left='1' then
			if msb='1' then
				for i in 0 to field'length/space'length-1 loop
					fld := fld rol space'length;
					if unsigned(fld(space'range))=space then
						fld := fld ror space'length;
						exit;
					end if;
				end loop;
			end if;
		elsif msb='0' then
			for i in 0 to field'length/space'length-1 loop
				fld := fld ror space'length;
				if unsigned(fld(space'range))=space then
					exit;
				end if;
			end loop;
		end if;

		field <= std_logic_vector(fld);

	end process;

end;
