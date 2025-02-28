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

entity sio_ff is
    port (
		si_clk   : in  std_logic;
        si_frm   : in  std_logic;
        si_irdy  : in  std_logic;
        si_trdy  : out std_logic;
		si_full  : out std_logic;
        si_data  : in  std_logic_vector;

        so_data  : out std_logic_vector);
end;

architecture def of sio_ff is
	constant max_words   : natural := so_data'length/si_data'length;
	constant cntr_length : natural := unsigned_num_bits(max_words-1);
	constant len         : unsigned(0 to cntr_length) := to_unsigned(max_words, cntr_length+1);
	subtype addr_range is natural range 1 to cntr_length;

	signal wr_addr : unsigned(0 to cntr_length);

begin

	assert max_words > 0
	report "max_words should be greater than 0"
	severity FAILURE;

	process (si_frm, si_irdy, si_clk)
		variable rgtr : unsigned(so_data'range);
		variable cntr : unsigned(0 to cntr_length);
	begin
		if rising_edge(si_clk) then
			if si_frm='0' then
				cntr := (others => '0');
			elsif si_irdy='1' then 
				if cntr(0)='0' then
					if so_data'ascending and si_data'ascending then
						rgtr := rgtr ror si_data'length;
						rgtr(si_data'range) := unsigned(si_data);
					elsif not so_data'ascending and not si_data'ascending then
						rgtr := rgtr rol si_data'length;
						rgtr(si_data'range) := unsigned(si_data);
					elsif not so_data'ascending and si_data'ascending then
						rgtr(si_data'reverse_range) := unsigned(si_data);
						rgtr := rgtr ror si_data'length;
					else
						rgtr := rgtr rol si_data'length;
						rgtr(si_data'reverse_range) := unsigned(si_data);
					end if;

					cntr := cntr + 1;
				end if;
			end if;
			wr_addr <= cntr;
			so_data <= std_logic_vector(rgtr);
		end if;
	end process;

	si_trdy <= si_frm;
	si_full <= 
		'1' when wr_addr>=(so_data'length+si_data'length-1)/si_data'length else
		'0';

end;



