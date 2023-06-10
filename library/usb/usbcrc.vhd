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

library hdl4fpga;
use hdl4fpga.base.all;

entity usbcrc is
	port (
		clk   : in  std_logic;
		cken  : in  std_logic;
		dv    : in  std_logic;
		data  : in  std_logic;
		crc5  : buffer std_logic_vector(0 to 5-1);
		crc16 : buffer std_logic_vector(0 to 16-1));
end;

architecture def of usbcrc is
	constant g5    : std_logic_vector := b"0_0101";
	constant g16   : std_logic_vector := b"1000_0000_0000_0101";
	constant rem5  : std_logic_vector := b"01100";
	constant rem16 : std_logic_vector := b"1000_0000_0000_1101";
	constant g     : std_logic_vector := g5 & g16;
	constant slce  : natural_vector   := (0, g5'length, g5'length+g16'length);

	signal crc     : std_logic_vector(g'range);
	signal ncrc5   : std_logic_vector(crc5'range);
	signal ncrc16  : std_logic_vector(crc16'range);

begin

	usbcrc_g : for i in 0 to 1 generate
		signal d : std_logic_vector(0 to 0);
	begin
		d(0) <= data;
		crc_b : block
			port (
				clk  : in  std_logic;
				cken : in  std_logic;
				g    : in  std_logic_vector;
				dv   : in  std_logic;
				data : in  std_logic_vector;
				crc  : buffer std_logic_vector);
			port map (
				clk  => clk,
				cken => cken,
				g    => g(slce(i) to slce(i+1)-1),
				dv   => dv,
				data => d,
				crc  => crc(slce(i) to slce(i+1)-1));
		begin
			crc_p : process (clk)
				type states is (s_idle, s_run);
				variable state : states;
			begin
				if rising_edge(clk) then
					case state is
					when s_idle =>
						if cken='1' then
							if dv='1' then
								crc   <= galois_crc(data, (crc'range => '1'), g);
								state := s_run;
							else
								crc <= std_logic_vector(unsigned(crc) rol 1);
							end if;
						end if;
					when s_run =>
						if dv='1' then
							if cken='1' then
								crc <= galois_crc(data, crc, g);
								case crc'length is
								when 16 =>
									-- crc <= b"0000_0000_0000_0001";
								when  5 =>
									-- crc <= b"0_0001";
								when others =>
								end case;
							end if;
						else
							if cken='1' then
								crc <= std_logic_vector(unsigned(crc) rol 1);
							end if;
							state := s_idle;
						end if;
					end case;
				end if;
			end process;
		end block;
	end generate;

	crc5   <= crc(slce(0) to slce(1)-1);
	crc16  <= crc(slce(1) to slce(2)-1);
	ncrc5  <= not crc5;
	ncrc16 <= not crc16;

end;