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

entity rom7seg is
	generic (
		char_map : std_logic_vector);
	port (
		code : in std_logic_vector;
		segment_a : out std_logic;
		segment_b : out std_logic;
		segment_c : out std_logic;
		segment_d : out std_logic;
		segment_e : out std_logic;
		segment_f : out std_logic;
		segment_g : out std_logic;
		segment_dp : out std_logic);
end;

architecture mixed of rom7seg is
begin
	segment_a  <= CHAR_MAP(to_integer(unsigned(code))*8+0);
	segment_b  <= CHAR_MAP(to_integer(unsigned(code))*8+1);
	segment_c  <= CHAR_MAP(to_integer(unsigned(code))*8+2);
	segment_d  <= CHAR_MAP(to_integer(unsigned(code))*8+3);
	segment_e  <= CHAR_MAP(to_integer(unsigned(code))*8+4);
	segment_f  <= CHAR_MAP(to_integer(unsigned(code))*8+5);
	segment_g  <= CHAR_MAP(to_integer(unsigned(code))*8+6);
	segment_dp <= CHAR_MAP(to_integer(unsigned(code))*8+7);
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;

entity seg7 is
	generic (
		refresh : natural := 2**12;
		code_size : natural := 4;
		char_map : std_logic_vector := 
			"00000011" & -- 0
			"10011111" & -- 1
			"00100101" & -- 2
			"00001101" & -- 3
			"10011001" & -- 4
			"01001001" & -- 5
			"01000001" & -- 6
			"00011111" & -- 7
			"00000001" & -- 8
			"00001001" & -- 9
			"00010001" & -- A
			"11000001" & -- B
			"01100011" & -- C
			"10000101" & -- D
			"01100001" & -- E
			"01110001"); -- F
	port (
		clk : in  std_logic;
		data : in  std_logic_vector;
		segment_a : out std_logic;
		segment_b : out std_logic;
		segment_c : out std_logic;
		segment_d : out std_logic;
		segment_e : out std_logic;
		segment_f : out std_logic;
		segment_g : out std_logic;
		segment_dp : out std_logic;
		display_turnon : out std_logic_vector);
end;

architecture mixed of seg7 is
	signal display_code : std_logic_vector(0 to code_size-1);
	signal display_next : std_logic;
	signal display_ena  : std_logic_vector(0 to display_turnon'length-1) := ('0', others => '1');
begin
	rfsh_ctlr : process (clk)
		constant max_count : natural := refresh-1;
		variable refresh_counter : natural range 0 to max_count;
	begin
		if rising_edge(clk) then
			if refresh_counter < max_count then
				display_next <= '0';
				refresh_counter := refresh_counter +1;
			else 
				display_next <= '1';
				refresh_counter := 0;
			end if;
		end if;
	end process;

	sweep : process (clk)
	begin
		if rising_edge(clk) then
			if display_next='1' then
				display_ena <= display_ena(1 to display_ena'right) & display_ena(0);
			end if;
		end if;
	end process;

	mux_ctlr : process (display_ena, data)
		variable aux : std_logic;
	begin
		for i in display_code'range loop
			aux := '0';
			for j in display_ena'range loop
				if display_ena(j)='0' then
					aux := aux or data(data'left+code_size*j+i);
				end if;
			end loop;
			display_code(i) <= aux;
		end loop;
	end process;

	display : entity hdl4fpga.rom7seg 
	generic map (
		char_map => char_map)
	port map (
		display_code,
		segment_a,
		segment_b,
		segment_c,
		segment_d,
		segment_e,
		segment_f,
		segment_g,
		segment_dp);

	display_turnon <= display_ena;
end;

