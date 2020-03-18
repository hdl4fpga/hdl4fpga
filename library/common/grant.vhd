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

library hdl4fpga;

entity grant is
	port (
		gnt_clk : in  std_logic;
		gnt_rst : in  std_logic := '0';
		gnt_rdy : in  std_logic;

		dev_clk : in  std_logic_vector;
		dev_req : in  std_logic_vector;
		dev_gnt : buffer std_logic_vector;
		dev_rdy : out std_logic_vector);


end;

architecture def of grant is

	signal request : std_logic_vector(dev_clk'range);
	signal booked  : std_logic_vector(dev_clk'range);
	signal served  : std_logic_vector(booked'range);

	signal arbiter_req : std_logic_vector(dev_clk'range);

begin

	dev_g : for i in dev_clk'range generate
		process (dev_clk(i))
			variable dv : std_logic;
		begin
			if rising_edge(dev_clk(i)) then
				if served(i)='1' then
					if dev_req(i)='0' then
						request(i) <= '0';
					end if;
				elsif dev_req(i)='1' then
					request(i) <= '1';
				end if;
			end if;
		end process;
	end generate;

	book_p : process (gnt_clk)
		variable serving : std_logic_vector(served'range);
	begin
		if rising_edge(gnt_clk) then
			if gnt_rst='1'  then
				booked  <= (others => '0');
				serving := (others => '0');
			else
				booked  <= request or (booked and not served and not (dev_gnt and (dev_gnt'range => gnt_rdy)));
				serving := (request and served) or (request and booked and (dev_gnt and (dev_gnt'range => gnt_rdy)));
			end if;
			served <= serving;

			arbiter_req  <= not serving and booked;
		end if;
	end process;

	arbiter_e : entity hdl4fpga.arbiter
	port map (
		clk     => gnt_clk,
		bus_req => arbiter_req,
		bus_gnt => dev_gnt);

	dev_rdy <= served;

end;
