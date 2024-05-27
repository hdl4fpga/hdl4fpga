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
		debug   : boolean;
		payload_segments : natural_vector;
		payload : std_logic_vector :=
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
		rst      : in std_logic;
		usb_clk  : in std_logic;
		usb_dp   : inout std_logic;
		usb_dn   : inout std_logic);
end;

architecture def of usb_tb is

	signal hdlctx_frm    : std_logic;
	signal hdlctx_end    : std_logic;
	signal hdlctx_irdy   : std_logic := '1';
	signal hdlctx_trdy   : std_logic;
	signal hdlctx_data   : std_logic_vector(0 to 8-1);

	signal hdlcrx_frm    : std_logic;
	signal hdlcrx_end    : std_logic;
	signal hdlcrx_trdy   : std_logic;
	signal hdlcrx_irdy   : std_logic;
	signal hdlcrx_data   : std_logic_vector(0 to 8-1);
	signal hdlcfcsrx_sb  : std_logic;
	signal hdlcfcsrx_vld : std_logic;

	signal usbtx_trdy    : std_logic;
	signal usbtx_irdy    : std_logic;
	signal usbtx_data    : std_logic_vector(0 to 8-1);
	signal srctx_trdy    : std_logic;
	signal srctx_sel     : std_logic;
	signal srctx_data    : std_logic_vector(0 to 8-1);
	signal slzrtx_irdy   : std_logic;
	signal slzrtx_trdy   : std_logic;
	signal slzrtx_data   : std_logic_vector(0 to 1-1);

	signal usbrx_irdy    : std_logic;
	signal usbrx_data    : std_logic_vector(0 to 8-1);

	signal usb_cken      : std_logic;
	signal usb_idle      : std_logic;
	signal usb_txen      : std_logic := '0';
	signal usb_txbs      : std_logic;
	signal usb_txd       : std_logic := '0';
	signal usb_rxdv      : std_logic := '0';
	signal usb_rxbs      : std_logic;
	signal usb_rxd       : std_logic;

	signal dev_cfgd      : std_logic;
	signal cfg_txen      : std_logic := '0';
	signal cfg_txd       : std_logic := '0';

	signal indata_req    : std_logic := '0';
	signal indata_rdy    : std_logic := '0';
	signal indata_txen   : std_logic := '0';
	signal indata_txd    : std_logic := '0';

	signal outdata_req   : std_logic := '0';
	signal outdata_rdy   : std_logic := '0';
	signal outdata_txen  : std_logic := '0';
	signal outdata_txd   : std_logic := '0';

begin

	process 
		variable segment : natural;
		variable total   : natural;
		variable addr    : natural;
	begin
		if (outdata_rdy xor outdata_req)='0' then
			hdlctx_frm <= '0';
			hdlctx_end <= '0';
			addr       := 0;
			total      := 0;
			segment    := 0;
		elsif rising_edge(usb_clk) then
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
					if hdlctx_trdy='1' then
						hdlctx_frm <= '0';
						hdlctx_end <= '0';
						total   := total + payload_segments(segment);
						segment := segment + 1;
						wait;
					end if;
				else
					total   := total + payload_segments(segment);
					segment := segment + 1;
				end if;
			elsif slzrtx_irdy='0' then
				wait for 3 us;
				-- outdata_rdy <= outdata_req;
				indata_req <= not indata_rdy;
				hdlctx_data <= (others => '-');
			end if;
		end if;

		wait on rst, usb_clk;
	end process;

	hdlcdll_tx_e : entity hdl4fpga.hdlcdll_tx
	port map (
		hdlctx_frm  => hdlctx_frm,
		hdlctx_irdy => hdlctx_irdy,
		hdlctx_trdy => hdlctx_trdy,
		hdlctx_end  => hdlctx_end,
		hdlctx_data => hdlctx_data,

		uart_clk    => usb_clk,
		uart_irdy   => usbtx_irdy,
		uart_trdy   => usbtx_trdy,
		uart_data   => usbtx_data);

	indata_e : block
	begin
		process 
			type time_vector is array (natural range <>) of time;
			constant data   : std_logic_vector := 
				reverse(x"691530",8)(0 to 19-1) &
				reverse(x"d2",8);
			constant length : natural_vector   := (19, 8);
			constant delays : time_vector      := (45 us, 45 us);

			variable right  : natural;
			variable i      : natural;
			variable j      : natural;
		begin
			if rising_edge(usb_clk) then
				if dev_cfgd='0' then
					indata_rdy <= indata_req;
					indata_txen <= '0';
					i     := 0;
					j     := 0;
					right := 0;
				elsif (indata_req xor indata_rdy)='1' then
    				if j < right then
    					if usb_txbs='0' then
    						indata_txen <= '1';
    						indata_txd  <= data(j);
    						j := j + 1;
    					end if;
    				elsif usb_txbs='0' then
    					indata_txen <= '0';
    					if usb_idle='1' then
    						if  i < delays'length then
    							wait for delays(i);
    							right := right + length(i);
    							i     := i + 1;
    						else
								indata_txen <= '0';
								-- i     := 0;
								-- j     := 0;
								-- right := 0;
    							indata_rdy <= indata_req;
    						end if;
    					end if;
    				end if;
				end if;
			end if;
			wait on usb_clk;
		end process;
	end block;

	outata_e : block
		signal pid : std_logic_vector(0 to 8-1) := x"c3";
	begin
		process (usb_clk)
			type time_vector is array (natural range <>) of time;
			constant data   : std_logic_vector := reverse(x"e11530",8)(0 to 19-1);
			constant length : natural_vector   := (0 => 19);
			constant delays : time_vector      := (0 => 0 us);

			variable right  : natural;
			variable i      : natural;
			variable j      : natural;
		begin
			if rising_edge(usb_clk) then
				if dev_cfgd='0' then
					outdata_req  <= outdata_rdy;
					outdata_txen <= '0';
					i     := 0;
					j     := 0;
					right := 0;
				elsif (outdata_req xor outdata_rdy)='0' then
    				if j < right then
    					if usb_txbs='0' then
    						outdata_txen <= '1';
    						outdata_txd  <= data(j);
    						j := j + 1;
    					end if;
    				elsif usb_txbs='0' then
    					outdata_txen <= '0';
    					if usb_idle='1' then
    						if  i < delays'length then
    							right := right + length(i);
    							i     := i + 1;
    						else
								outdata_txen <= '0';
								i     := 0;
								j     := 0;
								right := 0;
    							outdata_req <= not outdata_rdy;
    						end if;
    					end if;
    				end if;
				end if;
			end if;
		end process;

		process (usb_clk)
			variable npid : std_logic_vector(0 to 8-1) := x"c3";
		begin
			if rising_edge(usb_clk) then
				if hdlctx_frm='0' then
					srctx_sel <= '0';
					pid <= npid;
				elsif srctx_trdy='1' then
					srctx_sel <= '1';
					npid := pid xor x"88"; 
				end if;
			end if;
		end process;

		usbtx_trdy <= '0'	when srctx_sel='0' else srctx_trdy;
		srctx_data <= pid when srctx_sel='0' else reverse(usbtx_data);

	end block;

	slzrtx_trdy <= dev_cfgd and not usb_txbs;
	txserlzr_e : entity hdl4fpga.serlzr
	port map (
		src_clk  => usb_clk,
		src_frm  => hdlctx_frm,
		src_irdy => usbtx_irdy,
		src_trdy => srctx_trdy,
		src_data => srctx_data,
		dst_clk  => usb_clk,
		dst_frm  => hdlctx_frm,
		dst_irdy => slzrtx_irdy,
		dst_trdy => slzrtx_trdy,
		dst_data => slzrtx_data);

	configuration_b : block
	begin
		process 
			type time_vector is array (natural range <>) of time;
			constant data : std_logic_vector := 
				reverse(x"2d0010",8)(0 to 19-1) &
				reverse(x"c3_0005_1500_0000_0000_e831",8)(0 to 72-1) &
				reverse(x"690010",8)(0 to 19-1) &
				reverse(x"d2",8) &

				reverse(x"2d1530",8)(0 to 19-1) &
				reverse(x"C3_0009_0100_0000_0000_2725",8)(0 to 72-1) &
				reverse(x"691530",8)(0 to 19-1) &
				reverse(x"d2",8);

			constant length : natural_vector := (
				19,   72,  19, 8,
				19,   72,  19, 8);

			constant delays : time_vector := (
				0 us, 0 us, 2 us, 3 us,
				0 us, 0 us, 2 us, 3 us);

			variable i     : natural;
			variable j     : natural;
			variable right : natural;
		begin
			if rising_edge(usb_clk) then
				if rst='1' then
					dev_cfgd <= '0';
					cfg_txen <= '0';
					i     := 0;
					j     := 0;
					right := 0;
				elsif j < right then
						if usb_txbs='0' then
							cfg_txd  <= data(j);
							cfg_txen <= '1';
							j := j + 1;
						end if;
				elsif usb_txbs='0' then
					cfg_txen <= '0';
					if usb_idle='1' then
						if  i < delays'length then
							wait for delays(i);
							right := right + length(i);
							i     := i + 1;
						else
							dev_cfgd <= '1';
							wait;
						end if;
					end if;
				end if;
			end if;

			wait on usbtx_irdy, slzrtx_irdy, slzrtx_data, usb_clk;
		end process;
	end block;

	(usb_txen, usb_txd) <= 
		std_logic_vector'(cfg_txen,  cfg_txd)  when dev_cfgd='0'                else
		std_logic_vector'(outdata_txen, outdata_txd) when (outdata_req xor outdata_rdy)='0' else
		std_logic_vector'(indata_txen,  indata_txd)  when (indata_req  xor indata_rdy)='1' else
		std_logic_vector'(slzrtx_irdy, slzrtx_data(0));

  	host_e : entity hdl4fpga.usbphycrc
	port map (
		dp   => usb_dp,
		dn   => usb_dn,
		idle => usb_idle,
		clk  => usb_clk,
		cken => usb_cken,

		txen => usb_txen,
		txbs => usb_txbs,
		txd  => usb_txd,

		rxdv => usb_rxdv,
		rxbs => usb_rxbs,
		rxd  => usb_rxd);

end;
