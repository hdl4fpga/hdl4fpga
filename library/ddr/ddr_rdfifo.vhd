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

entity ddr_rdfifo is
	generic (
		data_delay  : natural := 1;
		DATA_PHASES : natural := 1;
		DATA_GEAR   : natural := 64;
		WORD_SIZE   : natural := 16;
		BYTE_SIZE   : natural := 8);
	port (
		sys_clk : in  std_logic;
		sys_rdy : out std_logic_vector(DATA_PHASES*WORD_SIZE/BYTE_SIZE-1 downto 0);
		sys_rea : in  std_logic;
		sys_do  : out std_logic_vector(DATA_GEAR*WORD_SIZE-1 downto 0);

		ddr_win_dq  : in std_logic_vector(DATA_PHASES*WORD_SIZE/BYTE_SIZE-1 downto 0);
		ddr_win_dqs : in std_logic_vector(DATA_PHASES*WORD_SIZE/BYTE_SIZE-1 downto 0);
		ddr_dqsi    : in std_logic_vector(DATA_PHASES*WORD_SIZE/BYTE_SIZE-1 downto 0);
		ddr_dqi     : in std_logic_vector(DATA_GEAR*WORD_SIZE-1 downto 0));

end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture struct of ddr_rdfifo is
	subtype byte is std_logic_vector(BYTE_SIZE-1 downto 0);
	type byte_vector is array (natural range <>) of byte;

	subtype word is std_logic_vector(DATA_GEAR*WORD_SIZE/ddr_dqsi'length-1 downto 0);
	type word_vector is array (natural range <>) of word;

	function to_stdlogicvector (
		constant arg : word_vector)
		return std_logic_vector is
		variable dat : word_vector(arg'length-1 downto 0);
		variable val : unsigned(arg'length*byte'length-1 downto 0);
	begin
		dat := arg;
		for i in dat'range loop
			val := val sll byte'length;
			val(byte'range) := unsigned(dat(i));
		end loop;
		return std_logic_vector(val);
	end;

	impure function to_wordvector (
		constant arg : std_logic_vector) 
		return word_vector is
		variable dat : unsigned(arg'length-1 downto 0);
		variable val : word_vector(arg'length/word'length-1 downto 0);
	begin	
		dat := unsigned(arg);
		for i in val'reverse_range loop
			val(i) := std_logic_vector(dat(word'length-1 downto 0));
			dat := dat srl word'length;
		end loop;
		return val;
	end;

	signal do : word_vector(ddr_dqsi'length-1 downto 0);
	signal di : word_vector(ddr_dqsi'length-1 downto 0);

	signal sys_do_win : std_logic;
begin

	process (sys_clk)
		variable acc_rea_dly : std_logic;
	begin
		if rising_edge(sys_clk) then
			sys_do_win  <= acc_rea_dly;
			acc_rea_dly := not sys_rea;
		end if;
	end process;

	di  <= to_wordvector(ddr_dqi);
	datadelay_g : if data_delay/=0 generate
		bytes_g : for i in WORD_SIZE/BYTE_SIZE-1 downto 0 generate
			data_phases_g : for j in 0 to DATA_PHASES-1 generate
				signal pll_req : std_logic;
			begin
	
				process (sys_clk)
					variable q : std_logic_vector(0 to data_delay);
				begin 
					if rising_edge(sys_clk) then
						q := q(1 to q'right) & ddr_win_dq(i*DATA_PHASES+j);
						pll_req <= q(0);
					end if;
				end process;
				sys_rdy(i*DATA_PHASES+j) <= pll_req;
	
	
				inbyte_i : entity hdl4fpga.iofifo
				generic map (
					pll2ser => false,
					DATA_PHASES => 1,
					WORD_SIZE  => word'length,
					BYTE_SIZE  => byte'length)
				port map (
					pll_clk => sys_clk,
					pll_req => pll_req,
	
					ser_ar(0)  => sys_do_win,
					ser_ena(0) => ddr_win_dqs(i*DATA_PHASES+j),
					ser_clk(0) => ddr_dqsi(i*DATA_PHASES+j),
	
					di  => di(i*DATA_PHASES+j),
					do  => do(j*WORD_SIZE/BYTE_SIZE+i));
			end generate;
		end generate;
	end generate;

	no_datadelay_g : if data_delay=0 generate
		bytes_g : for i in WORD_SIZE/BYTE_SIZE-1 downto 0 generate
			data_phases_g : for j in 0 to DATA_PHASES-1 generate
				sys_rdy(i*DATA_PHASES+j) <= ddr_win_dqs(i*DATA_PHASES+j);
				do(j*WORD_SIZE/BYTE_SIZE+i) <= di(i*DATA_PHASES+j);
			end generate;
		end generate;
	end generate;

	
	sys_do <= to_stdlogicvector(do);

end;
