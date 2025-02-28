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

entity mii_1cksm is
	generic (
		n    : natural;
		init : std_logic_vector := (0 to 0 => '0'));
	port (
		mii_clk   : in  std_logic;
		mii_frm   : in  std_logic := '1';
		mii_irdy  : in  std_logic;
		mii_trdy  : out std_logic := '1';
		mii_end   : in  std_logic := '0';
		mii_empty : out std_logic;
		mii_data  : in  std_logic_vector;
		mii_cksm  : buffer std_logic_vector);
end;

architecture beh of mii_1cksm is

	signal ci  : std_logic;
	signal op1 : std_logic_vector(mii_data'length-1 downto 0);
	signal op2 : std_logic_vector(mii_data'length-1 downto 0);
	signal co  : std_logic;
	signal sum : std_logic_vector(n-1 downto 0);
	signal acc : std_logic_vector(n-1 downto 0);

begin

	op1 <= acc(mii_cksm'length-1 downto 0);
	op2 <= 
		(op2'range => '0') when mii_irdy='0' else
		(op2'range => '0') when mii_end='1'  else
		reverse(mii_data);

	adder_e : entity hdl4fpga.adder
	port map (
		ci  => ci,
		a   => op1,
		b   => op2,
		s   => mii_cksm,
		co  => co);

	process (sum, mii_clk)
	begin
		if rising_edge(mii_clk) then
			if mii_frm='0' then
				ci  <= '0';
				acc <= std_logic_vector(resize(unsigned(init), acc'length));
			elsif mii_irdy='1' then
				ci  <= co;
				acc <= sum;
			end if;
		end if;
	end process;

	sum <= mii_cksm & acc(acc'length-1 downto mii_data'length);

	process (mii_clk)
		variable cntr : unsigned(0 to unsigned_num_bits(n/mii_cksm'length-1));
	begin
		if rising_edge(mii_clk) then
			if mii_frm='0' then
				cntr := to_unsigned(n/mii_cksm'length-1, cntr'length);
			elsif mii_irdy='1' then
				if mii_end='1' then
					if cntr(0)='0' then
						cntr := cntr - 1;
					end if;
				end if;
			end if;
			mii_empty <= cntr(0);
		end if;
	end process;

end;




