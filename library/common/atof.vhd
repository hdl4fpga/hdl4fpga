library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity frac2bcd is
	port (
		frac : in  std_logic_vector;
		bcd  : out std_logic_vector);
end;

architecture def of frac2bcd is
begin
	process (frac)
		variable aux1 : unsigned(0 to 4+frac'length-1);
		variable aux2 : unsigned(4*((bcd'length+4-1)/4)-1 downto 0);
	begin
		aux1(4 to aux1'right) := unsigned(frac);
		for i in 0 to aux2'length/4-1 loop
			aux2 := aux2 sll 4;
			aux1(0 to 4-1) := (others => '0');
			aux1 := (aux1 sll 3) + (aux1 sll 1);
			aux2(4-1 downto 0) := aux1(0 to 4-1);
			bcd  <= std_logic_vector(aux2(bcd'length-1 downto 0));
		end loop;
	end process;
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity int2bcd is
	port (
		int  : in  std_logic_vector;
		bcd  : out std_logic_vector);
end;

architecture def of int2bcd is
begin
	process(int)
		variable aux1 : unsigned(0 to int'length-1);
		variable aux2 : unsigned(4*((bcd'length+4-1)/4)-1 downto 0) := (others => '0');
	begin
		aux1 := unsigned(int);
		aux2 := (others => '0');
		for i in 0 to int'length-1 loop
			for j in 0 to aux2'length/4-1 loop
				if aux2(3-1 downto 0) >= "101" then
					aux2(4-1 downto 0) := aux2(4-1 downto 0) + "0011";
				end if;
				aux2 := aux2 rol 4;
			end loop;
			aux2 := aux2 sll 1;
			aux2(0) := aux1(0);
			aux1 := aux1 sll 1;
		end loop;
		bcd <= std_logic_vector(aux2(bcd'length-1 downto 0));
	end process;
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;

entity fix2bcd is
	generic (
		frac : natural;
		spce : boolean := true);
	port (
		fix      : in  std_logic_vector;
		bcd_sign : out std_logic_vector(4-1 downto 0);
		bcd_int  : out std_logic_vector;
		bcd_frac : out std_logic_vector);
end;

architecture def of fix2bcd is
	signal auxf : std_logic_vector(fix'length-1 downto 0);
	signal auxi : std_logic_vector(bcd_int'length-1 downto 0);
	signal int  : std_logic_vector(bcd_int'length-1 downto 0);
begin
	auxf <= std_logic_vector(unsigned(not fix) + 1) when fix(fix'left)='1' else fix;
	int2bcd_e : entity hdl4fpga.int2bcd
	port map (
		int => auxf(fix'length-2 downto frac),
		bcd => auxi);

	frac2bcd_e : entity hdl4fpga.frac2bcd
	port map (
		frac => auxf(frac-1 downto 0),
		bcd  => bcd_frac);

	process (auxi)
		variable aux : unsigned(auxi'range);
	begin
		bcd_int  <= std_logic_vector(auxi);
		if spce then
			aux := unsigned(auxi);
			for i in 1 to auxi'length/4-1 loop
				aux := aux rol 4;
				if aux(4-1 downto 0)="0000" then
					aux(4-1 downto 0) := "1111";
				else
					aux := aux rol (aux'length-4*i);
					exit;
				end if;
			end loop;
			aux := aux rol 4;

			bcd_int  <= std_logic_vector(aux);
		end if;
	end process;

	bcd_sign <= "1100" when fix(fix'left)='1' else "1011";
end;
