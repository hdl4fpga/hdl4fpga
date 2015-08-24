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


---------------------------
-- Big Endian Store Unit --
---------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ldu is
	port (
		a     : in  std_ulogic_vector(1 downto 0);
		sz    : in  std_ulogic_vector(1 downto 0);
		sign  : in  std_ulogic;
		din   : in  std_ulogic_vector(0 to 31); 
		dout  : out std_ulogic_vector(31 downto 0);
		byteE : out std_ulogic_vector(3 downto 0));
end;

architecture beh of ldu is
	constant BYTE_SIZE : natural := 8;

	constant ld_byte : std_ulogic_vector := "00";
	constant ld_half : std_ulogic_vector := "01";
	constant ld_word : std_ulogic_vector := "11";

	constant load_byte_0 :std_ulogic_vector := "00";
	constant load_byte_1 :std_ulogic_vector := "01";
	constant load_byte_2 :std_ulogic_vector := "10";
	constant load_byte_3 :std_ulogic_vector := "11";

	constant load_word_0 :std_ulogic := '0';
	constant load_word_1 :std_ulogic := '1';

	subtype byte0_in is natural range  0 to 7;
	subtype byte1_in is natural range  8 to 15;
	subtype byte2_in is natural range 16 to 23;
	subtype byte3_in is natural range 24 to 31;

	subtype half0_in is natural range   0 to 15;
	subtype half1_in is natural range  16 to 31;

	subtype byte_out is natural range  7 downto 0;
	subtype half_out is natural range 15 downto 0;

begin
	process (a,sz,sign,din)
	begin
		dout <= (others => '-');
		case sz is
		when "00" =>
			case a is
			when load_byte_0 =>
				dout(byte_out) <= din(byte0_in);
				case sign is
				when '1' =>
					dout(31 downto 8) <= (others => din(0));
				when '0' =>
					dout(31 downto 8) <= (others => '0');
				when others =>
					dout(31 downto 8) <= (others => '-');
				end case;
			when load_byte_1 =>
				dout(byte_out) <= din(byte1_in);
				case sign is
				when '1' =>
					dout(31 downto 8) <= (others => din(8));
				when '0' =>
					dout(31 downto 8) <= (others => '0');
				when others =>
					dout(31 downto 8) <= (others => '-');
				end case;
			when load_byte_2 =>
				dout(byte_out) <= din(byte2_in);
				case sign is
				when '1' =>
					dout(31 downto 8) <= (others => din(16));
				when '0' =>
					dout(31 downto 8) <= (others => '0');
				when others =>
					dout(31 downto 8) <= (others => '-');
				end case;
			when load_byte_3 =>
				dout(byte_out) <= din(byte3_in);
				case sign is
				when '1' =>
					dout(31 downto 8) <= (others => din(24));
				when '0' =>
					dout(31 downto 8) <= (others => '0');
				when others =>
					dout(31 downto 8) <= (others => '-');
				end case;
			when others =>
				dout <= (others => '-');
			end case;
		when "01" =>
			case a(1) is
			when load_word_0 =>
				dout(half_out) <= din(half0_in);
				case sign is
				when '1' =>
					dout(31 downto 16) <= (others => din(0));
				when '0' =>
					dout(31 downto 16) <= (others => '0');
				when others =>
					dout(31 downto 16) <= (others => '-');
				end case;
			when load_word_1 =>
				dout(half_out) <= din(half1_in);
				case sign is
				when '1' =>
					dout(31 downto 16) <= (others => din(16));
				when '0' =>
					dout(31 downto 16) <= (others => '0');
				when others =>
					dout(31 downto 16) <= (others => '-');
				end case;
			when others =>
				dout <= (others => '-');
			end case;
		when "11" =>
			dout <= din;
		when others =>
			dout <= (others => '-');
		end case;

	end process;
end;
