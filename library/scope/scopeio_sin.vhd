library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_sin is
	port (
		sin_clk   : in  std_logic;
		sin_irdy  : in  std_logic := '1';
		sin_frm   : in  std_logic;
		sin_data  : in  std_logic_vector;
		
		data_frm  : out std_logic;
		data_ena  : out std_logic;
		data_len  : out std_logic_vector(8-1 downto 0);

		rgtr_idv  : out std_logic;
		rgtr_id   : out std_logic_vector;
		rgtr_dv   : out std_logic;
		rgtr_data : out std_logic_vector);
end;

architecture beh of scopeio_sin is
	subtype byte is std_logic_vector(8-1 downto 0);

	signal len : signed(0 to byte'length);
	signal rid : std_logic_vector(byte'length-1 downto 0);
	signal val : std_logic_vector(rgtr_data'length-1 downto 0);
	signal ptr : signed(0 to unsigned_num_bits(byte'length-1));
	signal datasize_ena : std_logic_vector(unsigned_num_bits(rgtr_data'length/byte'length)-1 downto 0);

	signal frm  : std_logic;
	signal ridv : std_logic;
	signal dv   : std_logic;
	signal ena  : std_logic;

	type reg_states is (regS_id, regS_size, regS_data);
	signal size : unsigned(byte'range);
	signal stt  : reg_states;
begin

	cp_p : process (sin_clk)
--		variable aux : unsigned(val'reverse_range);  -- Xilinx ISE can't deal with this reverse_range. It doesn't reverse the range;
		variable aux : unsigned(0 to rgtr_data'length-1);
	begin
		if rising_edge(sin_clk) then
			aux := unsigned(val);
			aux := aux ror byte'length;
			if sin_irdy='1' then
				if ptr(0)='1' then
					aux := aux rol 2*byte'length;
				end if;
				aux := aux ror sin_data'length;
				aux(0 to sin_data'length-1) := unsigned(sin_data);
			end if;
			aux := aux rol byte'length;
			val <= std_logic_vector(aux);
			dv  <= sin_frm;
			ena <= sin_irdy;
		end if;
	end process;

	process (sin_clk)
	begin
		if rising_edge(sin_clk) then
			if dv='0' then
				ptr <= to_signed(byte'length-1 - sin_data'length, ptr'length);
			elsif ena='1' then
				if ptr(0)='1' then
					ptr <= to_signed(byte'length-1 - sin_data'length, ptr'length);
				else
					ptr <= ptr - sin_data'length;
				end if;
			end if;
		end if;
	end process;

	process (sin_clk)
	begin
		if rising_edge(sin_clk) then
			if dv='0' then
				frm  <= '0';
				ridv <= '0';
				len  <= (others => '0');
				size <= (others => '0');
				stt  <= regS_id;
			elsif ena='1' then
				if ptr(0)='1' then
					case stt is
					when regS_id =>
						frm  <= '0';
						rid  <= val(rid'range);
						ridv <= '1';
						len  <= (others => '0');
						size <= (others => '0');
						stt  <= regS_size;
					when regS_size =>
						frm  <= '1';
						ridv <= '1';
						len  <= signed(resize(unsigned(val(len'length-2 downto 0)), len'length))-1;
						size <= (others => '0');
						stt  <= regS_data;
					when regS_data =>
						if len(0)='1' then
							frm  <= '0';
							ridv <= '0';
							len  <= (others => '0');
							size <= (others => '0');
							stt  <= regS_id;
						else
							frm  <= '1';
							ridv <= '1';
							len  <= len - 1;
							size <= size + 1;
							stt  <= regS_data;
						end if;
					end case;
				end if;
			end if;
		end if;
	end process;
 
	data_frm  <= frm;
	data_ena  <= (ena and dv and ptr(0) and setif(stt=regS_data));
	data_len  <= std_logic_vector(size);

	rgtr_idv  <= ridv and sin_irdy;
	rgtr_id   <= rid(rgtr_id'length-1 downto 0);
	rgtr_dv   <= ena and dv and len(0) and ptr(0);
	rgtr_data <= val;

end;
