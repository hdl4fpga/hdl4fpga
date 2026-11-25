-- Copyright (c) 2015 Miguel Angel Sagreras                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity fifo is
	generic (
		debug      : boolean := false;
		max_depth  : natural;
		mem_data   : std_logic_vector := (0 to 0 => '0');
		latency    : natural := 0;
		check_sov  : boolean := false;
		check_dov  : boolean := false);
	port (
		mode       : in  std_logic_vector(0 to 1) := "10";

		src_clk    : in  std_logic;
		src_irdy   : in  std_logic := '1';
		src_trdy   : buffer std_logic;
		src_data   : in  std_logic_vector;


		dst_clk    : in  std_logic;
		dst_irdy   : buffer std_logic;
		dst_trdy   : in  std_logic := '1';
		dst_data   : buffer std_logic_vector);

	constant addr_length : natural := unsigned_num_bits(max_depth)-1;
	constant flush       : std_logic_vector := "00";
	constant rollback    : std_logic_vector := "01";
	constant commit      : std_logic_vector := "10";
	constant queue       : std_logic_vector := "11";

end;

architecture def of fifo is

	subtype addr_range is natural range 1 to addr_length;
	signal rd_data : std_logic_vector(0 to src_data'length-1);

	signal wr_bptr : std_logic_vector(addr_range);
	signal rd_bptr : std_logic_vector(addr_range);
	signal wr_gcmp : std_logic_vector(0 to addr_length) := (others => '0');
	signal wr_gptr : std_logic_vector(0 to addr_length) := (others => '0');
	signal rd_gptr : std_logic_vector(0 to addr_length) := (others => '0');
	signal rd_gcmp : std_logic_vector(0 to addr_length) := (others => '0');

	signal lat_irdy : std_logic;
	signal lat_trdy : std_logic;
begin

	assert max_depth=2**addr_length
		report "fifo_depth should be a power of 2"
		severity FAILURE;

	process(src_clk)
		variable cntr : unsigned(rd_gptr'range) := (others => '0');
		variable cmp  : unsigned(wr_gptr'range) := (others => '0');
	begin
		if rising_edge(src_clk) then
			case mode is
			when flush =>
				cntr := gray2bin(rd_gptr);
				if src_irdy='1' then
					cntr := cntr + 1;
				end if;
				cmp := cntr;
			when rollback =>
				cntr := cmp;
			when others =>
				if src_irdy='1' then
					if src_trdy='1' or not check_sov then
						cntr := cntr + 1;
					end if;
				end if;
				if mode=commit then
					cmp := cntr;
				end if;
			end case;
			wr_bptr <= std_logic_vector(cntr(wr_bptr'range));
			wr_gptr <= bin2gray(cntr);
			wr_gcmp <= bin2gray(cmp); 
		end if;
	end process;
	src_trdy <= '1' when wr_gptr /= rd_gcmp else '0';

	fifo_b : block

		signal wr_addr : std_logic_vector(addr_range);
		signal rd_addr : std_logic_vector(addr_range);
		signal wr_ena  : std_logic;
	begin
		wr_ena <= 
			src_irdy              when mode=flush else
			src_irdy and src_trdy when check_sov else
			src_irdy;

		wr_addr <= 
			(others => '0') when mode=flush else
			wr_gptr(addr_range);

		rd_addr <= rd_gptr(addr_range);
		mem_e : entity hdl4fpga.dpram(def)
		generic map (
			synchronous_rdaddr => false,
			synchronous_rddata => setif(latency > 0),
			bitdata => mem_data)
		port map (
			wr_clk  => src_clk,
			wr_ena  => wr_ena,
			wr_addr => wr_bptr,
			wr_data => src_data,

			rd_clk  => dst_clk,
			rd_addr => rd_bptr,
			rd_data => rd_data);

	end block;

	lat_irdy <= '1' when wr_gcmp /= rd_gptr else '0';

	process(mode, dst_clk)
		variable cntr : unsigned(rd_gptr'range) := (others => '0');
	begin
		if rising_edge(dst_clk) then
			if (lat_irdy='1' or not check_dov) and lat_trdy='1' then
				cntr := cntr + 1;
			end if;
		end if;
		rd_bptr <= std_logic_vector(cntr(rd_bptr'range));
		rd_gptr <= bin2gray(cntr);
		rd_gcmp <= bin2gray(cntr) xor ("11" & (2 to rd_gcmp'length-1 => '0'));
	end process;

	latency_g : if latency > 0 generate 
		pskid_g : block
			port (
				mode     : in  std_logic_vector(0 to 1);
				clk      : in  std_logic;
				src_irdy : in  std_logic; 
				src_trdy : buffer std_logic;
				src_data : in  std_logic_vector;
				dst_irdy : buffer std_logic; 
				dst_trdy : in  std_logic;
				dst_data : out std_logic_vector);
			port map (
				mode     => mode,
				clk      => dst_clk,
				src_irdy => lat_irdy,
				src_trdy => lat_trdy,
				src_data => rd_data,
				dst_irdy => dst_irdy,
				dst_trdy => dst_trdy,
				dst_data => dst_data);

			signal valid  : std_logic := '0';
			signal loaded : std_logic := '0';
			signal buffr  : std_logic_vector(src_data'range);
		begin
			
			process (mode, dst_clk)
			begin
				if mode=flush then
					loaded <= '0';
					valid  <= '0';
				elsif rising_edge(dst_clk) then
					if dst_trdy='1' then
						if valid='0' then
							loaded <= '0';
						end if;
					elsif valid='1' then
						loaded <= '1';
					end if;

					if valid='1' then
						buffr <= src_data;
					end if;

					valid <= (dst_trdy and (src_irdy or not setif(check_dov))) or (not dst_irdy and src_irdy);
				end if;
			end process;

			dst_irdy <= valid or loaded;
			dst_data <= buffr when loaded='1' else src_data;
			src_trdy <= dst_trdy or (not dst_irdy and src_irdy);


		end block;
	end generate;

	latency0_g : if latency = 0 generate
		dst_irdy <= lat_irdy;
		lat_trdy <= dst_trdy;
		dst_data <= rd_data;
	end generate;
end;
