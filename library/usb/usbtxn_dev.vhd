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
		rxpid : in std_logic_vector(8-1 downto 0);
		rxbs  : in  std_logic;
		rxd   : in  std_logic);

end;

architecture def of usbtxn_dev is
	signal rgtr : unsigned(0 to 8+64+16-1);
begin

	data_p : process (clk)
		type states is (s_idle, s_data, s_ack);
		variable state   : states;
		variable piddata : std_logic_vector(8-1 downto 0);
	begin
		if rising_edge(clk) then
			if cken='1' then
				case state is
				when s_idle =>
					if rxdv='1' then
						if rxbs='0' then
							token := token rol 1;
							token(0) := rxd;
						end if;
					elsif pid=unsigned(tk_setup) then
						piddata := data0;
					elsif pid=unsigned(piddata) then
						state := s_data;
					end if;
				when s_data =>
					if rxdv='1' then
						if rxbs='0' then
							data := data rol 1;
							data(0) := rxd;
						end if;
					elsif pid=unsigned(data0) then
						cntr  := 0;
						txpid := unsigned(hs_ack);
						state := s_ack;
					elsif pid/=x"00" then
						state := s_setup;
					end if;
					setup_txen <= '0';
				when s_ack =>
					if txbs='0' then
						if cntr < 7 then
							cntr := cntr + 1;
						else
							state := s_setup;
						end if;
					end if;
					setup_txd <= txpid(0);
					txpid := txpid sll 1;
					Setup_txen  <= '1';
				end case;
			end if;
		end if;
	end process;

	setup_p : process (clk)
		type states is (s_setup, s_data, s_ack);
		variable state : states;
		alias  token   : unsigned(24-1 downto 0) is rgtr(0 to 24-1);
		alias  data    : unsigned(8+64+16-1 downto 0) is rgtr(0 to 8+64+16-1);
		alias  pid     : unsigned(8-1 downto 0) is rgtr(0 to 8-1);
		variable txpid : unsigned(0 to 8-1);
		variable cntr  : natural range 0 to 8-1;
	begin
		if rising_edge(clk) then
			if cken='1' then
				case state is
				when s_setup =>
					if rxdv='1' then
						if rxbs='0' then
							token := token rol 1;
							token(0) := rxd;
						end if;
					elsif pid=unsigned(tk_setup) then
						pid   := x"00";
						state := s_data;
					end if;
					setup_txen <= '0';
				when s_data =>
					if rxdv='1' then
						if rxbs='0' then
							data := data rol 1;
							data(0) := rxd;
						end if;
					elsif pid=unsigned(data0) then
						cntr  := 0;
						txpid := unsigned(hs_ack);
						state := s_ack;
					elsif pid/=x"00" then
						state := s_setup;
					end if;
					setup_txen <= '0';
				when s_ack =>
					if txbs='0' then
						if cntr < 7 then
							cntr := cntr + 1;
						else
							state := s_setup;
						end if;
					end if;
					setup_txd <= txpid(0);
					txpid := txpid sll 1;
					Setup_txen  <= '1';
				end case;
			end if;
		end if;
	end process;

	in_p : process (clk,cken)
		type states is (s_in, s_data);
		variable state : states;
		variable rgtr  : unsigned(0 to 8+64+16-1);
		alias  token   : unsigned(24-1 downto 0) is rgtr(0 to 24-1);
		alias  data    : unsigned(8+64+16-1 downto 0) is rgtr(0 to 8+64+16-1);
		alias  pid     : unsigned(8-1 downto 0) is rgtr(0 to 8-1);
		variable txpid : unsigned(0 to 8-1);
		variable dpid  : std_logic_vector(data0'range) := data0; 
		variable cntr  : natural range 0 to 8-1;
	begin
		if rising_edge(clk) then
			if cken='1' then
				if Setup_txen='1' then
					dpid := data0;
				end if;
			end if;

			if cken='1' then
				case state is
				when s_in =>
					if rxdv='1' then
						if rxbs='0' then
							token := token rol 1;
							token(0) := rxd;
						end if;
					elsif pid=unsigned(tk_in) then
						pid   := x"00";
						dpid := dpid xor reverse(x"88");
						txpid := unsigned(dpid);
						state := s_data;
					end if;
					in_txen <= '0';
					cntr  := 0;
				when s_data =>
					if txbs='0' then
						if cntr < 7 then
							cntr := cntr + 1;
						else
							state := s_in;
						end if;
					end if;
					in_txd  <= txpid(0);
					txpid := txpid sll 1;
					in_txen  <= '1';
				end case;
			end if;
		end if;
	end process;

	txen <= in_txen or setup_txen;
	txd  <= wirebus((in_txd, setup_txd), (in_txen, setup_txen));
end;