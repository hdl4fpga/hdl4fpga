-- Copyright (c) <2015> <Miguel Angel Sagreras>                                    --
--                                                                                 --
-- Permission is hereby granted, free of charge, to any person obtaining a copy of --
-- this software and associated documentation files (the "Software"), to deal in   --
-- the Software without restriction, including without limitation the rights to    --
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies   --
-- of the Software, and to permit persons to whom the Software is furnished to do  --
-- so, subject to the following conditions:                                        --
--                                                                                 --
-- The above copyright notice and this permission notice shall be included in all  --
-- copies or substantial portions of the Software.                                 --
--                                                                                 --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR i    --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,        --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE     --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER          --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,   --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE   --
-- SOFTWARE.                                                                       --
--                                                                                 --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity sio_ram is
	generic (
		mode_fifo  : boolean := true;
		mem_data   : std_logic_vector := (0 to 0 => '-');
		mem_length : natural := 0;
		mem_size   : natural := 0);
    port (
		si_clk     : in  std_logic;
		si_frm     : in  std_logic;
		si_irdy    : in  std_logic;
		si_trdy    : out std_logic;
		si_full    : buffer std_logic;
		si_data    : in  std_logic_vector;

		so_clk     : in  std_logic;
		so_frm     : in  std_logic;
		so_irdy    : in  std_logic;
		so_trdy    : out std_logic;
		so_empty   : out std_logic;
		so_end     : out std_logic;
		so_data    : out std_logic_vector);
end;

architecture def of sio_ram is
	constant max_words   : natural := setif(mem_length=0, setif(mem_size=0, mem_data'length, mem_size), mem_length)/si_data'length;
	constant cntr_length : natural := unsigned_num_bits(max_words-1);
	subtype addr_range is natural range 1 to cntr_length;

	signal wr_addr : unsigned(0 to cntr_length);
	signal wr_ena  : std_logic;
	signal rd_addr : unsigned(0 to cntr_length);
	signal len     : unsigned(0 to cntr_length);

begin

	assert so_data'length=si_data'length
	report "so_data and si_data have different length"
	severity FAILURE;

	assert max_words > 0
	report "max_words should be greater than 0"
	severity FAILURE;

	process (si_frm, si_irdy, si_clk)
		variable cntr : unsigned(0 to cntr_length);
	begin
		if rising_edge(si_clk) then
			if si_frm='0' then
				cntr := (others => '0');
			else
				if si_irdy='1' then 
					if cntr(0)='0' then
						cntr := cntr + 1;
					end if;
				end if;
				len <= cntr;
			end if;
			if mem_length /= 0 then
				len <= to_unsigned(max_words, len'length);
			end if;
			wr_addr <= cntr;
		end if;
		wr_ena <= not cntr(0) and si_frm and si_irdy;
	end process;
	si_trdy <= si_frm;
	si_full <= 
		'0' when mem_length=0 else 
		'1' when wr_addr>=(mem_length+si_data'length-1)/si_data'length else
		'0';

	mem_e : entity hdl4fpga.dpram 
	generic map (
		synchronous_rdaddr => false,
		synchronous_rddata => false,
		bitrom => mem_data)
	port map (
		wr_clk  => si_clk,
		wr_ena  => wr_ena,
		wr_addr => std_logic_vector(wr_addr(addr_range)),
		wr_data => si_data,

		rd_clk  => so_clk,
		rd_addr => std_logic_vector(rd_addr(addr_range)),
		rd_data => so_data);

	process(so_clk)
	begin
		if rising_edge(so_clk) then
			if not mode_fifo then
				if so_frm='0' then
					rd_addr <= len-1;
				elsif si_full='0' then
					rd_addr <= len-1;
				elsif so_irdy='1' then
					if rd_addr(0)='0' then
						rd_addr <= rd_addr - 1;
					end if;
				end if;
			elsif so_frm='0' then
				rd_addr <= (others => '0');
			elsif so_irdy='1' then
				if rd_addr < len then
					rd_addr <= rd_addr + 1;
				end if;
			end if;
		end if;
	end process;

	so_trdy  <= 
		setif(rd_addr < len) when mode_fifo else
		not rd_addr(0) and si_full;
	so_empty <= setif(len=(len'range => '0'));
	so_end   <=
		setif(rd_addr >= len) when mode_fifo else
		rd_addr(0);

end;

