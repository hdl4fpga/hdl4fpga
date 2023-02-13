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
use hdl4fpga.ethpkg.all;
use hdl4fpga.ipoepkg.all;

entity udp_tx is
	port (
		mii_clk       : in  std_logic;

		pl_frm        : in  std_logic;
		pl_irdy       : in  std_logic;
		pl_trdy       : buffer std_logic;
		pl_end        : in  std_logic;
		pl_data       : in  std_logic_vector;

		udp_frm       : out std_logic;

		dlltx_irdy    : out std_logic;
		dlltx_end     : in  std_logic;
		dlltx_data    : out std_logic_vector;

		netdatx_irdy  : out  std_logic;
		netdatx_end   : in  std_logic;
		netlentx_irdy : out  std_logic;
		netlentx_end  : in  std_logic;
		netlentx_data : out std_logic_vector;

		tptsp_irdy    : out std_logic;
		tptsp_end     : in  std_logic;
		tptdp_irdy    : out std_logic;
		tptdp_end     : in  std_logic;
		tptlen_irdy   : buffer std_logic;
		tptlen_end    : in  std_logic;
		tpttx_end     : in  std_logic;

		udpsp_irdy    : out std_logic;
		udpsp_end     : in  std_logic;
		udpsp_data    : in  std_logic_vector;

		udpdp_irdy    : out std_logic;
		udpdp_end     : in  std_logic;
		udpdp_data    : in  std_logic_vector;

		udplen_irdy   : out std_logic;
		udplen_end    : in  std_logic;
		udplen_data   : in  std_logic_vector;

		udp_irdy      : out std_logic;
		udp_trdy      : in  std_logic;
		udp_data      : out std_logic_vector;
		udp_end       : out std_logic;
		tp            : out std_logic_vector(1 to 32));
end;

architecture def of udp_tx is
	signal frm_ptr : std_logic_vector(0 to unsigned_num_bits(summation(udp4hdr_frame)/udp_data'length-1));

	signal cksm_irdy : std_logic;
	signal cksm_end  : std_logic;
	signal cksm_data : std_logic_vector(pl_data'range);
	signal so_sum    : std_logic_vector(pl_data'range);
	signal so_sum1   : std_logic_vector(pl_data'range);

begin

	process (mii_clk)
		variable cntr : unsigned(frm_ptr'range);
	begin
		if rising_edge(mii_clk) then
			if pl_frm='1' then
				if cntr(0)='0' then
					if (pl_trdy and pl_irdy)='1' then
						cntr := cntr - 1;
					end if;
				end if;
			else
				cntr := to_unsigned(summation(udp4hdr_frame)/udp_data'length-1, cntr'length);
			end if;
			frm_ptr <= std_logic_vector(cntr);
		end if;
	end process;

	udpcksm_e : entity hdl4fpga.sio_mux
	port map (
		mux_data => x"0000",
		sio_clk  => mii_clk,
		sio_frm  => pl_frm,
		sio_irdy => cksm_irdy,
		sio_trdy => open,
		so_end   => cksm_end,
		so_data  => cksm_data);

	netdatx_irdy  <= pl_irdy and udp_trdy when   dlltx_end='1' else '0';
	tptsp_irdy    <= pl_irdy and udp_trdy when netdatx_end='1' else '0';
	tptdp_irdy    <= pl_irdy and udp_trdy when   tptsp_end='1' else '0';
	tptlen_irdy   <= pl_irdy and udp_trdy when   tptdp_end='1' else '0';
	udpsp_irdy    <= pl_irdy and udp_trdy when  tptlen_end='1' else '0';
	udpdp_irdy    <= pl_irdy and udp_trdy when   udpsp_end='1' else '0';
	udplen_irdy   <= pl_irdy and udp_trdy when   udpdp_end='1' else '0';
	cksm_irdy     <= pl_irdy and udp_trdy when  udplen_end='1' else '0';
	udp_irdy      <= pl_irdy              when    cksm_end='1' else '0';
	netlentx_irdy <= tptlen_irdy;

	pl_trdy       <= 
		udp_trdy when tptlen_end='0' else
		'0'      when   cksm_end='0' else
		udp_trdy;

	adjlen_e : entity hdl4fpga.ipv4_adjlen
	generic map (
		adjust => std_logic_vector(to_unsigned((summation(udp4hdr_frame)/octect_size),16)))
	port map (
		sio_clk  => mii_clk,
		sio_frm  => pl_frm,
		sio_irdy => tptlen_irdy,
		sio_trdy => open,
		si_data  => pl_data,
		so_data  => so_sum);
	
	process (mii_clk)
	begin
		if rising_edge(mii_clk) then
		end if;
	end process;
	so_sum1 <= so_sum;

	netlentx_data <= so_sum1;

	dlltx_irdy <= pl_irdy and udp_trdy;
	dlltx_data <= pl_data;
	udp_frm <= pl_frm;
	udp_data <=
		pl_data     when   tptdp_end='0' else
		so_sum1     when  tptlen_end='0' else
		udpsp_data  when   udpsp_end='0' else
		udpdp_data  when   udpdp_end='0' else
		udplen_data when  udplen_end='0' else
		cksm_data   when    cksm_end='0' else
		pl_data;
	udp_end <= pl_end;

end;