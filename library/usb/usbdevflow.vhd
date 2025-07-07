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
use hdl4fpga.base.all;
use hdl4fpga.usbpkg.all;

entity usbdevflow is
	generic (
		rxbuffer  : boolean := true;
		txbuffer  : boolean := true);
	port (
		tp        : out std_logic_vector(1 to 32) := (others => '0');
		clk       : in  std_logic;
		cken      : in  std_logic;

		rx_req    : in  std_logic;
		rx_rdy    : buffer std_logic;
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

		rqst_req    : buffer bit;
		rqst_rdy    : in  bit;
		rqstin_req  : buffer  bit;
		rqstin_rdy  : in  bit;
		rqstack_req : buffer  bit;
		rqstack_rdy : in  bit;

		dev_txen  : in  std_logic;
		dev_txbs  : out std_logic;
		dev_txd   : in  std_logic;

		dev_rxdv  : out std_logic;
		dev_rxbs  : inout std_logic;
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
	signal value       : std_logic_vector(16-1 downto 0);
	signal index       : std_logic_vector(16-1 downto 0);
	signal length      : std_logic_vector(16-1 downto 0);

	signal ctlr_req    : bit;
	signal ctlr_rdy    : bit;
	signal stus_req    : bit;
	signal stus_rdy    : bit;
	signal setup_req   : bit;
	signal setup_rdy   : bit;
	signal out_req     : bit;
	signal out_rdy     : bit;
	signal in_req      : bit;
	signal in_rdy      : bit;
	signal ackrx_req   : bit;
	signal ackrx_rdy   : bit;
	signal acktx_rdy   : bit;
	signal acktx_req   : bit;

	signal buffer_txen : std_logic;
	signal buffer_txbs : std_logic;
	signal buffer_txd  : std_logic;
	signal clpcrc_rxdv : std_logic;
	alias  clpcrc_rxbs is rxbs;
	signal clpcrc_rxd  : std_logic;
	signal buffer_rxdv : std_logic;
	alias  buffer_rxbs is dev_rxbs;
	signal buffer_rxd  : std_logic;

	signal ddata       : std_logic_vector(data0'range);
	signal ddatao      : std_logic_vector(data0'range);
	signal ddatai      : std_logic_vector(data0'range);

	signal rxerr       : std_logic;

begin

	rxerr <= phyerr or tkerr or crcerr;

	dev_endp <= tkdata(dev_endp'range);
	hosttodev_p : process (cken, clk)
		constant tbit : std_logic_vector(data0'range) := b"1000";
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (rx_rdy xor rx_req)='1' then
					if rxpid=tk_setup then
					-- This is because GHDL. The worst vhdl compiler ever
    				-- case rxpid is
    				-- when tk_setup =>
						if tkdata(dev_addr'range) = (dev_addr'range => '0') or
						   tkdata(dev_addr'range) = dev_addr then
							if (setup_req xor setup_rdy)='0' then
								ddata     <= data0;
								ddatai    <= data0;
								ddatao    <= data0;
								rqst_req  <= not rqst_rdy;
								ctlr_req  <= not ctlr_rdy;
							end if;
							setup_req <= not setup_rdy;
    					end if;
					elsif rxpid=tk_in then
    				-- when tk_in =>
						if tkdata(dev_addr'range)=(dev_addr'range => '0') or
						   tkdata(dev_addr'range)=dev_addr then
							if (in_req xor in_rdy)='0' then
								if tkdata(dev_endp'range)=(dev_endp'range => '0') then
									if not txbuffer then
										rqstin_req <= not rqstin_rdy;
									end if;
								end if;
							end if;
							in_req <= not in_rdy;
    					end if;
					elsif rxpid=tk_out then
    				-- when tk_out=>
						if tkdata(dev_addr'range) = (dev_addr'range => '0') or
							tkdata(dev_addr'range) = dev_addr then
							out_req <= not out_rdy;
    					end if;
					elsif rxpid=data0 or
					      rxpid=data1 then
    				-- when data0|data1 =>
						if tkdata(dev_addr'range) = (dev_addr'range => '0') or
						   tkdata(dev_addr'range) = dev_addr then
							if rxerr='0' then
								if tkdata(dev_endp'range)=(dev_endp'range => '0') then
									ddata  <= ddata  xor tbit;
								else
									ddatao <= ddatao xor tbit;
								end if;
								-- case tkdata(dev_endp'range) is
								-- when (dev_endp'range => '0') =>
									-- ddata  <= ddata  xor tbit;
								-- when others =>
									-- ddatao <= ddatao xor tbit;
								-- end case;
								if (setup_rdy xor setup_req)='1' then
									acktx_req <= not acktx_rdy; 
								elsif (out_rdy xor out_req)='1' then
									acktx_req <= not acktx_rdy; 
								end if;
								out_rdy   <= out_req;
								setup_rdy <= setup_req;
							end if;
						end if;
					elsif rxpid=hs_ack then
    				-- when hs_ack =>
						if tkdata(dev_addr'range)=(dev_addr'range => '0') or
						   tkdata(dev_addr'range)=dev_addr then
							if tkdata(dev_endp'range)=(dev_endp'range => '0') then
								rqstack_req <= not rqstack_rdy;
							end if;
						end if;
						ackrx_req <= not ackrx_rdy;
						if (stus_rdy xor stus_req)='1' then
							ctlr_rdy <= ctlr_req;
						end if;
						stus_rdy <= stus_req;
						if tkdata(dev_endp'range)=(dev_endp'range => '0') then
							ddata  <= ddata  xor tbit;
						else
							ddatai <= ddatai xor tbit;
						end if;
						-- case tkdata(dev_endp'range) is
						-- when (dev_endp'range => '0') =>
							-- ddata <= ddata xor tbit;
						-- when others =>
							-- ddatai <= ddatai xor tbit;
						-- end case;
					else
    				-- when others =>
					end if;
    				-- end case;
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
						if tkdata(dev_endp'range)=(dev_endp'range => '0') then
							txpid  <= ddata;
						else
							txpid  <= ddatai;
						end if;
						-- case tkdata(dev_endp'range) is
						-- when (dev_endp'range => '0') =>
							-- txpid  <= ddata;
						-- when others =>
							-- txpid  <= ddatai;
						-- end case;
						tx_req  <= not to_stdulogic(to_bit(tx_rdy));
						if txen='0' then
							stus_req <= not stus_rdy;
						end if;
						in_rdy <= in_req;
					end if;
					if (acktx_rdy xor acktx_req)='1' then
							txpid   <= hs_ack;
							tx_req  <= not to_stdulogic(to_bit(tx_rdy));
						-- end if;
						acktx_rdy <= acktx_req;
					end if;
				end if;
			end if;
		end if;
	end process;

	txbuffer_b : block
		signal alt_wrena  : std_ulogic;
		signal alt_wraddr : std_logic_vector(1 to 9);
		signal alt_wrdata : std_logic_vector(0 to 0);
		signal alt_rdaddr : std_logic_vector(alt_wraddr'range);
		signal alt_rddata : std_logic_vector(alt_wrdata'range);
	begin
		-- Required for Altera Cyclone II MK4 architecture
		mem_e : entity hdl4fpga.dpram
		port map (
			wr_clk  => clk,
			wr_ena  => alt_wrena,
			wr_addr => alt_wraddr,
			wr_data => alt_wrdata,
			rd_clk  => clk,
			rd_addr => alt_rdaddr,
			rd_data => alt_rddata);
		buffer_txd <= alt_rddata(0);

    	txbuffer_p : process (acktx_rdy, clk)
    		subtype  byte_range is natural range 0 to alt_wraddr'right-3;
    		variable pin  : unsigned(0 to alt_wraddr'right);
    		variable pout : unsigned(pin'range);
    		variable we   : std_logic;
    		variable din  : std_logic;
    	begin
    		if rising_edge(clk) then
    			if cken='1' then
    				if (setup_rdy xor setup_req)='1' then
    					pin  := (others => '0');
    					pout := pin;
    					ackrx_rdy <= ackrx_req;
    				elsif (ackrx_rdy xor ackrx_req)='1' then
    					pin  := (others => '0');
    					pout := (others => '0');
    					ackrx_rdy <= ackrx_req;
    				elsif (in_rdy xor in_req)='1' then
    					pout := (others => '0');
    				elsif pout(byte_range) /= pin(byte_range) then
    					if txbs='0' then
    						pout := pout + 1;
    					end if;
    				end if;
    				alt_rdaddr <= std_logic_vector(pout(alt_wraddr'range));

    				if pout(byte_range)=pin(byte_range) then
    					buffer_txen <= '0';
    				else
    					buffer_txen <= '1';
    				end if;

    				if pin(0)='1' then
    					we  := '0';
    					din := '-';
    				elsif (ctlr_rdy xor ctlr_req)='1' then
    					we  := rqst_txen;
    					din := rqst_txd;
    				elsif buffer_txbs='0' then
    					we  := dev_txen;
    					din := dev_txd;
    				end if;
    				alt_wrena  <= we;
    				alt_wraddr <= std_logic_vector(pin(alt_wraddr'range));
    				alt_wrdata(0) <= din;
    				if we='1' then
    					pin := pin + 1;
    				end if;

    				buffertxbs_l : if (ctlr_rdy xor ctlr_req)='1' then
    					buffer_txbs <= '1';
    				elsif pin(0)='0' then
    					buffer_txbs <= '0';
    				else
    					buffer_txbs <= '1';
    				end if;

    				tp(11) <= buffer_txen;
    				tp(12) <= buffer_txbs;
    			end if;
    		end if;
    	end process;
	end block;

	txen <= 
		buffer_txen when txbuffer else
		rqst_txen   when (ctlr_rdy xor ctlr_req)='1' else
		dev_txen;
		
	txd <= 
		buffer_txd when txbuffer else
		rqst_txd   when (ctlr_rdy xor ctlr_req)='1' else
		dev_txd;
		
	rqst_txbs <= 
		not to_stdulogic(ctlr_rdy xor ctlr_req) when txbuffer else 
		txbs;

	dev_txbs <= 
		'0'         when dev_cfgd='0' else
		buffer_txbs when txbuffer     else
		txbs;

	(rqst_rxdv, rqst_rxbs, rqst_rxd) <= std_logic_vector'(rxdv, rxbs, rxd);

	clpcrc_p : process (rqst_rdy, clk)
		variable slr_rxd  : unsigned(0 to (16)-1) := (others => '0');
		variable slr_rxdv : unsigned(0 to (16)-1) := (others => '0');
	begin
		if rising_edge(clk) then
			if cken='1' then
				if rxbs='0' then
					clpcrc_rxdv <= slr_rxdv(0) and rxdv;
					slr_rxdv(0) := rxdv;
					slr_rxdv := slr_rxdv rol 1;

					clpcrc_rxd <= slr_rxd(0);
					slr_rxd(0) := rxd;
					slr_rxd := slr_rxd rol 1;
				end if;
			end if;
		end if;
	end process;

	rxbuffer_b : block
		signal alt_wrena  : std_ulogic;
		signal alt_wraddr : std_logic_vector(1 to 9);
		signal alt_wrdata : std_logic_vector(0 to 0);
		signal alt_rdena  : std_ulogic := '1';
		signal alt_rdaddr : std_logic_vector(alt_wraddr'range);
		signal alt_rddata : std_logic_vector(alt_wrdata'range);
	begin
		-- Required for Altera Cyclone II MK4 architecture
		mem_e : entity hdl4fpga.dpram
		port map (
			wr_clk  => clk,
			wr_ena  => alt_wrena,
			wr_addr => alt_wraddr,
			wr_data => alt_wrdata,
			rd_clk  => clk,
			rd_ena  => alt_rdena,
			rd_addr => alt_rdaddr,
			rd_data => alt_rddata);
		buffer_rxd <= alt_rddata(0);

    	rxbuffer_p : process (rqst_req, clk)
    		subtype  byte_range is natural range 0 to alt_wraddr'right-3;
    		variable pin   : unsigned(0 to alt_wraddr'right) := (others => '0');
    		variable pout  : unsigned(pin'range) := (others => '0');
    		variable pout0 : unsigned(pin'range) := (others => '0');
    		variable prty  : unsigned(pout'range) := (others => '0');
    		variable we    : std_logic;
    		variable din   : std_logic;
    	begin
    		if rising_edge(clk) then
    			if cken='1' then
    				if (setup_rdy xor setup_req)='1' then
    					pout := pin;
    					prty := pin;
    				elsif pout=prty then
    					if (out_rdy xor out_req)='0' then
    						if rxerr='1' then
    							pin := prty;
    						else
    							prty := pin;
    						end if;
    					end if;
    				end if;

    				if pout/=prty then
    					if buffer_rxbs='0' then
							pout0 := pout;
    						pout  := pout + 1;
    						buffer_rxdv <= '1';
    					end if;
    				else
    					buffer_rxdv <= '0';
    				end if;
    				alt_rdaddr <= std_logic_vector(pout0(alt_wraddr'range));

    				alt_wrena  <= we;
    				alt_wraddr <= std_logic_vector(pin(alt_wraddr'range));
    				alt_wrdata(0) <= din;
    				if we='1' then
    					pin := pin + 1;
    				end if;

    				if (out_rdy xor out_req)='1' then
    					if clpcrc_rxdv='0' then
    						we := '0';
    					elsif clpcrc_rxbs='1' then
    						we := '0';
    					else
    						we := '1';
    					end if;
    				end if;
    				din := clpcrc_rxd;
    			end if;
    		end if;
    	end process;
	end block;

	dev_rxd <= 
		buffer_rxd when rxbuffer else
		clpcrc_rxd;
		
	dev_rxdv <= 
		buffer_rxdv when rxbuffer else
		clpcrc_rxdv when tkdata(dev_addr'range)=dev_addr and tkdata(dev_endp'range)/=(dev_endp'range => '0') and (rxpid=data0 or rxpid=data1) else
		'0';

	dev_rxbs <= 
		'Z'  when rxbuffer else
		'1'  when dev_cfgd='0' else
		clpcrc_rxbs when tkdata(dev_addr'range)=dev_addr and tkdata(dev_endp'range)/=(dev_endp'range => '0') else
		'1';
		
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
