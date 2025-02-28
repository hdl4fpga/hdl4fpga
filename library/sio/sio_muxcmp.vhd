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

entity sio_muxcmp is
	generic (
		n : natural := 1);
    port (
		mux_data : in  std_logic_vector;
        sio_clk  : in  std_logic;
        sio_frm  : in  std_logic;
		sio_irdy : in  std_logic;
		sio_trdy : out std_logic;
        si_data  : in  std_logic_vector;
		so_last  : out std_logic;
		so_end   : out std_logic;
		so_equ   : out std_logic_vector(0 to n-1));
end;

architecture def of sio_muxcmp is
	signal sio_last : std_logic_vector(0 to n-1);
	signal sio_end  : std_logic_vector(0 to n-1);
begin

	g : for i in 0 to n-1 generate

		signal sio_data : std_logic_vector(0 to mux_data'length/n-1);
		signal so_data  : std_logic_vector(si_data'range);

	begin

		sio_data <= multiplex(mux_data, i, sio_data'length);
		data_e : entity hdl4fpga.sio_mux
		port map (
			mux_data => sio_data,
			sio_clk  => sio_clk,
			sio_frm  => sio_frm,
			sio_irdy => sio_irdy,
			sio_trdy => sio_trdy,
			so_last  => sio_last(i),
			so_end   => sio_end(i),
			so_data  => so_data);

		process (si_data, so_data, sio_clk)
			variable cy : std_logic;
		begin
			if rising_edge(sio_clk) then
				if sio_frm='0' then
					cy := '1';
				elsif sio_irdy='1' then
					cy := setif(so_data=si_data) and cy;
				end if;
			end if;
			so_equ(i) <= setif(so_data=si_data) and cy;
		end process;


	end generate;

	so_last <= sio_last(0);
	so_end  <= sio_end(0);
end;



