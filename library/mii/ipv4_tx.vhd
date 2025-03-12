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

entity ipv4_tx is
	port (
		mii_clk        : in  std_logic;

		pl_frm         : in  std_logic;
		pl_irdy        : in  std_logic;
		pl_trdy        : out std_logic;
		pl_end         : in  std_logic;
		pl_data        : in  std_logic_vector;

		ipv4_frm       : buffer std_logic;

		dlltx_irdy     : out std_logic;
		dlltx_end      : in  std_logic;

		nettx_irdy     : out std_logic;
		nettx_trdy     : in  std_logic := '1';
		nettx_end      : in  std_logic;

		ipv4a_frm      : buffer std_logic;
		ipv4a_irdy     : buffer std_logic;
		ipv4a_trdy     : in std_logic := '1';
		ipv4a_end      : in std_logic;
		ipv4a_data     : in std_logic_vector;

		ipv4len_frm    : buffer std_logic;
		ipv4len_irdy   : buffer std_logic;
		ipv4len_data   : in std_logic_vector;

		ipv4proto_frm  : buffer std_logic;
		ipv4proto_irdy : buffer std_logic;
		ipv4proto_trdy : in std_logic;
		ipv4proto_end  : in std_logic;
		ipv4proto_data : in std_logic_vector;

		ipv4_irdy      : buffer std_logic;
		ipv4_trdy      : in  std_logic;
		ipv4_end       : out std_logic;
		ipv4_data      : out std_logic_vector);
end;

architecture def of ipv4_tx is
	type states is (s_ipv4a, s_ipv4hdr);
	signal state         : states;
	signal frm_ptr       : std_logic_vector(0 to unsigned_num_bits(summation(ipv4hdr_frame)/ipv4_data'length-1));

	signal ipv4shdr_frm  : std_logic;
	signal ipv4shdr_irdy : std_logic;
	signal ipv4shdr_trdy : std_logic;
	signal ipv4shdr_data : std_logic_vector(ipv4_data'range);
	signal ipv4shdr_end  : std_logic;

	signal ipv4hdr_data  : std_logic_vector(ipv4_data'range);

	signal ipv4chsm_trdy : std_logic;
	signal ipv4chsm_end  : std_logic;
	signal ipv4chsm_data : std_logic_vector(ipv4_data'range);

	signal cksm_irdy     : std_logic;
	signal cksm_data     : std_logic_vector(ipv4_data'range);
	signal chksum        : std_logic_vector(0 to 16-1);
	signal chksum_rev    : std_logic_vector(16-1 downto 0);

begin

	pl_trdy <= 
		ipv4_trdy  when    dlltx_end='0' else
		nettx_trdy when    nettx_end='0' else
		'0'        when ipv4chsm_end='0' else
		'0'        when    ipv4a_end='0' else
		ipv4_trdy; 

	process (mii_clk)
		variable cntr : unsigned(frm_ptr'range);
	begin
		if rising_edge(mii_clk) then
			if pl_frm='1' then
				case state is
				when s_ipv4a =>
					if ipv4a_end='1' then
						if (ipv4_trdy and pl_irdy)='1' then
							cntr := cntr - 1;
						end if;
						state <= s_ipv4hdr;
					end if;
				when s_ipv4hdr =>
					if cntr(0)='0' then
						if (ipv4_trdy and pl_irdy)='1' then
							cntr := cntr - 1;
						end if;
					end if;
				end case;
			else
				cntr  := to_unsigned(summation(ipv4hdr_frame)/ipv4_data'length-1, cntr'length);
				state <= s_ipv4a;
			end if;
			frm_ptr <= std_logic_vector(cntr);
		end if;
	end process;

	ipv4shdr_e : entity hdl4fpga.sio_mux
	port map (
		mux_data => reverse(
			x"4500" &   -- Version, TOS
			x"0000" &   -- Identification
			x"0000" &   -- Fragmentation
			x"05",      -- Time To Live
			8),
		sio_clk  => mii_clk,
		sio_frm  => pl_frm,
		sio_irdy => ipv4shdr_irdy,
		sio_trdy => ipv4shdr_trdy,
		so_end   => ipv4shdr_end,
		so_data  => ipv4shdr_data);

	ipv4hdr_data <=
		ipv4shdr_data  when  ipv4shdr_frm='1' else
		ipv4proto_data when ipv4proto_frm='1' else
		ipv4len_data   when   ipv4len_frm='1' else
		(ipv4hdr_data'range => '-');

	cksm_data <= 
		ipv4a_data   when state=s_ipv4a and ipv4a_end='0' else
		ipv4hdr_data;
	cksm_irdy <= 
		ipv4a_trdy and ipv4a_irdy when state=s_ipv4a and ipv4a_end='0' else
	    ipv4_trdy;

	mii_1cksm_e : entity hdl4fpga.mii_1cksm
	generic map (
		n => 16)
	port map (
		mii_clk   => mii_clk,
		mii_frm   => pl_frm,
		mii_irdy  => cksm_irdy,
		mii_trdy  => ipv4chsm_trdy,
		mii_end   => ipv4proto_end,
		mii_empty => ipv4chsm_end,
		mii_data  => cksm_data,
		mii_cksm  => ipv4chsm_data);

	ipv4_frm <= pl_frm;
	field_p : process (pl_frm, frm_ptr, ipv4chsm_end, state, ipv4a_end)
	begin
		if pl_frm='1' then
			case state is
			when s_ipv4a   =>
				ipv4a_frm <= '1';
				if ipv4a_end='1' then
					ipv4shdr_frm  <= frame_decode(frm_ptr, reverse(ipv4hdr_frame), ipv4_data'length, (ipv4_verihl, ipv4_tos, ipv4_ident, ipv4_flgsfrg, ipv4_ttl));
				else
					ipv4shdr_frm  <= '0';
				end if;
				ipv4proto_frm <= '0';
				ipv4len_frm   <= '0';
			when s_ipv4hdr =>
				ipv4a_frm     <= ipv4chsm_end;
				ipv4shdr_frm  <= frame_decode(frm_ptr, reverse(ipv4hdr_frame), ipv4_data'length, (ipv4_verihl, ipv4_tos, ipv4_ident, ipv4_flgsfrg, ipv4_ttl));
				ipv4proto_frm <= frame_decode(frm_ptr, reverse(ipv4hdr_frame), ipv4_data'length, ipv4_proto);
				ipv4len_frm   <= frame_decode(frm_ptr, reverse(ipv4hdr_frame), ipv4_data'length, ipv4_len);
			end case;
		else
			ipv4a_frm     <= '0';
			ipv4shdr_frm  <= '0';
			ipv4proto_frm <= '0';
			ipv4len_frm   <= '0';
		end if;
	end process;

	dlltx_irdy <= pl_irdy and ipv4_trdy;
	nettx_irdy <= pl_irdy when dlltx_end='1' else '0';
	ipv4a_irdy <= 
		'0'       when dlltx_end='0'                     else 
		'1'       when (state=s_ipv4a and ipv4a_end='0') else
		ipv4_trdy when  state=s_ipv4hdr                  else
		ipv4_trdy;
	ipv4shdr_irdy  <= ipv4_trdy when  ipv4shdr_frm='1' else '0';
	ipv4proto_irdy <= ipv4_trdy when ipv4proto_frm='1' else '0';
	ipv4len_irdy   <= ipv4_trdy when   ipv4len_frm='1' else '0';
	ipv4_irdy <= 
		pl_irdy        when     dlltx_end='0' else 
		'0'            when (state=s_ipv4a and ipv4a_end='0') else
		ipv4shdr_trdy  when  ipv4shdr_end='0' else
		ipv4proto_trdy when ipv4proto_end='0' else
		ipv4chsm_trdy  when  ipv4chsm_end='0' else
		ipv4a_trdy     when     ipv4a_end='0' else
	    pl_irdy;

	ipv4_data <=  
		pl_data                    when     dlltx_end='0' else 
		ipv4hdr_data               when  ipv4shdr_end='0' else
		ipv4proto_data             when ipv4proto_end='0' else
		reverse(not ipv4chsm_data) when  ipv4chsm_end='0' else
		ipv4a_data                 when     ipv4a_end='0' else
		pl_data;

	ipv4_end <= 
		'0' when  ipv4shdr_end='0' else
		'0' when ipv4proto_end='0' else
		'0' when  ipv4chsm_end='0' else
		'0' when     ipv4a_end='0' else
	    pl_end;

end;