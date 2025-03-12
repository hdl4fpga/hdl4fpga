library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity sio_sin is
	generic (
		debug     : boolean := false);
	port (
		sin_clk   : in  std_logic;
		sin_frm   : in  std_logic;
		sin_irdy  : in  std_logic := '1';
		sin_trdy  : buffer std_logic;
		sin_data  : in  std_logic_vector;

		data_frm  : out std_logic;
		data_irdy : out std_logic;
		sout_irdy : out std_logic;
		data_ptr  : out std_logic_vector(8-1 downto 0);

		rgtr_frm  : out std_logic;
		rgtr_irdy : buffer std_logic;
		rgtr_trdy : in  std_logic := '1';
		rgtr_idv  : out std_logic;
		rgtr_id   : out std_logic_vector(8-1 downto 0);
		rgtr_lv   : out std_logic;
		rgtr_len  : buffer std_logic_vector(8-1 downto 0);
		rgtr_dv   : out std_logic;
		rgtr_data : out std_logic_vector;
		tp        : out std_logic_vector(1 to 32));
end;

architecture beh of sio_sin is

	signal des8_irdy : std_logic;
	signal des8_data : std_logic_vector(rgtr_id'range);
	signal rev8_data : std_logic_vector(des8_data'range); -- Xilinx ISE's bug

	type states is (s_id, s_size, s_data);
	signal stt : states;

begin

	byte_e : entity hdl4fpga.serdes
	generic map (
		debug => debug)
	port map (
		serdes_clk => sin_clk,
		serdes_frm => sin_frm,
		ser_irdy   => sin_irdy,
		ser_data   => sin_data,

		des_irdy   => des8_irdy,
		des_data   => des8_data);
	rev8_data <= reverse(des8_data);

	tp(1) <= sin_frm;
	tp(2) <= des8_irdy;
	tp(3 to 10) <= des8_data;

	process (sin_clk)
		variable rid  : std_logic_vector(rgtr_id'range);
		variable len  : unsigned(0 to rgtr_id'length);
		variable data : unsigned(rgtr_data'range);
		variable ptr  : unsigned(rgtr_id'range);
		variable idv  : std_logic;
		variable lv   : std_logic;
		variable dv   : std_logic;

	begin
		if rising_edge(sin_clk) then
			if rgtr_trdy='1' or to_stdulogic(to_bit(rgtr_irdy))='0' then
				if sin_frm='0' then
					ptr := (others => '0');
					len := (others => '0');
					idv := '0';
					lv  := '0';
					dv  := '0';
					stt <= s_id;
				elsif des8_irdy='1' then
					case stt is
					when s_id =>
						ptr := (others => '0');
--						rid := setif(rid'ascending, des8_data, reverse(des8_data));
						rid := setif(rid'ascending, des8_data, rev8_data); -- Xilinx ISE's bug returns '0's
						len := (others => '0');
						idv := '1';
						lv  := '0';
						dv  := '0';
						stt <= s_size;
					when s_size =>
						ptr := (others => '0');
--						len := resize(unsigned(setif(rid'ascending, des8_data, reverse(des8_data))), len'length); -- Xilinx ISE's bug returns '0's
						len := resize(unsigned(setif(rid'ascending, des8_data, rev8_data)), len'length);
						idv := '1';
						lv  := '1';
						dv  := '0';
						stt <= s_data;
					when s_data =>
						ptr := ptr + 1;
						len := len - 1;
						if len(0)='1' then
							idv := '0';
							stt <= s_id;
						else
							idv := '1';
							stt <= s_data;
						end if;
						lv  := '0';
						dv  := '1';
					end case;

				end if;
				rgtr_frm  <= to_stdulogic(to_bit(sin_frm));
				data_frm  <= setif(stt=s_data);
				rgtr_irdy <= des8_irdy;
				sout_irdy <= sin_irdy;
				data_irdy <= des8_irdy and setif(stt=s_data);
				rgtr_dv   <= des8_irdy and len(0);

				rgtr_idv  <= idv;
				rgtr_id   <= rid;
				rgtr_lv   <= lv;
				rgtr_len  <= std_logic_vector(len(1 to des8_data'length));

				if sin_irdy='1' then
					if sin_data'ascending=data'ascending then
						data(sin_data'range) := unsigned(sin_data);
						if sin_data'ascending then
							data := data rol sin_data'length;
						else
							data := data ror sin_data'length;
						end if;
					else
						if sin_data'ascending then
							data := data rol sin_data'length;
						else
							data := data ror sin_data'length;
						end if;
						data(sin_data'reverse_range) := unsigned(sin_data);
					end if;
				end if;

				rgtr_data <= setif(rgtr_data'ascending=sin_data'ascending, std_logic_vector(data), reverse(std_logic_vector(data)));

				data_ptr  <= std_logic_vector(ptr);
			end if;
		end if;
	end process;
	sin_trdy <= not to_stdulogic(to_bit(rgtr_irdy)) or rgtr_trdy;


end;
