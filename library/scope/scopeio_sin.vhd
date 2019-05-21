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
		
		rgtr_id   : out std_logic_vector;
		rgtr_dv   : out std_logic;
		rgtr_data : out std_logic_vector);
end;

architecture beh of scopeio_sin is
	signal len : signed(0 to 8);
	signal rid : std_logic_vector(8-1 downto 0);
	signal val : std_logic_vector(rgtr_data'length-1 downto 0);
	signal ld  : std_logic;
	signal ptr : signed(0 to unsigned_num_bits(8-1));

	signal dv  : std_logic;
	signal ena : std_logic;

	type reg_states is (regS_id, regS_size, regS_data);
	signal stt : reg_states;
begin

	cp_p : process (sin_clk)
--		variable aux : unsigned(val'reverse_range);  -- Xilinx ISE can't deal with this reverse_range. It doesn't reverse the range;
		variable aux : unsigned(0 to rgtr_data'length-1);
	begin
		if rising_edge(sin_clk) then
			aux := unsigned(val);
			aux := aux ror 8;
			if sin_irdy='1' then
				if ptr(0)='1' then
					aux := aux rol 2*8;
				end if;
				aux := aux ror sin_data'length;
				if sin_data'ascending then
					aux(0 to sin_data'length-1) := unsigned(reverse(sin_data));
				else
					aux(0 to sin_data'length-1) := unsigned(sin_data);
				end if;
--				aux(0 to sin_data'length-1) := unsigned(sin_data);
			end if;
			aux := aux rol 8;
			val <= std_logic_vector(aux);
			dv  <= sin_frm;
			ena <= sin_irdy;
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
			elsif ena='1' then
				if ptr(0)='1' then
					case stt is
					when regS_id =>
						rid <= val(rid'range);
						len <= (others => '0');
						stt <= regS_size;
					when regS_size =>
						len <= signed(resize(unsigned(val(len'length-2 downto 0)), len'length))-1;
						stt <= regS_data;
					when regS_data =>
						if len(0)='1' then
							len <= (others => '0');
							stt <= regS_id;
						else
							len <= len - 1;
							stt <= regS_data;
						end if;
					end case;
				end if;
			end if;
		end if;
	end process;
 
	rgtr_id   <= rid(rgtr_id'length-1 downto 0);
	rgtr_dv   <= ena and len(0) and ptr(0);
	rgtr_data <= val;

--	mem_b : block
--		signal rd_addr : std_logic_vector(mem_addr'range);
--		signal rd_data : std_logic_vector(mem_data'range);
--		signal wr_addr : std_logic_vector(mem_addr'range);
--		signal wr_data : std_logic_vector(mem_data'range);
--		signal wr_ena  : std_logic;
--	begin
--
--		wr_ena <= data_ena and len(0) and ptr(0);
--		process (sin_clk)
--			variable aux : unsigned(wr_addr'range);
--		begin
--			if rising_edge(sin_clk) then
--				if wr_ena='0' then
--					aux := (others => '0');
--				else
--					if ena='1' then
--						aux := aux + 1;
--					end if;
--					data_len <= std_logic_vector(aux);
--				end if;
--				wr_addr <= std_logic_vector(aux);
--			end if;
--		end process;
--		wr_data <= val(mem_data'length-1 downto 0);
--
--		ready_e : entity hdl4fpga.align
--		generic map (
--			n => 1,
--			d => (0 => 2))
--		port map (
--			clk   => mem_clk,
--			di(0) => mem_req,
--			do(0) => mem_rdy);
--
--		rd_addr_e : entity hdl4fpga.align
--		generic map (
--			n => mem_addr'length,
--			d => (mem_addr'range => 1))
--		port map (
--			clk => mem_clk,
--			di  => mem_addr,
--			do  => rd_addr);
--
--		mem_e : entity hdl4fpga.dpram 
--		port map (
--			wr_clk  => sin_clk,
--			wr_ena  => wr_ena,
--			wr_addr => wr_addr,
--			wr_data => wr_data,
--			rd_addr => rd_addr,
--			rd_data => rd_data);
--
--		rd_data_e : entity hdl4fpga.align
--		generic map (
--			n => mem_data'length,
--			d => (mem_data'range => 1))
--		port map (
--			clk => mem_clk,
--			di  => rd_data,
--			do  => mem_data);
--
--	end block;

end;
