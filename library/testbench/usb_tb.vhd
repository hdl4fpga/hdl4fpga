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

entity usb_tb is
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

architecture def of usb_tb is

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

	host_b : block
		signal tp   : std_logic_vector(1 to 32);
		signal rst  : std_logic;
		alias  clk  is usb_clk;
		signal cken : std_logic;
		signal txen : std_logic := '0';
		signal txbs : std_logic;
		signal txd  : std_logic := '0';
		signal rxdv : std_logic := '0';
		signal rxbs : std_logic;
		signal rxd  : std_logic;
		signal idle : std_logic;
	begin

		rst <= '1', '0' after 0.500 us;
		process 
			type time_vector is array (natural range <>) of time;
			-- constant data : std_logic_vector := reverse(x"a50df2",8)(0 to 19-1);
			-- constant data : std_logic_vector := reverse(x"a527b2",8)(0 to 19-1);
			-- constant data : std_logic_vector := reverse(x"a50302",8)(0 to 19-1);
			-- constant data : std_logic_vector := reverse(x"a5badf",8)(0 to 19-1);
			-- constant data : std_logic_vector := reverse(x"2d0010",8)(0 to 19-1);
			-- constant data : std_logic_vector := reverse(x"a5ff98",8)(0 to 19-1);
			-- constant data : std_logic_vector := reverse(x"a5ff47",8)(0 to 19-1);
			-- constant data : std_logic_vector := reverse(x"e10010",8)(0 to 19-1);
			-- constant data : std_logic_vector := reverse(x"c300_05_1500_0000_0000_e831",8)(0 to 72-1);
			-- constant data : std_logic_vector := reverse(x"c300_05_2d00_0000_0000_ec89",8)(0 to 72-1);
			-- constant data : std_logic_vector := reverse(x"c300_05_1700_0000_0000_e9d3",8)(0 to 72-1);
			-- constant data : std_logic_vector := reverse(x"c300_05_1700_0000_0000_e9d3",8)(0 to 72-1);
			-- constant data : std_logic_vector := reverse(x"c300_05_0c00_0000_0000_ea38",8)(0 to 72-1);
			-- constant data : std_logic_vector := reverse(x"c380_06_0001_0000_0800_eb94",8)(0 to 72-1);

			constant msg0 : std_logic_vector := x"4b" & x"606162636465666768696a6b6c6d6e6f";
			constant msg1 : std_logic_vector := x"c3" & x"707172737475767778797a7b7c7d7e7f";
			constant data : std_logic_vector := 
				reverse(x"2d0010",8)(0 to 19-1) &
				reverse(x"c3_0005_1500_0000_0000_e831",8)(0 to 72-1) &
				reverse(x"690010",8)(0 to 19-1) &
				reverse(x"d2",8) &
				reverse(x"2d1530",8)(0 to 19-1) &

				reverse(x"C3_8006_0001_0000_0800_eb94",8)(0 to 72-1) &
				reverse(x"691530",8)(0 to 19-1) &
				reverse(x"691530",8)(0 to 19-1) &
				reverse(x"d2",8) &
				reverse(x"2d1530",8)(0 to 19-1) &

				reverse(x"C3_8006_0001_0000_1200_ae04",8)(0 to 72-1) &
				reverse(x"691530",8)(0 to 19-1) &
				reverse(x"d2",8) &
				reverse(x"691530",8)(0 to 19-1) &
				reverse(x"d2",8) &

				reverse(x"2d1530",8)(0 to 19-1) &
				reverse(x"C3_0009_0100_0000_0000_2725",8)(0 to 72-1) &
				reverse(x"691530",8)(0 to 19-1) &
				reverse(x"d2",8) &
				reverse(x"691530",8)(0 to 19-1) &

				reverse(x"d2",8) &
				reverse(x"e19500",8)(0 to 19-1) &
				reverse(msg0, 8)  &
				reverse(x"699500",8)(0 to 19-1) &
				reverse(x"e19500",8)(0 to 19-1) &

				-- reverse(x"a50000",8)(0 to 19-1) &
				reverse(msg1, 8) &
				reverse(x"699500",8)(0 to 19-1) &
				reverse(x"d2",8) &
				reverse(x"699500",8)(0 to 19-1);

			constant length : natural_vector := (
				19,          72,          19,    8,    19,
				72,          19,          19,    8,    19,
				72,          19,           8,   19,     8,
				19,          72,          19,    8,    19,
				 8,          19, msg0'length,   19,    19,
				 0, msg1'length,          19,    8,    19);

			constant delays : time_vector := (
				 0 us,     0 us,        2 us,  3 us,  0 us,
				 0 us,     2 us,        9 us,  9 us,  0 us,
				 0 us,     2 us,       15 us,  0 us,  3 us,
				 0 us,     0 us,        2 us,  3 us,  0 us, 
				 3 us,     0 us,        0 us,  2 us, 14 us,
				 0 us,     0 us,        2 us, 14 us,  0 us);

			variable i     : natural;
			variable j     : natural;
			variable right : natural;
		begin
			if rising_edge(clk) then
				if rst='1' then
					txen  <= '0';
					i     := 0;
					j     := 0;
					right := 0;
				elsif j < right then
						if txbs='0' then
							txd  <= data(j);
							txen <= '1';
							j := j + 1;
						end if;
				elsif txbs='0' then
					txen <= '0';
					if idle='1' then
						if  i < delays'length then
							wait for delays(i);
							right := right + length(i);
							i     := i + 1;
						else
							wait;
						end if;
					end if;
				end if;
			end if;
			wait on clk;
		end process;

	  	host_e : entity hdl4fpga.usbphycrc
		port map (
			tp   => tp,
			dp   => dp,
			dn   => dn,
			idle => idle,
			clk  => clk,
			cken => cken,

			txen => txen,
			txbs => txbs,
			txd  => txd,

			rxdv => rxdv,
			rxbs => rxbs,
			rxd  => rxd);

		rx_p : process (clk)
			variable cntr : natural := 0;
			variable shr  : std_logic_vector(0 to 128-1);
			variable msb  : std_logic_vector(shr'range);
		begin
			if rising_edge(clk) then
				if cken='1' then
					if (rxdv and not rxbs)='1' then
						if cntr < shr'length then
							shr(cntr) := rxd;
							cntr := cntr + 1;
						end if;
					end if;
				end if;
				msb := reverse(shr,8);
			end if;
		end process;

	end block;


end;
