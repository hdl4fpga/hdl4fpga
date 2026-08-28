-- Copyright (c) 2015 Miguel Angel Sagreras                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.hdo.all;
use hdl4fpga.base.all;

entity tb_ipoe is
	generic (
		sha  : string;
		data : string);
	port (
		txc  : in  std_logic;
		req  : in  std_logic;
		rdy  : buffer std_logic := '0';
		txen : buffer std_logic;
		txd  : out std_logic_vector;

		rxc  : in  std_logic;
		rxdv : in  std_logic;
		rxd  : in  std_logic_vector);
end;

architecture def of tb_ipoe is
	signal ethtx_req : std_logic := '0';
	signal ethtx_rdy : std_logic := '0';
	signal fcs_sb    : std_logic;
	signal id : unsigned(0 to unsigned_num_bits(length(data)-1)-1);
begin

	process(txc)
		type states is (s_tx, s_rx);
		variable state : states;
	begin
		if rising_edge(txc) then
			if (rdy xor req)='1' then
				case state is
				when s_tx =>
					ethtx_req <= not ethtx_rdy;
					state := s_rx;
				when s_rx =>
					if (ethtx_req xor ethtx_rdy)='0' then
						if fcs_sb='1' then
							if (id+1) < length(data) then
								id <= id + 1;
							else
								rdy <= req;
							end if;
							state := s_tx;
						end if;
					end if;
				end case;
			else
				id <= (others => '0');
				state := s_tx;
			end if;
		end if;
	end process;

	tbethtx_e : entity work.tb_ethtx
	generic map (
		sha  => sha,
		data => data)
	port map (
		req  => ethtx_req,
		rdy  => ethtx_rdy,
		id   => std_logic_vector(id),
		txc  => txc,
		txen => txen,
		txd  => txd);

	tbehrx_e : entity hdl4fpga.eth_rx
	port map (
		mii_clk  => rxc,
		mii_frm  => rxdv,
		mii_irdy => rxdv,
		mii_data => rxd,
		fcs_sb   => fcs_sb);
end;
