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
use ieee.numeric_bit.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.usbpkg.all;

entity usbhostflow is
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
		tkdata    : buffer std_logic_vector(11-1 downto 0);
		phyerr    : in  std_logic;
		crcerr    : in  std_logic;
		tkerr     : in  std_logic;

		tx_req    : buffer std_logic := '0';
		tx_rdy    : in  std_logic;
		txpid     : out std_logic_vector(4-1 downto 0);
		txen      : buffer std_logic;
		txbs      : in  std_logic;
		txd       : buffer std_logic;

		tksetup_req : in bit;
		tksetup_rdy : buffer bit;
		tkin_req : in  bit;
		tkin_rdy : buffer bit;
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
		dev_addr  : in  std_logic_vector(7-1 downto 0);
		dev_endp  : in  std_logic_vector(11-1 downto 7);
		dev_cfgd  : in  std_logic;

		rqst_rxdv : out std_logic;
		rqst_rxbs : out std_logic;
		rqst_rxd  : out std_logic;
		rqst_txen : in  std_logic;
		rqst_txbs : out std_logic;
		rqst_txd  : in  std_logic);
end;

architecture def of usbhostflow is

	signal requesttype : std_logic_vector( 8-1 downto 0);
	signal value       : std_logic_vector(16-1 downto 0);
	signal index       : std_logic_vector(16-1 downto 0);
	signal length      : std_logic_vector(16-1 downto 0);

	signal ctlr_req    : bit;
	signal ctlr_rdy    : bit;
	signal status_req  : bit;
	signal status_rdy  : bit;
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
	signal sof_number  : unsigned(tkdata'range);

	signal tksof_req  : bit;
	signal tksof_rdy  : bit;

begin

	softimer_p : process(tksof_req ,clk)
		constant max_count: natural := natural(12.0e6*1.0e-3);
		variable timer : integer range -1 to max_count;
	begin
		if rising_edge(clk) then
			if cken='1' then
				if timer < 0 then
					timer      := max_count;
					sof_number <= sof_number + 1;
					tksof_req  <= not tksof_rdy;
				else
					timer := timer - 1;
				end if;
			end if;
		end if;
	end process;

	hosttodev_p : process (clk)
		type states is (s_idle, s_bulk);
		variable state : states;
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (tx_rdy xor tx_req)='0' then
					case state is
					when s_idle =>
						if (tksof_rdy xor tksof_req)='1' then
							txpid  <= tk_sof;
							tkdata <= to_stdlogicvector(bit_vector(sof_number));
							tksof_rdy <= tksof_req;
							tx_req <= not tx_rdy;
						elsif (tksetup_rdy xor tksetup_req)='1' then
							txpid  <= tk_setup;
							ddata  <= data0;
							ddatai <= data0;
							ddatao <= data0;
							tkdata(dev_endp'range) <= dev_endp;
							tkdata(dev_addr'range) <= dev_addr;
							rqst_req    <= not rqst_rdy;
							ctlr_req    <= not ctlr_rdy;
							rqstin_req  <= not rqstin_rdy;
							tksetup_rdy <= tksetup_req; 
							tx_req      <= not tx_rdy;
							state := s_bulk;
						elsif (tkin_rdy xor tkin_req)='1' then
							txpid  <= tk_in;
							tx_req <= not tx_rdy;
							tkin_rdy <= tkin_req; 
							rqstin_req <= not rqstin_rdy;
							tkdata(dev_endp'range) <= dev_endp;
							tkdata(dev_addr'range) <= dev_addr;
							state := s_bulk;
						elsif (acktx_rdy xor acktx_req)='1' then
							txpid   <= hs_ack;
							tx_req  <= not to_stdulogic(to_bit(tx_rdy));
							acktx_rdy <= acktx_req;
						end if;
					when s_bulk =>
						in_req <= not in_rdy;
						case tkdata(dev_endp'range) is
						when (dev_endp'range => '0') =>
							txpid  <= ddata;
						when others =>
							txpid  <= ddatai;
						end case;
						tx_req <= not tx_rdy;
						if txen='0' then
							status_req <= not status_rdy;
						end if;
						state := s_idle;
					end case;
				end if;
			end if;
		end if;
	end process;

	rxerr <= phyerr or tkerr or crcerr;


	devtohost_p : process (cken, clk)
		constant tbit : std_logic_vector(data0'range) := b"1000";
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (rx_rdy xor rx_req)='1' then
    				case rxpid is
    				when data0|data1 =>
						if rxerr='0' then
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
    				when hs_ack =>
						rqstack_req <= not rqstack_rdy;
						ackrx_req <= not ackrx_rdy;
						if (status_rdy xor status_req)='1' then
							ctlr_rdy <= ctlr_req;
						end if;
						status_rdy <= status_req;
						-- if dev_endp=(dev_endp'range => '0') then
							-- ddata <= ddata xor tbit;
						-- else
							-- ddatai <= ddatai xor tbit;
						-- end if;
    				when others =>
    				end case;
				end if;
				rx_rdy <= rx_req;
			end if;
		end if;
	end process;

	txbuffer_p : process (acktx_rdy, clk)
		variable mem  : std_logic_vector(0 to 64*8-1);
		subtype  mem_range  is natural range 1 to unsigned_num_bits(mem'length-1);
		subtype  byte_range is natural range 0 to unsigned_num_bits(mem'length-1)-3;
		variable pin  : unsigned(0 to unsigned_num_bits(mem'length-1));
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
				-- elsif (in_rdy xor in_req)='1' then
					-- pout := (others => '0');
				elsif pout(byte_range) /= pin(byte_range) then
					if txbs='0' then
						pout := pout + 1;
					end if;
				end if;
				buffer_txd <= mem(to_integer(pout(mem_range)));

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
				if we='1' then
					mem(to_integer(pin(mem_range))) := din;
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
		variable slr_rxd  : unsigned(0 to (16)-1);
		variable slr_rxdv : unsigned(0 to (16)-1);
	begin
		if rising_edge(clk) then
			if cken='1' then
				if rxbs='0' then
					clpcrc_rxdv <= to_stdulogic(slr_rxdv(0) and to_bit(rxdv));
					slr_rxdv(0) := to_bit(rxdv);
					slr_rxdv := slr_rxdv rol 1;

					clpcrc_rxd <= to_stdulogic(slr_rxd(0));
					slr_rxd(0) := to_bit(rxd);
					slr_rxd := slr_rxd rol 1;
				end if;
			end if;
		end if;
	end process;

	rxbuffer_p : process (rqst_req, clk)
		variable mem  : std_logic_vector(0 to 64*2**3-1);
		subtype  mem_range is natural range 1 to unsigned_num_bits(mem'length-1);
		subtype  byte_range is natural range 1 to unsigned_num_bits(mem'length-1)-3;
		variable pin  : unsigned(0 to unsigned_num_bits(mem'length-1)) := (others => '0');
		variable pout : unsigned(pin'range);
		variable prty : unsigned(pout'range);
		variable we   : std_logic;
		variable din  : std_logic;
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
						buffer_rxd <= mem(to_integer(pout(mem_range)));
						pout := pout + 1;
						buffer_rxdv <= '1';
					end if;
				else
					buffer_rxdv <= '0';
				end if;

				if we='1' then
					mem(to_integer(pin(mem_range))) := din;
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
		
end;
