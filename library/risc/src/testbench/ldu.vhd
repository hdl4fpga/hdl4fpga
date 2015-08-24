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

entity testbench is
end;

architecture behavioral of testbench is

	type dinT is array (natural range <>) of std_ulogic_vector (0 to 31);
	type szT  is array (natural range <>) of std_ulogic_vector (0 to 1);

	constant signC : std_ulogic_vector := "01";
	constant a0C : std_ulogic_vector := "01";
	constant a1C : std_ulogic_vector := "01";
	constant szC  : szT (0 to 2) := ("00", "01", "11");
	constant dinC : dinT(0 to 3) := (
	    X"81020304", X"01820304", X"01028304", X"01020384");

	component ldu
		port (
			a     : in  std_ulogic_vector(0 to 1);
			sz    : in  std_ulogic_vector(0 to 1);
			sign  : in  std_ulogic;
			din   : in  std_ulogic_vector(0 to 31);
			dout  : out std_ulogic_vector(31 downto 0);
			byteE : out std_ulogic_vector(0 to 3));
	end component;
			
	signal aS     : std_ulogic_vector(1 downto 0);
	signal szS    : std_ulogic_vector(0 to 1);
	signal signS  : std_ulogic;
	signal dinS   : std_ulogic_vector(0 to 31);
	signal doutS  : std_ulogic_vector(31 downto 0);
	signal byteES : std_ulogic_vector(3 downto 0);

begin
	dut : ldu
		port map (
			a    => aS,
			sz   => szS,
			sign => signS,
			din  => dinS,
			dout => doutS,
			byteE => byteES);

	process
		variable step   : natural := 0;
		variable mullen : natural := 0;
	begin
	    
        mullen := 1;

		signS <= signC((step / mullen) mod signC'length);
		mullen := mullen * signC'length;

		aS(0) <= a0C((step / mullen) mod a0C'length);
		mullen := mullen * a0C'length;
		
		aS(1) <= a1C((step / mullen) mod a1C'length);
		mullen := mullen * a1C'length;
		
		szS   <= szC((step / mullen) mod szC'length);
		mullen := mullen * szC'length;
		
		dinS  <= dinC((step / mullen) mod dinC'length);
        mullen := mullen * dinS'length;

		step := step + 1;
		wait for 20 ns;
	end process;
end;
