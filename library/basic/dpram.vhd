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

entity dpram is
	generic (
		synchronous_rdaddr : boolean := false;
		synchronous_rddata : boolean := false;
		synchronous_wraddr : boolean := false;
		synchronous_wrdata : boolean := false;
		synchronous_wrena  : boolean := false;
		bitrom : std_logic_vector := (0 to 0 => '-'));
	port (
		rd_clk  : in  std_logic := '-';
		rd_addr : in  std_logic_vector;
		rd_ena  : in  std_logic := '1';
		rd_data : out std_logic_vector;

		wr_clk  : in std_logic;
		wr_ena  : in std_logic := '1';
		wr_addr : in std_logic_vector;
		wr_data : in std_logic_vector);
end;

architecture def of dpram is
	subtype word is std_logic_vector(0 to wr_data'length-1);
	type word_vector is array (natural range <>) of word;

	function init_ram (
		constant bitrom : std_logic_vector;
		constant size   : natural)
		return   word_vector is
		alias bitrom0   : std_logic_vector(0 to bitrom'length-1) is bitrom;
		variable aux    : std_logic_vector(0 to size*word'length-1);
		variable retval : word_vector(0 to size-1);
	begin
		aux := (others => '0'); -- Latticesemi Diamond bug, it won't accept '-' as default value
		if bitrom'length > 0 then  -- "if" WORKAROUND suggested by emard @ github.com
			if aux'length >= bitrom'length then
				aux(0 to bitrom'length-1) := bitrom0;
			else
				aux := bitrom0(0 to aux'length-1);
			end if;

			for i in retval'range loop
				retval(i) := aux(i*retval(0)'length to (i+1)*retval(0)'length-1);
			end loop;
		end if;
		return retval;
	end;

	signal async_rdaddr : std_logic_vector(rd_addr'range);
	signal async_rddata : std_logic_vector(rd_data'range);
	signal async_wraddr : std_logic_vector(wr_addr'range);
	signal async_wrdata : std_logic_vector(wr_data'range);
	signal async_wrena  : std_logic;
	signal ram : word_vector(0 to 2**wr_addr'length-1) := init_ram(bitrom, 2**wr_addr'length);

begin

	assert wr_addr'length=rd_addr'length
	report "Difference address size"
	severity failure;


	assert wr_data'length=rd_data'length
	report "Difference data size"
	severity failure;

	sync_rdaddr_g : if synchronous_rdaddr generate
		sync_p : process (rd_clk)
		begin
			if rising_edge(rd_clk) then
				async_rdaddr <= rd_addr;
			end if;
		end process;
	end generate;

	async_rdaddr_g : if not synchronous_rdaddr generate
		async_rdaddr <= rd_addr;
	end generate;

	process (async_rdaddr, ram)
	begin
		async_rddata <= ram(to_integer(unsigned(async_rdaddr)));
	end process;
		
	sync_rddata_g : if synchronous_rddata generate
		rddata_p : process (rd_clk)
		begin
			if rising_edge(rd_clk) then
				if rd_ena='1' then
					rd_data <= async_rddata;
				end if;
			end if;
		end process;
	end generate;

	async_rddata_g : if not synchronous_rddata generate
		rd_data <= async_rddata;
	end generate;

	sync_wraddr_g : if synchronous_wraddr generate
		sync_p : process (wr_clk)
		begin
			if rising_edge(wr_clk) then
				async_wraddr <= wr_addr;
			end if;
		end process;
	end generate;

	async_wraddr_g : if not synchronous_wraddr generate
		async_wraddr <= wr_addr;
	end generate;

	sync_wrdata : if synchronous_wrdata generate
		sync_p : process (wr_clk)
		begin
			if rising_edge(wr_clk) then
				async_wrdata <= wr_data;
			end if;
		end process;
	end generate;

	async_wrdata_g : if not synchronous_wrdata generate
		async_wrdata <= wr_data;
	end generate;

	sync_wrena : if synchronous_wrena generate
		sync_p : process (wr_clk)
		begin
			if rising_edge(wr_clk) then
				async_wrena <= wr_ena;
			end if;
		end process;
	end generate;

	async_wrena_g : if not synchronous_wrena generate
		async_wrena <= wr_ena;
	end generate;

	wrdata_p : process (wr_clk)
	begin
		if rising_edge(wr_clk) then
			if async_wrena='1' then
				ram(to_integer(unsigned(async_wraddr))) <= async_wrdata;
			end if;
		end if;
	end process;
end;
