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

entity igbx is
	generic (
		device    : fpga_devices := xc7a;
		size      : natural := 1;
		gear      : natural := 2;
		data_edge : string := "SAME_EDGE");
	port (
		rst       : in  std_logic := '0';
		sclk      : in std_logic := '0';
		clkx2     : in std_logic := '0';
		clk       : in std_logic;
		d         : in  std_logic_vector(0 to size-1);
		q         : out std_logic_vector(0 to size*gear-1));
end;

library unisim;
use unisim.vcomponents.all;

architecture beh of igbx is
begin

	reg_g : for i in d'range generate
		signal po : std_logic_vector(0 to 4-1);
	begin

		gear1_g : if gear=1 generate
			ffd_i : fdrse
			port map (
				c  => clk,
				ce => '1',
				s  => '0',
				r  => '0',
				d  => d(i),
				q  => po(0));

		end generate;

		gear2_g : if gear=2 generate
			xc3s_g : if device=xc3s generate
				signal clk_n : std_logic;
			begin
				clk_n <= not clk;
				iddr_i : iddr2
				generic map (
					ddr_alignment => "NONE")
				port map (
					c0  => clk,
					c1  => clk_n,
					ce => '1',
					d  => d(i),
					q0 => po(0),
					q1 => po(1));
			end generate;

			xv5_g : if device=xc5v generate
				iddr_i : iddr
				generic map (
					DDR_CLK_EDGE => data_edge)
				port map (
					c  => clk,
					ce => '1',
					d  => d(i),
					q1 => po(0),
					q2 => po(1));
			end generate;

		end generate;

		iserdese_g : if gear=4 generate
			xv5_g : if device=xc5v generate
				signal sy_rst : std_logic;
				signal clkb   : std_logic;
				signal oclkb  : std_logic;
			begin

				process (rst, clk)
				begin
					if rst='1' then
						sy_rst <= '1';
					elsif rising_edge(clk) then
						sy_rst <= '0';
					end if;
				end process;

				clkb  <= not sclk;
				iser_i : iserdes_nodelay
				generic map (
					INTERFACE_TYPE => "MEMORY",
					DATA_RATE      => "DDR",
					DATA_WIDTH     => 4)
				port map (
					rst      => sy_rst,
					clk      => sclk,
					clkb     => clkb,
					oclk     => clkx2,
					clkdiv   => clk,
					d        => d(i),
					q1       => po(3),
					q2       => po(2),
					q3       => po(1),
					q4       => po(0),
	
					bitslip  => '0',
					ce1      => '1',
					ce2      => '1',
					shiftin1 => '0',
					shiftin2 => '0');
			end generate;

			xv7_g : if device=xc7a generate
				signal clkb  : std_logic;
				signal oclkb : std_logic;
			begin
				clkb  <= not sclk;
				oclkb <= not clkx2;
				iser_i : iserdese2
				generic map (
					INTERFACE_TYPE => "MEMORY_DDR3",
					DATA_RATE      => "DDR",
					IOBDELAY       => "BOTH")
				port map (
					rst          => rst,
					clk          => sclk,
					clkb         => clkb,
					oclk         => clkx2,
					oclkb        => oclkb,
					clkdivp      => clk,
					clkdiv       => clk,
					ddly         => d(i),
					q1           => po(3),
					q2           => po(2),
					q3           => po(1),
					q4           => po(0),
	
					dynclksel    => '0',
					dynclkdivsel => '0',
					bitslip      => '0',
					ce1          => '1',
					ce2          => '1',
					d            => '0',
					ofb          => '0',
					shiftin1     => '0',
					shiftin2     => '0');
			end generate;

		end generate;

		process (po)
		begin
			for j in 0 to gear-1 loop
				q(gear*i+j) <= po(j);
			end loop;
		end process;

	end generate;

end;




