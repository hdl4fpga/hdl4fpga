--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                         --
--    Miguel Angel Sagreras                                                   --
--                                                                            --
-- This source file may be used and distributed without restriction provided  --
-- that this copyright statement is not removed from the file and that any    --
-- derivative work contains  the original copyright notice and the associated --
-- disclaimer.                                                                --
--                                                                            --
-- This source file is free software; you can redistribute it and/or modify   --
-- it under the terms of the GNU General Public License as published by the   --
-- Free Software Foundation, either version 3 of the License, or (at your     --
-- option) any later version.                                                 --
--                                                                            --
-- This source is distributed in the hope that it will be useful, but WITHOUT --
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      --
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   --
-- more details at http://www.gnu.org/licenses/.                              --
--                                                                            --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity iofifo is
	generic (
		pll2ser : boolean;
		DATA_PHASES : natural;
		WORD_SIZE   : natural;
		BYTE_SIZE   : natural);
	port (
		pll_clk : in  std_logic;
		pll_req : in  std_logic := '-';
		pll_ena : in  std_logic := '1';

		ser_ar  : in  std_logic_vector(0 to DATA_PHASES-1) := (others => '1');
		ser_clk : in  std_logic_vector(0 to DATA_PHASES-1);
		ser_ena : in  std_logic_vector(0 to DATA_PHASES-1);

		di  : in  std_logic_vector(WORD_SIZE-1 downto 0);
		do  : out std_logic_vector(WORD_SIZE-1 downto 0));
end;

library hdl4fpga;
use hdl4fpga.base.all;

architecture mix of iofifo is
	component sff
		port (
			clk : in  std_logic;
			sr  : in  std_logic;
			d   : in  std_logic;
			q   : out std_logic);
	end component;

	component aff is
		port (
			ar  : in  std_logic;
			clk : in  std_logic;
			ena : in  std_logic := '1';
			d   : in  std_logic;
			q   : out std_logic);
	end component;

	component dbram
	generic (
		n : natural);
	port (
		clk : in  std_logic;
		we  : in  std_logic;
		wa  : in  std_logic_vector(4-1 downto 0);
		di  : in  std_logic_vector(n-1 downto 0);
		ra  : in  std_logic_vector(4-1 downto 0);
		do  : out  std_logic_vector(n-1 downto 0));
	end component;

	subtype byte is std_logic_vector(WORD_SIZE/DATA_PHASES-1 downto 0);
	type byte_vector is array (natural range <>) of byte;

	signal fifo_clk : std_logic;
	signal fifo_do : byte_vector(ser_clk'reverse_range);
	signal fifo_di : byte_vector(fifo_do'range);

	subtype aword is std_logic_vector(0 to 4-1);

	function to_stdlogicvector (
		arg : byte_vector)
		return std_logic_vector is
		variable dat : byte_vector(arg'length-1 downto 0);
		variable val : unsigned(arg'length*byte'length-1 downto 0);
	begin
		dat := arg;
		for i in arg'range loop
			val := val sll byte'length;
			val(byte'range) := unsigned(arg(i));
		end loop;
		return std_logic_vector(val);
	end;

	function to_bytevector (
		arg : std_logic_vector)
		return byte_vector is
		variable dat : unsigned(arg'length-1 downto 0);
		variable val : byte_vector(arg'length/byte'length-1 downto 0);
	begin
		dat := unsigned(arg);
		for i in val'reverse_range loop
			val(i) := std_logic_vector(dat(byte'range));
			dat := dat srl byte'length;
		end loop;
		return val;
	end;

	signal apll_d : aword;
	signal apll_q : aword;

begin

	apll_d <= inc(gray(apll_q));
	apll_g: for j in apll_d'range generate
		signal apll_set : std_logic;
	begin
		apll_set <= not pll_req;
		ffd_i : aff
		port map (
			clk => pll_clk,
			ar  => apll_set,
			ena => pll_ena,
			d   => apll_d(j),
			q   => apll_q(j));
	end generate;

	fifo_di <= to_bytevector(di);

	phases_g : for l in ser_clk'range generate
		signal aser_d : aword;
		signal aser_q : aword;
		signal fifo_we : std_logic;
		signal fifo_wa : aword;
		signal fifo_ra : aword;
	begin


		aser_d <= inc(gray(aser_q));

		sr_g : if pll2ser generate
			gcntr_g: for k in aser_q'range  generate
				signal aser_set : std_logic;
			begin
				aser_set <= not ser_ena(l);

				ffd_i : sff
				port map (
					clk => ser_clk(l),
					sr  => aser_set,
					d   => aser_d(k),
					q   => aser_q(k));
			end generate;	
		end generate;	

		ar_g : if not pll2ser generate
			gcntr_g: for k in aser_q'range  generate
				ffd_i : aff
				port map (
					ar  => ser_ar(l),
					clk => ser_clk(l),
					ena => ser_ena(l),
					d   => aser_d(k),
					q   => aser_q(k));
			end generate;
		end generate;

		fifo_clk <= 
			pll_clk when pll2ser else
			ser_clk(l);

		fifo_wa <=
			apll_q when pll2ser else
			aser_q;

		fifo_we <=
			pll_req when pll2ser else
			ser_ena(l);

		ram_i : dbram
		generic map (
			n => byte'length)
		port map (
			clk => fifo_clk,
			we  => fifo_we,
			wa  => fifo_wa,
			di  => fifo_di(l),
			ra  => fifo_ra,
			do  => fifo_do(l));

		fifo_ra <=
			aser_q when pll2ser else
			apll_q;

	end generate;

	do <= to_stdlogicvector(fifo_do);
end;
