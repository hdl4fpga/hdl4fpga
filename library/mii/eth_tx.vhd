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

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity eth_tx is
	generic (
		debug       : boolean := false);
	port (
		mii_clk     : in  std_logic;

		pl_frm      : in  std_logic;
		pl_irdy     : in  std_logic := '1';
		pl_trdy     : buffer std_logic;
		pl_end      : in  std_logic;
		pl_data     : in  std_logic_vector;

		hwda_irdy   : out std_logic;
		hwda_end    : in  std_logic := '1';
		hwda_data   : in  std_logic_vector;

		hwsa_irdy   : out std_logic;
		hwsa_end    : in  std_logic := '1';
		hwsa_data   : in  std_logic_vector;

		hwtyp_irdy  : out std_logic;
		hwtyp_end   : in  std_logic := '1';
		hwtyp_data  : in  std_logic_vector;

		mii_frm     : buffer std_logic;
		mii_irdy    : buffer std_logic;
		mii_trdy    : in  std_logic := '1';
		mii_end     : buffer std_logic;
		mii_data    : out std_logic_vector);

end;

architecture def of eth_tx is

	signal pre_trdy : std_logic;
	signal pre_end  : std_logic;
	signal pre_data : std_logic_vector(mii_data'range);

	signal minpkt   : std_logic;

	signal fcs_irdy : std_logic;
	signal fcs_mode : std_logic;
	signal fcs_data : std_logic_vector(mii_data'range);
	signal fcs_end  : std_logic;
	signal fcs_crc  : std_logic_vector(0 to 32-1);

	signal tx_irdy : std_logic;
	signal tx_trdy : std_logic;
	signal tx_end  : std_logic;
	signal tx_data : std_logic_vector(pl_data'range);

begin

	buffer_b : block

		signal i_irdy  : std_logic;
		signal i_trdy  : std_logic;
		signal i_data  : std_logic_vector(pl_data'range);

	begin

		pl_trdy <= 
			i_trdy  when  hwda_end='0' else
			'0'     when  hwsa_end='0' else
			'0'     when hwtyp_end='0' else
			i_trdy;

		i_irdy <= 
			-- hwda_irdy when hwda_end='0' else
			pl_irdy when  hwda_end='0' else
			'1'     when  hwsa_end='0' else
			'1'     when hwtyp_end='0' else
			pl_irdy;

		i_data <= 
			-- hwda_data when hwda_end='0' else
			pl_data    when  hwda_end='0' else
			hwsa_data  when  hwsa_end='0' else
			hwtyp_data when hwtyp_end='0' else
			pl_data;

    	miibuffer_e : entity hdl4fpga.mii_buffer
    	port map(
    		io_clk => mii_clk,
    		i_frm  => pl_frm,
    		i_irdy => i_irdy,
    		i_trdy => i_trdy,
    		i_end  => pl_end, 
    		i_data => i_data,
			o_frm  => mii_frm,
    		o_irdy => tx_irdy,
    		o_trdy => tx_trdy,
    		o_data => tx_data,
    		o_end  => tx_end);

		hwda_irdy  <= i_trdy;
		hwsa_irdy  <= i_trdy when hwda_end='1' else '0';
		hwtyp_irdy <= i_trdy when hwsa_end='1' else '0';

	end block;

	pre_e : entity hdl4fpga.sio_mux
	port map (
		mux_data => reverse(x"5555_5555_5555_55d5", 8),
		sio_clk  => mii_clk,
		sio_frm  => mii_frm,
		sio_irdy => mii_trdy,
		sio_trdy => pre_trdy,
		so_end   => pre_end,
		so_data  => pre_data);

	process(mii_clk)
		variable cntr : unsigned(0 to unsigned_num_bits(64*8/mii_data'length-1));
	begin
		if rising_edge(mii_clk) then
			if pl_frm='0' then
				cntr := to_unsigned((64*8-32)/mii_data'length-1, cntr'length);
			elsif mii_trdy='1' and pre_end='1' then
				if cntr(0)='0' then
					cntr := cntr - 1;
				end if;
			end if;
			minpkt <= cntr(0) or setif(debug);
		end if;
	end process;

	tx_trdy  <= 
		'0'       when pre_end='0' else
		mii_trdy  when  tx_end='0' else
		fcs_end;
	fcs_irdy <= 
		'0'                    when pre_end='0' else
		(tx_irdy and mii_trdy) when  tx_end='0' else 
		mii_trdy;
	fcs_data <= 
		tx_data                when  tx_end='0' else 
		(fcs_data'range => '0');

	process (mii_clk)
		variable cntr : unsigned(0 to unsigned_num_bits(fcs_crc'length/mii_data'length-1));
	begin
		if rising_edge(mii_clk) then
			if pl_frm='0' then
				cntr := (others => '0');
			elsif tx_end='1' and minpkt='1' and cntr(0)='0' then
				if fcs_irdy='1' then
					cntr := cntr + 1;
				end if;
			end if;
			fcs_end <= cntr(0);
		end if;
	end process;

	fcs_mode <= tx_end and minpkt;
	fcs_e : entity hdl4fpga.crc
	port map (
		g    => x"04c11db7",
		clk  => mii_clk,
		frm  => mii_frm,
		irdy => fcs_irdy,
		mode => fcs_mode,
		data => fcs_data,
		crc  => fcs_crc);

	mii_irdy <=
		pre_trdy   when pre_end='0' else
		tx_irdy    when  tx_end='0' else
		'1';

	mii_data <=
		pre_data                when pre_end='0' else
		tx_data                 when  tx_end='0' else
		(mii_data'range => '0') when  minpkt='0' else
		fcs_crc(mii_data'range);
	mii_end <= fcs_end;

end;

