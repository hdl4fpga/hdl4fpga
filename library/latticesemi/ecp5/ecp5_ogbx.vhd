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

entity ecp5_ogbx is
	generic (
		lfbt_frst : boolean := true;
		interlace : boolean := false;
		mem_mode  : boolean := true;
		size      : natural := 1;
		gear      : natural);
	port (
		rst       : in  std_logic := '0';
		sclk      : in  std_logic;
		eclk      : in std_logic := '0';
		dqsw270   : in std_logic := '0';
		t         : in  std_logic_vector(0 to gear*size-1) := (others => '0');
		tq        : out std_logic_vector(0 to size-1);
		d         : in  std_logic_vector(0 to gear*size-1);
		q         : out std_logic_vector(0 to size-1));
end;

library ecp5u;
use ecp5u.components.all;

library hdl4fpga;
use hdl4fpga.base.all;

architecture beh of ecp5_ogbx is
	signal ti : std_logic_vector(d'range);
	signal di : std_logic_vector(d'range);
begin

	ti <= 
		reverse(reverse(t), size) when not lfbt_frst and not interlace else
		reverse(         t, gear) when not lfbt_frst and     interlace else
		t;

	di <= 
		reverse(reverse(d), size) when not lfbt_frst and not interlace else
		reverse(         d, gear) when not lfbt_frst and     interlace else
		d;

	dr_g : for i in q'range generate
		gear1_g : if gear = 1 generate
			ffdt_i : fd1s3ax
			port map (
				ck => sclk,
				d  => ti(i),
				q  => tq(i));

			ffd_i : fd1s3ax
			port map (
				ck => sclk,
				d  => di(i),
				q  => q(i));
		end generate;

		gear2_g : if gear=2 generate
    		oddr_i : oddrx1f
    		port map (
    			rst  => rst,
    			sclk => sclk,
    			d0   => di(setif(interlace, gear*i+0, 0*size+i)),
    			d1   => di(setif(interlace, gear*i+1, 1*size+i)),
    			q    => q(i));

			tq(i) <= ti(i);
		end generate;

		memgear4_g : if gear=4 and mem_mode generate
    		tshx2dqa_i : tshx2dqa
    		port map (
    			rst  => rst,
    			sclk => sclk,
    			eclk => eclk,
    			dqsw270 => dqsw270,
    			t0   => ti(setif(interlace, gear*i+0, 0*size+i)),
    			t1   => ti(setif(interlace, gear*i+2, 2*size+i)),
    			q    => tq(i));

    		oddrx2dqa_i : oddrx2dqa
    		port map (
    			rst  => rst,
    			sclk => sclk,
    			eclk => eclk,
    			dqsw270 => dqsw270,
    			d0   => di(setif(interlace, gear*i+0, 0*size+i)),
    			d1   => di(setif(interlace, gear*i+1, 1*size+i)),
    			d2   => di(setif(interlace, gear*i+2, 2*size+i)),
    			d3   => di(setif(interlace, gear*i+3, 3*size+i)),
    			q    => q(i));
		end generate;

		sergear4_g : if gear=4 and not mem_mode generate
			ffdt_i : fd1s3ax
			port map (
				ck => sclk,
				d  => ti(i),
				q  => tq(i));

			oddr_i : oddrx2f
			port map(
				rst  => rst,
				sclk => sclk,
				eclk => eclk,
				d0   => di(gear*i+0),
				d1   => di(gear*i+1),
				d2   => di(gear*i+2),
				d3   => di(gear*i+3),
				q    => q(i));
		end generate;

		gear7_g : if gear=7 generate
			ffdt_i : fd1s3ax
			port map (
				ck => sclk,
				d  => ti(i),
				q  => tq(i));

			oddr_i : oddr71b
			port map(
				rst  => rst,
				eclk => eclk,
				sclk => sclk,
				d0   => di(gear*i+0),
				d1   => di(gear*i+1),
				d2   => di(gear*i+2),
				d3   => di(gear*i+3),
				d4   => di(gear*i+4),
				d5   => di(gear*i+5),
				d6   => di(gear*i+6),
				q    => q(i));
		end generate;

	end generate;

end;
