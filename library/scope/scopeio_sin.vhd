library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_sin is
	port (
		sin_clk   : in  std_logic;
		sin_frm   : in  std_logic;
		sin_irdy  : in  std_logic := '1';
		sin_data  : in  std_logic_vector;
		
		data_frm  : out std_logic;
		data_ena  : out std_logic;
		data_len  : out std_logic_vector(8-1 downto 0);

		rgtr_id   : out std_logic_vector;
		rgtr_dv   : out std_logic;
		rgtr_data : out std_logic_vector);
end;

architecture beh of scopeio_sin is
	subtype byte is std_logic_vector(8-1 downto 0);

	signal des8_irdy : std_logic;
	signal des8_data : byte;
	signal ser8_irdy : std_logic;
	signal des_irdy  : std_logic;
	signal des_data  : std_logic_vector;

	signal len : unsigned(0 to byte'length);
	signal rid : std_logic_vector(byte'length-1 downto 0);
	signal val : std_logic_vector(rgtr_data'length-1 downto 0);

	signal size : unsigned(byte'range);
	type states is (s_id, s_size, s_data);
	signal state  : reg_states;
begin

	serdes_e : entity hdl4fpga.serdes
	port map (
		serdes_clk => sin_clk,
		serdes_frm => sin_frm,
		ser_irdy   => sin_irdy,
		ser_data   => sin_data,

		des_irdy   => des8_irdy,
		des_data   => des8_data);

	serdes8_e : entity hdl4fpga.serdes
	port map (
		serdes_clk => sin_clk,
		serdes_frm => sin_frm,
		ser_irdy   => ser8_irdy,
		ser_data   => des8_data,

		des_data   => rgtr_data);

	ser8_irdy <= des8_irdy and setif(state=s_data);
	process (sin_clk)
	begin
		if rising_edge(sin_clk) then
			if sin_frm='0' then
				rid   <= (others => '-');
				len   <= (others => '-');
				state <= s_id;
			elsif des8_irdy='1' then
				case state is
				when s_id =>
					rid   <= des8_data;
					len   <= (others => '-');
					state <= s_size;
				when s_size =>
					len    <= resize(unsigned(des8_data), len'length));
					state  <= s_data;
				when s_data =>
					len  <= len - 1;
					if len(0)='1' then
						state <= s_id;
					else
						state <= s_data;
					end if;
				end case;
			end if;
		end if;
	end process;
 
	data_frm  <= sin_frm;
	data_ena  <= des_irdy;
	data_len  <= std_logic_vector(size);

	rgtr_id   <= rid(rgtr_id'length-1 downto 0);
	rgtr_dv   <= len(0);

end;
