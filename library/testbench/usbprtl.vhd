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

architecture usbprtcl of testbench is
	constant usb_freq : real := 12.0e6;
    constant oversampling : natural := 4;

	-- constant data : std_logic_vector(0 to 24-1) := reverse(x"a50df2",8);
	-- constant data : std_logic_vector(0 to 24-1) := reverse(x"a527b2",8);
	-- constant data : std_logic_vector(0 to 24-1) := reverse(x"a50302",8);
	-- constant data : std_logic_vector(0 to 24-1) := reverse(x"a5badf",8);
	-- constant data : std_logic_vector(0 to 24-1) := reverse(x"2d0010",8);
	constant data : std_logic_vector := reverse(x"c300052f_0000000000_ed6b",8);
	-- constant data : std_logic_vector := reverse(x"c300_0517_000000_0000_e9d3",8);

	signal txc  : std_logic := '0';
	signal txen : std_logic := '0';
	signal txd  : std_logic := '0';
	signal dp   : std_logic;
	signal dn   : std_logic;
	signal rxc  : std_logic := '0';
	signal rxdv : std_logic := '0';
	signal busy : std_logic;

	signal rxd  : std_logic;
	signal clk  : std_logic;
	signal cken : std_logic;
begin

	txc <= not txc after 1 sec/(2.0*usb_freq)*(50.0e6/12.0e6); --*0.975;
	rxc <= not rxc after 1 sec/(2.0*usb_freq);

	process (txc)
		variable cntr : natural := 0;
	begin
		if rising_edge(txc) then
			if cntr < data'length then
				if busy='0' then
					txd  <= data(cntr);
					txen <= '1';
					cntr := cntr + 1;
				end if;
			elsif busy='0' then
				if cntr > data'length+7 then
					txen <= '0';
				else
					cntr := cntr + 1;
				end if;
			end if;
		end if;
	end process;

	tx_d : entity hdl4fpga.usbphy_tx
	port map (
		clk  => txc,
		txen => txen,
		txbs => busy,
		txd  => txd,
		txdp => dp,
		txdn => dn);

   	usbprtl_d : entity hdl4fpga.usbprtl
   	generic map (
   		oversampling => oversampling)
	port map (
		dp   => dp,
		dn   => dn,
		clk  => clk,
		cken => cken,

		txen => '0',
		txbs => open,
		txd  => '-',

		rxdv => rxdv,
		rxd  => rxd);

	process (rxc)
		variable rx_data : unsigned(data'range);
	begin
		if rising_edge(rxc) then
			if (rxdv and cken)='1' then
				rx_data(0) := rxd;
				rx_data := rx_data rol 1;
			end if;
		end if;
	end process;

end;