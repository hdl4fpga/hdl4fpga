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
use ieee.math_real.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.hdo.all;
use hdl4fpga.ipoepkg.all;
use hdl4fpga.sdrampkg.all;
use hdl4fpga.videopkg.all;
use hdl4fpga.scopeiopkg.all;
use hdl4fpga.xc7a_profiles.all;

library unisim;
use unisim.vcomponents.all;

architecture scopeio of arty is

	constant vt_step  : real := 1.0/2.0**16; -- Volts
	constant settings : string := "{" &   
		"inputs:" & "9"                                                                                        & ',' &
		"waveform:{"                                                                                           &
			"video:{"                                                                                          &
				"dcm:"     & string'(hdl4fpga.xc7a_profiles.video_dcm(".'100mhz'.'64mhz'"))                   & ',' &
				"timings:" & string'(hdl4fpga.videopkg.timings_db**".'1920x1080'.'@60'.'150mhz'")              & ',' &
				"pixel:"   & "{R:8,G:8,B:8}}"                                                                  & ',' &
			"max_delay:"       & natural'image(2**14)                                                          & ',' &
			"min_storage:"     & "256"                                                                         & ',' & -- samples, storage size will be equal or larger than this
			"num_of_segments:" & "4"                                                                           & ',' &
			"grid:{"                                                                                           &
				"width:"  & natural'image(50*32+1)                                                             & ',' &
				"height:" & natural'image( 8*32+1)                                                             & ',' &
				"color:"  & "0xff_ff_00_ff"                                                                    & ',' &
				"background-color:" & "0xff_00_00_00}"                                                         & ',' &
			"axis:{"                                                                                           &
				"horizontal:{"                                                                                 &
					"unit:"    & "31.25e-6"                                                                    & ',' &
					"scales:["                                                                                 &
						natural'image(2**(0+0)*5**(0+0))                                                       & ',' & -- [0]
						natural'image(2**(0+0)*5**(0+0))                                                       & ',' & -- [1]
						natural'image(2**(0+0)*5**(0+0))                                                       & ',' & -- [2]
						natural'image(2**(0+0)*5**(0+0))                                                       & ',' & -- [3]
						natural'image(2**(0+0)*5**(0+0))                                                       & ',' & -- [4]
						natural'image(2**(1+0)*5**(0+0))                                                       & ',' & -- [5]
						natural'image(2**(2+0)*5**(0+0))                                                       & ',' & -- [6]
						natural'image(2**(0+0)*5**(1+0))                                                       & ',' & -- [7]
						natural'image(2**(0+1)*5**(0+1))                                                       & ',' & -- [8]
						natural'image(2**(1+1)*5**(0+1))                                                       & ',' & -- [9]
						natural'image(2**(2+1)*5**(0+1))                                                       & ',' & -- [10]
						natural'image(2**(0+1)*5**(1+1))                                                       & ',' & -- [11]
						natural'image(2**(0+2)*5**(0+2))                                                       & ',' & -- [12]
						natural'image(2**(1+2)*5**(0+2))                                                       & ',' & -- [13]
						natural'image(2**(2+2)*5**(0+2))                                                       & ',' & -- [14]
						natural'image(2**(0+2)*5**(1+2)) & ']'                                                 & ',' &  -- [15]
					"color:"   & "0xff_00_00_00"                                                               & ',' &
					"background-color:" & "0xff_00_ff_ff}"                                                     & ',' &
				"vertical:{"                                                                                   &
					"unit:"  & "2.0e-3"                                                                        & ',' &
					"width:" & natural'image(6*8)                                                              & ',' &
					"color:" & "0xff_00_00_00"                                                                 & ',' &
					"background-color : 0xff_00_ff_ff}},"                                                      &
			"textbox:{"                                                                                        &
				"width:"     & natural'image(33*8)                                                             & ',' &
				"color:"     & "0xff_ff_00_ff"                                                                 & ',' &
				"background-color:" & "0xff_00_00_00}"                                                         & ',' &
			"main:{"                                                                                           &
				"top:5, left:1, right:0, bottom:0, vertical:1, horizontal:1, background-color: 0xff_00_00_00}" & ',' &
			"segment:{"                                                                                        &
				"top:1, left:1, right:1, bottom:1, vertical:0, horizontal:1, background-color: 0xff_ff_ff_ff}" & ',' &
			"vt:["                                                                                             &
				"{text: 'V P+ V N-', " & "step:" & real'image(vt_step)      & ',' & "color: 0xff_00_ff_ff}"    & ',' & -- vt(0)
				"{text: 'A6+  A7-',  " & "step:" & real'image(vt_step)      & ',' & "color: 0xff_ff_ff_ff}"    & ',' & -- vt(1)
				"{text: 'A8+  A9-',  " & "step:" & real'image(vt_step)      & ',' & "color: 0xff_00_ff_ff}"    & ',' & -- vt(2)
				"{text: 'A10+ A11-', " & "step:" & real'image(vt_step)      & ',' & "color: 0xff_ff_ff_ff}"    & ',' & -- vt(3)
				"{text: 'A0',"         & "step:" & real'image(3.33*vt_step) & ',' & "color: 0xff_00_ff_ff}"    & ',' & -- vt(4)
				"{text: 'A1',"         & "step:" & real'image(3.33*vt_step) & ',' & "color: 0xff_ff_ff_ff}"    & ',' & -- vt(5)
				"{text: 'A2',"         & "step:" & real'image(3.33*vt_step) & ',' & "color: 0xff_00_ff_ff}"    & ',' & -- vt(6)
				"{text: 'A3',"         & "step:" & real'image(3.33*vt_step) & ',' & "color: 0xff_ff_ff_ff}"    & ',' & -- vt(7)
				"{text: 'A4',"         & "step:" & real'image(3.33*vt_step) & ',' & "color: 0xff_00_ff_ff}]}"  & ',' & -- vt(8)
		"sdram:{"                                                                                              &
			"dcm:"       & string'(hdl4fpga.xc7a_profiles.sdram_dcm(".'100mhz'.'400mhz'"))                     & ',' &
			"chip_data:" & string'(hdo(sdram_db)**".MT41K128M16-125")                                          & ',' &
			"phy_data:"  & string'(hdo(phy_db)**".xc7vg4")                                                     & ',' &
			"cwl:"       & "'000'"                                              & ',' &
			"cl:"        & "'0100'}}";

	constant io_link : string := "io_ipoe";

	signal sys_rst         : std_logic;
	alias sys_clk is gclk100;

	signal so_frm          : std_logic;
	signal so_irdy         : std_logic := '1';
	signal so_trdy         : std_logic := '1';
	signal so_data         : std_logic_vector(0 to 8-1);
	signal si_frm          : std_logic;
	signal si_irdy         : std_logic := '1';
	signal si_trdy         : std_logic := '1';
	signal si_end          : std_logic;
	signal si_data         : std_logic_vector(0 to 8-1);

	signal video_clk       : std_logic;
	signal video_hzsync    : std_logic;
	signal video_vtsync    : std_logic;
	signal video_vton      : std_logic;
	signal video_blank     : std_logic;
	signal video_pixel     : std_logic_vector(settings**".video.pixel.R=8"+settings**".video.pixel.G=8"+settings**".video.pixel.B=8"-1 downto 0);
	signal dvid_crgb       : std_logic_vector(4*settings**".video.gear=1" downto 0);

	constant inputs        : natural := hdo(settings)**".inputs";
	signal input_clk       : std_logic;
	signal input_lck       : std_logic;
	signal input_ena       : std_logic;
	signal input_sample    : std_logic_vector(16-1 downto 0);
	signal input_samples   : std_logic_vector(0 to inputs*input_sample'length-1);
	signal input_maxchn    : std_logic_vector(4-1 downto 0);

	signal xadccfg_req     : bit;
	signal xadccfg_rdy     : bit;

	signal miilnk_frm      : std_logic := '0';
	signal miilnk_irdy     : std_logic := '1';
	signal miilnk_trdy     : std_logic := '1';
	signal miilnk_data     : std_logic_vector(si_data'range);

	signal iolink_frm      : std_logic;
	signal iolink_irdy     : std_logic;
	signal iolink_trdy     : std_logic := '1';
	signal iolink_data     : std_logic_vector(si_data'range);

	constant bank_length   : natural := hdo(settings)**".sdram.chip_data.orgz.addr.ba=1";
	constant addr_length   : natural := hdo(settings)**".sdram.chip_data.orgz.addr.row=1";
	constant data_mask     : natural := hdo(settings)**".sdram.chip_data.orgz.data.dm=1";
	constant data_length   : natural := hdo(settings)**".sdram.chip_data.orgz.data.dq=1";
	constant sdram_gear    : natural := hdo(settings)**".sdram.phy_data.orgz.gear=1";

	signal ctlr_clk        : std_logic;
	signal ctlr_clkx2      : std_logic;
	signal ctlr_clk90      : std_logic;
	signal ctlr_clk90x2    : std_logic;
	signal ctlr_rst        : std_logic;
	signal ctlr_rst90      : std_logic;

	signal iodctrl_rst     : std_logic;
	signal iodctrl_clk     : std_logic;
	signal iodctrl_rdy     : std_logic;

	signal ctlrphy_frm     : std_logic;
	signal ctlrphy_trdy    : std_logic;
	signal ctlrphy_locked  : std_logic;
	signal ctlrphy_ini     : std_logic;
	signal ctlrphy_rw      : std_logic;
	signal ctlrphy_wlreq   : std_logic;
	signal ctlrphy_wlrdy   : std_logic;
	signal ctlrphy_rlreq   : std_logic;
	signal ctlrphy_rlrdy   : std_logic;

	signal ctlrphy_rst     : std_logic_vector(0 to (sdram_gear+1)/2-1);
	signal ctlrphy_cke     : std_logic_vector(0 to (sdram_gear+1)/2-1);
	signal ctlrphy_cs      : std_logic_vector(0 to (sdram_gear+1)/2-1);
	signal ctlrphy_ras     : std_logic_vector(0 to (sdram_gear+1)/2-1);
	signal ctlrphy_cas     : std_logic_vector(0 to (sdram_gear+1)/2-1);
	signal ctlrphy_we      : std_logic_vector(0 to (sdram_gear+1)/2-1);
	signal ctlrphy_odt     : std_logic_vector(0 to (sdram_gear+1)/2-1);
	signal ctlrphy_cmd     : std_logic_vector(0 to 3-1);
	signal ctlrphy_b       : std_logic_vector((sdram_gear+1)/2*bank_length-1 downto 0);
	signal ctlrphy_a       : std_logic_vector((sdram_gear+1)/2*addr_length-1 downto 0);
	signal ctlrphy_dqst    : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_dqso    : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_dmi     : std_logic_vector(sdram_gear*data_mask-1 downto 0);
	signal ctlrphy_dmo     : std_logic_vector(sdram_gear*data_mask-1 downto 0);
	signal ctlrphy_dqt     : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_dqi     : std_logic_vector(sdram_gear*data_length-1 downto 0);
	signal ctlrphy_dqo     : std_logic_vector(sdram_gear*data_length-1 downto 0);
	signal ctlrphy_dqv     : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_sto     : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_sti     : std_logic_vector(sdram_gear*data_mask-1 downto 0);

	signal ddr_b           : std_logic_vector(bank_length-1 downto 0);
	signal ddr_a           : std_logic_vector(addr_length-1 downto 0);
	signal ddr_cke         : std_logic_vector(0 to 0);
	signal ddr_cs          : std_logic_vector(0 to 0);
	signal ddr_odt         : std_logic_vector(0 to 0);

	signal ddr3_clk        : std_logic_vector(1-1 downto 0);
	signal ddr3_dqst       : std_logic_vector(data_mask-1 downto 0);
	signal ddr3_dqso       : std_logic_vector(data_mask-1 downto 0);
	signal ddr3_dqsi       : std_logic_vector(data_mask-1 downto 0);
	signal ddr3_dqo        : std_logic_vector(data_length-1 downto 0);
	signal ddr3_dqt        : std_logic_vector(data_length-1 downto 0);

	constant bufiog        : boolean  := true;

	signal tp_sdrphy       : std_logic_vector(1 to 32);
	alias sio_clk is eth_tx_clk;
begin

	sys_rst <= '0';

	dcm_e : block
		signal video_clkfb : std_logic;
		signal video_lck   : std_logic;
		signal adc1_rst    : std_logic;
		signal adc1_clkfb  : std_logic;
		signal adc1_clkin  : std_logic;
		signal adc1_lck    : std_logic;
		signal adc2_rst    : std_logic;
		signal adc2_clkfb  : std_logic;
		signal adc2_clkin  : std_logic;
	begin
		video_i : mmcme2_base
		generic map (
			clkin1_period    => 10.0,
			clkfbout_mult_f  => 12.0,
			clkout0_divide_f =>  8.0,
			clkout1_divide   => 75,
			bandwidth        => "LOW")
		port map (
			pwrdwn   => '0',
			rst      => '0',
			clkin1   => sys_clk,
			clkfbin  => video_clkfb,
			clkfbout => video_clkfb,
			clkout0  => video_clk,
			clkout1  => adc1_clkin,
			locked   => video_lck);

		adc1_rst <= not video_lck;
		adc1_i : mmcme2_base
		generic map (
			clkin1_period    => 10.0*75.0/12.0,
			clkfbout_mult_f  => 13.0*4.0,
			clkout0_divide_f => 25.0,
			bandwidth        => "LOW")
		port map (
			pwrdwn   => '0',
			rst      => adc1_rst,
			clkin1   => adc1_clkin,
			clkfbin  => adc1_clkfb,
			clkfbout => adc1_clkfb,
			clkout0  => adc2_clkin,
			locked   => adc1_lck);

		adc2_rst <= not adc1_lck;
		adc2_i : mmcme2_base
		generic map (
			clkin1_period    => (10.0*75.0/12.0)*25.0/(13.0*4.0),
			clkfbout_mult_f  => 32.0,
			clkout0_divide_f => 10.0,
			bandwidth        => "LOW")
		port map (
			pwrdwn   => '0',
			rst      => adc2_rst,
			clkin1   => adc2_clkin,
			clkfbin  => adc2_clkfb,
			clkfbout => adc2_clkfb,
			clkout0  => input_clk,
			locked   => input_lck);
	end block;
   
	sdrampll_g : if string'(settings**".sdram") /= "" generate
		sdramdcm_i : entity hdl4fpga.xc7a_sdramdcm
		generic map (
			settings  => settings**".sdram.dcm")
		port map (
			rst          => sys_rst,
			clk          => sys_clk,
			ctlr_clk     => ctlr_clk,
			ctlr_clkx2   => ctlr_clkx2,
			ctlr_clk90   => ctlr_clk90,
			ctlr_clk90x2 => ctlr_clk90x2,
			ctlr_rst     => ctlr_rst,
			ctlr_rst90   => ctlr_rst90);
	end generate;

	process (sys_clk)
		variable div : unsigned(0 to 1) := (others => '0');
	begin
		if rising_edge(sys_clk) then
			div := div + 1;
			eth_ref_clk <= div(0);
		end if;
	end process;

	ipoe_g : if io_link="io_ipoe" generate
		mii_e : entity hdl4fpga.link_mii
		generic map (
			rmii          => false,
			default_mac   => x"00_40_00_01_02_03",
			default_ipv4a => aton("192.168.0.14"),
			n             => eth_rxd'length)
		port map (
			si_frm     => si_frm,
			si_irdy    => si_irdy,
			si_trdy    => si_trdy,
			si_end     => si_end,
			si_data    => si_data,
		
			so_frm     => iolink_frm,
			so_irdy    => iolink_irdy,
			so_trdy    => iolink_trdy,
			so_data    => iolink_data,
			dhcp_btn   => btn0,
			mii_txc    => eth_tx_clk,
			mii_txen   => eth_tx_en,
			mii_txd    => eth_txd,

			mii_rxc    => eth_rx_clk,
			mii_rxdv   => eth_rx_dv, 
			mii_rxd    => eth_rxd);   
	end generate;

	stactlr_g : if io_link="" generate
		stactlr_e : entity hdl4fpga.scopeio_stactlr
		generic map (
			debug  => debug,
			settings => settings)
		port map (
			left    => btn(3),
			up      => btn(2),
			down    => btn(1),
			right   => btn(0),
			video_vton => video_vton,
			sio_clk => sio_clk,
			si_frm  => miilnk_frm,
			si_irdy => miilnk_irdy,
			si_trdy => miilnk_trdy,
			si_data => miilnk_data,
			so_frm  => iolink_frm,
			so_irdy => iolink_irdy,
			so_trdy => iolink_trdy,
			so_data => iolink_data);
	end generate;

	inputs_b : block
		constant max_delay     : natural := 2**14;
		constant hzoffset_bits : natural := unsigned_num_bits(max_delay-1);
		constant mux_sampling  : natural := 10;

		signal rgtr_id   : std_logic_vector(8-1 downto 0);
		signal rgtr_dv   : std_logic;
		signal rgtr_data : std_logic_vector(0 to 4*32-1);
		signal rgtr_revs : std_logic_vector(rgtr_data'reverse_range);

		signal hz_dv      : std_logic;
		signal hz_scale   : std_logic_vector(4-1 downto 0);
		signal hz_slider  : std_logic_vector(hzoffset_bits-1 downto 0);
		signal opacity    : unsigned(0 to inputs-1);
		signal opacity_frm  : std_logic;
		signal opacity_data : std_logic_vector(si_data'range);
	begin

		sio_sin_e : entity hdl4fpga.sio_sin
		port map (
			sin_clk   => sio_clk,
			sin_frm   => iolink_frm,
			sin_irdy  => iolink_irdy,
			sin_data  => iolink_data,
			rgtr_dv   => rgtr_dv,
			rgtr_id   => rgtr_id,
			rgtr_data => rgtr_data);
		rgtr_revs <= reverse(rgtr_data,8);

		hzaxis_e : entity hdl4fpga.scopeio_rgtrhzaxis
		port map (
			rgtr_clk  => sio_clk,
			rgtr_dv   => rgtr_dv,
			rgtr_id   => rgtr_id,
			rgtr_data => rgtr_revs,

			hz_dv     => hz_dv,
			hz_scale  => hz_scale,
			hz_offset => hz_slider);

		process (hz_scale)
			variable no_inputs : natural range 0 to mux_sampling-1;
		begin
			case hz_scale is
			when x"0" =>
				no_inputs := mnm(inputs-1, 1-1);
			when x"1" =>
				no_inputs := mnm(inputs-1, 2-1);
			when x"2" =>
				no_inputs := mnm(inputs-1, 4-1);
			when x"3" =>
				no_inputs := mnm(inputs-1, 5-1);
			when others =>
				no_inputs := 10-1;
			end case;
			for i in opacity'range loop
				if i <= no_inputs then
					opacity(i) <= '1';
				else
					opacity(i) <= '0';
				end if;
			end loop;
		end process;

		process (opacity, sio_clk)
			variable data : unsigned(0 to inputs*32-1);
			variable cntr : unsigned(0 to unsigned_num_bits((data'length+opacity_data'length-1)/opacity_data'length)-1);
		begin
			if rising_edge(sio_clk) then
				if cntr < (data'length+opacity_data'length-1)/opacity_data'length then
					if opacity_frm='1' then
						cntr := cntr + 1;
					end if;
				elsif hz_dv='1' then
					cntr := (others => '0');
				end if;
				if cntr < (data'length+opacity_data'length-1)/opacity_data'length then
					if opacity_frm='0' then
						opacity_frm <= not iolink_frm;
					end if;
				else
					opacity_frm <= '0';
				end if;
			end if;

			for i in 0 to inputs-1 loop
				data(0 to 32-1) := unsigned(rid_palette) & x"01" & to_unsigned(pltid_order'length+i,13) & opacity(i) & b"01";
				data := data rol 32;
			end loop;
			opacity_data <= multiplex(reverse(std_logic_vector(data),8), std_logic_vector(cntr), opacity_data'length);
		end process;

		so_frm  <= iolink_frm  when opacity_frm='0' else '1';
		so_irdy <= iolink_irdy when opacity_frm='0' else '1';
		so_data <= iolink_data when opacity_frm='0' else opacity_data;
		iolink_trdy <= si_trdy;

		process (input_clk)
		begin
			if rising_edge(input_clk) then
				if (xadccfg_req xor xadccfg_rdy)='0' then
					if input_maxchn /= to_stdlogicvector(to_bitvector(hz_scale)) then
						xadccfg_req  <= not xadccfg_rdy;
						input_maxchn <= to_stdlogicvector(to_bitvector(hz_scale));
					end if;
				end if;
			end if;
		end process;

	end block;

	scopeio_e : entity hdl4fpga.scopeio
	generic map (
		debug       => debug,
		profile     => 1,
		sdram_freq  => sdram_freq(settings**".sdram.dcm")/2.0,
		burst_length => 8,
		settings    => settings)
	port map (
		sio_clk       => sio_clk,
		si_frm        => so_frm,
		si_irdy       => so_irdy,
		si_trdy       => so_trdy,
		si_data       => so_data,
		so_frm        => si_frm,
		so_irdy       => si_irdy,
		so_trdy       => si_trdy,
		so_end        => si_end,
		so_data       => si_data,
		input_clk     => input_clk,
		input_ena     => input_ena,
		input_data    => input_samples,

		video_clk     => video_clk,
		video_pixel   => video_pixel,
		video_hzsync  => video_hzsync,
		video_vtsync  => video_vtsync,
		video_vton    => video_vton,
		video_blank   => video_blank,

		ctlr_clk      => ctlr_clk,
		ctlr_rst      => ctlr_rst,
		ctlr_bl       => "00",
		ctlr_cl       => settings**".sdram.cl",
		ctlr_cwl      => settings**".sdram.cwl",
		ctlr_rtt      => "001",
		ctlr_cmd      => ctlrphy_cmd,
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
		ctlrphy_b    => ddr_b,
		ctlrphy_a    => ddr_a,
		ctlrphy_dqst => ctlrphy_dqst,
		ctlrphy_dqso => ctlrphy_dqso,
		ctlrphy_dmi  => ctlrphy_dmi,
		ctlrphy_dmo  => ctlrphy_dmo,
		ctlrphy_dqi  => ctlrphy_dqi,
		ctlrphy_dqt  => ctlrphy_dqt,
		ctlrphy_dqo  => ctlrphy_dqo,
		ctlrphy_sto  => ctlrphy_sto,
		ctlrphy_sti  => ctlrphy_sti,
		ctlrphy_dqv  => ctlrphy_dqv);


	sdramphy_g : if string'(settings**".sdram") /= "" generate
		cgear_g : for i in 1 to sdram_gear/2-1 generate
			ctlrphy_rst(i) <= ctlrphy_rst(0);
			ctlrphy_cke(i) <= ctlrphy_cke(0);
			ctlrphy_cs(i)  <= ctlrphy_cs(0);
			ctlrphy_ras(i) <= '1';
			ctlrphy_cas(i) <= '1';
			ctlrphy_we(i)  <= '1';
			ctlrphy_odt(i) <= ctlrphy_odt(0);
		end generate;

		process (ddr_b)
		begin
			for i in ddr_b'range loop
				for j in 0 to sdram_gear/2-1 loop
					ctlrphy_b(i*sdram_gear/2+j) <= ddr_b(i);
				end loop;
			end loop;
		end process;

		process (ddr_a)
		begin
			for i in ddr_a'range loop
				for j in 0 to sdram_gear/2-1 loop
					ctlrphy_a(i*sdram_gear/2+j) <= ddr_a(i);
				end loop;
			end loop;
		end process;

		iodctrl_b : block
			signal clkfb  : std_logic;
			signal locked : std_logic;
		begin
			pll_i :  plle2_base
			generic map (
				clkin1_period  => gclk100_per*1.0e9,
				clkfbout_mult  => 12,
				clkout0_divide => 6)
			port map (
				pwrdwn   => '0',
				rst      => sys_rst,
				clkin1   => sys_clk,
				clkfbin  => clkfb,
				clkfbout => clkfb,
				clkout0  => iodctrl_clk,
				locked   => locked);
			iodctrl_rst <= not locked;
		end block;

		idelayctrl_i : idelayctrl
		port map (
			rst    => iodctrl_rst,
			refclk => iodctrl_clk,
			rdy    => iodctrl_rdy);

		sdrphy_e : entity hdl4fpga.xc_sdrphy
		generic map (
			bank_size   => ddr3_ba'length,
			addr_size   => ddr3_a'length,
			word_size   => ddr3_dq'length,
			byte_size   => ddr3_dq'length/ddr3_dm'length,
			gear        => sdram_gear,
			ba_latency  => 1,
			device     => hdo(settings)**".sdram.phy_data.device",
			-- taps        => natural(floor(sdram_tcp/((gclk100_per/2.0)/(32.0*2.0))))-1,
			taps        => natural(floor((32.0*2.0*gclk100_freq)/(sdram_freq(settings**".sdram.dcm")/2.0)))-1,
			dqs_highz   => false,
			bufio       => bufiog,
			bypass      => false,
			wr_fifo     => true)
			-- dqs_delay => (0 to 0 => 1.35 ns),
			-- dqi_delay => (0 to 0 => 0 ns),
		port map (

			tp_sel      => sw(1 downto 0),
			tp          => tp_sdrphy,

			rst         => ctlr_rst,
			rst_shift   => ctlr_rst90,
			iod_clk     => sys_clk,
			clk         => ctlr_clk,
			clk_shift   => ctlr_clk90,
			clkx2       => ctlr_clkx2,
			clkx2_shift => ctlr_clk90x2,

			phy_frm     => ctlrphy_frm,
			phy_trdy    => ctlrphy_trdy,
			phy_rw      => ctlrphy_rw,
			phy_ini     => ctlrphy_ini,

			phy_cmd     => ctlrphy_cmd,
			phy_wlreq   => ctlrphy_wlreq,
			phy_wlrdy   => ctlrphy_wlrdy,

			phy_rlreq   => ctlrphy_rlreq,
			phy_rlrdy   => ctlrphy_rlrdy,

			phy_locked   => ctlrphy_locked,

			sys_cke     => ctlrphy_cke,
			sys_rst     => ctlrphy_rst,
			sys_cs      => ctlrphy_cs,
			sys_ras     => ctlrphy_ras,
			sys_cas     => ctlrphy_cas,
			sys_we      => ctlrphy_we,
			sys_b       => ctlrphy_b,
			sys_a       => ctlrphy_a,

			sys_dqst    => ctlrphy_dqst,
			sys_dqsi    => ctlrphy_dqso,
			sys_dmi     => ctlrphy_dmo,
			sys_dmo     => ctlrphy_dmi,
			sys_dqo     => ctlrphy_dqi,
			sys_dqv     => ctlrphy_dqv,
			sys_dqt     => ctlrphy_dqt,
			sys_dqi     => ctlrphy_dqo,
			sys_odt     => ctlrphy_odt,
			sys_sti     => ctlrphy_sto,
			sys_sto     => ctlrphy_sti,

			sdram_rst   => ddr3_reset,
			sdram_clk   => ddr3_clk,
			sdram_cke   => ddr_cke,
			sdram_cs    => ddr_cs,
			sdram_ras   => ddr3_ras,
			sdram_cas   => ddr3_cas,
			sdram_we    => ddr3_we,
			sdram_b     => ddr3_ba,
			sdram_a     => ddr3_a,
			sdram_odt   => ddr_odt,
			-- sdram_dm    => ddr3_dm,
			sdram_dq    => ddr3_dq,
			sdram_dqst  => ddr3_dqst,
			sdram_dqs   => ddr3_dqsi,
			sdram_dqso  => ddr3_dqso);

		ddr3_cke <= ddr_cke(0);
		ddr3_cs  <= ddr_cs(0);
		ddr3_odt <= ddr_odt(0);
		ddr3_dm <= (others => '0');

		ddr_clk_g : for i in ddr3_clk'range generate
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

	end generate;

	nosdram_g : if string'(settings**".sdram") = "" generate

		ddr3_cs  <= '1';
		ddr3_cke <= 'Z';
		ddr3_odt <= 'Z';
		ddr3_ras <= 'Z';
		ddr3_cas <= 'Z';
		ddr3_we  <= 'Z';
		ddr3_ba  <= (others => 'Z');
		ddr3_a   <= (others => 'Z');
		ddr3_dm  <= (others => 'Z');
		ddr3_dq  <= (others => 'Z');

		ddr_clk_g : for i in ddr3_clk'range generate
			ddr_ck_obufds : obufds
			generic map (
				iostandard => "DIFF_SSTL135")
			port map (
				i  => 'Z',
				o  => ddr3_clk_p,
				ob => ddr3_clk_n);
		end generate;

		ddr_dqs_g : for i in ddr3_dqs_p'range generate
			dqsiobuf_i : iobufds
			generic map (
				iostandard => "DIFF_SSTL135")
			port map (
				t   => '1',
				i   => 'Z',
				o   => open,
				io  => ddr3_dqs_p(i),
				iob => ddr3_dqs_n(i));

		end generate;
	end generate;

	process (video_clk)
	begin
		if rising_edge(video_clk) then
			ja(1)  <= video_pixel(3*8-1);
			ja(2)  <= video_pixel(2*8-1);
			ja(3)  <= video_pixel(1*8-1);
			ja(4)  <= not video_hzsync;
			ja(10) <= not video_vtsync;
		end if;
	end process;
  
	synth_g : if tsttab generate
		constant size : natural := 2**input_sample'length;

		function sintab (
			constant size       : natural;
			constant resolution : natural := 16;
			constant unipolar   : boolean := false)
			return std_logic_vector  is
			constant pi     : real := 4.0*arctan(1.0);
			constant n : natural := 7;
			constant n1 : natural := 8;
			variable retval : std_logic_vector(0 to size*resolution-1);
		begin
			for i in 0 to size-1 loop
				retval(resolution*i to resolution*(i+1)-1) := std_logic_vector(to_signed(integer((2.0**(resolution-1)-1.0)*sin(2.0*pi*real(i)/real(size))), resolution));
				retval(resolution*i to resolution*(i+1)-1) := std_logic_vector(to_signed(2**(resolution-2), resolution));
			end loop;
			retval(resolution*n to resolution*(n+1)-1) := std_logic_vector(to_signed(2**(resolution-1)-1, resolution));
			retval(resolution*n1 to resolution*(n1+1)-1) := (others => '0');
			return retval;
		end;

		signal addr : unsigned(0 to unsigned_num_bits(size-1)-1) := (others => '0');

	begin
		process (input_clk)
		begin
			if rising_edge(input_clk) then
				addr <= addr + 1;
			end if;
		end process;

		rom_e : entity hdl4fpga.rom
		generic map (
			latency => 2,
			bitrom => sintab(size => 2**addr'length, resolution => input_sample'length))
		port map (
			clk => input_clk,
			addr => std_logic_vector(addr),
			data => input_sample);

		input_ena <= '1';
		input_samples(0*input_sample'length to (0+1)*input_sample'length-1) <= input_sample;

	end generate;

	xadcctlr_g : if not tsttab generate
		signal rst     : std_logic;
		signal di      : std_logic_vector(0 to 16-1);
		signal dwe     : std_logic;
		signal den     : std_logic;
		signal daddr   : std_logic_vector(7-1 downto 0);
		signal drdy    : std_logic;
		signal eoc     : std_logic;
		signal channel : std_logic_vector(5-1 downto 0);
		signal vauxp   : std_logic_vector(16-1 downto 0);
		signal vauxn   : std_logic_vector(16-1 downto 0);
	begin
		vauxp <= vaux_p(16-1 downto 12) & "0000" & vaux_p(8-1 downto 4) & "0000";
		vauxn <= vaux_n(16-1 downto 12) & "0000" & vaux_n(8-1 downto 4) & "0000";

		rst <= not input_lck;
		xadc_e : xadc
		generic map (
		
			INIT_40 => X"0403",
			INIT_41 => X"2000",
			INIT_42 => X"0400",
			
			INIT_48 => x"0800",
			INIT_49 => X"0000",

			INIT_4A => X"0000",
			INIT_4B => X"0000",

			INIT_4C => X"0800",
			INIT_4D => X"f0f0",

			INIT_4E => X"0000",
			INIT_4F => X"0000",

			INIT_50 => X"0000",
			INIT_51 => X"0000",
			INIT_52 => X"0000",
			INIT_53 => X"0000",
			INIT_54 => X"0000",
			INIT_55 => X"0000",
			INIT_56 => X"0000",
			INIT_57 => X"0000",
			INIT_58 => X"0000",
			INIT_5C => X"0000",
			SIM_MONITOR_FILE => "design.txt")
		port map (
			reset     => rst,
			vauxp     => vauxp,
			vauxn     => vauxn,
			vp        => v_p(0),
			vn        => v_n(0),
			convstclk => '0',
			convst    => '0',

			eos       => input_ena,
			eoc       => eoc,
			dclk      => input_clk,
			drdy      => drdy,
			channel   => channel,
			daddr     => daddr,
			den       => den,
			dwe       => dwe,
			di        => di,
			do        => input_sample); 

		sample_rgtr_p : process(input_clk)
		begin
			if rising_edge(input_clk) then
				if drdy='1' then
					case daddr(channel'range) is
					when "00011" => --  0
						input_samples(0*input_sample'length to (0+1)*input_sample'length-1) <= input_sample;
					when "10100" =>	--  4                       
						input_samples(4*input_sample'length to (4+1)*input_sample'length-1) <= input_sample;
					when "10101" =>	--  5
						input_samples(5*input_sample'length to (5+1)*input_sample'length-1) <= input_sample;
					when "10110" => --  6                        
						input_samples(6*input_sample'length to (6+1)*input_sample'length-1) <= input_sample;
					when "10111" => --  7
						input_samples(7*input_sample'length to (7+1)*input_sample'length-1) <= input_sample;
					when "11100" => -- 12
						input_samples(1*input_sample'length to (1+1)*input_sample'length-1) <= input_sample;
					when "11101" => -- 13
						input_samples(2*input_sample'length to (2+1)*input_sample'length-1) <= input_sample;
					when "11110" => -- 14
						input_samples(3*input_sample'length to (3+1)*input_sample'length-1) <= input_sample;
					when "11111" => -- 15
						input_samples(8*input_sample'length to (8+1)*input_sample'length-1) <= input_sample;
					when "10000" =>	--  1                       
					when others =>
					end case;
				end if;
			end if;
		end process;

		xadccfg_p : process(input_clk)
			type states is (s_dfltmode, s_setseq, s_contmode);
			variable state : states;
			variable data_req : bit;
			variable data_rdy : bit;
		begin
			if rising_edge(input_clk) then
				if drdy='1' then
					data_rdy := data_req;
				end if;
				if (den or dwe)='1' then
					dwe <= '0';
					den <= '0';
				elsif (data_req xor data_rdy)='0' and drdy='0' then
					if (xadccfg_rdy xor xadccfg_req)='1' then
						-- 7 Series FPGAs and Zynq-7000 All Programmable SoC 
						-- XADC Dual 12-Bit 1 MSPS Analog-to-Digital Converter User Guide
						-- Chapter 4 XADC Operating Modes Continuos Sequence Mode
						den <= '1';
						dwe <= '1';
						case state is
						when s_dfltmode =>
							daddr <= b"100_0001";
							di <= x"0000";
							state := s_setseq;
						when s_setseq =>
							daddr <= b"100_1001";
							case input_maxchn is
							when x"0" =>
								di <= x"0000";
							when x"1" =>
								di <= x"1000";
							when x"2" =>
								di <= x"7000";
							when x"3" =>
								di <= x"7010";
							when others =>
								di <= x"f0f1";
							end case;
							state := s_contmode;
						when s_contmode =>
							daddr <= b"100_0001";
							di    <= x"2000";
							xadccfg_rdy <= xadccfg_req;
							state := s_dfltmode;
						end case;
						data_req := not data_rdy;
					else
						if eoc='1' then
							daddr <= std_logic_vector(resize(unsigned(channel), daddr'length));
							den   <= '1';
							dwe   <= '0';
							data_req := not data_rdy;
						end if;
						state := s_dfltmode;
					end if;
				end if;
			end if;
		end process;
	end generate;

	tp_cntr_p : process (sys_clk)
		constant n : natural := 0;
		variable cntr : unsigned(0 to 22-1);
	begin
		if rising_edge(sys_clk) then
			(jd(9), jd(8), jd(7), jc(1), jd(10), jd(4), jd(3), jd(2), jd(1)) <= std_logic_vector(cntr(0+n to 9+n-1));
			cntr := cntr + 1;
		end if;
	end process;

	eth_rstn <= '1';
	eth_mdc  <= '0';
	eth_mdio <= '0';

end;
