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

entity sio_ram is
	generic (
		bitdata : std_logic_vector);
    port (
		si_clk  : in  std_logic := '0';
		si_frm  : in  std_logic := '0';
		si_irdy : in  std_logic := '0';
		si_trdy : out std_logic := '1';
		si_data : in  std_logic_vector;

		so_clk  : in  std_logic := '0';
		so_frm  : in  std_logic := '0';
		so_irdy : in  std_logic := '0';
		so_trdy : out std_logic := '0';
		so_data : out std_logic_vector);
end;

architecture def of sio_ram is
	signal rd_addr : std_logic_vector(1 to unsigned_num_bits(bitdata'length/so_data'length-1));
	signal wr_addr : std_logic_vector(rd_addr'range);
	signal wr_ena  : std_logic;

begin

	assert so_data'length=si_data'length
		report "sio_ram() : so_data => " & natural'image(so_data'length) & " and si_data => " & natural'image(si_data'length) & " have different length"
		severity failure;

	process (so_frm, so_irdy, so_clk)
		variable cntr : unsigned(0 to rd_addr'length);
		variable last : std_logic;
	begin
		if rising_edge(so_clk) then
			if ((last or so_frm) and so_irdy)='1' then
				cntr := cntr + 1;
			end if;
			if (so_frm or so_irdy)='0' then
				cntr := (others => '0');
				cntr := cntr-bitdata'length/so_data'length;
			end if;
			if so_frm='0' then
				if so_irdy='0' then
					last := '0';
				elsif last='1' then
					last := '0';
				end if;
			elsif so_irdy='1' then
				last := '1';
			end if;
			rd_addr <= std_logic_vector(cntr(rd_addr'range));
		end if;
		so_trdy <= (so_frm or last) and so_irdy;
	end process;

	process (si_frm, si_irdy, si_clk)
		variable cntr : unsigned(0 to rd_addr'length);
		variable last : std_logic;
	begin
		if rising_edge(si_clk) then
			if ((last or si_frm) and si_irdy)='1' then
				cntr := cntr + 1;
			end if;
			if (si_frm or si_irdy)='0' then
				cntr := (others => '0');
				cntr := cntr-bitdata'length/si_data'length;
			end if;
			if si_frm='0' then
				if si_irdy='0' then
					last := '0';
				elsif last='1' then
					last := '0';
				end if;
			elsif si_irdy='1' then
				last := '1';
			end if;
			wr_addr <= std_logic_vector(cntr(rd_addr'range));
		end if;
		si_trdy <= (si_frm or last) and si_irdy;
		wr_ena  <= (si_frm or last) and si_irdy;
	end process;

	mem_i : entity hdl4fpga.dpram
	generic map (
		bitdata  => std_logic_vector(resize(unsigned(bitdata), so_data'length*2**rd_addr'length)))
	port map (
		rd_addr => rd_addr,
		rd_data => so_data,

		wr_clk  => si_clk,
		wr_ena  => wr_ena,
		wr_addr => wr_addr,
		wr_data => si_data);

end;