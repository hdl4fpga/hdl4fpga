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

entity timer is
	generic (
		slices : natural_vector);
	port (
		data : in  std_logic_vector;
		clk  : in  std_logic;
		req  : in  std_logic;
		rdy  : buffer std_logic);
end;

architecture def of timer is

	signal en : std_logic_vector(slices'length downto 0) := (0 => '1', others => '0');
	signal q  : std_logic_vector(slices'length-1 downto 0);
	constant slices0 : natural_vector(slices'length-1 downto 0) := slices;
	signal cy : std_logic_vector(slices'length downto 0); 
begin

	process (clk)
	begin
		if rising_edge(clk) then
			if (to_bit(req) xor to_bit(rdy))='0' then
				cy <= (0 =>'1', others => '0');
			else
				for i in 0 to slices0'length-1 loop
					if cy(cy'left)='0' then
						cy(i+1) <= q(i) and cy(i);
					end if;
				end loop;
				rdy <= cy(cy'left) xnor req;
			end if;
		end if;
	end process;
	en <= cy(slices0'length downto 1) & not cy(slices0'length);

	cntr_g : for i in 0 to slices0'length-1 generate

		function csize (
			constant i : natural)
			return natural is
		begin
			if i = 0 then
				return 0;
			end if;
			return slices0(i-1);
		end;
		constant size : natural := csize(i+1)-csize(i);
		signal cntr : unsigned(0 to size-1);

	begin
		cntr_p : process (clk)
			variable csize : natural_vector(slices0'length downto 0) := (others => 0);
		begin
			if rising_edge(clk) then
				csize(slices0'length downto 1) := slices0;
				if (to_bit(req) xor to_bit(rdy))='0' then
					cntr <= resize(shift_right(unsigned(data), csize(i)), size);
				elsif en(i)='1' then
					if cntr(0)='1' then
						cntr <= to_unsigned((2**(size-1)-2), size);
					else
						cntr <= cntr - 1;
					end if;
				end if;
			end if;
		end process;
		q(i) <= cntr(0);
	end generate;
end;
