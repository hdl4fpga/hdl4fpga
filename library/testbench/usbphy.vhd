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

architecture usbphy of testbench is
	constant usb_freq : real := 12.0e6;
    constant oversampling : natural := 4;

	-- constant data : std_logic_vector(0 to 24-1) := reverse(x"a50df2",8);
	-- constant data : std_logic_vector(0 to 24-1) := reverse(x"a527b2",8);
	-- constant data : std_logic_vector(0 to 24-1) := reverse(x"a50302",8);
	constant data : std_logic_vector(0 to 24-1) := reverse(x"a5badf",8);
	-- constant data : std_logic_vector := reverse(x"c300052f_0000000000_ed6b",8);
	-- constant data : std_logic_vector := reverse(x"c300_0517_000000_0000_e9d3",8);

	signal txc  : std_logic := '0';
	signal txen : std_logic := '0';
	signal txd  : std_logic := '0';
	signal dp   : std_logic;
	signal dn   : std_logic;
	signal rxc  : std_logic := '0';
	signal frm : std_logic := '0';
	signal xxx : std_logic := '0';
	signal crc_frm : std_logic := '0';
	signal rxdv : std_logic := '0';
	signal busy : std_logic;

	signal datao : std_logic_vector(data'range) := (others => '0');
	signal rxd : std_logic_vector(0 to 0);
	signal rx_crc : std_logic_vector(0 to 5-1);
	signal rx_crc16 : std_logic_vector(0 to 16-1);
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
		txc  => txc,
		txen => txen,
		busy => busy,
		txd  => txd,
		txdp => dp,
		txdn => dn);

	rx_b : block
	begin

    	rx_d : entity hdl4fpga.usbphy_rx
    	generic map (
    		oversampling => oversampling)
    	port map (
    		data => rxd(0),
    		dv   => rxdv,
    		frm  => frm,
    		rxc  => rxc,
    		rxdp => dp,
    		rxdn => dn);

		usbcrc_b : block
    		constant g5   : std_logic_vector := b"00101";
    		constant g16  : std_logic_vector := x"8005";
    		constant g    : std_logic_vector := g5 & g16;
			constant slce : natural_vector := (0, g5'length, g5'length+g16'length);
			signal crc    : std_logic_vector(g'range);

			alias crc5   : std_logic_vector(slce(0) to slce(1)-1);
			alias crc16  : std_logic_vector(slce(1) to slce(2)-1);
		begin
    		usbcrc_g : for i in 0 to 1 generate
    			crc_b : block
    				port (
    					clk  : in  clk;
    					g    : in  std_logic_vector;
    					ena  : in  std_logic_vector;
    					data : in  std_logic_vector;
    					crc  : buffer std_logic_vector)
    				port map (
    					clk  => rxc,
    					g    => g(slce(i) to slce(i+1)-1),
    					ena  => rxdv
    					data => rxd,
    					crc  => crc(slce(i) to slce(i+1)-1));
    			begin
    				crc_p : process (clk)
    				begin
    					if rising_edge(clk) then
    						if frm='0' then
    							crc <= (crc'range => '0');
    						elsif ena='1' then
    							crc <= not galois_crc(data, not crc, g);
    						end if;
    					end if;
    				end process;
    			end block;

    			process (rxc)
    			begin
    				if rising_edge(rxc) then
    					if frm='1' then
    						crc;
    					end if;
    				end if;
    			end process;

    		end generate;
		end block;

    	crc5_e : entity hdl4fpga.crc
    	port map (
    		g    => b"00101",
    		clk  => rxc,
    		frm  => crc_frm,
    		irdy => rxdv,
    		data => rxd,
    		crc  => rx_crc);

    	crc16_e : entity hdl4fpga.crc
    	port map (
    		g    => x"8005",
    		clk  => rxc,
    		frm  => crc_frm,
    		irdy => rxdv,
    		data => rxd,
    		crc  => rx_crc16);

    	crc_frm <= frm and xxx;
		process (rxc)
			variable cntr : natural := 0;
		begin
			if rising_edge(rxc) then
				if (frm and rxdv)='1' then
					datao(cntr) <= rxd(0);
					cntr := cntr + 1;
				end if;
				if cntr >= 8 then
					xxx <= '1';
				end if;
			end if;
		end process;
	end block;

end;