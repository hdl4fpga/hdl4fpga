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