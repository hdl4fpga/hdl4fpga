--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                    --
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

package cpu_parts is
	component rom is 
		generic (
			M : natural;
			N : natural;
			DATA : std_ulogic_vector);
		port (
			addr : in  std_ulogic_vector(M-1 downto 0);
			dout : out std_ulogic_vector(N-1 downto 0));
	end component;

	component spram is 
		generic (
			M : natural;
			N : natural;
			SYNC_ADDRESS : boolean := TRUE;
			READ_FIRST : boolean := FALSE);
		port (
			clk  : in  std_ulogic;
			we   : in  std_ulogic := '0';
			addr : in  std_ulogic_vector(M-1 downto 0);
			din  : in  std_ulogic_vector(N-1 downto 0) := (others => '-');
			dout : out std_ulogic_vector(N-1 downto 0));
	end component;

	component dpram
		generic (
			M : natural;
			N : natural);
		port (
			clk   : in  std_ulogic;
			we    : in  std_ulogic;
			wAddr : in  std_ulogic_vector(M-1 downto 0);
			rAddr : in  std_ulogic_vector(M-1 downto 0);
			din   : in  std_ulogic_vector(N-1 downto 0);
			dout  : out std_ulogic_vector(N-1 downto 0));
	end component;

	component pc32 is
		generic (
			N : natural := 32;
			M : natural := 2);
		port (
			rst : in std_ulogic;
			clk : in std_ulogic;
			ena : in std_ulogic;
			enaSel : in std_ulogic := '1';
			selData : in std_ulogic_vector (M-1 downto 0);
			data   : in std_ulogic_vector (2**M*N-1 downto N);
			dataP2 : in std_ulogic_vector (2**M*N-1 downto N);
			q   : out std_ulogic_vector (N-1 downto 0);
			cy  : out std_ulogic);
	end component;

	component barrel
		generic (
			N : natural;
			M : natural);
		port (
			sht  : in  std_ulogic_vector(M-1 downto 0);
			din  : in  std_ulogic_vector(N-1 downto 0);
			dout : out std_ulogic_vector(N-1 downto 0));
	end component;

	component shift_mask is
		generic (
			N : natural;
			M : natural);
		port (
			sht  : in  std_ulogic_vector(M-1 downto 0);
			mout : out std_ulogic_vector(N-1 downto 0));
	end component;

	component ldu
		port (
			a     : in  std_ulogic_vector(1 downto 0);
			sz    : in  std_ulogic_vector(1 downto 0);
			sign  : in  std_ulogic;
			din   : in  std_ulogic_vector(0 to 31); 
			dout  : out std_ulogic_vector(31 downto 0);
			byteE : out std_ulogic_vector(3 downto 0));
	end component;

	component stu is
		port (
			a    : in  std_ulogic_vector(1 downto 0);
			sz   : in  std_ulogic_vector(1 downto 0);
			din  : in  std_ulogic_vector(31 downto 0); 
			dout : out std_ulogic_vector(0 to 31);
			memE : out std_ulogic_vector(0 to 3));
	end component;
end;
