library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dtof is
	port (
		clk    : in  std_logic;
		bcd_dv : in  std_logic := '1';
		bcd_di : in  std_logic_vector;
		bcd_do : out std_logic_vector);
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

	signal value_d : unsigned(bcd_di'length-1 downto 0);
	signal value_q : unsigned(bcd_di'length-1 downto 0);

	signal shtio_d : unsigned(bin_di'length-1 downto 0);
	signal shtio_q : unsigned(bin_di'length-1 downto 0);

begin

	reg_p : process (clk)
	begin
		if rising_edge(clk) then
			shtio_q <= shtio_d;
		end if;
	end process;

	process (bcd_di, bcd_dv, shtio_q)
		variable tmp_value : unsigned(bcd_di'length-1 downto 0);
		variable tmp_shtio : unsigned(fix_point-1 downto 0);
	begin
			tmp_value := unsigned(bcd_di);
			if bcd_dv='1' then
				tmp_shtio := (others => '0');
			else
				tmp_shtio := shtio_q;
			end if;
	
			for k in 0 to fix_point-1 loop

				for i in 0 to value'length/4-1 loop
					tmp_value := tmp_value rol 4;
					dbdbb (tmp_shtio(0), tmp_value(4-1 downto 0));
				end loop;

				tmp_shtio := tmp_shtio rol 1;
			end loop;
			shtio_d <= tmp_shtio;
			bcd_do  <= std_logic_vector(value);
		end if;
	end process;

--	process (clk)
--		variable value : unsigned(bcd_di'length-1 downto 0);
--		variable shtio : unsigned(fix_point-1 downto 0);
--		variable point : unsigned(0 to unsigned_num_bits(fix_do'length/4-1)-1);
--	begin
--		if rising_edge(clk) then
--			value := unsigned(bcd_di);
--			if bcd_dv='1' then
--				shtio := (others => '0');
--				point := (others => '0');
--			end if;
--			for k in 0 to fix_point-1 loop
--
--				for i in 0 to value'length/4-1 loop
--					value := value rol 4;
--					dbdbb (shtio(0), value(4-1 downto 0));
--				end loop;
--
--				shtio := shtio rol 1;
--			end loop;
--			fix_do  <= std_logic_vector(value);
--		end if;
--	end process;
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity btod is
	port (
		clk    : in  std_logic := '0';

		bin_dv : in  std_logic;
		bin_di : in  std_logic_vector;

		bcd_dv : in  std_logic := '1';
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


	signal shtio_d : unsigned(bin_di'length-1 downto 0);
	signal shtio_q : unsigned(bin_di'length-1 downto 0);

begin

	reg_p : process (clk)
	begin
		if rising_edge(clk) then
			shtio_q <= shtio_d;
		end if;
	end process;

	comb_p : process (bin_dv, bin_di, bcd_dv, bcd_di, shtio_q)
		variable tmp_value : unsigned(bcd_di'length-1 downto 0);
		variable tmp_shtio : unsigned(bin_di'length-1 downto 0);
	begin
		tmp_value := unsigned(bcd_di);

		if bin_dv='1' then
			tmp_shtio := unsigned(bin_di);
		else
			tmp_shtio := shtio_q;
		end if;

		for k in tmp_shtio'range loop
			tmp_shtio := tmp_shtio rol 1;
			for i in 0 to tmp_value'length/4-1 loop
				dbdbb(tmp_shtio(0), tmp_value(4-1 downto 0));
				tmp_value := tmp_value ror 4;
			end loop;
		end loop;

		bcd_do  <= tmp_value;
		shtio_d <= tmp_shtio;
	end process;

--	p : process(clk)
--		variable value : unsigned(bcd_di'length-1 downto 0);
--		variable shtio : unsigned(bin_di'length-1 downto 0);
--	begin
--		if rising_edge(clk) then
--			if bcd_dv='1' then
--				value := unsigned(bcd_di);
--			end if;
--			if bin_dv='1' then
--				shtio := unsigned(bin_di);
--			end if;
--
--			for k in shtio'range loop
--				shtio := shtio rol 1;
--				for i in 0 to value'length/4-1 loop
--					dbdbb(shtio(0), value(4-1 downto 0));
--					value := value ror 4;
--				end loop;
--			end loop;
--
--			bcd_do <= std_logic_vector(value);
--		end if;
--	end process;

end;

