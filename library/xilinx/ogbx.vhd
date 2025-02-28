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
use hdl4fpga.profiles.all;

entity ogbx is
	generic (
		device    : fpga_devices := xc7a;
		size      : natural;
		gear      : natural);
	port (
		rst   : in  std_logic := '0';
		clk   : in  std_logic;
		clkx2 : in  std_logic := '0';
		t     : in  std_logic_vector(0 to gear*size-1) := (others => '0');
		tq    : out std_logic_vector(0 to size-1);
		d     : in  std_logic_vector(0 to gear*size-1);
		q     : out std_logic_vector(0 to size-1));
end;

library unisim;
use unisim.vcomponents.all;

library hdl4fpga;

architecture beh of ogbx is

begin

	reg_g : for i in q'range generate
		signal pi  : std_logic_vector(0 to 8-1);
		signal pit : std_logic_vector(0 to 8-1);
	begin

		process (d)
		begin
			pi <= (others => '0');
			for j in 0 to gear-1 loop
				pi(j) <= d(gear*i+j);
			end loop;
		end process;

		process (t)
		begin
			pit <= (others => '0');
			for j in 0 to gear-1 loop
				pit(j) <= t(gear*i+j);
			end loop;
		end process;

		gear1_g : if gear = 1 generate
			fft_i : fdrse
			port map (
				c  => clk,
				ce => '1',
				s  => '0',
				r  => '0',
				d  => pit(0),
				q  => tq(i));

			ffd_i : fdrse
			port map (
				c  => clk,
				ce => '1',
				s  => '0',
				r  => '0',
				d  => pi(0),
				q  => q(i));

		end generate;

		gear2_g : if gear = 2 generate
			xc3s_g : if device=xc3s generate
				signal clk_n : std_logic;
			begin
				ddrto_i : fdce
				port map (
					clr => '0',
					c   => clk,
					ce  => '1',
					d   => pit(0),
					q   => tq(i));
		
				clk_n <= not clk;
				oddr_i : oddr2
				port map (
					c0 => clk,
					c1 => clk_n,
					ce => '1',
					r  => '0',
					s  => '0',
					d0 => pi(0),
					d1 => pi(1),
					q  => q(i));
			end generate;

			xcother_g : if device/=xc3s generate
				fft_i : fdrse
				port map (
					c  => clk,
					ce => '1',
					s  => '0',
					r  => '0',
					d  => pit(0),
					q  => tq(i));

				oddr_i : oddr
				generic map (
					ddr_clk_edge => "SAME_EDGE")
				port map (
					c  => clk,
					ce => '1',
					d1 => pi(0),
					d2 => pi(1),
					q  => q(i));
			end generate;

		end generate;

		oserdese_g : if gear > 2 generate
			xc5v_g : if device=xc5v generate
				signal sr : std_logic;
			begin

				oser_i : oserdes
				generic map (
					data_width => gear)
				port map (
					sr       => rst,
					clk      => clkx2,
					clkdiv   => clk,
					d1       => pi(0),
					d2       => pi(1),
					d3       => pi(2),
					d4       => pi(3),
					d5       => pi(4),
					d6       => pi(5),
					oq       => q(i),
	
					rev      => '0',
					t1       => pit(0),
					t2       => pit(1),
					t3       => pit(2),
					t4       => pit(3),
					tq       => tq(i),
					oce      => '1',
					shiftin1 => '0',
					shiftin2 => '0',
					tce      => '1');
			end generate;

			xc7a_g : if device=xc7a generate
				oser_i : oserdese2
				generic map (
					data_width => gear)
				port map (
					rst      => rst,
					clk      => clkx2,
					clkdiv   => clk,
					d1       => pi(0),
					d2       => pi(1),
					d3       => pi(2),
					d4       => pi(3),
					d5       => pi(4),
					d6       => pi(5),
					d7       => pi(6),
					d8       => pi(7),
					oq       => q(i),
	
					t1       => pit(0),
					t2       => pit(1),
					t3       => pit(2),
					t4       => pit(3),
					tq       => tq(i),
					oce      => '1',
					shiftin1 => '0',
					shiftin2 => '0',
					tce      => '1',
					tbytein  => '0');
			end generate;
		end generate;

	end generate;

end;





