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

entity xdr_rdfifo is
	generic (
		data_delay  : natural := 1;
		data_phases : natural := 1;
		line_size   : natural := 64;
		word_size   : natural := 16;
		byte_size   : natural := 8);
	port (
		sys_clk : in  std_logic;
		sys_rdy : out std_logic_vector((line_size/word_size)-1 downto 0);
		sys_rea : in  std_logic;
		sys_do  : out std_logic_vector(line_size-1 downto 0);

		xdr_win_dq  : in std_logic_vector(data_phases*word_size/byte_size-1 downto 0);
		xdr_win_dqs : in std_logic_vector(data_phases*word_size/byte_size-1 downto 0);
		xdr_dqsi    : in std_logic_vector(data_phases*word_size/byte_size-1 downto 0);
		xdr_dqi     : in std_logic_vector(line_size-1 downto 0));

end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture struct of xdr_rdfifo is
	subtype byte is std_logic_vector(byte_size-1 downto 0);
	type byte_vector is array (natural range <>) of byte;

	function to_bytevector (
		arg : std_logic_vector) 
		return byte_vector is
		variable dat : unsigned(arg'length-1 downto 0);
		variable val : byte_vector(arg'length/byte'length-1 downto 0);
	begin	
		dat := unsigned(arg);
		for i in val'reverse_range loop
			val(i) := std_logic_vector(dat(byte'length-1 downto 0));
			dat := dat srl byte'length;
		end loop;
		return val;
	end;

	function to_stdlogicvector (
		arg : byte_vector)
		return std_logic_vector is
		variable dat : byte_vector(arg'length-1 downto 0);
		variable val : std_logic_vector(arg'length*byte'length-1 downto 0);
	begin
		dat := arg;
		for i in dat'range loop
			val := val sll byte'length;
			val(byte'range) := dat(i);
		end loop;
		return val;
	end;

	subtype word is std_logic_vector(line_size/xdr_dqsi'length-1 downto 0);
	type word_vector is array (natural range <>) of word;

	function shuffle_word (
		arg : byte_vector)
		return word_vector is
		variable aux : byte_vector(word'length/byte'length-1 downto 0);
		variable val : word_vector(arg'length/aux'length-1 downto 0);
	begin
		for i in val'range loop
			aux := (others => (others => '-'));
			for j in aux'range loop
				aux(j) := arg(i*aux'length+j);
			end loop;
			val(i) := to_stdlogicvector(aux);
		end loop;
		return val;
	end;

	function unshuffle_word (
		arg : word_vector)
		return byte_vector is
		variable aux : byte_vector(word'length/byte'length-1 downto 0);
		variable val : byte_vector(arg'length*aux'length-1 downto 0);
	begin
		for i in arg'range loop
			aux := to_bytevector(arg(i));
			for j in aux'range loop
				val(j*arg'length+i) := aux(j);
			end loop;
		end loop;
		return val;
	end;

	signal do : word_vector(xdr_dqsi'length-1 downto 0);
	signal di : word_vector(xdr_dqsi'length-1 downto 0);

begin

	di  <= shuffle_word(to_bytevector(xdr_dqi));
	xdr_fifo_g : for i in xdr_dqsi'range generate
		signal pll_req : std_logic;
		signal ser_clk : std_logic;
		signal ser_req : std_logic;

	begin

		process (sys_clk)
			variable acc_rea_dly : std_logic;
			variable sys_do_win : std_logic;
		begin
			if rising_edge(sys_clk) then
				ser_req  <= not sys_do_win;
				sys_do_win  := acc_rea_dly;
				acc_rea_dly := not sys_rea;
			end if;
		end process;

		process (sys_clk)
			variable q : std_logic_vector(0 to data_delay);
		begin 
			if rising_edge(sys_clk) then
				q := q(1 to q'right) & xdr_win_dq(i);
				pll_req <= q(0);
			end if;
		end process;
		sys_rdy(i) <= pll_req;

--		clk_data_phases_g: if data_edges > 1 generate
--			dqs_delayed_e : entity hdl4fpga.pgm_delay
--			port map (
--				xi  => xdr_dqsi(i),
--				x_p => ser_clk(0),
--				x_n => ser_clk(1));
--		end generate;

		inbyte_i : entity hdl4fpga.iofifo
		generic map (
			pll2ser => false,
			data_phases => 1,
			word_size  => word'length,
			byte_size  => byte'length)
		port map (
			pll_clk => sys_clk,
			pll_req => pll_req,

			ser_req(0) => ser_req,
			ser_ena(0) => xdr_win_dqs(i),
			ser_clk(0) => ser_clk,

			do  => do(i),
			di  => di(i));
	end generate;
	sys_do <= to_stdlogicvector(unshuffle_word(do));

end;
