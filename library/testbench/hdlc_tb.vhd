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

library hdl4fpga;
use hdl4fpga.base.all;

entity hdlc_tb is
	generic (
		debug     : boolean;
		baudrate  : natural;
		uart_freq : real;
		payload_segments : natural_vector;
		payload   : std_logic_vector :=
			x"01007e" &
			x"18ff"   &
			x"000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f" &
			x"202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f" &
			x"404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f" &
			x"606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f" &
			x"808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9f" &
			x"a0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebf" &
			x"c0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedf" &
			x"e0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff" &
			x"1702_0000ff_1603_0000_0000" &
			x"010008_1702_0000ff_1603_8000_0000");
	port (
		rst       : in  std_logic;
		uart_clk  : in  std_logic;
		uart_sin  : in  std_logic;
		uart_sout : out std_logic);
end;

architecture def of hdlc_tb is

	signal uart_trdy     : std_logic;
	signal uart_irdy     : std_logic;
	signal uart_txd      : std_logic_vector(0 to 8-1);

	signal uartrx_irdy   : std_logic;
	signal uartrx_data   : std_logic_vector(0 to 8-1);

	signal hdlctx_frm    : std_logic;
	signal hdlctx_end    : std_logic;
	signal hdlctx_trdy   : std_logic;
	signal hdlctx_data   : std_logic_vector(0 to 8-1);

	signal hdlcrx_frm    : std_logic;
	signal hdlcrx_end    : std_logic;
	signal hdlcrx_trdy   : std_logic;
	signal hdlcrx_irdy   : std_logic;
	signal hdlcrx_data   : std_logic_vector(0 to 8-1);
	signal hdlcfcsrx_sb  : std_logic;
	signal hdlcfcsrx_vld : std_logic;

	signal rst_n         : std_logic;

begin

	rst_n <= not rst;

	process 
		variable segment : natural;
		variable total   : natural;
		variable addr    : natural;
	begin
		if rst='1' then
			hdlctx_frm <= '0';
			hdlctx_end <= '0';
			addr       := 0;
			total      := 0;
			segment    := 0;
		elsif rising_edge(uart_clk) then
			if addr < total then
				hdlctx_data <= reverse(payload(addr to addr+8-1));
				if hdlctx_trdy='1' then
					addr := addr + 8;
				end if;
				if addr < total then
					hdlctx_frm <= '1';
					hdlctx_end <= '0';
				else
					hdlctx_frm <= '1';
					hdlctx_end <= '1';
				end if;
			elsif segment < payload_segments'length then
				if segment > 0 then
					if debug then
						wait for 5 us;
					else
						wait for 100 us;
					end if;
					hdlctx_frm <= '0';
					hdlctx_end <= '0';
				end if;
				total   := total + payload_segments(segment);
				segment := segment + 1;
			else
				hdlctx_data <= (others => '-');
			end if;

		end if;
		wait on rst, uart_clk;
	end process;

	hdlcdll_tx_e : entity hdl4fpga.hdlcdll_tx
	port map (
		hdlctx_frm  => hdlctx_frm,
		hdlctx_irdy => '1',
		hdlctx_trdy => hdlctx_trdy,
		hdlctx_end  => hdlctx_end,
		hdlctx_data => hdlctx_data,

		uart_clk    => uart_clk,
		uart_irdy   => uart_irdy,
		uart_trdy   => uart_trdy,
		uart_data   => uart_txd);

	uarttx_e : entity hdl4fpga.uart_tx
	generic map (
		baudrate  => baudrate,
		clk_rate  => uart_freq)
	port map (
		uart_frm  => rst_n,
		uart_txc  => uart_clk,
		uart_sout => uart_sout,
		uart_trdy => uart_trdy,
		uart_irdy => uart_irdy,
		uart_data => uart_txd);

	uartrx_e : entity hdl4fpga.uart_rx
	generic map (
		baudrate  => baudrate,
		clk_rate  => uart_freq)
	port map (
		uart_rxc  => uart_clk,
		uart_sin  => uart_sin,
		uart_irdy => uartrx_irdy,
		uart_data => uartrx_data);

	hdlcdll_rx_e : entity hdl4fpga.hdlcdll_rx
	port map (
		uart_clk    => uart_clk,
		uartrx_irdy => uartrx_irdy,
		uartrx_data => uartrx_data,

		hdlcrx_frm  => hdlcrx_frm,
		hdlcrx_irdy => hdlcrx_irdy,
		hdlcrx_data => hdlcrx_data,
		hdlcrx_end  => hdlcrx_end,
		fcs_sb      => hdlcfcsrx_sb,
		fcs_vld     => hdlcfcsrx_vld);

end;
