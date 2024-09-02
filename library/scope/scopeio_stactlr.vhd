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
		so_data : out std_logic_vector(0 to 8-1));
end;

architecture def of scopeio_stactlr is
				
	signal req       : std_logic := '0';
	signal rdy       : std_logic := '0';
	signal btn       : std_logic_vector(0 to 4-1);
	signal debnc     : std_logic_vector(btn'range) := (others => '0');
	signal event_vld : std_logic;
	signal event     : std_logic_vector(0 to 2-1) := "00";

begin

	btn <= (right, left, down, up);
	debounce_g : for i in btn'range generate
		process (sio_clk)
			constant rebound0s : natural := 6;
			constant rebound1s : integer := -1;

			type states is ( s_released, s_pressed);
			variable state : states := s_released;
			variable cntr  : integer range -1 to max(rebound1s, rebound0s) := -1;
			variable edge  : std_logic;
		begin
			if rising_edge(sio_clk) then
				case state is
				when s_released =>
					debnc(i) <= '0';
					if btn(i)='1' then
						if cntr < 0 then
							cntr := rebound0s;
							debnc(i) <= '1';
							state := s_pressed;
						elsif (video_vton and not edge)='1' then
							cntr := cntr - 1;
						end if;
					elsif cntr < rebound1s then
						if (video_vton and not edge)='1' then
							cntr := cntr + 1;
						end if;
					end if;
				when s_pressed =>
					debnc(i) <= '1';
					if btn(i)='0' then
						if cntr < 0 then
							debnc(i) <= '0';
							cntr  := rebound1s;
							state := s_released;
						elsif (video_vton and not edge)='1' then
							cntr := cntr - 1;
						end if;
					elsif cntr < rebound0s then
						if (video_vton and not edge)='1' then
							cntr := cntr + 1;
						end if;
					end if;
				end case;
				edge := video_vton;
			end if;
		end process;
	end generate;

	event_vld <= '0' when debnc=(debnc'range => '0') else '1';
	event <= encoder(debnc);
	tp(1 to 8) <= debnc & not debnc;
	btnctlr_e : entity hdl4fpga.scopeio_btnctlr
	generic map (
		layout => layout)
	port map (
		-- tp      => tp,
		event_vld => event_vld,
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