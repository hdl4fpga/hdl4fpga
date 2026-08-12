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
use hdl4fpga.videopkg.all;
use hdl4fpga.ipoepkg.all;
use hdl4fpga.ecp5_profiles.all;

library ecp5u;
use ecp5u.components.all;

architecture ser_debug of ulx3s is

	constant usb_oversampling : natural := 3;
	constant usb_device : boolean := true;
	constant monitor : boolean := true;

	constant settings : string := "{"                                                             &
		"io_link: io_ipoe,"                                                                                &
		"video:{"                                                                                         &
			"dcm:"          & string'(hdl4fpga.ecp5_profiles.video_dcm(".'25mhz'.'40mhz'", 36.0e6)) & ',' &
			"videoio_freq:" & "36.0e6,"                                                                   &
			"gear:"         & "2,"                                                                        &
			"timings:"      & string'(hdl4fpga.videopkg.timings_db**".'800x600'.'@60'.'40mhz'")     & ',' &
			"pixel:{"                                                                                     &
				"R:8,"                                                                                    &
				"G:8,"                                                                                    &
				"B:8}}}";

	constant io_link      : string := hdo(settings)**".io_link";

	alias sys_rst is fire1;
	alias sys_clk is clk_25mhz;

	signal videoio_clk     : std_logic;
	signal video_clk       : std_logic;
	signal video_shift_clk : std_logic;
	signal video_lck       : std_logic;
	signal video_hzsync    : std_logic;
	signal video_vtsync    : std_logic;
	signal video_pixel     : std_logic_vector(0 to settings**".video.pixel.R=8"+settings**".video.pixel.G=8"+settings**".video.pixel.B=8"-1);
	signal dvid_crgb       : std_logic_vector(7 downto 0);

	signal so_frm          : std_logic;
	signal so_irdy         : std_logic;
	signal so_trdy         : std_logic;
	signal so_data         : std_logic_vector(0 to 8-1);
	signal si_frm          : std_logic;
	signal si_irdy         : std_logic;
	signal si_trdy         : std_logic;
	signal si_end          : std_logic;
	signal si_data         : std_logic_vector(0 to 8-1);

	signal ser_clk         : std_logic;
	signal ser_frm         : std_logic;
	signal ser_irdy        : std_logic;
	signal ser_data        : std_logic_vector(0 to setif(io_link="io_ipoe", 2,1)-1);

	constant hdplx         : std_logic := setif(debug, '0', '1');
begin

	videodcm_e : entity hdl4fpga.ecp5_videodcm
	generic map (
		settings    => settings**".video")
	port map (
		rst         => sys_rst,
		clk         => sys_clk,
		videoio_clk => videoio_clk,
		video_clk   => video_clk,
		video_shift_clk => video_shift_clk,
		video_lck   => video_lck);

	usb_g : if io_link="io_usb" generate
		signal cken : std_logic;
		signal cfgd : std_logic;

		signal txen : std_logic;
		signal txbs : std_logic;
		signal txd  : std_logic;

		signal rxdv : std_logic;
		signal rxbs : std_logic;
		signal rxd  : std_logic;

		signal fltr_on : std_logic;
		signal fltr_en : std_logic;
		signal fltr_bs : std_logic;
		signal fltr_d  : std_logic;

		signal tp   : std_logic_vector(1 to 32);
	begin
		usb_fpga_dp    <= 'Z';-- when up='0' else '0';
		usb_fpga_dn    <= 'Z';-- when up='0' else '0';
		usb_fpga_bd_dp <= 'Z';
		usb_fpga_bd_dn <= 'Z';

		txen <= rxdv;
		rxbs <= txbs;
		txd  <= rxd;

		usbdev_g : if usb_device generate
			usb_fpga_pu_dp <= '1'; -- D+ pullup for USB1.1 device mode
			usb_fpga_pu_dn <= 'Z'; -- D- no pullup for USB1.1 device mode
			usbdev_e : entity hdl4fpga.usbdev
			generic map (
				oversampling => usb_oversampling)
			port map (
				tp   => tp,
				dp   => usb_fpga_dp,
				dn   => usb_fpga_dn,
				clk  => videoio_clk,
				dev_cfgd => cfgd,
				cken => cken,
				txen => txen, 
				txbs => txbs,
				txd  => txd,
				rxdv => rxdv, 
				rxbs => rxbs,
				rxd  => rxd);
		end generate;
			
		usbhost_g : if not usb_device generate
			signal init_req : std_logic := '0';
			signal init_rdy : std_logic := '0';
		begin
			process (videoio_clk)
				variable ena : bit := '1';
			begin
				if rising_edge(videoio_clk) then
					if left='1' then
						init_req <= init_rdy;
					elsif fire2='1' then
						if ena='1' then
							init_req <= not init_rdy;
						end if;
						ena := '0';
					elsif fire2='1' then
						ena := '1';
					end if;
				end if;
			end process;

			usb_fpga_pu_dp <= 'Z' when left='0' else '0'; -- D+ pullup for USB1.1 host mode
			usb_fpga_pu_dn <= 'Z' when left='0' else '0'; -- D- no pullup for USB1.1 host mode
			usbhost_e : entity hdl4fpga.usbhostdvr
			generic map (
				oversampling => usb_oversampling)
			port map (
				dp   => usb_fpga_dp,
				dn   => usb_fpga_dn,
				clk  => videoio_clk,
				cken => cken,
				init_req => init_req,
				init_rdy => init_rdy);
			led <= (others => '1'); --tp(9 to 16);
		end generate;
			
		monitor_g : if monitor generate 
			signal tp : std_logic_vector(1 to 32);
			signal cken : std_logic;
		begin

			--tp(1 to 3) <= tp_phy (1 to 3);
			usbphy_e : entity hdl4fpga.usbphy
		   	generic map (
				-- monitor => true,
				oversampling => usb_oversampling)
			port map (
				tp    => tp,
				dp    => usb_fpga_dp,
				dn    => usb_fpga_dn,
				clk   => videoio_clk,
				cken  => cken);
	
			process (videoio_clk)
			begin
				if rising_edge(videoio_clk) then
					if up='1' then
						fltr_on <= '0';
					elsif down='1' then
						fltr_on <= '1';
					end if;
				end if;
			end process;
	
			usbfltrsof_e : entity hdl4fpga.usbfltr_sof
			port map (
				usb_clk  => videoio_clk,
				usb_cken => cken,
				phy_en   => tp(1),
				phy_bs   => tp(2),
				phy_d    => tp(3),
				fltr_on  => fltr_on,
				fltr_en  => fltr_en,
				fltr_bs  => fltr_bs,
				fltr_d   => fltr_d);
	
				ser_clk     <= videoio_clk;
				ser_frm     <= fltr_en; 
				ser_irdy    <= not fltr_bs;
				ser_data(0) <= fltr_d;
		end generate;

		-- led(4) <= tp(4);
		-- led(3) <= tp(5);
		-- led(2) <= cfgd;
	end generate;

	ipoe_g : if io_link="io_ipoe" generate
		signal rmii_clk  : std_logic;
		signal rmii_rxdv : std_logic;
		signal rmii_rxd  : std_logic_vector(0 to 2-1);
		alias md_btn  is fire1;

		signal md_clk : std_logic;
		signal md_req : std_logic := '0';
		signal md_rdy : std_logic := '0';
		signal md_t   : std_logic;
		signal tp     : std_logic_vector(1 to 32);

		signal fcs_sb : std_logic;
		signal fcs_vld : std_logic;
	begin

		process(rmii_crsdv, rmii_clk)
			variable shr_dv  : unsigned(0 to 2-1);
			variable shr_rxd : unsigned(0 to 2*2-1);
		begin
			if rising_edge(rmii_clk) then
				case std_logic_vector'(shr_dv(0), shr_dv(1), rmii_crsdv) is
				when "000"|"001"|"011" =>
					rmii_rxdv <= '0';
				when others =>
					rmii_rxdv <=  '1';
				end case;
				rmii_rxd <= std_logic_vector(shr_rxd(0 to 2-1));

				shr_rxd(0 to 2-1) := unsigned'(rmii_rx0 & rmii_rx1);
				shr_rxd   := rotate_left(shr_rxd, 2);
				shr_dv(0) := rmii_crsdv;
				shr_dv    := rotate_left(shr_dv, 1);
			end if;
		end process;

		rmii_clk <= not rmii_nintclk;
		mii_e : entity hdl4fpga.link_mii
		generic map (
			hwaddr     => x"00_40_00_01_02_03",
			ipv4addr   => aton("192.168.0.14"),
			n          => 2)
		port map (
			tp         => tp,
			si_frm     => si_frm,
			si_irdy    => si_irdy,
			si_trdy    => si_trdy,
			si_data    => si_data,
		
			so_frm     => so_frm,
			so_irdy    => so_irdy,
			so_trdy    => so_trdy,
			so_data    => so_data,
			dhcp_btn   => md_btn,
			mii_txc    => rmii_clk,
			mii_txen   => rmii_tx_en,
			mii_txd(0) => rmii_tx0,
			mii_txd(1) => rmii_tx1,

			fcs_sb     => fcs_sb,
			fcs_vld    => fcs_vld,
			mii_rxc    => rmii_clk,
			mii_rxdv   => rmii_rxdv,
			mii_rxd    => rmii_rxd);

		rmii_nintclk <= 'Z';
		rmii_crsdv   <= 'Z';
		rmii_rx0     <= 'Z';
		rmii_rx1     <= 'Z';

		mdclk_p : process(rmii_clk)
			constant max : natural := (50+2*2-1)/(2*2)-2; -- 50MHz/(2MHz*2);
			variable cntr : integer range -1 to max;
		begin
			if rising_edge(rmii_clk) then
				if cntr < 0 then
					cntr := max;
					md_clk <= not md_clk;
				else
					cntr := cntr-1 ;
				end if;
			end if;
		end process;

		req_p : process(md_clk)
			type states is (s_rdy, s_req);
			variable state : states;
		begin
			if rising_edge(md_clk) then
				case state is
				when s_rdy =>
					if md_btn='1' then
						md_req <= not md_rdy;
						state := s_req;
					end if;
				when s_req =>
					if (md_req xor md_rdy)='0' then
						if md_btn='0' then
							state := s_rdy;
						end if;
					end if;
				end case;
			end if;
		end process;

		mdio_e : entity hdl4fpga.mdio
		port map (
			clk => md_clk,
			req => md_req,
			rdy => md_rdy,
			wr  => '1',
			dev => b"00001",
			rid => b"00000",
			din => x"1200",
			mdt => md_t);

		rmii_mdc  <= not md_clk; 
		rmii_mdio <= '0' when md_t='0' else 'Z';

		ser_clk <= rmii_clk;
		process(rmii_clk)
		begin
			if rising_edge(rmii_clk) then
				ser_frm  <= tp(1);
				ser_irdy <= '1';
				ser_data <= rmii_rxd;
				if fcs_sb='1' then
					led(7) <= fcs_vld;
				end if;
			end if;
		end process;

		process (md_clk)
			variable q : std_logic;
		begin
			if rising_edge(md_clk) then
				q := not q;
				led(0) <= q;
				led(1) <= not q;
			end if;
		end process;

		wifi_en   <= '0';
	end generate;

	video_g : if monitor generate
		ser_debug_e : entity hdl4fpga.ser_debug
		generic map (
			settings        => hdo(settings)**".video")
		port map (
			ser_clk         => ser_clk, 
			ser_frm         => ser_frm, 
			ser_irdy        => ser_irdy, 
			ser_data        => ser_data, 
			
			video_clk       => video_clk,
			video_shift_clk => video_shift_clk,
			video_hzsync    => video_hzsync,
			video_vtsync    => video_vtsync,
			video_pixel     => video_pixel,
			dvid_crgb       => dvid_crgb);
	
		ddr_g : for i in gpdi_d'range generate
			oddr_i : oddrx1f
			port map(
				sclk => video_shift_clk,
				rst  => '0',
				d0   => dvid_crgb(2*i),
				d1   => dvid_crgb(2*i+1),
				q    => gpdi_d(i));
		end generate;
	end generate;

end;
