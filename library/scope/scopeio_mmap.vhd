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
	signal rid : std_logic_vector(8-1 downto 0);
	signal val : std_logic_vector(3*8-1 downto 0);
	signal ld  : std_logic;
	signal ptr : signed(0 to unsigned_num_bits(8-1));

	signal rgtr : std_logic_vector(13-1 downto 0);
	signal ena  : std_logic;
		type reg_states is (regS_id, regS_size, regS_data);
		signal stt : reg_states;
begin

	cp_p : process (in_clk)
		variable aux : unsigned(val'reverse_range);
	begin
		if rising_edge(in_clk) then
			aux := unsigned(val);
			aux := aux ror 8;
			if in_ena='1' then
				if ptr(0)='1' then
					aux := aux rol 2*8;
				end if;
				aux := aux ror in_data'length;
				aux(in_data'range) := unsigned(reverse(in_data));
			end if;
			aux := aux rol 8;
			val <= std_logic_vector(aux);
			ena <= in_ena;
		end if;
	end process;

	process (in_clk)
	begin
		if rising_edge(in_clk) then
			if ena='0' then
				ptr <= to_signed(8-1 - in_data'length, ptr'length);
			elsif ptr(0)='1' then
				ptr <= to_signed(8-1 - in_data'length, ptr'length);
			else
				ptr <= ptr - in_data'length;
			end if;
		end if;
	end process;

	process (in_clk)
	begin
		if rising_edge(in_clk) then
			if ena='0' then
				stt <= regS_id;
			elsif ptr(0)='1' then
				case stt is
				when regS_id =>
					len <= (others => '-');
					rid <= val(rid'range);
					stt <= regS_size;
				when regS_size =>
					len <= unsigned(val(len'reverse_range))-1;
					stt <= regS_data;
				when regS_data =>
					if len(0)='1' then
						len <= (others => '-');
						stt <= regS_id;
					else
						len <= len - 1;
						stt <= regS_data;
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
			if len(0)='1' and ptr(0)='1' then
				for i in rgtr_size'range loop
					if i=to_integer(unsigned(rid)) then
						aux(rgtr_size(i)-1 downto 0) := unsigned(val(rgtr_size(i)-1 downto 0));
					end if;
					aux := aux ror rgtr_size(i);
				end loop;
			end if;
			rgtr <= std_logic_vector(aux);
		end if;
	end process;
end;
