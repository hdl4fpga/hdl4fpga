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

entity dmacntr is
	port (
		clk     : in  std_logic;
		load    : in  std_logic;
		ena     : in  std_logic;
		iaddr   : in  std_logic_vector;
		ilen    : in  std_logic_vector;
		taddr   : out std_logic_vector;
		tlen    : out std_logic_vector;
		bnk     : buffer std_logic_vector;
		row     : buffer std_logic_vector;
		col     : buffer std_logic_vector;
		bnk_eoc : out std_logic;
		row_eoc : out std_logic;
		col_eoc : out std_logic;
		len_eoc : buffer std_logic);

end;

architecture def of dmacntr is

	constant slices : natural_vector := (
--		0 => col'length,
--		1 => row'length,
--		2 => bnk'length);
		0 => 1,
		1 => col'length-1,
		2 => (row'length+0)/2,
		3 => (row'length+1)/2,
		4 => bnk'length);

	signal ena_addr : std_logic;
	signal addr_q   : std_logic_vector(bnk'length+row'length+col'length-1 downto 0);
	signal addr_eoc : std_logic_vector(slices'length-1 downto 0);

	signal ena_cntr : std_logic;
	signal cntr_eoc : std_logic_vector(slices'length-1 downto 0);
begin

	assert iaddr'length=addr_q'length
		report "it won't work"
		severity failure;
	ena_addr <= not len_eoc and ena;
	addr_e : entity hdl4fpga.cntrcs
	generic map (
		slices => slices)
	port map (
		clk  => clk,
		load => load,
		ena  => ena_addr,
		updn => std_logic'('0'),
		d    => iaddr,
		q    => addr_q,
		eoc  => addr_eoc);
	col_eoc <= addr_eoc(1);
	row_eoc <= addr_eoc(3);
	bnk_eoc <= addr_eoc(4);
--	col_eoc <= addr_eoc(0);
--	row_eoc <= addr_eoc(1);
--	bnk_eoc <= addr_eoc(2);

	col   <= addr_q(col'length-1 downto 0);
	row   <= addr_q(row'length+col'length-1 downto col'length);
	bnk   <= addr_q(bnk'length+row'length+col'length-1 downto row'length+col'length);
	taddr <= addr_q;

	ena_cntr <= not len_eoc and ena;
	cntr_e : entity hdl4fpga.cntrcs
	generic map (
		slices => slices)
	port map (
		clk     => clk,
		load    => load,
		updn    => std_logic'('1'),
		ena     => ena_cntr,
		d       => ilen,
		q       => tlen,
		eoc     => cntr_eoc);
	len_eoc <= cntr_eoc(4);

end;
