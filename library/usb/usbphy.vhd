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

entity usbphy is
   	generic (
		oversampling : natural := 0;
		watermark    : natural := 0;
		bit_stuffing : natural := 6);
	port (
		dp    : inout std_logic := 'Z';
		dn    : inout std_logic := 'Z';
		clk   : in  std_logic;
		cken  : buffer std_logic;

		txen  : in  std_logic := '0';
		txbs  : out std_logic;
		txd   : in  std_logic := '-';

		rxdv  : out std_logic := '0';
		rxbs  : out std_logic := '0';
		rxd   : out std_logic;
		rxerr : out std_logic);
end;

architecture def of usbphy is

	signal j     : std_logic;
	signal k     : std_logic;
	signal se0   : std_logic;
	signal s_k   : std_logic;
	signal s_j   : std_logic;
	signal s_se0 : std_logic;
	signal txdp  : std_logic;
	signal txdn  : std_logic;
begin

	dp <= 'L' when txen='0' else txdp;
	dn <= 'L' when txen='0' else txdn;

	k   <= not dp and     dn;
	j   <=     dp and not dn;
	se0 <= not dp and not dn;
		
	linestates_p : process (j, k, clk)
		type states is (s_idle, s_sop, s_eop, s_resume, s_suspend);
		variable state : states;
	begin
		if rising_edge(clk) then
			case state is
			when s_idle =>
				if k='1' then
					state := s_sop;
				end if;
			when s_sop =>
				if se0='1' then
					if cken='1' then
						state := s_eop;
					end if;
				end if;
			when s_resume =>
			when s_suspend =>
			when s_eop =>
				if j='1' then
					state := s_idle;
				end if;
			end case;
		end if;
	end process;

	oversampling_g : if oversampling/=0 generate
    	oversampling_p : process (clk)
			constant wm : natural := setif(watermark=0, (oversampling)/2, watermark);
    		variable cntr  : natural range 0 to oversampling-1;
    		variable q     : std_logic;
    	begin
    		if rising_edge(clk) then
    			if (to_bit(q) xor to_bit(k))='1' then
    				cntr := oversampling-1;
    			elsif cntr=0 then
    				cntr := oversampling-1;
    			else
    				cntr := cntr - 1;
    			end if;
    			if cntr=wm then
    				cken <= '1';
    			else
    				cken <= '0';
    			end if;
    			q     := k;
    			s_k   <= k;
    			s_j   <= j;
    			s_se0 <= se0;
    		end if;
    	end process;
	end generate;
	
	nooversampling_g : if oversampling=0 generate
		s_k   <= k;
		s_j   <= j;
		s_se0 <= se0;
		cken  <= '1';
	end generate;

	rx_d : entity hdl4fpga.usbphy_rx
   	generic map (
		bit_stuffing => bit_stuffing)
	port map (
		clk  => clk,
		cken => cken,
		k    => s_k,
		j    => s_j,
		se0  => s_se0,
		rxdv => rxdv,
		rxbs => rxbs,
		rxd  => rxd,
		err  => rxerr);
		
	tx_d : entity hdl4fpga.usbphy_tx
	port map (
		clk  => clk,
		cken => cken,
		txen => txen,
		txbs => txbs,
		txd  => txd,
		txdp => txdp,
		txdn => txdn);

end;