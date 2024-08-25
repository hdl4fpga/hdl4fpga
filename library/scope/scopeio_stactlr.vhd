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
use ieee.math_real.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.hdo.all;

entity scopeio_stactlr is
	generic (
		debug  : boolean := false;
		layout : string);
	port (
		tp      : out std_logic_Vector(1 to 32);
		left    : in  std_logic;
		up      : in  std_logic; 
		down    : in  std_logic;
		right   : in  std_logic;
		sio_clk : in  std_logic;
		video_vton : in std_logic;
		si_frm  : in  std_logic := '0';
		si_irdy : in  std_logic := '1';
		si_trdy : out std_logic := '0';
		si_data : in  std_logic_vector;
		so_frm  : out std_logic;
		so_irdy : out std_logic;
		so_trdy : in  std_logic := '1';
		so_data : out std_logic_vector);
end;

architecture def of scopeio_stactlr is
				
	signal req       : std_logic := '0';
	signal rdy       : std_logic := '0';
	signal btn       : std_logic_vector(0 to 4-1);
	signal debnc     : std_logic_vector(btn'range);
	signal event     : std_logic_vector(0 to 2-1);

begin

	btn <= (right, left, down, up);
	debounce_g : for i in btn'range generate
		process (sio_clk)
			constant rebounds : natural := 0;
			type states is (s_pressed, s_released);
			variable state : states;
			variable cntr  : integer range -1 to rebounds;
			variable edge  : std_logic;
		begin
			if rising_edge(sio_clk) then
				if (video_vton and not edge)='1' or debug then
					case state is
					when s_pressed =>
						if btn(i)='0' then
							if cntr < 0 then
								debnc(i) <= '0';
								state := s_released;
							else
								cntr := cntr - 1;
							end if;
						elsif cntr < rebounds then
							cntr := cntr + 1;
						end if;
					when s_released =>
						if btn(i)='1' then
							if cntr >= rebounds then
								cntr := rebounds;
								debnc(i) <= '1';
								state := s_pressed;
							else
								cntr := cntr + 1;
							end if;
						elsif cntr >= 0 then
							cntr := cntr - 1;
						end if;
					end case;
				end if;
				edge := video_vton;
			end if;
		end process;
	end generate;

	process(sio_clk)
		type states is (s_request, s_wait);
		variable state : states;
	begin
		if rising_edge(sio_clk) then
			case state is
			when s_request =>
				if to_bitvector(debnc)/=(debnc'range =>'0') then
					event <= to_stdlogicvector(to_bitvector(encoder(debnc)));
					req <= not to_stdulogic(to_bit(rdy));
					state := s_wait;
				else
					event <= (others => '-');
				end if;
			when s_wait =>
				if (to_bit(req) xor to_bit(rdy))='0' then
					if debnc(to_integer(unsigned(event)))='0' then
						state := s_request;
					else
						req <= not to_stdulogic(to_bit(rdy));
					end if;
				end if;
			end case;
		end if;
	end process;

	btnctlr_e : entity hdl4fpga.scopeio_btnctlr
	generic map (
		debug => debug,
		layout => layout)
	port map (
		tp      => tp,
		req     => req,
		rdy     => rdy,
		event   => event,
		sio_clk => sio_clk,
		video_vton => video_vton,
		si_frm  => si_frm,
		si_irdy => si_irdy,
		si_trdy => si_trdy,
		si_data => si_data,
		so_frm  => so_frm,
		so_irdy => so_irdy,
		so_trdy => so_trdy,
		so_data => so_data);

end;