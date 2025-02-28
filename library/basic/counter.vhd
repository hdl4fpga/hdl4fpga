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

entity counter is
	generic (
		stage_size : natural_vector := (0 => 13, 1 => 26, 2 => 30));
	port (
		clk  : in  std_logic;
		ena  : in  std_logic;
		load : in  std_logic;
		data : in  std_logic_vector(stage_size(stage_size'high)-1 downto 0);
		co   : out std_logic_vector(stage_size'length-1 downto 0);
		qo   : out std_logic_vector(stage_size(stage_size'high)-1 downto 0));
end;

architecture def of counter is

	signal en : std_logic_vector(stage_size'length-1 downto 0) := (0 => '1', others => '0');
	signal q  : std_logic_vector(stage_size'length-1 downto 0);

begin

	en <= q(q'left-1 downto 0) & ena;

	cntr_g : for i in 0 to stage_size'length-1 generate

		impure function csize (
			constant i : natural)
			return natural is
		begin
			if i = 0 then
				return 0;
			end if;
			return stage_size(i-1);
		end;

		constant size       : natural := csize(i+1)-csize(i);
		constant cntr_left  : natural := csize(i)+size-1;
		constant cntr_right : natural := csize(i);
		signal   cntr       : unsigned(csize(i)+size-1 downto csize(i));

	begin

		cntr_p : process (clk)
		begin
			if rising_edge(clk) then
				if load='1' then
					cntr <= resize(shift_right(unsigned(data), csize(i)), size);
				elsif cntr(cntr'left)='1' then
					if i /= (stage_size'length-1) then
						cntr <= to_unsigned((2**(size-1)-1), size);
					end if;
				elsif en(i)='1' then
					cntr <= cntr - 1;
				end if;
			end if;
		end process;

		qo_g : for i in cntr_left downto cntr_right generate
			qo(i) <= cntr(i);
		end generate;
		q(i) <= cntr(cntr'left);

	end generate;
	co <= q;
end;




