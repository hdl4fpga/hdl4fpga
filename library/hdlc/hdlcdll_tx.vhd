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

entity hdlcdll_tx is
	port (
		fcs_g       : in  std_logic_vector := std_logic_vector'(x"1021");
		fcs_rem     : in  std_logic_vector := std_logic_vector'(x"1d0f");

		uart_clk    : in  std_logic;
		uart_frm    : out std_logic;
		uart_irdy   : out std_logic;
		uart_trdy   : in  std_logic;
		uart_data   : out std_logic_vector;

		hdlctx_frm  : in  std_logic;
		hdlctx_irdy : in  std_logic;
		hdlctx_trdy : buffer std_logic;
		hdlctx_end  : in  std_logic;
		hdlctx_data : in  std_logic_vector);

end;

architecture def of hdlcdll_tx is

	signal fcs_frm  : std_logic;
	signal fcs_irdy : std_logic;
	signal fcs_trdy : std_logic;
	signal fcs_end  : std_logic;
	signal fcs_data : std_logic_vector(hdlctx_data'range);

	signal crc_irdy : std_logic;
	signal crc_trdy : std_logic := '1';
	signal crc_data : std_logic_vector(0 to 16-1);

begin

	cntr_p : process (uart_clk)
		variable cntr : unsigned(0 to unsigned_num_bits(crc_data'length/fcs_data'length-1));
	begin
		if rising_edge(uart_clk) then
			if hdlctx_frm='0' then
				cntr := to_unsigned(crc_data'length/hdlctx_data'length-1, cntr'length);
			elsif hdlctx_end='1' then
				if fcs_trdy='1' then
					if cntr(0)='0' then
						cntr := cntr - 1;
					end if;
				end if;
			end if;
			fcs_end <= cntr(0);
		end if;
	end process;
	hdlctx_trdy <=
		fcs_trdy when hdlctx_end='0' else
		'0'      when fcs_end='0' else
		fcs_trdy;

	crc_irdy <=
		hdlctx_irdy and hdlctx_trdy when hdlctx_end='0' else
		fcs_trdy;

	crc_e : entity hdl4fpga.crc
	port map (
		g    => x"1021",
		clk  => uart_clk,
		frm  => hdlctx_frm,
		irdy => crc_irdy,
		mode => hdlctx_end,
		data => hdlctx_data,
		crc  => crc_data);

	fcs_frm <= hdlctx_frm;

	fcs_irdy <=
		hdlctx_irdy when hdlctx_end='0' else
		crc_trdy;

	fcs_data <=
		hdlctx_data when hdlctx_end='0' else
		crc_data(0 to fcs_data'length-1);

	hdlctx_e : entity hdl4fpga.hdlcsync_tx
	port map (
		uart_clk    => uart_clk,
		uart_frm    => uart_frm,
		uart_irdy   => uart_irdy,
		uart_trdy   => uart_trdy,
		uart_data   => uart_data,

		hdlctx_frm  => fcs_frm,
		hdlctx_irdy => fcs_irdy,
		hdlctx_trdy => fcs_trdy,
		hdlctx_end  => fcs_end,
		hdlctx_data => fcs_data);


end;
