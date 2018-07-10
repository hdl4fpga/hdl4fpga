library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_mmap is
	port (
		in_clk       : in  std_logic;
		in_ena       : in  std_logic;
		in_data      : in  std_logic_vector);
end;

architecture beh of scopeio_mmap is
	constant rid_tgrlevel   : natural := 0;
	constant rid_tgrchannel : natural := 1;

	constant rgtr_size : natural_vector := (
		rid_tgrlevel   => 8,
		rid_tgrchannel => 5);

	signal len : unsigned(0 to 8-1);
	signal rid : std_logic_vector(0 to 8-1);
	signal val : std_logic_vector(0 to 8-1);
	signal ld  : std_logic;
	signal ptr : signed(0 to unsigned_num_bits(8-1));

	signal rgtr : std_logic_vector(0 to 16);
begin

	cp_p : process (in_clk)
		variable aux : unsigned(val'range);
	begin
		if rising_edge(in_clk) then
			aux := unsigned(val);
			if in_ena='1' then
				aux(in_data'range) := unsigned(in_data);
				aux := aux ror in_data'length;
			end if;
			val <= std_logic_vector(aux);
		end if;
	end process;

	process (in_clk)
	begin
		if rising_edge(in_clk) then
			if in_ena='0' then
				ptr <= to_signed(8-1 - in_data'length, ptr'length);
			elsif ptr(0)='1' then
				ptr <= to_signed(8-1 - in_data'length, ptr'length);
			else
				ptr <= ptr - in_data'length;
			end if;
		end if;
	end process;

	process (in_clk)
		type reg_states is (regS_id, regS_size, regS_data);
		variable stt : reg_states;
	begin
		if rising_edge(in_clk) then
			if in_ena='0' then
				stt := regS_id;
			elsif ptr(0)='1' then
				case stt is
				when regS_id =>
					len <= (others => '0');
					rid <= reverse(val(rid'range));
					stt := regS_size;
				when regS_size =>
					len <= unsigned(reverse(val(len'range)));
					stt := regS_data;
				when regS_data =>
					if len(0)='1' then
						len <= (others => '0');
						stt := regS_id;
					else
						len <= len - 1;
						stt := regS_data;
					end if;
				end case;
			end if;
		end if;
	end process;
 
	process (in_clk)
		variable aux : unsigned(rgtr'range);
	begin
		if rising_edge(in_clk) then
			aux := unsigned(rgtr);
			if len(0)='1' then
				for i in rgtr_size'range loop
					if i=to_integer(unsigned(rid)) then
						aux(0 to rgtr_size(i)-1) := unsigned(reverse(val(0 to rgtr_size(i)-1)));
					end if;
					aux := aux rol rgtr_size(i);
				end loop;
			end if;
			rgtr <= std_logic_vector(aux);
		end if;
	end process;
end;
