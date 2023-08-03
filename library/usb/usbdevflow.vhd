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
use hdl4fpga.usbpkg.all;

entity usbdevflow is
	generic (
		txbuffer : boolean := false);
	port (
		tp        : out std_logic_vector(1 to 32) := (others => '0');
		clk       : in  std_logic;
		cken      : in  std_logic;

		rx_req    : in  std_logic;
		rx_rdy    : buffer std_logic;
		rxpidv    : in  std_logic;
		rxpid     : in  std_logic_vector(4-1 downto 0);
		rxdv      : in  std_logic;
		rxbs      : in  std_logic;
		rxd       : in  std_logic;
		tkdata    : in  std_logic_vector(0 to 11-1);
		phyerr    : in  std_logic;
		crcerr    : in  std_logic;
		tkerr     : in  std_logic;

		tx_req    : buffer std_logic;
		tx_rdy    : in  std_logic;
		txpid     : out std_logic_vector(4-1 downto 0);
		txen      : buffer std_logic;
		txbs      : in  std_logic;
		txd       : buffer std_logic;

		rqst_req : buffer bit;
		rqst_rdy : in  bit;

		dev_txen  : in  std_logic;
		dev_txbs  : out std_logic;
		dev_txd   : in  std_logic;

		dev_rxdv  : out std_logic;
		dev_rxbs  : buffer std_logic;
		dev_rxd   : out std_logic;
		dev_addr  : in  std_logic_vector(0 to 7-1);
		dev_endp  : out std_logic_vector(7 to 11-1);
		dev_cfgd  : in  std_logic;

		rqst_rxdv : out std_logic;
		rqst_rxbs : out std_logic;
		rqst_rxd  : out std_logic;
		rqst_txen : in  std_logic;
		rqst_txbs : out std_logic;
		rqst_txd  : in  std_logic);
end;

architecture def of usbdevflow is

	signal requesttype : std_logic_vector( 8-1 downto 0);
	signal value   : std_logic_vector(16-1 downto 0);
	signal index   : std_logic_vector(16-1 downto 0);
	signal length  : std_logic_vector(16-1 downto 0);

	signal ctlr_req  : bit;
	signal ctlr_rdy  : bit;
	signal stus_req  : bit;
	signal stus_rdy  : bit;
	signal setup_req : bit;
	signal setup_rdy : bit;
	signal in_req    : bit;
	signal in_rdy    : bit;
	signal out_req   : bit;
	signal out_rdy   : bit;
	signal ackrx_rdy : bit;
	signal ackrx_req : bit;
	signal acktx_rdy : bit;
	signal acktx_req : bit;

	signal buffer_txen : std_logic;
	signal buffer_txbs : std_logic;
	signal buffer_txd  : std_logic;

	signal ddata     : std_logic_vector(data0'range);

	signal rxerr     : std_logic;

begin

	rxerr <= phyerr or tkerr or crcerr;

	dev_endp <= tkdata(dev_endp'range);
	hosttodev_p : process (cken, clk)
		constant tbit : std_logic_vector(data0'range) := b"1000";
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (rx_rdy xor rx_req)='1' then
    				case rxpid is
    				when tk_setup =>
    					if (setup_req xor setup_rdy)='0' then
							if tkdata(dev_addr'range) = (dev_addr'range => '0') or
							   tkdata(dev_addr'range) = dev_addr then
								ddata     <= data0;
								rqst_req <= not rqst_rdy;
								ctlr_req  <= not ctlr_rdy;
								setup_req <= not setup_rdy;
							end if;
    					end if;
    				when tk_in =>
    					if (in_req xor in_rdy)='0' then
							if tkdata(dev_addr'range) = (dev_addr'range => '0') or
							   tkdata(dev_addr'range) = dev_addr then
								in_req   <= not in_rdy;
							end if;
    					end if;
    				when tk_out=>
    					if (out_req xor out_rdy)='0' then
							if tkdata(dev_addr'range) = (dev_addr'range => '0') or
							   tkdata(dev_addr'range) = dev_addr then
								out_req <= not out_rdy;
							end if;
    					end if;
    				when data0|data1 =>
						if tkdata(dev_addr'range) = (dev_addr'range => '0') or
						   tkdata(dev_addr'range) = dev_addr then
							if rxerr='0' then
								ddata     <= ddata xor tbit;
								out_rdy   <= out_req;
								acktx_req <= not acktx_rdy; 
							end if;
						end if;
    				when hs_ack =>
						if (ackrx_req xor ackrx_rdy)='0' then
							ackrx_req <= not ackrx_rdy;
						end if;
						if (stus_rdy xor stus_req)='1' then
							ctlr_rdy <= ctlr_req;
							stus_rdy <= stus_req;
						end if;
    					ddata <= ddata xor tbit;
    				when others =>
    				end case;
				end if;
				rx_rdy <= to_stdulogic(to_bit(rx_req));
			end if;
		end if;
	end process;

	devtohost_p : process (clk)
		type states is (s_idle, s_bulk);
		variable state : states;
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (to_bit(tx_rdy) xor to_bit(tx_req))='0' then
					if (in_rdy xor in_req)='1' then
						txpid   <= ddata;
						tx_req  <= not to_stdulogic(to_bit(tx_rdy));
						if txen='0' then
							stus_req <= not stus_rdy;
						end if;
						in_rdy <= in_req;
					end if;
					if (acktx_rdy xor acktx_req)='1' then
						txpid   <= hs_ack;
						tx_req  <= not to_stdulogic(to_bit(tx_rdy));
						acktx_rdy <= acktx_req;
					end if;
				end if;
			end if;
		end if;
	end process;

	rxbuffer_p : process (rqst_req, clk)
		variable mem  : std_logic_vector(0 to 1024*8-1);
		variable pin  : natural range mem'range;
		variable pout : natural range mem'range;
		variable prty : natural range mem'range;
		variable we   : std_logic;
		variable din  : std_logic;
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (setup_rdy xor setup_req)='1' then
					pout := pin;
					prty := pin;
				elsif pout /= prty then
					if dev_rxbs='0' then
						pout := pout + 1;
					end if;
				elsif (out_rdy xor out_req)='0' then
					if rxerr='1' then
						prty := pin;
					else
						pin := prty;
					end if;
				end if;

				if pout=pin then
					dev_rxdv <='0';
				else
					dev_rxdv <='1';
				end if;
				dev_rxd <= mem(pout);
				if we='1' then
					mem(pin) := din;
					pin := pin + 1;
				end if;

				if (out_rdy xor out_req)='1' then
					if rxpidv='0' then
						we := '0';
					elsif rxbs='1' then
						we := '0';
					else
						we := '1';
					end if;
				end if;
				din := rxd;
			end if;
		end if;
	end process;

	buffer_txbs <= txbs;
	txbuffer_p : process (rqst_rdy, clk)
		variable mem  : std_logic_vector(0 to 1024*8-1);
		variable pin  : natural range mem'range;
		variable pout : natural range mem'range;
		variable prty : natural range mem'range;
		variable we   : std_logic;
		variable din  : std_logic;
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (setup_rdy xor setup_req)='1' then
					pout := pin;
					prty := pout;
					ackrx_rdy <= ackrx_req;
				elsif pout /= pin then
					if buffer_txbs='0' then
						pout := pout + 1;
					end if;
				elsif (ackrx_rdy xor ackrx_req)='1' then
					prty := pout;
					ackrx_rdy <= ackrx_req;
				elsif (in_rdy xor in_req)='1' then
					pout := prty;
				end if;

				if pout=pin then
					buffer_txen <='0';
				else
					buffer_txen <='1';
				end if;
				buffer_txd <= mem(pout);
				if we='1' then
					mem(pin) := din;
					pin := pin + 1;
				end if;

				if (ctlr_rdy xor ctlr_req)='1' then
					we  := rqst_txen;
					din := rqst_txd;
				else
					we  := dev_txen;
					din := dev_txd;
				end if;
			end if;
		end if;
	end process;
	(txen, txd) <= 
		std_logic_vector'(buffer_txen, buffer_txd) when txbuffer else
		std_logic_vector'(rqst_txen,   rqst_txd)   when (ctlr_rdy xor ctlr_req)='1' else
		std_logic_vector'(dev_txen,    dev_txd);
		
	rqst_txbs <= 
		not to_stdulogic(ctlr_rdy xor ctlr_req) when txbuffer else 
		txbs;
	dev_txbs <= 
		'0'                                 when dev_cfgd='0' else
		to_stdulogic(ctlr_rdy xor ctlr_req) when txbuffer     else
		txbs;

	(rqst_rxdv, rqst_rxbs, rqst_rxd) <= std_logic_vector'(rxpidv, rxbs, rxd);

	tp(1)  <= to_stdulogic(setup_req);
	tp(2)  <= to_stdulogic(setup_rdy);
	tp(3)  <= to_stdulogic(out_req);
	tp(4)  <= to_stdulogic(out_rdy);
	tp(5)  <= to_stdulogic(in_req);
	tp(6)  <= to_stdulogic(in_rdy);
	tp(7)  <= to_stdulogic(ackrx_req);
	tp(8)  <= to_stdulogic(ackrx_rdy);
	tp(9)  <= to_stdulogic(stus_req);
	tp(10) <= to_stdulogic(stus_rdy);

end;