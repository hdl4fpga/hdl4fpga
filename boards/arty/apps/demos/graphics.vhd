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
use ieee.math_real.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.profiles.all;
use hdl4fpga.ddr_db.all;
use hdl4fpga.videopkg.all;
use hdl4fpga.ipoepkg.all;

library unisim;
use unisim.vcomponents.all;

architecture graphics of arty is

	type apps is (
		mode900p_ddr333MHz,
		mode900p_ddr350MHz,
		mode900p_ddr375MHz,
		mode900p_ddr400MHz,
		mode900p_ddr425MHz,
		mode900p_ddr450MHz,
		mode900p_ddr475MHz,
		mode900p_ddr500MHz,
		mode900p_ddr525MHz,
		mode900p_ddr550MHz,
		mode900p_ddr575MHz,
		mode900p_ddr600MHz);

	constant app : apps := mode900p_ddr525MHz;

	signal sys_rst : std_logic;

	signal si_frm  : std_logic;
	signal si_irdy : std_logic;
	signal si_trdy : std_logic;
	signal si_end  : std_logic;
	signal si_data : std_logic_vector(0 to 8-1);

	signal so_frm  : std_logic;
	signal so_irdy : std_logic;
	signal so_trdy : std_logic;
	signal so_data : std_logic_vector(0 to 8-1);

	constant sys_per  : real := 10.0e-9;
	constant sys_freq : real := 1.0/(sys_per);

	type pll_params is record
		dcm_mul : natural;
		dcm_div : natural;
	end record;

	type ddr_params is record
		pll : pll_params;
		cl  : std_logic_vector(0 to 3-1);
		cwl : std_logic_vector(0 to 3-1);
	end record;

	type ddr_speeds is (
		ddr333MHz,
		ddr350MHz,
		ddr375MHz,
		ddr400MHz,
		ddr425MHz,
		ddr450MHz,
		ddr475MHz,
		ddr500MHz,
		ddr525MHz,
		ddr550MHz,
		ddr575MHz,
		ddr600MHz);

	type ddram_vector is array (ddr_speeds) of ddr_params;

	constant ddr_tab : ddram_vector := (

		------------------------------------------------------------------------
		-- Frequency   -- 333 Mhz -- 350 Mhz -- 375 Mhz -- 400 Mhz -- 425 Mhz --
		-- Multiply by --  10     --   7     --  15     --   4     --  17     --
		-- Divide by   --   3     --   2     --   4     --   1     --   4     --
		------------------------------------------------------------------------

		ddr333MHz => (pll => (dcm_mul => 10, dcm_div => 3), cl => "001", cwl => "000"),
		ddr350MHz => (pll => (dcm_mul =>  7, dcm_div => 2), cl => "010", cwl => "000"),
		ddr375MHz => (pll => (dcm_mul => 15, dcm_div => 4), cl => "010", cwl => "000"),
		ddr400MHz => (pll => (dcm_mul =>  4, dcm_div => 1), cl => "010", cwl => "000"),
		ddr425MHz => (pll => (dcm_mul => 17, dcm_div => 4), cl => "011", cwl => "001"),

		------------------------------------------------------------------------
		-- Frequency   -- 450 Mhz -- 475 Mhz -- 500 Mhz -- 525 Mhz -- 550 Mhz --
		-- Multiply by --   9     --  19     --   5     --  21     --  22     --
		-- Divide by   --   2     --   4     --   1     --   4     --   4     --
		------------------------------------------------------------------------

		ddr450MHz => (pll => (dcm_mul =>  9, dcm_div => 2), cl => "011", cwl => "001"),
		ddr475MHz => (pll => (dcm_mul => 19, dcm_div => 4), cl => "011", cwl => "001"),
		ddr500MHz => (pll => (dcm_mul =>  5, dcm_div => 1), cl => "011", cwl => "001"),
		ddr525MHz => (pll => (dcm_mul => 21, dcm_div => 4), cl => "011", cwl => "001"),
		ddr550MHz => (pll => (dcm_mul => 11, dcm_div => 2), cl => "101", cwl => "010"),  -- latency 9
		
		---------------------------------------
		-- Frequency   -- 575 Mhz -- 600 Mhz --
		-- Multiply by --  23     --   6     --
		-- Divide by   --   4     --   1     --
		---------------------------------------

		ddr575MHz => (pll => (dcm_mul => 23, dcm_div => 4), cl => "101", cwl => "010"),  -- latency 9
		ddr600MHz => (pll => (dcm_mul =>  6, dcm_div => 1), cl => "101", cwl => "010")); -- latency 9

	constant sclk_phases   : natural := 1;
	constant sclk_edges    : natural := 1;
	constant data_edges    : natural := 1;
	constant cmmd_gear     : natural := 2;
	constant data_gear     : natural := 4;

	constant bank_size     : natural := ddr3_ba'length;
	constant addr_size     : natural := ddr3_a'length;
	constant coln_size     : natural := 10;
	constant word_size     : natural := ddr3_dq'length;
	constant byte_size     : natural := ddr3_dq'length/ddr3_dqs_p'length;


	signal ddr_clk0        : std_logic;
	signal ddr_clk0x2      : std_logic;
	signal ddr_clk90x2     : std_logic;
	signal ddr_clk90       : std_logic;
	signal ddrsys_rst      : std_logic;

	signal ctlrphy_frm     : std_logic;
	signal ctlrphy_trdy    : std_logic;
	signal ctlrphy_ini     : std_logic;
	signal ctlrphy_rw      : std_logic;
	signal ctlrphy_wlreq   : std_logic;
	signal ctlrphy_wlrdy   : std_logic;
	signal ctlrphy_rlreq   : std_logic;
	signal ctlrphy_rlrdy   : std_logic;

	signal ddr_ba          : std_logic_vector(ddr3_ba'range);
	signal ddr_a           : std_logic_vector(ddr3_a'range);
	signal ctlrphy_rst     : std_logic_vector(0 to cmmd_gear-1);
	signal ctlrphy_cke     : std_logic_vector(0 to cmmd_gear-1);
	signal ctlrphy_cs      : std_logic_vector(0 to cmmd_gear-1);
	signal ctlrphy_ras     : std_logic_vector(0 to cmmd_gear-1);
	signal ctlrphy_cas     : std_logic_vector(0 to cmmd_gear-1);
	signal ctlrphy_we      : std_logic_vector(0 to cmmd_gear-1);
	signal ctlrphy_odt     : std_logic_vector(0 to cmmd_gear-1);
	signal ctlrphy_cmd     : std_logic_vector(0 to 3-1);
	signal ctlrphy_ba      : std_logic_vector(cmmd_gear*ddr3_ba'length-1 downto 0);
	signal ctlrphy_a       : std_logic_vector(cmmd_gear*ddr3_a'length-1 downto 0);
	signal ctlrphy_dqsi    : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dqst    : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dqso    : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dmi     : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dmt     : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dmo     : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dqi     : std_logic_vector(data_gear*word_size-1 downto 0);
	signal ctlrphy_dqt     : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dqo     : std_logic_vector(data_gear*word_size-1 downto 0);
	signal ctlrphy_sto     : std_logic_vector(0 to data_gear*word_size/byte_size-1);
	signal ctlrphy_sti     : std_logic_vector(0 to data_gear*word_size/byte_size-1);

	signal ddr3_clk        : std_logic_vector(1-1 downto 0);
	signal ddr3_dqst       : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddr3_dqso       : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddr3_dqsi       : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddr3_dqo        : std_logic_vector(word_size-1 downto 0);
	signal ddr3_dqt        : std_logic_vector(word_size-1 downto 0);

	type video_modes is (
		modedebug,
		mode900p);

	type io_iface is (
		io_hdlc,
		io_ipoe);

	type app_record is record
		iface      : io_iface;
		ddr_speed  : ddr_speeds;
		video_mode : video_modes;
	end record;

	type app_vector is array (apps) of app_record;
	constant app_tap : app_vector := (
		mode900p_ddr333MHz => (io_ipoe, ddr333MHz, mode900p),
		mode900p_ddr350MHz => (io_ipoe, ddr350MHz, mode900p),
		mode900p_ddr375MHz => (io_ipoe, ddr375MHz, mode900p),
		mode900p_ddr400MHz => (io_ipoe, ddr400MHz, mode900p),
		mode900p_ddr425MHz => (io_ipoe, ddr425MHz, mode900p),
		mode900p_ddr450MHz => (io_ipoe, ddr450MHz, mode900p),
		mode900p_ddr475MHz => (io_ipoe, ddr475MHz, mode900p),
		mode900p_ddr500MHz => (io_ipoe, ddr500MHz, mode900p),
		mode900p_ddr525MHz => (io_ipoe, ddr525MHz, mode900p),
		mode900p_ddr550MHz => (io_ipoe, ddr550MHz, mode900p),
		mode900p_ddr575MHz => (io_ipoe, ddr575MHz, mode900p),
		mode900p_ddr600MHz => (io_ipoe, ddr600MHz, mode900p));

	type video_params is record
		pll  : pll_params;
		mode : videotiming_ids;
	end record;

	type videoparams_vector is array (video_modes) of video_params;
	constant video_tab : videoparams_vector := (
		modedebug => (mode => pclk_debug,              pll => (dcm_mul => 1, dcm_div => 32)),
		mode900p  => (mode => pclk108_00m1600x900at60, pll => (dcm_mul => 1, dcm_div => 11)));

	constant video_mode : video_modes := video_modes'val(
		setif(debug, video_modes'pos(modedebug), video_modes'pos(app_tap(app).video_mode)));

	constant ddr_speed : ddr_speeds := app_tap(app).ddr_speed;
	constant ddr_param : ddr_params := ddr_tab(ddr_speed);
	constant ddr_tcp   : real := (sys_per*real(ddr_param.pll.dcm_div))/real(ddr_param.pll.dcm_mul); -- 1 ns /1ps

	alias  sys_clk        : std_logic is gclk100;
	alias  ctlr_clk       : std_logic is ddr_clk0;
	signal video_clk      : std_logic := '0';
	signal video_lck      : std_logic := '0';
	signal video_shf_clk  : std_logic := '0';
	signal video_hs       : std_logic;
	signal video_vs       : std_logic;
    signal video_blank    : std_logic;
    signal video_pixel    : std_logic_vector(0 to 32-1);
	signal dvid_crgb      : std_logic_vector(8-1 downto 0);

	signal sin_clk        : std_logic;
	signal sin_frm        : std_logic;
	signal sin_irdy       : std_logic;
	signal sin_data       : std_logic_vector(0 to 8-1); 
	signal sout_frm       : std_logic;
	signal sout_irdy      : std_logic;
	signal sout_trdy      : std_logic;
	signal sout_data      : std_logic_vector(0 to 8-1);

	alias  mii_txc        : std_logic is eth_tx_clk;
	alias  sio_clk        : std_logic is mii_txc;

	signal tp  : std_logic_vector(1 to 32);
	alias data : std_logic_vector(0 to 8-1) is tp(3 to 3+8-1);

	-----------------
	-- Select link --
	-----------------

	constant io_link  : io_iface := io_ipoe;

	constant mem_size : natural := 8*(1024*8);

	signal rst0div_rst : std_logic;
	signal rst90div_rst : std_logic;
	signal ioctrl_rst : std_logic;
	signal ioctrl_clk : std_logic;
	signal ioctrl_rdy : std_logic;

	signal tp_delay   : std_logic_vector(word_size/byte_size*8-1 downto 0);
	signal tp1        : std_logic_vector(1 to 32);

begin

	sys_rst <= btn(0);

	idelayctrl_i : idelayctrl
	port map (
		rst    => ioctrl_rst,
		refclk => ioctrl_clk,
		rdy    => ioctrl_rdy);

	debug_q : if debug generate
		signal q : bit;
	begin
		q <= not q after 1 ns;
		eth_ref_clk <= to_stdulogic(q);
	end generate;

	nodebug_g : if not debug generate
		process (sys_clk)
			variable div : unsigned(0 to 1) := (others => '0');
		begin
			if rising_edge(sys_clk) then
				div := div + 1;
				eth_ref_clk <= div(0);
			end if;
		end process;
	end generate;

	dcm_b : block
		constant clk0div   : natural := 0;
		constant clk90div  : natural := 1;
		constant iodclk    : natural := 2;
		constant clk0      : natural := 3;
		constant clk90     : natural := 4;
		constant clk270div : natural := 5;
	begin

		ioctrl_b : block
			signal video_clk_mmce2 : std_logic;
			signal video_shf_clk_mmce2 : std_logic;
			signal ioctrl_clkfb  : std_logic;
			signal ioctrl_lkd    : std_logic;
		begin
			ioctrl_i :  mmcme2_base
			generic map (
				clkfbout_mult_f => 10.75,		-- 200 MHz
				clkin1_period => sys_per*1.0e9,
				clkout0_divide_f => 5.375,
				clkout1_divide   => 10,
				clkout2_divide   => 2,
				bandwidth => "LOW")
			port map (
				pwrdwn   => '0',
				rst      => sys_rst,
				clkin1   => sys_clk,
				clkfbin  => ioctrl_clkfb,
				clkfbout => ioctrl_clkfb,
				clkout0  => ioctrl_clk,
				clkout1  => open, -- video_clk,
				clkout2  => open, -- video_shf_clk,
				locked   => ioctrl_lkd);
			ioctrl_rst <= not ioctrl_lkd;
			video_clk <= ioctrl_lkd;

		end block;

		ddr_b : block
			signal ddr_lkd           : std_logic;
			signal ddr_clkfb         : std_logic;
			signal ddr_clk0x2_mmce2  : std_logic;
			signal ddr_clk90x2_mmce2 : std_logic;
			signal ddr_clk0_mmce2    : std_logic;
			signal ddr_clk90_mmce2   : std_logic;
		begin
			ddr_i : mmcme2_base
			generic map (
				divclk_divide    => ddr_param.pll.dcm_div,
				clkfbout_mult_f  => real(2*ddr_param.pll.dcm_mul),
				clkin1_period    => sys_per*1.0e9,
				clkout0_divide_f => real(data_gear/2),
				clkout1_divide   => data_gear/2,
				clkout1_phase    => 90.0+180.0,
				clkout2_divide   => data_gear,
				clkout3_divide   => data_gear,
				clkout3_phase    => 90.0/real((data_gear/2))+270.0)
			port map (
				pwrdwn   => '0',
				rst      => sys_rst,
				clkin1   => sys_clk,
				clkfbin  => ddr_clkfb,
				clkfbout => ddr_clkfb,
				clkout0  => ddr_clk0x2_mmce2,
				clkout1  => ddr_clk90x2_mmce2,
				clkout2  => ddr_clk0_mmce2,
				clkout3  => ddr_clk90_mmce2,
				locked   => ddr_lkd);

			ddr_clk0_bufg : bufio
			port map (
				i => ddr_clk0x2_mmce2,
				o => ddr_clk0x2);

			ddr_clk90_bufg : bufio
			port map (
				i => ddr_clk90x2_mmce2,
				o => ddr_clk90x2);

			ddr_clk0div_bufg : bufg
			port map (
				i => ddr_clk0_mmce2,
				o => ddr_clk0);

			ddr_clk90div_bufg : bufg
			port map (
				i => ddr_clk90_mmce2,
				o => ddr_clk90);

			ctlrphy_dqsi <= (others => ddr_clk90);
			ddrsys_rst <= not ddr_lkd;

			process(ddr_clk0)
			begin
				if rising_edge(ddr_clk0) then
					rst0div_rst <= ddrsys_rst;
				end if;
			end process;

			process(ddr_clk90)
			begin
				if rising_edge(ddr_clk90) then
					rst90div_rst <= ddrsys_rst;
				end if;
			end process;

		end block;

	end block;

	hdlc_g : if io_link=io_hdlc generate

		constant uart_xtal : real := 
			real(video_tab(video_mode).pll.dcm_mul)*sys_freq/
			real(video_tab(video_mode).pll.dcm_div);

		constant baudrate : natural := setif(
			uart_xtal >= 32.0e6, 3000000, setif(
			uart_xtal >= 25.0e6, 2000000,
                                 115200));

		signal uart_clk   : std_logic;
		signal uart_rxdv  : std_logic;
		signal uart_rxd   : std_logic_vector(0 to 8-1);
		signal uarttx_frm : std_logic;
		signal uart_idle  : std_logic;
		signal uart_txen  : std_logic;
		signal uart_txd   : std_logic_vector(uart_rxd'range);

		signal tp         : std_logic_vector(1 to 32);

		alias ftdi_txd    : std_logic is uart_txd_in;
		alias ftdi_rxd    : std_logic is uart_rxd_out;

		signal dummy_txd  : std_logic_vector(uart_rxd'range);
	begin

		process (uart_clk)
			variable q0 : std_logic := '0';
			variable q1 : std_logic := '0';
		begin
			if rising_edge(uart_clk) then
--				led(1) <= q1;
--				led(7) <= q0;
				if tp(1)='1' then
					if tp(2)='1' then
						q1 := not q1;
					end if;
				end if;
				if uart_rxdv='1' then
					q0 := not q0;
				end if;
			end if;
		end process;

		process (dummy_txd ,uart_clk)
			variable q : std_logic := '0';
			variable e : std_logic := '1';
		begin
			if rising_edge(uart_clk) then
--				led(5) <= q;
				if (so_frm and not e)='1' then
					q := not q;
				end if;
	--			led(4) <= so_frm;
				e := so_frm;
			end if;
		end process;

		nodebug_g : if not debug generate
			uart_clk <= video_clk;
		end generate;

		debug_g : if debug generate
			uart_clk <= not to_stdulogic(to_bit(uart_clk)) after 0.1 ns /2;
		end generate;

		assert FALSE
			report "BAUDRATE : " & " " & integer'image(baudrate)
			severity NOTE;

		uartrx_e : entity hdl4fpga.uart_rx
		generic map (
			baudrate => baudrate,
			clk_rate => uart_xtal)
		port map (
			uart_rxc  => uart_clk,
			uart_sin  => ftdi_txd,
			uart_irdy => uart_rxdv,
			uart_data => uart_rxd);

		uarttx_e : entity hdl4fpga.uart_tx
		generic map (
			baudrate => baudrate,
			clk_rate => uart_xtal)
		port map (
			uart_txc  => uart_clk,
			uart_frm  => video_lck,
			uart_irdy => uart_txen,
			uart_trdy => uart_idle,
			uart_data => uart_txd,
			uart_sout => ftdi_rxd);

		siodaahdlc_e : entity hdl4fpga.sio_dayhdlc
		generic map (
			mem_size    => mem_size)
		port map (
			uart_clk    => uart_clk,
			uartrx_irdy => uart_rxdv,
			uartrx_data => uart_rxd,
			uarttx_frm  => uarttx_frm,
			uarttx_trdy => uart_idle,
			uarttx_data => uart_txd,
			uarttx_irdy => uart_txen,
			sio_clk     => sio_clk,
			so_frm      => so_frm,
			so_irdy     => so_irdy,
			so_trdy     => so_trdy,
			so_data     => so_data,

			si_frm      => si_frm,
			si_irdy     => si_irdy,
			si_trdy     => si_trdy,
			si_end      => si_end,
			si_data     => si_data,
			tp          => tp);

	end generate;

	ipoe_e : if io_link=io_ipoe generate

		alias  mii_rxc    : std_logic is eth_rx_clk;
		alias  mii_rxdv   : std_logic is eth_rx_dv;
		alias  mii_rxd    : std_logic_vector(eth_rxd'range) is eth_rxd;

		signal mii_txd    : std_logic_vector(eth_txd'range);
		signal mii_txen   : std_logic;
		signal dhcpcd_req : std_logic := '0';
		signal dhcpcd_rdy : std_logic := '0';

		signal miirx_frm  : std_logic;
		signal miirx_irdy : std_logic;
		signal miirx_data : std_logic_vector(mii_rxd'range);

		signal miitx_frm  : std_logic;
		signal miitx_irdy : std_logic;
		signal miitx_trdy : std_logic;
		signal miitx_end  : std_logic;
		signal miitx_data : std_logic_vector(si_data'range);

	begin

		sync_b : block

			signal rxc_rxbus : std_logic_vector(0 to mii_rxd'length);
			signal txc_rxbus : std_logic_vector(0 to mii_rxd'length);
			signal dst_irdy  : std_logic;
			signal dst_trdy  : std_logic;

		begin

			process (mii_rxc)
			begin
				if rising_edge(mii_rxc) then
					rxc_rxbus <= mii_rxdv & mii_rxd;
				end if;
			end process;

			rxc2txc_e : entity hdl4fpga.fifo
			generic map (
				max_depth  => 4,
				latency    => 0,
				dst_offset => 0,
				src_offset => 2,
				check_sov  => false,
				check_dov  => true,
				gray_code  => false)
			port map (
				src_clk  => mii_rxc,
				src_data => rxc_rxbus,
				dst_clk  => mii_txc,
				dst_irdy => dst_irdy,
				dst_trdy => dst_trdy,
				dst_data => txc_rxbus);

			process (mii_txc)
			begin
				if rising_edge(mii_txc) then
					dst_trdy   <= to_stdulogic(to_bit(dst_irdy));
					miirx_frm  <= txc_rxbus(0);
					miirx_irdy <= txc_rxbus(0);
					miirx_data <= txc_rxbus(1 to mii_rxd'length);
				end if;
			end process;
		end block;

		dhcp_p : process(mii_txc)
		begin
			if rising_edge(mii_txc) then
				if to_bit(dhcpcd_req xor dhcpcd_rdy)='0' then
			--		dhcpcd_req <= dhcpcd_rdy xor not sw1;
				end if;
			end if;
		end process;

		udpdaisy_e : entity hdl4fpga.sio_dayudp
		generic map (
			debug         => debug,
			my_mac        => x"00_40_00_01_02_03",
			default_ipv4a => aton("192.168.0.14"))
		port map (
			tp         => open,

			sio_clk    => sio_clk,
			dhcpcd_req => dhcpcd_req,
			dhcpcd_rdy => dhcpcd_rdy,
			miirx_frm  => miirx_frm,
			miirx_irdy => miirx_irdy,
			miirx_trdy => open,
			miirx_data => miirx_data,

			miitx_frm  => miitx_frm,
			miitx_irdy => miitx_irdy,
			miitx_trdy => miitx_trdy,
			miitx_end  => miitx_end,
			miitx_data => miitx_data,

			si_frm     => si_frm,
			si_irdy    => si_irdy,
			si_trdy    => si_trdy,
			si_end     => si_end,
			si_data    => si_data,

			so_frm     => so_frm,
			so_irdy    => so_irdy,
			so_trdy    => so_trdy,
			so_data    => so_data);

		desser_e: entity hdl4fpga.desser
		port map (
			desser_clk => mii_txc,

			des_frm    => miitx_frm,
			des_irdy   => miitx_irdy,
			des_trdy   => miitx_trdy,
			des_data   => miitx_data,

			ser_irdy   => open,
			ser_data   => mii_txd);

		mii_txen <= miitx_frm and not miitx_end;
		process (mii_txc)
		begin
			if rising_edge(mii_txc) then
				eth_tx_en <= mii_txen;
				eth_txd   <= mii_txd;
			end if;
		end process;

	end generate;

	grahics_e : entity hdl4fpga.demo_graphics
	generic map (
		debug        => debug,
		profile      => 1,
		ddr_tcp      => 2.0*ddr_tcp,
		fpga         => xc7a,
		mark         => m2g125,
		sclk_phases  => sclk_phases,
		sclk_edges   => sclk_edges,
		burst_length => 8,
		data_phases  => data_gear,
		data_edges   => data_edges,
		data_gear    => data_gear,
		cmmd_gear    => cmmd_gear,
		bank_size    => bank_size,
		addr_size    => addr_size,
		coln_size    => coln_size,
		word_size    => word_size,
		byte_size    => byte_size,

		timing_id    => video_tab(video_mode).mode,
		red_length   => 8,
		green_length => 8,
		blue_length  => 8,

		fifo_size    => 8*2048)

	port map (
--		tpin         => sw,
		sio_clk      => sio_clk,
		sin_frm      => so_frm,
		sin_irdy     => so_irdy,
		sin_trdy     => so_trdy,
		sin_data     => so_data,
		sout_frm     => si_frm,
		sout_irdy    => si_irdy,
		sout_trdy    => si_trdy,
		sout_end     => si_end,
		sout_data    => si_data,

		video_clk    => video_clk,
		video_hzsync => video_hs,
		video_vtsync => video_vs,
		video_blank  => video_blank,
		video_pixel  => video_pixel,
		dvid_crgb    => dvid_crgb,

		ctlr_clks(0) => ctlr_clk,
		ctlr_rst     => ddrsys_rst,
		ctlr_bl      => "000",
		ctlr_cl      => ddr_param.cl,
		ctlr_cwl     => ddr_param.cwl,
		ctlr_rtt     => "001",
		ctlr_cmd     => ctlrphy_cmd,

		ctlrphy_wlreq => ctlrphy_wlreq,
		ctlrphy_wlrdy => ctlrphy_wlrdy,
		ctlrphy_rlreq => ctlrphy_rlreq,
		ctlrphy_rlrdy => ctlrphy_rlrdy,

		ctlrphy_irdy => ctlrphy_frm,
		ctlrphy_trdy => ctlrphy_trdy,
		ctlrphy_ini  => ctlrphy_ini,
		ctlrphy_rw   => ctlrphy_rw,

		ctlrphy_rst  => ctlrphy_rst(0),
		ctlrphy_cke  => ctlrphy_cke(0),
		ctlrphy_cs   => ctlrphy_cs(0),
		ctlrphy_ras  => ctlrphy_ras(0),
		ctlrphy_cas  => ctlrphy_cas(0),
		ctlrphy_we   => ctlrphy_we(0),
		ctlrphy_odt  => ctlrphy_odt(0),
		ctlrphy_b    => ddr_ba,
		ctlrphy_a    => ddr_a,
		ctlrphy_dsi  => ctlrphy_dqsi,
		ctlrphy_dst  => ctlrphy_dqst,
		ctlrphy_dso  => ctlrphy_dqso,
		ctlrphy_dmi  => ctlrphy_dmi,
		ctlrphy_dmt  => ctlrphy_dmt,
		ctlrphy_dmo  => ctlrphy_dmo,
		ctlrphy_dqi  => ctlrphy_dqi,
		ctlrphy_dqt  => ctlrphy_dqt,
		ctlrphy_dqo  => ctlrphy_dqo,
		ctlrphy_sto  => ctlrphy_sto,
		ctlrphy_sti  => ctlrphy_sti,
		tp => tp);

	process (ddr_ba)
	begin
		for i in ddr_ba'range loop
			for j in 0 to cmmd_gear-1 loop
				ctlrphy_ba(i*cmmd_gear+j) <= ddr_ba(i);
			end loop;
		end loop;
	end process;

	process (ddr_a)
	begin
		for i in ddr_a'range loop
			for j in 0 to cmmd_gear-1 loop
				ctlrphy_a(i*cmmd_gear+j) <= ddr_a(i);
			end loop;
		end loop;
	end process;

	ctlrphy_rst(1) <= ctlrphy_rst(0);
	ctlrphy_cke(1) <= ctlrphy_cke(0);
	ctlrphy_cs(1)  <= ctlrphy_cs(0);
	ctlrphy_ras(1) <= '1';
	ctlrphy_cas(1) <= '1';
	ctlrphy_we(1)  <= '1';
	ctlrphy_odt(1) <= ctlrphy_odt(0);

	ddrphy_e : entity hdl4fpga.xc7a_ddrphy
	generic map (
		taps      => natural(floor(ddr_tcp*(32.0*2.0)/(sys_per/2.0)))-1,
		bank_size => bank_size,
        addr_size => addr_size,
		cmmd_gear => cmmd_gear,
		data_gear => data_gear,
		word_size => word_size,
		byte_size => byte_size)
	port map (

		tp_sel    => btn(3),
		tp_delay  => tp_delay,
		tp1       => tp1(1 to 6),

		rst       => ddrsys_rst,
		iod_clk   => sys_clk,
		clk0      => ddr_clk0,
		clk90     => ddr_clk90,
		clk0x2    => ddr_clk0x2,
		clk90x2   => ddr_clk90x2,

		phy_frm   => ctlrphy_frm,
		phy_trdy  => ctlrphy_trdy,
		phy_rw    => ctlrphy_rw,
		phy_ini   => ctlrphy_ini,

		phy_cmd   => ctlrphy_cmd,
		phy_wlreq => ctlrphy_wlreq,
		phy_wlrdy => ctlrphy_wlrdy,

		phy_rlreq => ctlrphy_rlreq,
		phy_rlrdy => ctlrphy_rlrdy,

		sys_cke   => ctlrphy_cke,
		sys_rst   => ctlrphy_rst,
		sys_cs    => ctlrphy_cs,
		sys_ras   => ctlrphy_ras,
		sys_cas   => ctlrphy_cas,
		sys_we    => ctlrphy_we,
		sys_ba    => ctlrphy_ba,
		sys_a     => ctlrphy_a,

		sys_dqst  => ctlrphy_dqst,
		sys_dqso  => ctlrphy_dqso,
		sys_dmi   => ctlrphy_dmo,
		sys_dmt   => ctlrphy_dmt,
		sys_dmo   => ctlrphy_dmi,
		sys_dqo   => ctlrphy_dqi,
		sys_dqt   => ctlrphy_dqt,
		sys_dqi   => ctlrphy_dqo,
		sys_odt   => ctlrphy_odt,
		sys_sti   => ctlrphy_sto,
		sys_sto   => ctlrphy_sti,

		ddr_rst   => ddr3_reset,
		ddr_clk   => ddr3_clk,
		ddr_cke   => ddr3_cke,
		ddr_cs    => ddr3_cs,
		ddr_ras   => ddr3_ras,
		ddr_cas   => ddr3_cas,
		ddr_we    => ddr3_we,
		ddr_b     => ddr3_ba,
		ddr_a     => ddr3_a,
		ddr_odt   => ddr3_odt,
--		ddr_dm    => ddr3_dm,
		ddr_dqo   => ddr3_dqo,
		ddr_dqi   => ddr3_dq,
		ddr_dqt   => ddr3_dqt,
		ddr_dqst  => ddr3_dqst,
		ddr_dqsi  => ddr3_dqsi,
		ddr_dqso  => ddr3_dqso);

	ddriob_b : block
	begin

		ddr_clks_g : for i in ddr3_clk'range generate
			ddr_ck_obufds : obufds
			generic map (
				iostandard => "DIFF_SSTL135")
			port map (
				i  => ddr3_clk(i),
				o  => ddr3_clk_p,
				ob => ddr3_clk_n);
		end generate;

		ddr_dqs_g : for i in ddr3_dqs_p'range generate
			dqsiobuf_i : iobufds
			generic map (
				iostandard => "DIFF_SSTL135")
			port map (
				t   => ddr3_dqst(i),
				i   => ddr3_dqso(i),
				o   => ddr3_dqsi(i),
				io  => ddr3_dqs_p(i),
				iob => ddr3_dqs_n(i));

		end generate;

		ddr_d_g : for i in ddr3_dq'range generate
			ddr3_dq(i) <= ddr3_dqo(i) when ddr3_dqt(i)='0' else 'Z';
		end generate;

	end block;

	process (sw, tp_delay)
		variable data : std_logic_vector(8-1 downto 0);
	begin
		rgbled <= (others => '0');
		data := word2byte(tp_delay, sw(2-1 downto 0), data'length);
		for i in 0 to 4-1 loop
			if data(i)='1' then
				rgbled(3*i+0) <= '1';
			end if;
		end loop;
		led(0) <= data(4);
		led(1) <= data(5);
		led(2) <= data(6);
		led(3) <= data(7);
	end process;

	ddr3_dm <= (others => '0');


	-- VGA --
	---------

	hdmi_b : block
		signal q : std_logic_vector(0 to 4-1);
		signal p : std_logic_vector(q'range);
		signal n : std_logic_vector(p'range);
	begin
		oddr_i : entity hdl4fpga.omdr
		generic map (
			SIZE => 4,
			GEAR => 2)
		port map (
			clk(0) => video_shf_clk,
			clk(1) => '-',
			d      => dvid_crgb,
			q      => q);

		hdmi_g : for i in q'range generate
			obufds_i : obufds
			generic map (
				iostandard => "LVDS_25")
			port map (
				i  => q(i),
				o  => p(i),
				ob => n(i));
		end generate;
		(jb(1), jb(3), jb(7), jb(9)) <= p;
		(jb(2), jb(4), jb(8), jb(10)) <= n;

	end block;

	eth_rstn <= not ioctrl_rst;
	eth_mdc  <= '0';
	eth_mdio <= '0';

end;
