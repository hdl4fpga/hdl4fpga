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

entity usbtxn_dev is
	port (
		tp    : out std_logic_vector(1 to 32);
		clk   : in  std_logic;
		cken  : in  std_logic;

		txen  : out std_logic;
		txbs  : in  std_logic;
		txd   : out std_logic;

		rxdv  : in  std_logic;
		rxpid : in  std_logic_vector(8-1 downto 0);
		rxbs  : in  std_logic;
		rxd   : in  std_logic);

	constant tk_out   : std_logic_vector(8-1 downto 0) := reverse(not b"0001" & b"0001");
	constant tk_in    : std_logic_vector(8-1 downto 0) := reverse(not b"1001" & b"1001");
	constant tk_setup : std_logic_vector(8-1 downto 0) := reverse(not b"1101" & b"1101");
	constant tk_sof   : std_logic_vector(8-1 downto 0) := reverse(not b"0101" & b"0101");

	constant data0    : std_logic_vector(8-1 downto 0) := reverse(not b"0011" & b"0011");
	constant data1    : std_logic_vector(8-1 downto 0) := reverse(not b"1011" & b"1011");

	constant hs_ack   : std_logic_vector(8-1 downto 0) := reverse(not b"0010" & b"0010");
	constant hs_nack  : std_logic_vector(8-1 downto 0) := reverse(not b"1010" & b"1010");
	constant hs_stall : std_logic_vector(8-1 downto 0) := reverse(not b"1110" & b"1110");

end;

architecture def of usbtxn_dev is
	signal rx_token : std_logic_vector(0 to 16-1);
	signal tx_pid : std_logic_vector(8-1 downto 0);
	signal tx_req : std_logic;
	signal tx_rdy : std_logic;
begin

	txntx_p : process (clk)
		type states is (s_idle, s_token, s_data, s_hs);
		variable state : states;
		variable pid   : unsigned(8-1 downto 0);
		variable cntr  : natural range 0 to pid'length-1;
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (tx_req xor tx_rdy)='1' then
					case state is
					when s_idle =>
						txen <= '0';
						cntr := 0;
    					case tx_pid is
    					when tk_setup|tk_in|tk_out|tk_sof =>
    						state := s_token;
    					when data0|data1 =>
    						state := s_data;
    					when hs_ack|hs_nack|hs_stall =>
    						state := s_hs;
						when others =>
    					end case;
					when s_token =>
						tx_rdy <= tx_req;
						state  := s_idle;
					when s_data =>
						tx_rdy <= tx_req;
						state  := s_idle;
					when s_hs =>
						if txbs='0' then
							if cntr < 7 then
								cntr   := cntr + 1;
								txd    <= pid(0);
								pid    := pid srl 1;
								txen   <= '1';
							else
								txen   <= '0';
								tx_rdy <= tx_req;
								state  := s_idle;
							end if;
						end if;
					end case;
				else
					txen  <= '0';
					state := s_idle;
				end if;
			end if;
		end if;
	end process;

	data_p : process (clk)
		type states is (s_idle, s_token, s_data);
		variable state    : states;
		variable data_pid : std_logic_vector(8-1 downto 0);
	begin
		if rising_edge(clk) then
			if cken='1' then
				data_pid := data0;
			end if;
		end if;
	end process;

	txnrx_p : process (clk)
		type states is (s_idle, s_token, s_data);
		variable state    : states;
		variable token    : unsigned(rx_token'range);
		variable data_pid : std_logic_vector(8-1 downto 0);
	begin
		if rising_edge(clk) then
			if cken='1' then
				case state is
				when s_idle =>
					if rxdv='1' then
						if rxbs='0' then
    						case rxpid is
        					when tk_setup|tk_in|tk_out|tk_sof =>
    							token := token rol 1;
    							token(0) := rxd;
								state := s_token;
    						when others =>
    							if rxpid=data_pid then
    								state := s_data;
    							end if;
							end case;
						end if;
					end if;
				when s_token =>
					if rxdv='1' then
						if rxbs='0' then
							token := token rol 1;
							token(0) := rxd;
						end if;
					else
						state := s_idle;
					end if;
				when s_data  =>
				end case;
			end if;
		end if;
	end process;

end;