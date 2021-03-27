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

entity testbench is
end;

architecture ip4_tx of testbench is

	signal mii_clk   : std_logic;
	signal pl_req    : std_logic;
	signal pl_frm    : std_logic;
	signal pl_irdy   : std_logic;
	signal pl_trdy   : std_logic;
	signal pl_data   : std_logic_vector(0 to 3*8-1) := x"ffaaee";
	signal ipv4_data : std_logic_vector(0 to 8-1);
	signal cntr      : unsigned(0 to 8);


begin

	mii_clk <= not to_stdulogic(to_bit(mii_clk)) after 20 ns;
	pl_req  <= '0', '1' after 100 ns;
	pl_frm  <= pl_req when cntr<2 else '0';
	pl_irdy <= pl_req when cntr<2 else '0';

	process (mii_clk)
	begin
		if rising_edge(mii_clk) then
			if pl_req='0' then
				cntr <= (others => '0');
			elsif cntr(0)='0' then
				cntr <= cntr + 1;
				pl_data <= std_logic_vector(unsigned(pl_data) rol 8);
			end if;
		end if;
	end process;

	du_e : entity hdl4fpga.ipv4_tx 
	port map (
		mii_clk    => mii_clk,

		pl_frm     => pl_frm,
		pl_irdy    => pl_irdy,
		pl_trdy    => pl_trdy,
		pl_data    => pl_data(0 to 8-1),

		ipv4_len   => x"1234",
		ipv4_sa    => x"56789abc",
		ipv4_da    => x"def01234",
		ipv4_proto => x"11",

		ipv4_trdy  => '1',
		ipv4_data  => ipv4_data);

end;
