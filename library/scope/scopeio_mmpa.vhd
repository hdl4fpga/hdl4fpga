library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_mmap is
	port (
		in_clk       : in  std_logic;
		in_ena       : in  std_logic;
		in_data      : in  std_logic_vector;

		trigger_edge    : out std_logic;
		trigger_level   : out std_logic_vector;
		trigger_channel : out std_logic_vector;

		hzaxis_data  : out std_logic_vector;
		vtaxis_data  : out std_logic_vector);
end;

architecture beh of scopeio_downsampler is
	constant rid_tgrlevel   : natural := 0;
	constant rid_tgrchannel : natural := 1;

	constant rgtr_size : natural_vector := (
		(rid_tgrlevel,   10),
		(rid_tgrchannel,  5));

	signal value : std_logic_vector(0 to 64-1);

	signal ptr : unsigned(0 to unsigned_num_bits(8-1));
begin

	cp_p : process (in_clk)
		variable aux : unsigned(value'range);
	begin
		if rising_edge(in_clk) then
			aux := unsigned(value);
			if in_ena='1' then
				aux(in_data'range) := unsigned(in_data);
				aux := aux sll in_data'length;
			end if;
			value <= std_logic_vector(aux);
		end if;
	end process;

	process (in_clk)
	begin
		if rising_edge(in_clk) then
			if in_ena='0' then
				ptr <= to_unsigned(8-1, ptr'length);
			elsif ptr(0)='1' then
				ptr <= to_unsigned(8-1, ptr'length);
			else
				ptr <= ptr - in_data'length;
			end if;
		end if;
	end process;

	process (in_clk)
		type reg_states is (regS_id, regS_size, regS_data);
		variable state : reg_states;
		variable len   : unsigned(0 to 8-1);
	begin
		if rising_edge(in_clk) then
			if in_ena='0' then
				reg_state := regS_id;
			elsif ptr(0)='1' then
				case reg_state is
				when regS_id =>
					len       := (others => '-');
					reg_id    <= value(reg_id'range);
					reg_state := regS_size;
				when regS_size =>
					len       := unsigned(value(len'range));
					reg_state := regS_data;
				when regS_data =>
					if len=(len'range => '0') then
						len       := (others => '-');
						reg_val   <= value(reg'range);
						reg_state := regS_id;
					else
						len       := len - 1;
						reg_state := regS_data;
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
			if then
				for i in rgtr_size'range loop
					if i=to_integer(unsigned(reg_id)) then
						aux(0 to rgtr_size(i).len-1) := unsigned(value(0 to rgtr_size(i).len-1));
					end if;
					aux := aux rol rgtr_size(i).size;
				end loop;
			end if;
			rtgr <= std_logic_vector(aux);
		end if;
	end process;
end;
