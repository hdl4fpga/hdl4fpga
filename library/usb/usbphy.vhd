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
		tp    : out std_logic_vector(1 to 32);
		dp    : inout std_logic := 'Z';
		dn    : inout std_logic := 'Z';
		idle  : out std_logic;
		clk   : in  std_logic;
		cken  : buffer std_logic;

		txen  : in  std_logic := '0';
		txbs  : buffer std_logic;
		txd   : in  std_logic := '-';

		rxdv  : buffer std_logic;
		rxbs  : buffer std_logic;
		rxd   : buffer std_logic;
		rxerr : out std_logic);
end;

architecture def of usbphy is

	signal j     : std_logic;
	signal k     : std_logic;
	signal se0   : std_logic;
	signal s_k   : std_logic;
	signal s_j   : std_logic;
	signal s_se0 : std_logic;

	signal tx_tp : std_logic_vector(tp'range);
	signal echo : std_logic;
begin

	process (clk)
	begin
		if rising_edge(clk) then
			if cken='1' then
				if tx_tp(1)='1' then
					echo <= '1';
				elsif rxdv='0' then
					echo <= '0';
				end if;
			end if;
		end if;
	end process;

	tp(1) <= '1'      when tx_tp(1)='1' else rxdv when echo='0' else '0';
	tp(2) <= tx_tp(2) when tx_tp(1)='1' else rxbs;
	tp(3) <= tx_tp(3) when tx_tp(1)='1' else rxd;

	linestates_p : process (clk)
		type states is (s_idle, s_sop, s_eop, s_resume, s_suspend);
		variable state : states;
	begin
		if rising_edge(clk) then
			case state is
			when s_idle =>
				if k='1' then
					idle  <= '0';
					state := s_sop;
				else
					idle  <= '1';
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
					idle  <= '1';
					state := s_idle;
				end if;
			end case;
		end if;
	end process;

	oversampling_g : if oversampling/=0 generate
    	oversampling_p : process (clk)
			-- constant wm : natural := setif(watermark=0, (oversampling)/2, watermark);
			constant wm : natural := setif(watermark=0, (oversampling)/2, watermark);
    		variable cntr : natural range 0 to oversampling-1;
    		variable q    : std_logic;
			variable dp_s : std_logic;
			variable dn_s : std_logic;
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
    			q     := not dp_s and     dn_s;
    			s_k   <= not dp_s and     dn_s;
    			s_j   <=     dp_s and not dn_s;
    			s_se0 <= not dp_s and not dn_s;
				dp_s := dp;
				dn_s := dn;
    		end if;
			k   <= not dp_s and     dn_s;
			j   <=     dp_s and not dn_s;
			se0 <= not dp_s and not dn_s;
    	end process;
	end generate;
	
	nooversampling_g : if oversampling=0 generate
		k     <= not dp and     dn;
		j     <=     dp and not dn;
		se0   <= not dp and not dn;
		s_k   <= k;
		s_j   <= j;
		s_se0 <= se0;
		cken  <= '1';
	end generate;

	usbphyrx_e : entity hdl4fpga.usbphy_rx
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
		
	usbphytx_e : entity hdl4fpga.usbphy_tx
	port map (
		tp   => tx_tp,
		clk  => clk,
		cken => cken,
		txen => txen,
		txbs => txbs,
		txd  => txd,
		txdp => dp,
		txdn => dn);

end;