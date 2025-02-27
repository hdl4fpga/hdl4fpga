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
	signal event_vld : std_logic := '0';
	signal event     : std_logic_vector(0 to 2-1);

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
	btnctlr_e : entity hdl4fpga.scopeio_btnctlr
	generic map (
		layout => layout)
	port map (
		tp      => tp,
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

