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
		mii_clk     : in  std_logic;

		pl_frm      : in  std_logic;
		pl_irdy     : in  std_logic;
		pl_trdy     : buffer std_logic;
		pl_end      : in  std_logic;
		pl_data     : in  std_logic_vector;

		udp_frm     : buffer std_logic;

		dlltx_irdy  : out std_logic := '1';
		dlltx_end   : in  std_logic := '1';

		nettx_irdy  : out std_logic := '1';
		nettx_trdy  : in  std_logic := '1';
		nettx_end   : in  std_logic := '1';

		tpttx_irdy  : out std_logic := '1';
		tpttx_trdy  : in  std_logic := '1';
		tpttx_end   : in  std_logic := '1';

		udpsp_irdy  : out std_logic;
		udpsp_trdy  : in  std_logic := '1';
		udpsp_end   : in  std_logic;
		udpsp_data  : in  std_logic_vector;

		udpdp_irdy  : out std_logic;
		udpdp_trdy  : in  std_logic := '1';
		udpdp_end   : in  std_logic;
		udpdp_data  : in  std_logic_vector;

		udplen_irdy : out std_logic;
		udplen_trdy : in  std_logic := '1';
		udplen_end  : in  std_logic;
		udplen_data : in  std_logic_vector;

		udp_irdy    : out std_logic;
		udp_trdy    : in  std_logic;
		udp_data    : out std_logic_vector;
		udp_end     : out std_logic;
		tp          : out std_logic_vector(1 to 32));
end;

architecture def of udp_tx is
	signal frm_ptr : std_logic_vector(0 to unsigned_num_bits(summation(udp4hdr_frame)/udp_data'length-1));

	signal cksm_irdy   : std_logic;
	signal cksm_end    : std_logic;
	signal cksm_data   : std_logic_vector(pl_data'range);


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

	dlltx_irdy  <= pl_irdy;
	nettx_irdy  <= pl_irdy  when  dlltx_end='1' else '0';
	tpttx_irdy  <= pl_irdy  when  nettx_end='1' else '0';
	udpsp_irdy  <= udp_trdy when  tpttx_end='1' else '0';
	udpdp_irdy  <= udp_trdy when  udpsp_end='1' else '0';
	udplen_irdy <= udp_trdy when  udpdp_end='1' else '0';
	cksm_irdy   <= udp_trdy when udplen_end='1' else '0';

	udp_irdy <=
		'0'      when cksm_end='0' else
		pl_irdy;

	pl_trdy <=
		nettx_trdy when nettx_end='0' else
		tpttx_trdy when tpttx_end='0' else
		udp_trdy;
	udp_frm  <= pl_frm;
	udp_end  <= pl_end;

	udp_data <=
		pl_data     when  dlltx_end='0' else
		pl_data     when  nettx_end='0' else
		pl_data     when  tpttx_end='0' else
		udpdp_data  when  udpdp_end='0' else
		udpsp_data  when  udpsp_end='0' else
		udplen_data when udplen_end='0' else
		(udp_data'range => '-');

end;