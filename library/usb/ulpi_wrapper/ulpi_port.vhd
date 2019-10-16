--
-- Copyright (C) 2013 Vad Rulezz <vr5@narod.ru>
--
-- This module is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License version 2 as
-- published by the Free Software Foundation.
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ulpi_port is
port(
	ulpi_data_in  : in  std_logic_vector(7 downto 0);
	ulpi_data_out : out std_logic_vector(7 downto 0) := x"00";
	ulpi_dir      : in  std_logic;
	ulpi_nxt      : in  std_logic;
	ulpi_stp      : out std_logic := '1';
	ulpi_reset    : out std_logic := '1';
	ulpi_clk60    : in  std_logic;

	utmi_databus16_8 : in  std_logic;
	utmi_reset       : in  std_logic;
	utmi_xcvrselect  : in  std_logic;
	utmi_termselect  : in  std_logic;
	utmi_opmode      : in  std_logic_vector(1 downto 0);
	utmi_linestate   : out std_logic_vector(1 downto 0) := "00";
	utmi_clkout      : out std_logic;
	utmi_txvalid     : in  std_logic;
	utmi_txready     : out std_logic := '0';
	utmi_rxvalid     : out std_logic := '0';
	utmi_rxactive    : out std_logic := '0';
	utmi_rxerror     : out std_logic := '0';
	utmi_datain      : out std_logic_vector(7 downto 0) := x"00";
	utmi_dataout     : in  std_logic_vector(7 downto 0)
);
end ulpi_port;

architecture behave of ulpi_port is

signal xcvrselect_d : std_logic := '1';
signal termselect_d : std_logic := '0';
signal opmode_d     : std_logic_vector(1 downto 0) := "00";

signal dir_d : std_logic := '0';

signal ulpi_control   : std_logic_vector(7 downto 0) := x"41";
signal control_update : std_logic := '0';
signal ulpi_rxvalid   : std_logic := '0';
signal ulpi_rxactive  : std_logic := '0';

signal save_outp  : std_logic_vector(7 downto 0);
signal save_valid : std_logic;

type state_type is (INIT, IDLE, TXDATA, TXDATA1, TXDATA2, TXCTL, TXCTL1, TXCTL2);
signal state : state_type := INIT;

signal reset_timer : integer := 0;

begin

utmi_clkout <= ulpi_clk60;
utmi_rxactive <= ulpi_rxactive or ulpi_rxvalid;
utmi_rxvalid  <= ulpi_rxvalid;

process (ulpi_clk60)
begin
	if ulpi_clk60'event and ulpi_clk60 = '1' then
		ulpi_reset    <= '0';
		ulpi_stp      <= '0';
		utmi_txready  <= '0';
		ulpi_rxvalid  <= '0';

		if utmi_xcvrselect /= xcvrselect_d then
			ulpi_control(0) <= utmi_xcvrselect;
			control_update  <= '1';
		end if;
		if utmi_termselect /= termselect_d then
			ulpi_control(2) <= utmi_termselect;
			control_update  <= '1';
		end if;
		if utmi_opmode /= opmode_d then
			ulpi_control(4 downto 3) <= utmi_opmode;
			control_update  <= '1';
		end if;

		xcvrselect_d <= utmi_xcvrselect;
		termselect_d <= utmi_termselect;
		opmode_d     <= utmi_opmode;

		utmi_datain <= ulpi_data_in;

		if ulpi_dir = dir_d then	-- if not equal wait for bus turnaround
			if ulpi_dir = '1' then
				ulpi_rxvalid <= ulpi_nxt;

				if ulpi_nxt = '0' then
					utmi_linestate <= ulpi_data_in(1 downto 0);

					case ulpi_data_in(5 downto 4) is
					when "00" =>
						ulpi_rxactive <= '0';
						utmi_rxerror  <= '0';
					when "01" =>
						ulpi_rxactive <= '1';
						utmi_rxerror  <= '0';
					when "11" =>
						ulpi_rxactive <= '1';
						utmi_rxerror  <= '1';
					when others =>
					end case;
				end if; -- ulpi_nxt
			else
				case state is
				when INIT =>
					if reset_timer /= 31 then
						reset_timer <= reset_timer + 1;
					else
						ulpi_data_out <= x"8a"; -- reg write - otg control
						state <= TXCTL1;
					end if;

				when IDLE =>
					if control_update = '1' then
						ulpi_data_out <= x"84"; -- reg write - function control
						control_update <= '0';
						state <= TXCTL;
					elsif utmi_txvalid = '1' then
						utmi_txready  <= '1';
						state <= TXDATA;
					end if;

				when TXDATA =>
					ulpi_data_out <= x"40"; -- tx cmd
					ulpi_data_out(3 downto 0) <= UTMI_DATAOUT(3 downto 0); -- pkt id
					state <= TXDATA1;
					utmi_txready <= '1';

				when TXDATA1 =>
					if ulpi_nxt = '1' then
						if utmi_txvalid = '1' then
							utmi_txready <= '1';
							ulpi_data_out <= utmi_dataout;
						else
							ulpi_stp      <= '1';
							ulpi_data_out <= x"00";
							state <= IDLE;
						end if;
					else
						save_valid <= utmi_txvalid;
						save_outp  <= utmi_dataout;
						state <= TXDATA2;
					end if;

				when TXDATA2 =>
					if ulpi_nxt = '1' then
						if save_valid = '1' then
							utmi_txready  <= utmi_txvalid;
							ulpi_data_out <= save_outp;
							state <= TXDATA1;
						else
							ulpi_stp      <= '1';
							ulpi_data_out <= x"00";
							state <= IDLE;
						end if;
					end if;

				when TXCTL =>
					if ulpi_nxt = '1' then
						ulpi_data_out  <= ulpi_control;
						state <= TXCTL2;
					end if;

				when TXCTL1 =>
					if ulpi_nxt = '1' then
						ulpi_data_out  <= x"00";	-- OTG control - device mode
						state <= TXCTL2;
					end if;

				when TXCTL2 =>
					ulpi_stp      <= '1';
					ulpi_data_out <= x"00";
					state <= IDLE;
				end case;
			end if; -- ulpi_dir
		end if; -- ulpi_dir = dir_d
		
		dir_d <= ulpi_dir;
	end if; -- clk
end process;

end behave;
