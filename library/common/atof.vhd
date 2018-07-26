library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dtof is
	generic (
		fix_point : natural;
		align_dot : boolean := FALSE);
	port (
		clk     : in  std_logic;
		bcd_di  : in  std_logic_vector;
		bcd_dv  : in  std_logic;
--		dot_pos : out std_logic_vector;
		fix_do  : out std_logic_vector);
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture def of dtof is

	procedure dbdbb(
		variable shtio : inout std_logic;
		variable digit : inout unsigned) is
		variable save  : std_logic;
	begin
		save     := digit(0);
		digit(0) := shtio;
		shtio    := save;
		digit    := digit ror 1;
		if digit >= "0101" then
			digit := digit - "0011";
		end if;
	end;

begin
	process (clk)
		variable value : unsigned(bcd_di'length-1 downto 0);
		variable shtio : unsigned(fix_point-1 downto 0);
		variable point : unsigned(0 to unsigned_num_bits(fix_do'length/4-1)-1);
	begin
		if rising_edge(clk) then
			value := unsigned(bcd_di);
			if bcd_dv='1' then
				shtio := (others => '0');
				point := (others => '0');
			end if;
			for k in 0 to fix_point-1 loop

				if bcd_dv='1' then
					if align_dot then
						value := value rol 4;
						while value(4-1 downto 0) = (4-1 downto 0 => '0') loop
							value := value rol 4;
							point := point + 1;
						end loop;
						value := value ror 4;
					end if;
				end if;

				for i in 0 to value'length/4-1 loop
					value := value rol 4;
					dbdbb (shtio(0), value(4-1 downto 0));
				end loop;

				if align_dot then
					if bcd_dv='1' then
						value := value rol 4;
						if value(4-1 downto 0) = (4-1 downto 0 => '0') then
							dbdbb (shtio(0), value(4-1 downto 0));
							point := point + 1;
						else
							value := value ror 4;
						end if;
					end if;
				end if;

				shtio := shtio rol 1;
			end loop;
	--		dot_pos <= std_logic_vector(point);
			fix_do  <= std_logic_vector(value);
		end if;
	end process;
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity btod is
	port (
		clk    : in  std_logic;

		bin_dv : in  std_logic;
		bin_di : in  std_logic_vector;

		bcd_dv : in  std_logic;
		bcd_di : in  std_logic_vector;
		bcd_do : out std_logic_vector);
end;

architecture def of btod is

	procedure dbdbb(
		variable shtio : inout std_logic;
		variable digit : inout unsigned) is
		variable save  : std_logic;
	begin
		if digit >= "0101" then
			digit := digit + "0011";
		end if;
		digit    := digit rol 1;
		save     := digit(0);
		digit(0) := shtio;
		shtio    := save;
	end;

begin

	p : process(clk)
		variable value : unsigned(bcd_di'length-1 downto 0);
		variable shtio : unsigned(bin_di'length-1 downto 0);
	begin
		if rising_edge(clk) then
			if bcd_dv='1' then
				value := unsigned(bcd_di);
			end if;
			if bin_dv='1' then
				shtio := unsigned(bin_di);
			end if;

			for k in shtio'range loop
				shtio := shtio rol 1;
				for i in 0 to value'length/4-1 loop
					dbdbb(shtio(0), value(4-1 downto 0));
					value := value ror 4;
				end loop;
			end loop;

			bcd_do <= std_logic_vector(value);
		end if;
	end process;

end;
