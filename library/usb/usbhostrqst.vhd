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
use hdl4fpga.usbpkg.all;

entity usbhostrqst is
	port (
		tp          : out std_logic_vector(1 to 32) := (others => '0');
		clk         : in  std_logic;
		cken        : in  std_logic;

		init_req    : in  std_logic;
		init_rdy    : buffer std_logic := '0';
		flush_req   : buffer  std_logic := '0';
		flush_rdy   : in std_logic := '0';
		phy_rst     : buffer std_logic;

		dev_addr    : out std_logic_vector(7-1 downto 0);
		dev_endp    : out std_logic_vector(11-1 downto 7);
		dev_ackrx   : in  std_logic := '1';
		dev_acktx   : in  std_logic := '1';
		tksetup_req : buffer std_logic := '0';
		tksetup_rdy : in  std_logic := '0';
		tkstall_req : in  std_logic := '0';
		tkstall_rdy : buffer std_logic := '0';
		tknak_req   : in std_logic;
		tknak_rdy   : buffer std_logic;
		tkin_req    : buffer std_logic := '0';
		tkin_rdy    : in  std_logic;
		tkout_req   : buffer std_logic := '0';
		tkout_rdy   : in  std_logic;
		sof_tick    : in  std_logic;

		rxdv        : in  std_logic := '-';
		rxbs        : in  std_logic := '-';
		rxd         : in  std_logic := '-';

		txen        : out std_logic;
		txbs        : in  std_logic;
		txd         : out std_logic);

end;

architecture def of usbhostrqst is
	signal hub_rgtr   : std_logic_vector(11+64-1 downto 0);
	signal setup_rgtr : std_logic_vector(11+64-1 downto 0);

	constant test : string := segment_map(
		"["&
			"{content:0x" & -- Hexadecimal format
				"80"      & -- Device to Host
				"06"      & -- GET_DESCRIPTOR
				"00"      & -- Descriptor index 
				"01"      & -- Descriptor type -> DEVICE
				"0000"    & -- Offset 
				"ffff"    & -- Length 64 bytes
			"}"           & 
			","           &
			"{content:0x" & -- Hexadecimal format
				"00"      & -- Host to Device
				"05"      & -- SET_ADDRESS
				"----"    & -- Address
				"0000"    & -- Offset 
				"0000"    & -- Length 64 bytes
			"}"           & 
			","           &
			"{content:0x" & -- Hexadecimal format
				"80"      & -- Device to Host
				"06"      & -- GET_DESCRIPTOR
				"00"      & -- Descriptor index 
				"02"      & -- Descriptor type -> CONFIGURATION
				"0000"    & -- Offset 
				"ffff"    & -- Length 64 bytes
			"}"           & 
			","           &
			"{content:0x" & -- segment_id=2, addr=10
				"00"      & -- Host to Device
				"09"      & -- SET_CONFIGURATION
				"0100"    & -- Configuration 1
				"0000"    & -- Offset
				"0000"    & -- Length 0 bytes
			"}"           &
			","           &
			"{content:0x" & -- Hexadecimal format
				"a0"      & -- Device to Host, Class 
				"06"      & -- GET_DESCRIPTOR
				"00"      & -- Descriptor index 
				"29"      & -- Descriptor type -> HUB
				"0000"    & -- Offset 
				"ffff"    & -- Length 64 bytes
			"}"           & 
			","           &
			"{content:0x" & -- Hexadecimal format
				"23"      & -- Device to Host
				"03"      & -- GET_DESCRIPTOR
				"04"      & -- Descriptor index 
				"00"      & -- Descriptor type -> DEVICE
				"0100"    & -- Offset 
				"0000"    & -- Length 64 bytes
			"}"           & 
			","           &
			"{content:0x" & -- Hexadecimal format
				"23"      & -- Device to Host
				"03"      & -- GET_DESCRIPTOR
				"08"      & -- Descriptor index 
				"00"      & -- Descriptor type -> DEVICE
				"0100"    & -- Offset 
				"0000"    & -- Length 64 bytes
			"}"           & 
			","           &
			"{content:0x" & -- Hexadecimal format
				"23"      & -- Device to Host
				"03"      & -- GET_DESCRIPTOR
				"04"      & -- Descriptor index 
				"00"      & -- Descriptor type -> DEVICE
				"0100"    & -- Offset 
				"0000"    & -- Length 64 bytes
			"}"           & 
			","           &
			"{content:0x" & -- Hexadecimal format
				"a0"      & -- Device to Host
				"00"      & 
				"0000"    &
				"0000"    & -- Offset 
				"0400"    & -- Length 64 bytes
			"}"           & 
			","           &
			"{content:0x" & -- Hexadecimal format
				"a3"      & -- Device to Host
				"00"      & 
				"0000"    &
				"0100"    & -- Offset 
				"0400"    & -- Length 64 bytes
			"}"           & 
			","           &
			"{content:0x" & -- Hexadecimal format
				"80"      & -- Device to Host
				"06"      & -- GET_DESCRIPTOR
				"00"      & -- Descriptor index 
				"01"      & -- Descriptor type -> DEVICE
				"0000"    & -- Offset 
				"ffff"    & -- Length 64 bytes
			"}"           & 
			","           &
			"{content:0x" & -- Hexadecimal format
				"00"      & -- Host to Device
				"05"      & -- SET_ADDRESS
				"----"    & -- Address
				"0000"    & -- Offset 
				"0000"    & -- Length 64 bytes
			"}"           & 
			","           &
			"{content:0x" & -- Hexadecimal format
				"80"      & -- Device to Host
				"06"      & -- GET_DESCRIPTOR
				"00"      & -- Descriptor index 
				"02"      & -- Descriptor type -> CONFIGURATION
				"0000"    & -- Offset 
				"ffff"    & -- Length 64 bytes
			"}"           & 
		"]");

	signal rqst_req  : bit;
	signal rqst_rdy  : bit;
	signal ctlr_req  : std_ulogic;
	signal ctlr_rdy  : std_ulogic;
	signal ctlr_reqs : std_logic_vector(0 to 2-1);
	signal ctlr_rdys : std_logic_vector(ctlr_reqs'range);
	signal rply_req  : bit;
	signal rply_rdy  : bit;
	signal setup_req : bit;
	signal setup_rdy : bit;
				
	signal pending   : std_logic;

begin

	init_p : process (cken, clk)
		type states is (s_init, s_setup);
		variable state : states;
		variable timer : integer range -1 to 2**6-1;
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (tkstall_rdy xor tkstall_req)='0' then
					if (init_rdy xor init_req)='1' then
						case state is
						when s_init =>
							if timer < 0 then
								phy_rst <= '0';
								if (flush_req xor flush_rdy)='0' then
									setup_req <= not setup_rdy;
									state     := s_setup;
								end if;
							elsif sof_tick='1' then
								if phy_rst='0' then
									flush_req <= not flush_rdy;
								end if;
								phy_rst <= '1';
								timer   := timer - 1;
							end if;
						when s_setup =>
							if (setup_req xor setup_rdy)='0' then
								init_rdy <= init_req;
							end if;
						end case;
					else
						phy_rst <= '0';
						timer   := 63;
						state   := s_init;
					end if;
				else
					init_rdy    <= init_req;
					tkstall_rdy <= tkstall_req;
					state       := s_init;
				end if;
			end if;
		end if;
	end process;

	hub_p : process (clk)
    	alias  bmRequestType : std_logic_vector( 8-1 downto 0) is hub_rgtr( 8-1 downto  0);
    	alias  bRequest      : std_logic_vector( 8-1 downto 0) is hub_rgtr(16-1 downto  8);
    	alias  wValue        : std_logic_vector(16-1 downto 0) is hub_rgtr(32-1 downto 16);
    	alias  wIndex        : std_logic_vector(16-1 downto 0) is hub_rgtr(48-1 downto 32);
    	alias  wLength       : std_logic_vector(16-1 downto 0) is hub_rgtr(64-1 downto 48);
    	alias  dev_addr      : std_logic_vector( 7-1 downto 0) is hub_rgtr( 7+64-1 downto 0+64);
    	alias  dev_endp      : std_logic_vector(11-1 downto 7) is hub_rgtr(11+64-1 downto 7+64);

		variable step : natural range 0 to 5;
		constant addr : std_logic_vector(16-1 downto 0) := x"000a";
		alias ctlr_req is ctlr_reqs(1);
		alias ctlr_rdy is ctlr_rdys(1);
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (setup_req xor setup_rdy)='1' then
    				if pending='1' then
    					if sof_tick='1' then
    						ctlr_req <= not ctlr_rdy;
    					end if;
    				elsif (ctlr_req xor ctlr_rdy)='0' then
    					case step is
    					when 0 =>
    						bmRequestType <= x"a0";
    						bRequest      <= x"06";
    						wValue        <= x"2900";
    						wIndex        <= x"0000";
    						wLength       <= x"ffff";
							ctlr_req <= not ctlr_rdy;
    					when 1 =>
    						bmRequestType <= x"23";
    						bRequest      <= x"03";
    						wValue        <= x"0004";
    						wIndex        <= x"0001";
    						wLength       <= x"ffff";
							ctlr_req <= not ctlr_rdy;
    					when 2 =>
							bmRequestType <= x"23";
							bRequest      <= x"03";
							wValue        <= x"0008";
							wIndex        <= x"0001";
							wLength       <= x"0000";
    					when 3 =>
							bmRequestType <= x"23";
							bRequest      <= x"03";
							wValue        <= x"0004";
							wIndex        <= x"0001";
							wLength       <= x"0000";
    					when 4 =>
							bmRequestType <= x"a0";
							bRequest      <= x"00";
							wValue        <= x"0000";
							wIndex        <= x"0000";
							wLength       <= x"0004";
    					when 5 =>
    						-- setup_rdy <= setup_req;
    					end case;
    				end if;
				else
				end if;
			end if;
		end if;
	end process;

	setup_p : process (clk)
    	alias  bmRequestType : std_logic_vector( 8-1 downto 0) is setup_rgtr( 8-1 downto  0);
    	alias  bRequest      : std_logic_vector( 8-1 downto 0) is setup_rgtr(16-1 downto  8);
    	alias  wValue        : std_logic_vector(16-1 downto 0) is setup_rgtr(32-1 downto 16);
    	alias  wIndex        : std_logic_vector(16-1 downto 0) is setup_rgtr(48-1 downto 32);
    	alias  wLength       : std_logic_vector(16-1 downto 0) is setup_rgtr(64-1 downto 48);
    	alias  dev_addr      : std_logic_vector( 7-1 downto 0) is setup_rgtr( 7+64-1 downto 0+64);
    	alias  dev_endp      : std_logic_vector(11-1 downto 7) is setup_rgtr(11+64-1 downto 7+64);
		type steps is (s_setaddress, s_getdescriptor, s_setconfiguration, s_stop);
		variable step : steps;
		constant addr : std_logic_vector(16-1 downto 0) := x"000a";
		alias ctlr_req is ctlr_reqs(0);
		alias ctlr_rdy is ctlr_rdys(0);
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (setup_req xor setup_rdy)='1' then
    				if pending='1' then
    					if sof_tick='1' then
    						ctlr_req <= not ctlr_rdy;
    					end if;
    				elsif (ctlr_req xor ctlr_rdy)='0' then
						dev_addr  <= (others => '0');
						dev_endp  <= (others => '0');
    					case step is
    					when s_setaddress =>
							dev_addr      <= (others => '0');
    						bmRequestType <= x"00";
    						bRequest      <= x"05";
    						wValue        <= addr;
    						wIndex        <= x"0000";
    						wLength       <= x"0000";
							ctlr_req <= not ctlr_rdy;
							step := s_getdescriptor;
    					when s_getdescriptor =>
							dev_addr      <= addr(dev_addr'range);
    						bmRequestType <= x"80";
    						bRequest      <= x"06";
    						wValue        <= x"0200";
    						wIndex        <= x"0000";
    						wLength       <= x"ffff";
							ctlr_req <= not ctlr_rdy;
							step := s_setconfiguration;
    					when s_setconfiguration =>
							dev_addr      <= addr(dev_addr'range);
    						bmRequestType <= x"00";
    						bRequest      <= x"09";
    						wValue        <= x"0001";
    						wIndex        <= x"0000";
    						wLength       <= x"0000";
							ctlr_req <= not ctlr_rdy;
							step := s_stop;
						when s_stop =>
    						setup_rdy <= setup_req;
							step := s_setaddress;
    					end case;
    				end if;
				else
    				step := s_setaddress;
				end if;
			end if;
		end if;
	end process;

	descriptors_p : process (rply_req, clk)
		variable rgtr : std_logic_vector(0 to 16*8-1);
		variable cntr : natural range 0 to rgtr'length;
		variable bLength         : std_logic_vector( 8-1 downto 0);
		variable bDescriptorType : std_logic_vector( 8-1 downto 0);
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (rply_rdy xor rply_req)='1' then
					if rxdv='1' then
						if cntr < rgtr'length then
							rgtr(cntr) := rxd;
						end if;
						if rxbs='1' then
							cntr := cntr + 1;
						end if;
					end if;
					if cntr >= 8 then
						if cntr/8 >= unsigned(bLength) then
							case bDescriptorType is
							when others =>
							end case;
							cntr := 0 ;
						end if;
					end if;
				else
					cntr := 0;
				end if;
			end if;
		end if;
	end process;

	config_p : process (rply_rdy, clk)
		variable bLength         : unsigned( 8-1 downto 0);
		variable bDescriptorType : unsigned( 8-1 downto 0);
		variable wTotalLength    : unsigned(16-1 downto 0);
		variable cntr            : natural range 0 to 512*8;
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (rply_rdy xor rply_req)='1' then
					if rxdv='1' then
						if rxbs='0' then
							if cntr < 8 then
								blength(0) := rxd;
								blength := blength ror 1;
							elsif cntr < 16 then
								bDescriptorType(0) := rxd;
								bDescriptorType := bDescriptorType ror 1;
							elsif cntr < 32 then
								if bDescriptorType=unsigned(config) then
									wTotalLength(0) := rxd;
									wTotalLength :=  wTotalLength ror 1;
								end if;
							end if;
							if cntr < 512*8 then 
								cntr := cntr + 1;
							end if;
						end if;
					end if;
					if cntr >=16 then
						if bDescriptorType=unsigned(config) then
							if cntr >= 32 then
								if cntr/8 >= wTotalLength then
									rply_rdy <= rply_req;
								elsif cntr >= 512*8 then 
									rply_rdy <= rply_req;
								end if;
							end if;
						elsif cntr/8 >= blength then
							rply_rdy <= rply_req;
						end if;
					end if;
				else
					cntr := 0;
				end if;
			end if;
		end if;
	end process;

	ctlr_b : block
		signal ctlr_rgtr     : std_logic_vector(11+64-1 downto 0);
    	alias  bmRequestType : std_logic_vector( 8-1 downto 0) is ctlr_rgtr( 8-1 downto  0);
    	alias  bRequest      : std_logic_vector( 8-1 downto 0) is ctlr_rgtr(16-1 downto  8);
    	alias  wValue        : std_logic_vector(16-1 downto 0) is ctlr_rgtr(32-1 downto 16);
    	alias  wIndex        : std_logic_vector(16-1 downto 0) is ctlr_rgtr(48-1 downto 32);
    	alias  wLength       : std_logic_vector(16-1 downto 0) is ctlr_rgtr(64-1 downto 48);
    	alias  addr          : std_logic_vector( 7-1 downto 0) is ctlr_rgtr( 7+64-1 downto 0+64);
    	alias  endp          : std_logic_vector(11-1 downto 7) is ctlr_rgtr(11+64-1 downto 7+64);
	begin

    	ctlrarbiter_b : block
    		generic (
    			n : natural;
    			m : natural);
    		generic map (
    			n => ctlr_reqs'length,
    			m => ctlr_rgtr'length);
    		port (
    			clk  : in std_ulogic;
    			ena  : in std_ulogic := '1';
    			reqs : in std_logic_vector(0 to n-1);
    			rdys : buffer std_logic_vector(0 to n-1);
    			di   : in std_logic_vector(0 to n*m-1);
    			req  : buffer std_ulogic;
    			rdy  : in std_ulogic;
    			do   : out std_logic_vector(0 to m-1));
    		port map (
    			clk  => clk,
    			ena  => cken,
    			reqs => ctlr_reqs,
    			rdys => ctlr_rdys,
    			di(0*ctlr_rgtr'length to 1*ctlr_rgtr'length-1) => setup_rgtr,
    			di(1*ctlr_rgtr'length to 2*ctlr_rgtr'length-1) => hub_rgtr,
    			req  => ctlr_req,
    			rdy  => ctlr_rdy,
				do   => ctlr_rgtr);
    	begin

    		arbiter_p : process (clk)
    			type states is (s_rdy, s_req);
    			variable state : states;
    			variable id    : natural range 0 to reqs'length-1;
    		begin
    			if rising_edge(clk) then
    				if ena='1' then
    					case state is
    					when s_rdy =>
    						for i in reqs'range loop
    							if (rdys(i) xor reqs(i))='1' then
    								id  := i;
    								do  <= di(i*m to (i+1)*m-1);
    								req <= not rdy;
    								state := s_req;
    								exit;
    							end if;
    						end loop;
    					when s_req =>
    						if (req xor rdy)='0' then
    							rdys(id) <= reqs(id);
    							state    := s_rdy;
    						end if;
    					end case;
    				end if;
    			end if;
    		end process;
    	end block;

		dev_addr <= addr;
		dev_endp <= endp;
    	ctlr_p : process (ctlr_rdy, clk)
    		type states is (s_idle, s_setup, s_in, s_statusin, s_statusout);
    		variable state   : states;
    	begin
    		if rising_edge(clk) then
    			if cken='1' then
    				if (tkstall_req xor tkstall_rdy)='0' then
    					case state is
    					when s_idle =>
    						if (ctlr_rdy xor ctlr_req)='1' then
    							if pending='1' then
    								pending <= '0';
    								state   := s_setup;
    							else
    								tksetup_req <= not tksetup_rdy;
    								rqst_req    <= not rqst_rdy;
    								pending     <= '0';
    								state       := s_setup;
    							end if;
    						end if;
    					when s_setup =>
    						if (rqst_req xor rqst_rdy)='0' then
    							rply_req <= not rply_rdy;
    							if bmRequestType(bmRequestType'left)='1' then
    								tkin_req <= not tkin_rdy;
    								state    := s_in;
    							else
    								tkin_req <= not tkin_rdy;
    								state    := s_statusout;
    							end if;
    						end if;
    					when s_in =>
    						if (tkin_req xor tkin_rdy)='0' then
    							if rxdv='0' then
    								if (tknak_rdy xor tknak_req)='1' then
    									pending   <= '1';
    									tknak_rdy <= tknak_req;
    									ctlr_rdy  <= ctlr_req;
    									state     := s_idle;
    								elsif (rply_rdy xor rply_req)='1' then
    									tkin_req <= not tkin_rdy;
    								else
    									tkout_req <= not tkout_rdy;
    									state     := s_statusin;
    								end if;
    							end if;
    						end if;
    					when s_statusin =>
    						if (tkout_req xor tkout_rdy)='0' then
    							ctlr_rdy <= ctlr_req;
    							state    := s_idle;
    						end if;
    					when s_statusout =>
    						if (tkin_req xor tkin_rdy)='0' then
    							if (tknak_rdy xor tknak_req)='1' then
    								pending   <= '1';
    								tknak_rdy <= tknak_req;
    								ctlr_rdy  <= ctlr_req;
    								state     := s_idle;
    							else
    								ctlr_rdy <= ctlr_req;
    								state    := s_idle;
    							end if;
    						end if;
    					end case;
    				else
    					ctlr_rdy <= ctlr_req;
    					state    := s_idle;
    				end if;
    			end if;
    		end if;
    	end process;

    	request_p : process (clk)
			alias rqst is ctlr_rgtr(64-1 downto 0);
    		variable cntr : unsigned(0 to 3+3);
    	begin
    		if rising_edge(clk) then
    			if cken='1' then
    				if (rqst_rdy xor rqst_req)='1' then
    					if cntr(0)='0' then
    						if txbs='0' then
    							txd  <= multiplex(reverse(rqst), std_logic_vector(cntr));
    							cntr := cntr + 1;
    						end if;
    					else
    						rqst_rdy <= rqst_req;
    					end if;
    				else
    					cntr := (others => '0');
    				end if;
    				txen <= to_stdulogic(rqst_rdy xor rqst_req);
    			end if;
    		end if;
    	end process;
	end block;

end;
