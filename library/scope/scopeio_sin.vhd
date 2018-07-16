library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_sin is
	generic(
		rgtr_map : natural_vector);
	port (
		sin_clk   : in  std_logic;
		sin_ena   : in  std_logic := '1';
		sin_dv    : in  std_logic;
		sin_data  : in  std_logic_vector;

		rgtr      : out std_logic_vector;
		mem_clk   : in  std_logic := '-';
		mem_req   : in  std_logic := '-';
		mem_addr  : in  std_logic_vector := std_logic_vector'(0 to 0 => '-');
		mem_rdy   : out std_logic;
		data_len  : out std_logic_vector;
		mem_data  : out std_logic_vector);
end;

architecture beh of scopeio_sin is
	signal len : signed(0 to 8);
	signal rid : std_logic_vector(8-1 downto 0);
	signal val : std_logic_vector(3*8-1 downto 0);
	signal ld  : std_logic;
	signal ptr : signed(0 to unsigned_num_bits(8-1));

	signal dv  : std_logic;
	signal ena : std_logic;
	signal data_ena : std_logic;

	type reg_states is (regS_id, regS_size, regS_data);
	signal stt : reg_states;
begin

	cp_p : process (sin_clk)
		variable aux : unsigned(val'reverse_range);
	begin
		if rising_edge(sin_clk) then
			aux := unsigned(val);
			aux := aux ror 8;
			if sin_ena='1' then
				if ptr(0)='1' then
					aux := aux rol 2*8;
				end if;
				aux := aux ror sin_data'length;
				aux(sin_data'range) := unsigned(reverse(sin_data));
			end if;
			aux := aux rol 8;
			val <= std_logic_vector(aux);
			dv  <= sin_dv;
			ena <= sin_ena;
		end if;
	end process;

	process (sin_clk)
	begin
		if rising_edge(sin_clk) then
			if dv='0' then
				ptr <= to_signed(8-1 - sin_data'length, ptr'length);
			elsif ena='1' then
				if ptr(0)='1' then
					ptr <= to_signed(8-1 - sin_data'length, ptr'length);
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
				stt <= regS_id;
				data_ena <= '0';
			elsif ena='1' then
				if ptr(0)='1' then
					case stt is
					when regS_id =>
						rid <= val(rid'range);
						if data_ena='1' then
							data_ena <= '1';
							len <= (others => '0');
							stt <= regS_id;
						elsif val(rid'range)=(rid'range => '1') then
							data_ena <= '1';
							len <= to_signed(mem_data'length/8-2, len'length);
							stt <= regS_data;
						else
							data_ena <= '0';
							len <= (others => '0');
							stt <= regS_size;
						end if;
					when regS_size =>
						data_ena <= '0';
						len <= signed(resize(unsigned(val(len'length-2 downto 0)), len'length))-1;
						stt <= regS_data;
					when regS_data =>
						if len(0)='1' then
							if data_ena='1' then
								data_ena <= '1';
								len <= to_signed(mem_data'length/8-2, len'length);
								stt <= regS_data;
							else
								data_ena <= '0';
								len <= (others => '0');
								stt <= regS_id;
							end if;
						else
							len <= len - 1;
							stt <= regS_data;
						end if;
					end case;
				end if;
			end if;
		end if;
	end process;
 
	process (sin_clk)
		variable aux : unsigned(rgtr'length-1 downto 0);
	begin
		if rising_edge(sin_clk) then
			if ena='1' then
				if len(0)='1' then
					if ptr(0)='1' then
						for i in rgtr_map'range loop
							if i=to_integer(unsigned(rid)) then
								aux(rgtr_map(i)-1 downto 0) := unsigned(val(rgtr_map(i)-1 downto 0));
							end if;
							aux := aux ror rgtr_map(i);
						end loop;
					end if;
				end if;
				rgtr <= std_logic_vector(aux);
			end if;
		end if;
	end process;

	mem_b : block
		signal rd_addr : std_logic_vector(mem_addr'range);
		signal rd_data : std_logic_vector(mem_data'range);
		signal wr_addr : std_logic_vector(mem_addr'range);
		signal wr_data : std_logic_vector(mem_data'range);
		signal wr_ena  : std_logic;
	begin

		wr_ena <= data_ena and len(0) and ptr(0);
		process (sin_clk)
			variable aux : unsigned(wr_addr'range);
		begin
			if rising_edge(sin_clk) then
				if wr_ena='0' then
					aux := (others => '0');
				else
					if ena='1' then
						aux := aux + 1;
					end if;
					data_len <= std_logic_vector(aux);
				end if;
				wr_addr <= std_logic_vector(aux);
			end if;
		end process;
		wr_data <= val(mem_data'length-1 downto 0);

		ready_e : entity hdl4fpga.align
		generic map (
			n => 1,
			d => (0 => 2))
		port map (
			clk   => mem_clk,
			di(0) => mem_req,
			do(0) => mem_rdy);

		rd_addr_e : entity hdl4fpga.align
		generic map (
			n => mem_addr'length,
			d => (mem_addr'range => 1))
		port map (
			clk => mem_clk,
			di  => mem_addr,
			do  => rd_addr);

		mem_e : entity hdl4fpga.dpram 
		port map (
			wr_clk  => sin_clk,
			wr_ena  => wr_ena,
			wr_addr => wr_addr,
			wr_data => wr_data,
			rd_addr => rd_addr,
			rd_data => rd_data);

		rd_data_e : entity hdl4fpga.align
		generic map (
			n => mem_data'length,
			d => (mem_data'range => 1))
		port map (
			clk => mem_clk,
			di  => rd_data,
			do  => mem_data);

	end block;

end;
