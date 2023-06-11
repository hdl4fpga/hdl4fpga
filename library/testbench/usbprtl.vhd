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
	constant usb_freq     : real := 12.0e6;

	signal usb_clk : std_logic := '0';
	signal dp      : std_logic;
	signal dn      : std_logic;
begin

	usb_clk <= not usb_clk after 1 sec/(2.0*usb_freq);
	dp <= 'H';
	dn <= 'L';

	tb_b : block
		signal tp   : std_logic_vector(1 to 32);
		signal rst  : std_logic;
		alias  clk  is usb_clk;
		signal cken : std_logic;
		signal txen : std_logic := '0';
		signal txbs : std_logic;
		signal txd  : std_logic := '0';
		signal rxdv : std_logic := '0';
		signal rxbs : std_logic;
		signal rxd  : std_logic;
	begin

		rst <= '1', '0' after 0.500 us;
    	process (cken, clk)
    		-- constant data : std_logic_vector := reverse(x"a50df2",8)(0 to 19-1);
    		-- constant data : std_logic_vector := reverse(x"a527b2",8)(0 to 19-1);
    		-- constant data : std_logic_vector := reverse(x"a50302",8)(0 to 19-1);
    		-- constant data : std_logic_vector := reverse(x"a5badf",8)(0 to 19-1);
    		-- constant data : std_logic_vector := reverse(x"2d0010",8)(0 to 19-1);
    		   constant data : std_logic_vector := reverse(x"c300_0515_000000_0000_e831",8)(0 to 72-1);
    		-- constant data : std_logic_vector := reverse(x"c300_0517_000000_0000_e9d3",8)(0 to 112-1);
    		-- constant data : std_logic_vector := reverse(x"c300_0517_000000_0000_e9d3",8)(0 to 112-1);
    		-- constant data : std_logic_vector := reverse(x"c300_050c_000000_0000_ea38",8)(0 to 112-1);
    		variable cntr : natural := 0;
    	begin
    		if rising_edge(clk) then
				if rst='1' then
					cntr := 0;
					txen <= '0';
    			elsif cntr < data'length then
    				if txbs='0' then
    					txd  <= data(cntr);
    					txen <= '1';
    					cntr := cntr + 1;
    				end if;
    			elsif txbs='0' then
    				if cntr > data'length+7 then
    					txen <= '0';
    				else
    					cntr := cntr + 1;
    				end if;
    			end if;
    		end if;
		end process;

      	tb_e : entity hdl4fpga.usbprtl
    	port map (
    		tp   => tp,
    		dp   => dp,
    		dn   => dn,
    		clk  => clk,
    		cken => cken,

    		txen => txen,
    		txbs => txbs,
    		txd  => txd,

    		rxdv => rxdv,
			rxbs => rxbs,
    		rxd  => rxd);

    	process (clk)
    		variable cntr : natural := 0;
    		variable data : std_logic_vector(0 to 128-1);
    	begin
    		if rising_edge(clk) then
    			if cken='1' then
        			if (rxdv and not rxbs)='1' then
        				if cntr < data'length then
        					data(cntr) := rxd;
        					cntr := cntr + 1;
        				end if;
        			end if;
    			end if;
    		end if;
    	end process;

	end block;

	du_b : block
		constant oversampling : natural := 3;
		signal tp   : std_logic_vector(1 to 32);
		signal rst  : std_logic;
		signal clk  : std_logic := '0';
		signal cken : std_logic;
		signal txen : std_logic := '0';
		signal txbs : std_logic;
		signal txd  : std_logic;
		signal rxdv : std_logic;
		signal rxbs : std_logic;
		signal rxd  : std_logic;
	begin
		rst <= '1'; --, '0' after 0.500 us;

    	with oversampling select
    	clk <= 
    		not clk after 1 sec/((2.0*usb_freq)*(50.00e6/usb_freq)) when 4,
    		not clk after 1 sec/((2.0*usb_freq)*(36.37e6/usb_freq)) when 3,
    		not clk after 1 sec/((2.0*usb_freq)*(12.00e6/usb_freq)) when others; --*0.975;

     	tx_p : process (clk)
    		constant data : std_logic_vector := reverse(x"a5badf",8)(0 to 19-1);
    		-- constant data : std_logic_vector := reverse(x"c300050c_0000000000",8);
    		variable cntr : natural := 0;
    	begin
    		if rising_edge(clk) then
				if rst='1' then
					cntr := 0;
					txen <= '0';
    			elsif cken='1' then
    				if cntr < data'length then
    					if txbs='0' then
    						txd  <= data(cntr);
    						txen <= '1';
    						cntr := cntr + 1;
    					end if;
    				elsif txbs='0' then
    					if cntr >= data'length then
    						txen <= '0';
    					else
    						cntr := cntr + 1;
    					end if;
    				end if;
    			end if;
    		end if;
    	end process;

    	tp_p : process (rxdv, clk)
    		alias dv is tp(1);
    		alias bs is tp(2);
    		alias rd is tp(3);

    		variable cntr : natural := 0;
    		variable data : std_logic_vector(0 to 128-1);
    	begin
    		if rising_edge(clk) then
    			if cken='1' then
        			if (dv and not bs)='1' then
        				if cntr < data'length then
        					data(cntr) := rd ;
        					cntr := cntr + 1;
        				end if;
        			end if;
    			end if;
    		end if;
    	end process;

       	du : entity hdl4fpga.usbprtl
       	generic map (
       		oversampling => oversampling)
    	port map (
    		tp   => tp,
    		dp   => dp,
    		dn   => dn,
    		clk  => clk,
    		cken => cken,

    		txen => txen,
    		txbs => txbs,
    		txd  => txd,

    		rxdv => rxdv,
    		rxbs => rxbs,
    		rxd  => rxd);

    	rx_p : process (rxbs, clk)
    		variable cntr : natural := 0;
    		variable data : std_logic_vector(0 to 128-1);
    	begin
    		if rising_edge(clk) then
    			if cken='1' then
        			if (rxdv and not rxbs)='1' then
        				if cntr < data'length then
        					data(cntr) := rxd;
        					cntr := cntr + 1;
        				end if;
        			end if;
    			end if;
    		end if;
    	end process;

	end block;

end;