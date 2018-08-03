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
	generic (
		registered_output : boolean := false);
	port (
		clk    : in  std_logic := '0';

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

	signal value_d : unsigned(bcd_di'length-1 downto 0);
	signal value_q : unsigned(bcd_di'length-1 downto 0);

	signal shtio_d : unsigned(bin_di'length-1 downto 0);
	signal shtio_q : unsigned(bin_di'length-1 downto 0);

begin

	reg_p : process (clk)
	begin
		if rising_edge(clk) then
			value_q <= value_d;
			shtio_q <= shtio_d;
		end if;
	end process;

	comb_p : process (bin_dv, bin_di, bcd_dv, bcd_di, value_q, shtio_q)
		variable tmp_value : unsigned(bcd_di'length-1 downto 0);
		variable tmp_shtio : unsigned(bin_di'length-1 downto 0);
	begin
		if bcd_dv='1' then
			tmp_value := unsigned(bcd_di);
		else
			tmp_value := value_q;
		end if;
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

		value_d <= tmp_value;
		shtio_d <= tmp_shtio;
	end process;
	bcd_do <= std_logic_vector(value_q) when registered else std_logic_vector(value_d);

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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity ftod is
	generic (
		fracbin_size : natural;
		fracbcd_size : natural);
	port (
		clk  : in  std_logic;
		fix  : in  std_logic_vector;
		bcd  : out std_logic_vector);
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture struct of ftod is
	constant intbcd_size : natural := integer(ceil(log(2.0**(fix'length-fracbin_size), 10.0)));

	signal int_do : std_logic_vector(0 to 4*intbcd_size-1);
begin

	integer_e : block
		signal bcd_do : std_logic_vector(int_do'range);
	begin
		btod_e : entity hdl4fpga.btod
		port map (
			clk    => clk,

			bin_dv => '1',
			bin_di => fix(fix'left to fix'right-fracbin_size),

			bcd_dv => '1',
			bcd_di => (bcd_do'range => '0'),
			bcd_do => bcd_do);

		latency_e : entity hdl4fpga.align
		generic map (
			n => bcd_do'length,
			d => (bcd_do'range => 1))
		port map (
			clk => clk,
			di  => bcd_do,
			do  => int_do);
	end block;

	fraction_b: block
		constant bcd_size : natural := integer(ceil(log(2.0**fracbin_size, 10.0)));

		signal bcd_do : std_logic_vector(0 to 4*bcd_size-1);
		signal bcd_di : std_logic_vector(0 to 4*(bcd_size+fracbcd_size)-1);
		signal fix_do : std_logic_vector(bcd_di'range);
	begin
		btod_e : entity hdl4fpga.btod
		port map (
			clk    => clk,

			bin_dv => '1',
			bin_di => fix(fix'length-fracbin_size to fix'right),

			bcd_dv => '1',
			bcd_di => (bcd_do'range => '0'),
			bcd_do => bcd_do);

		bcd_di <= bcd_do & (0 to 4*fracbcd_size-1 => '0');
		dtof_e : entity hdl4fpga.dtof
		generic map (
			fix_point => fracbin_size)
		port map (
			clk    => clk,

			bcd_di => bcd_di,
			bcd_dv => '1',
			fix_do => fix_do);

		bcd <= int_do & fix_do(bcd_do'length to fix_do'right);
	end block;

end;
