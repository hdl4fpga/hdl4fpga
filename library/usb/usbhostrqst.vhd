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
		clk         : in  std_ulogic;
		cken        : in  std_ulogic;

		init_req    : in  std_ulogic;
		init_rdy    : buffer std_ulogic := '0';
		flush_req   : buffer  std_ulogic := '0';
		flush_rdy   : in std_ulogic := '0';
		phy_rst     : buffer std_ulogic;

		dev_addr    : out std_logic_vector(7-1 downto 0);
		dev_endp    : out std_logic_vector(11-1 downto 7);
		dev_ackrx   : in  std_ulogic := '1';
		dev_acktx   : in  std_ulogic := '1';
		tksetup_req : buffer std_ulogic := '0';
		tksetup_rdy : in  std_ulogic := '0';
		tkstall_req : in  std_ulogic := '0';
		tkstall_rdy : buffer std_ulogic := '0';
		tknak_req   : in std_ulogic := '0';
		tknak_rdy   : buffer std_ulogic := '0';
		tkin_req    : buffer std_ulogic := '0';
		tkin_rdy    : in  std_ulogic;
		tkout_req   : buffer std_ulogic := '0';
		tkout_rdy   : in  std_ulogic;
		sof_tick    : in  std_ulogic;

		rxdv        : in  std_ulogic := '-';
		rxbs        : in  std_ulogic := '-';
		rxd         : in  std_ulogic := '-';

		txen        : out std_ulogic;
		txbs        : in  std_ulogic;
		txd         : out std_ulogic);

end;

architecture def of usbhostrqst is
	signal ctlr_rgtr  : std_logic_vector(11+64 downto 0);
	signal setup_rgtr : std_logic_vector(ctlr_rgtr'range) := (others => '0');
	signal hub_rgtr   : std_logic_vector(ctlr_rgtr'range) := (others => '0');
	signal hid_rgtr   : std_logic_vector(ctlr_rgtr'range) := (others => '0');
	signal descriptor_rgtr  : std_logic_vector(256*8-1 downto 0);

	signal rqst_req   : std_ulogic := '0';
	signal rqst_rdy   : std_ulogic := '0';
	signal ctlr_req   : std_ulogic := '0';
	signal ctlr_rdy   : std_ulogic := '0';
	signal ctlr_reqs  : std_logic_vector(0 to 3-1) := (others => '0');
	signal ctlr_rdys  : std_logic_vector(ctlr_reqs'range) := (others => '0');
	signal ctlr_gntds : std_logic_vector(ctlr_reqs'range);
	signal rply_req   : std_ulogic := '0';
	signal rply_rdy   : std_ulogic := '0';
	signal setup_req  : std_ulogic := '0';
	signal setup_rdy  : std_ulogic := '0';
	signal setup_reqs : std_logic_vector(0 to 2-1) := (others => '0');
	signal setup_rdys : std_logic_vector(0 to 2-1) := (others => '0');
	signal hub_req    : std_ulogic := '0';
	signal hub_rdy    : std_ulogic := '0';
	signal hid_req    : std_ulogic := '0';
	signal hid_rdy    : std_ulogic := '0';
				
	signal ctlr_nak   : std_ulogic := '0';

	signal keyboard_interface : natural range 0 to 15;
	signal mouse_interface    : natural range 0 to 15;
	signal keyboard_present : std_logic;
	signal mouse_present    : std_logic;

begin

	init_p : process (cken, clk)
		type states is (s_init, s_setup);
		variable state : states;
		variable timer : integer range -1 to 2**6-1;
		alias setup_req is setup_reqs(0);
		alias setup_rdy is setup_rdys(0);
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
								hid_req <= not hid_rdy;
								init_rdy <= init_req;
							end if;
						end case;
					else
						phy_rst <= '0';
						timer   := 0;
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

	hub_b : block
		alias bmRequestType : std_logic_vector( 8-1 downto 0) is hub_rgtr(    8-1 downto  0);
		alias bRequest      : std_logic_vector( 8-1 downto 0) is hub_rgtr(   16-1 downto  8);
		alias wValue        : std_logic_vector(16-1 downto 0) is hub_rgtr(   32-1 downto 16);
		alias wIndex        : std_logic_vector(16-1 downto 0) is hub_rgtr(   48-1 downto 32);
		alias wLength       : std_logic_vector(16-1 downto 0) is hub_rgtr(   64-1 downto 48);
		alias dev_addr      : std_logic_vector( 7-1 downto 0) is hub_rgtr( 7+64-1 downto 0+64);
		alias dev_endp      : std_logic_vector(11-1 downto 7) is hub_rgtr(11+64-1 downto 7+64);
		alias pending       : std_ulogic is hub_rgtr(11+64);

		alias bNbrPorts     : std_logic_vector( 8-1 downto 0) is descriptor_rgtr(24-1 downto 16);
		alias wPortStatus   : std_logic_vector(16-1 downto 0) is descriptor_rgtr(16-1 downto  0);
		alias wPortChange   : std_logic_vector(16-1 downto 0) is descriptor_rgtr(32-1 downto 16);

		alias ccs       is wPortStatus(0);
		alias pes       is wPortStatus(1);

		alias setup_req is setup_reqs(1);
		alias setup_rdy is setup_rdys(1);
		alias ctlr_req  is ctlr_reqs(1);
		alias ctlr_rdy  is ctlr_rdys(1);
		alias ctlr_gntd is ctlr_gntds(1);

	begin

		hub_p : process (clk, ctlr_gntds)
			type steps is (s_getdescriptor, s_poweron, s_getstatus, s_resetport, s_ready);
			variable step : steps;
			constant addr : std_logic_vector(16-1 downto 0) := x"000a";
			constant max_count : natural := 2**12;
			variable timer    : natural range 0 to max_count;
			constant max_nbrports : natural := 15;
			variable nbrports : natural range 1 to max_nbrports;
			variable portno   : natural range 1 to max_nbrports;
			impure function next_port 
				return natural is
			begin
				if portno < nbrports then
					return portno + 1;
				else
					return 1;
				end if;
			end;
			variable flags    : std_ulogic_vector(1 to max_nbrports);
		begin
			if rising_edge(clk) then
				if cken='1' then
					dev_addr  <= addr(dev_addr'range);
					dev_endp  <= (others => '0');
					if (hub_req xor hub_rdy)='1' then
						if pending='1' then
							if sof_tick='1' then
								ctlr_req <= not ctlr_rdy;
							end if;
						elsif (ctlr_req xor ctlr_rdy)='0' then
							case step is
							when s_getdescriptor =>
								bmRequestType <= x"a0";
								bRequest <= get_descriptor;
								wValue   <= x"2900";
								wIndex   <= x"0000";
								wLength  <= x"ffff";
								portno   := 1;
								ctlr_req <= not ctlr_rdy;
								step := s_poweron;
							when s_poweron =>
								bmRequestType <= x"23";
								bRequest <= set_feature;
								wValue   <= hub_port_power;
								wIndex   <= std_logic_vector(to_unsigned(portno, wIndex'length));
								wLength  <= x"0000";
								nbrports := to_integer(unsigned(bNbrPorts));
								ctlr_req <= not ctlr_rdy;
								flags(portno) := '0';
								portno := next_port;
								if portno=1 then 
									step := s_getstatus;
								end if;
							when s_getstatus =>
								bmRequestType <= x"a3";
								bRequest <= get_status;
								wValue   <= x"0000";
								wIndex   <= std_logic_vector(to_unsigned(portno, wIndex'length));
								wLength  <= x"0004";
								if timer < max_count then 
									if sof_tick='1' then
										timer := timer + 1;
									end if;
								else
									ctlr_req <= not ctlr_rdy;
									step := s_resetport;
								end if;
							when s_resetport =>
								tp(1 to 8) <= wPortStatus(8-1 downto 0);
								timer := 0;
								case std_logic_vector'(pes, ccs) is
								when "00"|"10" =>
									flags(portno) := '0';
									portno := next_port;
									step   := s_getstatus;
								when "01" =>
									flags(portno) := '0';
									bmRequestType <= x"23";
									bRequest <= set_feature;
									wValue   <= hub_port_reset;
									wIndex   <= std_logic_vector(to_unsigned(portno, wIndex'length));
									wLength  <= x"0000";
									portno   := next_port;
									ctlr_req <= not ctlr_rdy;
									step     := s_getstatus;
								when "11" =>
									if flags(portno)='0' then
										setup_req <= not setup_rdy; 
										flags(portno) := '1';
									elsif (setup_req xor setup_rdy)='0' then
									end if;
										portno := next_port;
										step   := s_getstatus;
								when others =>
									portno := next_port;
									step   := s_getstatus;
								end case;
							when s_ready =>
								hub_rgtr <= (others => '-');
								step     := s_getdescriptor;
								hub_rdy  <= hub_req;
							end case;
						end if;
					else
						portno := 1;
						hub_rgtr <= (others => '-');
						step := s_getdescriptor;
					end if;
					if ctlr_gntd='1' then
						pending <= ctlr_nak;
					end if;
				end if;
			end if;
		end process;
	end block;
	
	hid_b : block
		alias bmRequestType : std_logic_vector( 8-1 downto 0) is hid_rgtr(    8-1 downto  0);
		alias bRequest      : std_logic_vector( 8-1 downto 0) is hid_rgtr(   16-1 downto  8);
		alias wValue        : std_logic_vector(16-1 downto 0) is hid_rgtr(   32-1 downto 16);
		alias wIndex        : std_logic_vector(16-1 downto 0) is hid_rgtr(   48-1 downto 32);
		alias wLength       : std_logic_vector(16-1 downto 0) is hid_rgtr(   64-1 downto 48);
		alias dev_addr      : std_logic_vector( 7-1 downto 0) is hid_rgtr( 7+64-1 downto 0+64);
		alias dev_endp      : std_logic_vector( 4-1 downto 0) is hid_rgtr(11+64-1 downto 7+64);
		alias pending       : std_ulogic is hid_rgtr(11+64);

		alias bInterfaceNumber : std_logic_vector(8-1 downto 0) is descriptor_rgtr(3*8-1 downto 2*8);
		alias bInterfaceClass  : std_logic_vector(8-1 downto 0) is descriptor_rgtr(6*8-1 downto 5*8);
		alias ctlr_req  is ctlr_reqs(2);
		alias ctlr_rdy  is ctlr_rdys(2);
		alias ctlr_gntd is ctlr_gntds(2);

		signal dev_class : std_logic_vector(8-1 downto 0);

		signal hid_last : unsigned(4-1 downto 0);
		signal hid_next : unsigned(4-1 downto 0);
	begin

		hdi_table : block
			signal wr_ena  : std_logic;
			signal wr_data : std_logic_vector(dev_addr'length+dev_class'length+interface_no'length-1 downto 0);
			signal rd_data : std_logic_vector(wr_data'range);
		begin

			wr_ena  <= cken and '1';
			wr_data <= dev_addr & dev_class & std_logic_vector(interface_no);
			hiddata_e : entity hdl4fpga.dpram
			port map (
				wr_clk  => clk,
				wr_ena  => wr_ena,
				wr_addr => std_logic_vector(hid_last),
				wr_data => wr_data,
				rd_addr => std_logic_vector(hid_next),
				rd_data => rd_data);

			process (rd_data)
				variable shr : unsigned(rd_data'range);
			begin 
				shr := unsigned(rd_data);
				dev_class <= std_logic_vector(shr(dev_class'range));
				shr := shr srl dev_class'length;
				dev_addr <= std_logic_vector(shr(dev_addr'range));
			end process;
			dev_endp <= (others => '0');

		end block;

		hid_p : process (clk, ctlr_gntds)
			constant addr : std_logic_vector(16-1 downto 0) := x"000a";
			constant max_count : natural := 2**11;
			variable timer : natural range 0 to max_count;
			variable xxxx  : std_ulogic := '0';
		begin
			if rising_edge(clk) then
				if cken='1' then
	begin

		hid_p : process (clk, ctlr_gntds)
			type steps is (s_setprotocol, s_getreport, s_ready);
			variable step : steps;
			constant addr : std_logic_vector(16-1 downto 0) := x"000a";
			constant max_count : natural := 2**11;
			variable timer    : natural range 0 to max_count;
			variable tries : natural range 0 to 16;
			variable toggle : std_logic;
		begin
			if rising_edge(clk) then
				if cken='1' then
					dev_addr  <= addr(dev_addr'range);
					dev_endp  <= (others => '0');
					if (hid_req xor hid_rdy)='1' then
						if pending='1' then
							if sof_tick='1' then
								ctlr_req <= not ctlr_rdy;
							end if;
						elsif (ctlr_req xor ctlr_rdy)='0' then
							case step is
							when s_setprotocol =>
								bmRequestType <= x"21";
								bRequest <= set_protocol;
								wValue   <= x"0000";
								wIndex   <= x"0001";
								wLength  <= x"0000";
								ctlr_req <= not ctlr_rdy;
								step := s_getreport;
								tries := 0;
								timer := 0;
							when s_getreport =>
								bmRequestType <= x"a1";
								bRequest <= get_report;
								wValue   <= x"0100";
								if toggle='0' then
									if keyboard_present='1' then
										wIndex  <= std_logic_vector(to_unsigned(keyboard_interface, wIndex'length));
										wLength <= x"0008";
										toggle  := '1';
									elsif mouse_present='1' then
										wIndex  <= std_logic_vector(to_unsigned(mouse_interface, wIndex'length));
										wLength <= x"0003";
									end if;
								else
									if mouse_present='1' then
										wIndex  <= std_logic_vector(to_unsigned(mouse_interface, wIndex'length));
										wLength <= x"0003";
										toggle  := '0';
									elsif keyboard_present='1' then
										wIndex  <= std_logic_vector(to_unsigned(keyboard_interface, wIndex'length));
										wLength <= x"0008";
									end if;
								end if;
								-- wIndex   <= x"0000"; -- set the intreface here to test
								-- wLength  <= x"0008"; -- set the size packet here to test
								if timer < max_count then
									if sof_tick='1' then
										timer := timer + 1;
									end if;
								-- elsif tries < 15 then
								else
									timer := 0;
									tries := tries + 1;
									ctlr_req <= not ctlr_rdy;
								-- else
									-- step := s_ready;
								end if;
							when s_ready =>
								hid_rgtr <= (others => '-');
								step     := s_getreport;
								hid_rdy  <= hid_req;
							end case;
						end if;
					else
						hid_rgtr <= (others => '-');
						toggle := '0';
						step := s_setprotocol;
					end if;
					if ctlr_gntd='1' then
						pending <= ctlr_nak;
					end if;
				end if;
			end if;
		end process;
	end block;
	
   	setupmux_e : entity hdl4fpga.devmux
		generic map (
			n => setup_reqs'length)
		port map (
			clk  => clk,
			ena  => cken,
			reqs => setup_reqs,
			rdys => setup_rdys,
			req  => setup_req,
			rdy  => setup_rdy);

	setup_p : process (clk, setup_rgtr)
		alias  bmRequestType : std_logic_vector( 8-1 downto 0) is setup_rgtr( 8-1 downto  0);
		alias  bRequest      : std_logic_vector( 8-1 downto 0) is setup_rgtr(16-1 downto  8);
		alias  wValue        : std_logic_vector(16-1 downto 0) is setup_rgtr(32-1 downto 16);
		alias  wIndex        : std_logic_vector(16-1 downto 0) is setup_rgtr(48-1 downto 32);
		alias  wLength       : std_logic_vector(16-1 downto 0) is setup_rgtr(64-1 downto 48);
		alias  dev_addr      : std_logic_vector( 7-1 downto 0) is setup_rgtr( 7+64-1 downto 0+64);
		alias  dev_endp      : std_logic_vector(11-1 downto 7) is setup_rgtr(11+64-1 downto 7+64);
		alias  pending       : std_ulogic is setup_rgtr(11+64);

		type steps is (s_getdevice, s_setaddress, s_getconfiguration, s_setconfiguration, s_ready);
		variable step : steps;
		variable addr : unsigned(16-1 downto 0) := x"000a";
		alias ctlr_req  is ctlr_reqs(0);
		alias ctlr_rdy  is ctlr_rdys(0);
		alias ctlr_gntd is ctlr_gntds(0);
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
						when s_getdevice =>
							dev_addr      <= (others => '0');
							dev_endp      <= (others => '0');
							bmRequestType <= x"80";
							bRequest      <= get_descriptor;
							wValue        <= x"0100";
							wIndex        <= x"0000";
							wLength       <= x"ffff";
							ctlr_req <= not ctlr_rdy;
							step := s_setaddress;
						when s_setaddress =>
							dev_addr      <= (others => '0');
							dev_endp      <= (others => '0');
							bmRequestType <= x"00";
							bRequest      <= set_address;
							wValue        <= std_logic_vector(addr);
							wIndex        <= x"0000";
							wLength       <= x"0000";
							ctlr_req <= not ctlr_rdy;
							step := s_getconfiguration;
						when s_getconfiguration =>
							dev_addr      <= std_logic_vector(addr(dev_addr'range));
							bmRequestType <= x"80";
							bRequest      <= get_descriptor;
							wValue        <= x"0200";
							wIndex        <= x"0000";
							wLength       <= x"ffff";
							ctlr_req <= not ctlr_rdy;
							step := s_setconfiguration;
						when s_setconfiguration =>
							dev_addr      <= std_logic_vector(addr(dev_addr'range));
							bmRequestType <= x"00";
							bRequest      <= set_configuration;
							wValue        <= x"0001";
							wIndex        <= x"0000";
							wLength       <= x"0000";
							ctlr_req <= not ctlr_rdy;
							step := s_ready;
						when s_ready =>
							setup_rgtr <= (others => '-');
							setup_rdy <= setup_req;
							addr := addr + 1;
							step := s_getdevice;
						end case;
					end if;
				else
					setup_rgtr <= (others => '-');
					step := s_getdevice;
				end if;
				if ctlr_gntd='1' then
					pending <= ctlr_nak;
				end if;
			end if;
		end if;
	end process;

	descriptors_p : process (rply_req, clk)
		constant max_count : natural := 256*8;
		variable cntr    : natural range 0 to max_count;
		alias bLength            : std_logic_vector(8-1 downto 0) is descriptor_rgtr(1*8-1 downto 0*8);
		alias bDescriptorType    : std_logic_vector(8-1 downto 0) is descriptor_rgtr(16-1 downto  8);
		alias bInterfaceNumber   : std_logic_vector(8-1 downto 0) is descriptor_rgtr(3*8-1 downto 2*8);
		alias bInterfaceClass    : std_logic_vector(8-1 downto 0) is descriptor_rgtr(6*8-1 downto 5*8);
		alias bInterfaceProtocol : std_logic_vector(8-1 downto 0) is descriptor_rgtr(8*8-1 downto 7*8);
		alias bRequest           : std_logic_vector(8-1 downto 0) is ctlr_rgtr(16-1 downto 8);
		variable interface_no    : natural range 0 to 15;
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (rply_rdy xor rply_req)='1' then
					case bRequest is
					when get_descriptor|get_status => 
						if rxdv='1' then
							if rxbs='0' then
								if cntr < descriptor_rgtr'length then
									descriptor_rgtr(cntr) <= rxd;
								end if;
								if cntr < max_count then
									cntr := cntr + 1;
								end if;
							end if;
						end if;

						case bRequest is
						when get_descriptor =>
							if cntr >= 8 then
								if cntr/8 >= unsigned(bLength) then
									case bDescriptorType is
									when interface =>
										case bInterfaceClass is
										when class_hid =>
											case bInterfaceProtocol is
											when keyboard_protocol =>
												keyboard_interface <= interface_no;
												keyboard_present <= '1';
											when mouse_protocol =>
												mouse_present <= '1';
												mouse_interface <= interface_no;
											when others =>
											end case;
										when others =>
										end case;
										interface_no := interface_no + 1;
									when endpoint =>
									when others =>
									end case;
									cntr := 0;
								end if;
							end if;
						when others =>
						end case;
					when others =>
						cntr := 0;
					end case;
   				else
					interface_no     := 0;
   					cntr := 0;
   				end if;
			end if;
		end if;
	end process;

	config_p : process (rply_rdy, clk)
		variable cnfg_rgtr    : std_logic_vector(32-1 downto 0);
		alias bRequest        : std_logic_vector( 8-1 downto 0) is ctlr_rgtr(16-1 downto  8);
		alias wLength         : std_logic_vector(16-1 downto 0) is ctlr_rgtr(64-1 downto 48);
		alias bLength         : std_logic_vector( 8-1 downto 0) is cnfg_rgtr( 8-1 downto  0);
		alias bDescriptorType : std_logic_vector( 8-1 downto 0) is cnfg_rgtr(16-1 downto  8);
		alias wTotalLength    : std_logic_vector(16-1 downto 0) is cnfg_rgtr(32-1 downto 16);

		constant max_count : natural := 256*8;
		variable cntr : natural range 0 to max_count;

	begin
		if rising_edge(clk) then
			if cken='1' then
				if (rply_rdy xor rply_req)='1' then
					if rxdv='1' then
						if cntr < cnfg_rgtr'length then
							cnfg_rgtr(cntr) := rxd;
						end if;
						if rxbs='0' then
							if cntr < max_count then 
								cntr := cntr + 1;
							end if;
						end if;
					end if;
					case bRequest is
					when get_descriptor => 
						if cntr >=16 then
							if bDescriptorType=config then
								if cntr >= 32 then
									if cntr/8 >= unsigned(wTotalLength) then
										rply_rdy <= rply_req;
									elsif cntr >= max_count then 
										rply_rdy <= rply_req;
									end if;
								end if;
							elsif cntr/8 >= unsigned(blength) then
								rply_rdy <= rply_req;
							end if;
						end if;
					when others =>
						if cntr/8 >= unsigned(wLength) then
							rply_rdy <= rply_req;
						end if;
					end case;
				else
					cntr := 0;
				end if;
			end if;
		end if;
	end process;

	ctlr_b : block
		alias  bmRequestType : std_logic_vector( 8-1 downto 0) is ctlr_rgtr( 8-1 downto  0);
		alias  bRequest      : std_logic_vector( 8-1 downto 0) is ctlr_rgtr(16-1 downto  8);
		alias  wValue        : std_logic_vector(16-1 downto 0) is ctlr_rgtr(32-1 downto 16);
		alias  wIndex        : std_logic_vector(16-1 downto 0) is ctlr_rgtr(48-1 downto 32);
		alias  wLength       : std_logic_vector(16-1 downto 0) is ctlr_rgtr(64-1 downto 48);
		alias  addr          : std_logic_vector( 7-1 downto 0) is ctlr_rgtr( 7+64-1 downto 0+64);
		alias  endp          : std_logic_vector(11-1 downto 7) is ctlr_rgtr(11+64-1 downto 7+64);
		alias  pending       : std_ulogic is ctlr_rgtr(11+64);
	begin

		devmux_e : entity hdl4fpga.devmux
		generic map (
			n => ctlr_reqs'length,
			m => ctlr_rgtr'length)
		port map (
			clk  => clk,
			ena  => cken,
			reqs => ctlr_reqs,
			rdys => ctlr_rdys,
			di(0*ctlr_rgtr'length to 1*ctlr_rgtr'length-1) => setup_rgtr,
			di(1*ctlr_rgtr'length to 2*ctlr_rgtr'length-1) => hub_rgtr,
			di(2*ctlr_rgtr'length to 3*ctlr_rgtr'length-1) => hid_rgtr,
			req  => ctlr_req,
			rdy  => ctlr_rdy,
			gntd => ctlr_gntds,
			do   => ctlr_rgtr);

		dev_addr <= addr;
		dev_endp <= endp;
		ctlr_p : process (ctlr_rdy, clk)
			type states is (s_idle, s_setup, s_in, s_statusin, s_statusout);
			variable state : states;
			variable retries : natural range 0 to 8;
		begin
			if rising_edge(clk) then
				if cken='1' then
					if (tkstall_req xor tkstall_rdy)='0' then
						case state is
						when s_idle =>
							if (ctlr_rdy xor ctlr_req)='1' then
								if pending='1' then
									ctlr_nak <= '0';
									state   := s_setup;
								else
									tksetup_req <= not tksetup_rdy;
									rqst_req <= not rqst_rdy;
									state    := s_setup;
								end if;
							end if;
							retries := 0;
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
										ctlr_nak  <= '1';
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
									ctlr_nak  <= '1';
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
					txen <= rqst_rdy xor rqst_req;
				end if;
			end if;
		end process;
	end block;

end;
