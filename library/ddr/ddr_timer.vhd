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

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.ddr_param.all;

entity ddr_timer is
	generic ( 
		timers : natural_vector);
	port (
		sys_clk : in  std_logic;
		tmr_sel : in  std_logic_vector;
		sys_req : in  std_logic;
		sys_rdy : out std_logic);
end;

architecture def of ddr_timer is

	constant stages : natural := unsigned_num_bits(max(timers))/4;
	constant timer_size : natural := unsigned_num_bits(max(timers))+stages;
	subtype tword is std_logic_vector(timer_size-1 downto 0);
	type tword_vector is array (natural range <>) of tword;
	
	impure function stage_size
		return natural_vector is
		variable val : natural_vector(stages downto 0);
		variable quo : natural := timer_size mod stages;
	begin
		val(0) := 0;
		for i in 1 to stages loop
			val(i) := timer_size/stages + val(i-1);
			if i*quo >= stages then
				val(i) := val(i) + 1;
				quo := quo - 1;
			end if;
		end loop;
		return val;
	end;

	impure function to_twordvector 
		return tword_vector is
		variable val : tword_vector(timers'range);
		variable csize : natural;
	begin
		val := (others => (others => '-'));
		for i in timers'range loop
			for j in stages-1 downto 0 loop
				csize := stage_size(j+1)-stage_size(j);
				val(i) := std_logic_vector(unsigned(val(i)) sll csize);
				val(i)(csize-1 downto 0) := std_logic_vector(to_unsigned(((2**csize-1)+((timers(i)-stages)/2**(stage_size(j)-j)) mod 2**(csize-1)) mod 2**csize, csize));
			end loop;
		end loop;
		return val;
	end;

	constant timer_values : tword_vector := to_twordvector;
	constant xx : natural_vector(stages-1 downto 0) := stage_size(stages downto 1);

	signal data : tword;

begin

	process (sys_clk)
	begin
		if rising_edge(sys_clk) then
--			if sys_req='1' then
				data <= timer_values(to_integer(unsigned(tmr_sel)));
--			end if;
		end if;
	end process;

	timer_e : entity hdl4fpga.timer
	generic map (
		stage_size => xx)
	port map (
		data => data,
		clk => sys_clk,
		req => sys_req,
		rdy => sys_rdy);

end;
