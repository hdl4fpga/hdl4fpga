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
use hdl4fpga.hdo.all;
use hdl4fpga.ipoepkg.all;
use hdl4fpga.videopkg.all;
use hdl4fpga.sdrampkg.all;
use hdl4fpga.xc3s_profiles.all;

library unisim;
use unisim.vcomponents.all;

architecture scopeio of s3estarter is

	constant vt_step  : string := "0.152587890625e-3";  -- 2.5V/ 2.0**14 real'image() does not work on Xilinx ISE
	constant settings : string := "{"                                                             &
		"inputs:" & "2"                                                                           & ',' &
		"waveform:{"                                                                              &
			"video:{"                                                                             &
				"dcm:"     & string'(hdl4fpga.xc3s_profiles.video_dcm(".'50mhz'.'40mhz'"))        & ',' &
				"timings:" & string'(hdl4fpga.videopkg.timings_db**".'800x600'.'@60'.'40mhz'")    & ',' &
				"pixel:"   & "{R:1,G:1,B:1}}"                                                     & ',' &
			"num_of_segments:" & "2"                                                              & ',' &
			"grid:{"                                                                              &
				"width:"  & natural'image(15*32+1)                                                & ',' &
				"height:" & natural'image( 6*32+1)                                                & ',' &
				"color:"  & "0xff_ff_00_ff"                                                       & ',' &
				"background-color:" & "0xff_00_00_00}"                                            & ',' &
			"axis:{"                                                                              &
				"horizontal:{"                                                                    &
					"scales:["                                                                    &
						natural'image(     2**(0+0)*5**(0+0))                                     & ',' & -- [0]
						natural'image(     2**(0+0)*5**(0+0))                                     & ',' & -- [1]
						natural'image(2**((-1)+2+0)*5**(0+0))                                     & ',' & -- [2]
						natural'image(2**((-1)+1+0)*5**(0+1))                                     & ',' & -- [3]
						natural'image(2**((-1)+0+1)*5**(1+0))                                     & ',' & -- [4]
						natural'image(2**((-1)+1+1)*5**(1+0))                                     & ',' & -- [5]
						natural'image(2**((-1)+2+1)*5**(0+1))                                     & ',' & -- [6]
						natural'image(2**((-1)+0+1)*5**(1+1))                                     & ',' & -- [7]
						natural'image(2**((-1)+0+2)*5**(2+0))                                     & ',' & -- [8]
						natural'image(2**((-1)+1+2)*5**(2+0))                                     & ',' & -- [9]
						natural'image(2**((-1)+2+2)*5**(0+2))                                     & ',' & -- [10]
						natural'image(2**((-1)+0+2)*5**(1+2))                                     & ',' & -- [11]
						natural'image(2**((-1)+0+3)*5**(3+0))                                     & ',' & -- [12]
						natural'image(2**((-1)+1+3)*5**(3+0))                                     & ',' & -- [13]
						natural'image(2**((-1)+2+3)*5**(0+3))                                     & ',' & -- [14]
						natural'image(2**((-1)+0+3)*5**(1+3)) & ']'                               & ',' & -- [15]
					"unit:"    & "25.0e-6"                                                        & ',' &
					"color:"   & "0xff_00_00_00"                                                  & ',' &
					"background-color:" & "0xff_00_ff_ff}"                                        & ',' &
				"vertical:{"                                                                      &
					"unit:"  & "5.0e-3"                                                           & ',' &
					"width:" & natural'image(6*8)                                                 & ',' &
					"color:" & "0xff_00_00_00"                                                    & ',' &
					"background-color : 0xff_00_ff_ff}},"                                         &
			"textbox:{"                                                                           &
				"width:"     & natural'image(33*8)                                                & ',' &
				"color:"     & "0xff_ff_00_ff"                                                    & ',' &
				"background-color:" & "0xff_00_00_00}"                                            & ',' &
			"main:{"                                                                              &
				"top:23, left:3, right:0, bottom:0, vertical:0, horizontal:0, background-color: 0xff_00_00_00}" & ',' &
			"segment:{"                                                                           &
				"top: 1, left:1, right:0, bottom:1, vertical:0, horizontal:0, background-color: 0xff_ff_ff_ff}" & ',' &
			"vt:[" &
				"{text: VINA," & "step:" & vt_step & ',' & "color:" & "0xff_00_ff_ff}"            & ',' &
				"{text: VINB," & "step:" & vt_step & ',' & "color:" & "0xff_ff_ff_ff}]}"          & ',' &
		"sdram:{"                                                                                 &
			"dcm:"       & string'(hdl4fpga.xc3s_profiles.sdram_dcm(".'50mhz'.'133mhz'"))         & ',' &
			"chip_data:" & string'(hdo(sdram_db)**".MT46V16M16M-6T")                              & ',' &
			"phy_data:"  & string'(hdo(phy_db)**".xc3sg2")                                        & ',' &
			"cl:"        & "'010'}}";
			-- "}";

	constant io_link : string := "io_ipoe";
	constant baudrate : natural := 115200;

	signal sys_rst       : std_logic;
	signal sys_clk       : std_logic;

	signal video_clk     : std_logic;
	signal video_vton    : std_logic;
	signal video_pixel   : std_logic_vector(0 to settings**".video.pixel.R=8"+settings**".video.pixel.G=8"+settings**".video.pixel.B=8"-1);

	constant inputs      : natural := hdo(settings)**".inputs";
	signal input_sample  : std_logic_vector(14-1 downto 0);
	signal input_samples : std_logic_vector(inputs*input_sample'length-1 downto 0);
	signal input_clk     : std_logic;
	signal input_ena     : std_logic;

	alias  sio_clk is e_tx_clk;
	signal si_frm        : std_logic;
	signal si_irdy       : std_logic;
	signal si_data       : std_logic_vector(0 to 8-1);
	signal so_frm        : std_logic;
	signal so_irdy       : std_logic;
	signal so_trdy       : std_logic;
	signal so_end        : std_logic;
	signal so_data       : std_logic_vector(0 to 8-1);

	constant sdram_freq  : real := sdram_freq(settings**".sdram.dcm={}");
	constant bank_length : natural := hdo(settings)**".sdram.chip_data.orgz.addr.ba=1";
	constant addr_length : natural := hdo(settings)**".sdram.chip_data.orgz.addr.row=1";
	constant data_mask   : natural := hdo(settings)**".sdram.chip_data.orgz.data.dm=1";
	constant data_length : natural := hdo(settings)**".sdram.chip_data.orgz.data.dq=1";
	constant sdram_gear  : natural := hdo(settings)**".sdram.phy_data.orgz.gear=1";

	signal ctlr_rst      : std_logic;
	signal ctlr_clk      : std_logic;
	signal ctlr_clk90    : std_logic;

	signal ctlrphy_rst   : std_logic;
	signal ctlrphy_cke   : std_logic_vector((sdram_gear+1)/2-1 downto 0);
	signal ctlrphy_cs    : std_logic_vector((sdram_gear+1)/2-1 downto 0);
	signal ctlrphy_ras   : std_logic_vector((sdram_gear+1)/2-1 downto 0);
	signal ctlrphy_cas   : std_logic_vector((sdram_gear+1)/2-1 downto 0);
	signal ctlrphy_we    : std_logic_vector((sdram_gear+1)/2-1 downto 0);
	signal ctlrphy_odt   : std_logic_vector((sdram_gear+1)/2-1 downto 0);
	signal ctlrphy_b     : std_logic_vector((sdram_gear+1)/2*bank_length-1 downto 0);
	signal ctlrphy_a     : std_logic_vector((sdram_gear+1)/2*addr_length-1 downto 0);
	signal ctlrphy_dqst  : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_dqsi  : std_logic_vector(sdram_gear*data_mask-1 downto 0);
	signal ctlrphy_dqso  : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_dmi   : std_logic_vector(sdram_gear*data_mask-1 downto 0);
	signal ctlrphy_dmo   : std_logic_vector(sdram_gear*data_mask-1 downto 0);
	signal ctlrphy_dqt   : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_dqi   : std_logic_vector(sdram_gear*data_length-1 downto 0);
	signal ctlrphy_dqo   : std_logic_vector(sdram_gear*data_length-1 downto 0);
	signal ctlrphy_dqv   : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_sto   : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_sti   : std_logic_vector(sdram_gear*data_mask-1 downto 0);

begin

	clkin_ibufg : ibufg
	port map (
		I => clk_50mhz,
		O => sys_clk);

	process(sys_clk)
	begin
		if rising_edge(sys_clk) then
			sys_rst <= btn_north;
		end if;
	end process;

	videodcm_b : if string'(settings**".waveform={}") /= "{}" generate
		videodcm_i : entity hdl4fpga.xc3s_videodcm
		generic map(
			settings => hdo(settings)**".waveform.video.dcm")
		port map(
			rst       => sys_rst,
			clk       => sys_clk,
			video_clk => video_clk);
	end generate;

	sdrdcm_b : if string'(settings**".sdram={}") /= "{}" generate
		signal ctlrdcm_locked : std_logic;
	begin
		sdramdcm_i : entity hdl4fpga.xc3s_sdramdcm
		generic map (
			settings  => settings**".sdram.dcm")
		port map (
			clk        => sys_clk,
			ctlr_clk   => ctlr_clk,
			ctlr_clk90 => ctlr_clk90,
			locked     => ctlrdcm_locked);
		ctlr_rst <= not ctlrdcm_locked;
	end generate;

	spi_b: block
		signal spiclk_rd : std_logic;
		signal spiclk_fd : std_logic;
		signal sckamp_rd : std_logic;
		signal sckamp_fd : std_logic;
		signal spiclk_n : std_logic;
		signal amp_spi   : std_logic;
		signal amp_sdi   : std_logic;
		signal amp_rdy   : std_logic;
		signal adc_spi   : std_logic;
		signal ampcs     : std_logic;
		signal spi_rst   : std_logic;
		signal dac_sdi   : std_logic;
	begin

		spidcm_e : entity hdl4fpga.dfs2dfs
		generic map (
			dcm_per  => 20.0,
			dfs1_mul => 32,
			dfs1_div => 25,
			dfs2_mul => 17,
			dfs2_div => 25)
		port map(
			dcm_rst  => '0',
			dcm_clk  => sys_clk,
			dfs_clk  => input_clk,
			dcm_lck  => spi_rst);
		spiclk_n <= not sys_clk;
--		input_clk <= sys_clk;
--		spi_rst <= not dfs_rst;


		spiclk_rd <= '0' when spi_rst='0' else sckamp_rd when amp_spi='1' else '0' ;
		spiclk_fd <= '0' when spi_rst='0' else sckamp_fd when amp_spi='1' else '1' ;
		spi_mosi  <= amp_sdi when amp_spi='1' else dac_sdi;

		adcclkab_e : oddr2
		port map (
			c0 => input_clk,
			c1 => spiclk_n,
			ce => '1',
			d0 => spiclk_rd,
			d1 => spiclk_fd,
			q  => spi_sck);

		ampclkr_p : process (spi_rst, input_clk)
			variable cntr : unsigned(0 to 4-1);
		begin
			if spi_rst='0' then
				cntr := (others => '0');
				sckamp_rd <= cntr(0);
				adc_spi <= '1';
			elsif rising_edge(input_clk) then
				cntr := cntr + 1;
				sckamp_rd <= cntr(0);
				amp_cs <= ampcs;
			end if;
		end process;

		ampclkf_p : process (spi_rst, input_clk)
		begin
			if spi_rst='0' then
				sckamp_fd <= '0';
			elsif falling_edge(input_clk) then
				sckamp_fd <= sckamp_rd;
			end if;
		end process;

		ampp2sr_p : process (spi_rst, sckamp_fd)
		begin
			if spi_rst='0' then
				ampcs <= '1';
			elsif falling_edge(sckamp_fd) then
				ampcs <= not amp_rdy or not amp_spi;
			end if;
		end process;

		amp_p : process (spi_rst, sckamp_fd)
			variable cntr : unsigned(0 to 4);
			variable val  : unsigned(0 to 8-1);
		begin
			if spi_rst='0' then
				amp_spi <= '1';
				amp_rdy <= '0';
				amp_sdi <= '0';
				cntr    := to_unsigned(val'length-2,cntr'length);
				val     := B"0001_0001";
			elsif falling_edge(sckamp_fd) then
				if ampcs='0' then
					if cntr(0)='0' then
						cntr := cntr - 1;
						val  := val rol 1;
					end if;
				end if;
				amp_sdi <= val(0);
				amp_rdy <= not cntr(0);
				amp_spi <= not cntr(0) or not ampcs;
			end if;
		end process;

		adcdac_p : process (amp_spi, input_clk)
			constant p2p        : natural := 2*1550;
			constant cycle      : natural := 34;
			variable cntr       : unsigned(0 to 6) := (others => '0');
			variable adin       : unsigned(32-1 downto 0);
			variable aux        : unsigned(input_samples'range);
			variable dac_shr    : unsigned(0 to 30-1);
			variable adcdac_sel : std_logic;
			variable dac_data   : unsigned(0 to 12-1);
			variable dac_chan   : unsigned(0 to 2-1);
			variable hz_scale   : std_logic_vector(4-1 downto 0) := (others =>'0');
		begin
			if amp_spi='1' then
				cntr       := to_unsigned(cycle-2, cntr'length);
				adcdac_sel := '0';
				dac_sdi    <= '0';
				dac_cs     <= '1';
			elsif rising_edge(input_clk) then
				if cntr(0)='1' then
					if adcdac_sel ='0' then
						input_samples <= std_logic_vector(
							adin(1*16+input_sample'length-1 downto 1*16) &
							adin(0*16+input_sample'length-1 downto 0*16));
						input_ena <= not amp_spi;
						ad_conv   <= '0';
					else
						if to_integer(dac_data)=(2048+p2p/2) then
							dac_data := to_unsigned(2048-p2p/2, dac_data'length);
						else
							dac_data := dac_data + 1;
						end if;
						ad_conv <= not amp_spi;
					end if;

					if hz_scale=(hz_scale'range=> '0') then
						adcdac_sel := '0';
						ad_conv    <= '1';
					else 
						adcdac_sel := not adcdac_sel;
					end if;

					dac_shr := (1 to 10 => '-') & "001100" & dac_chan & dac_data;
					cntr    := to_unsigned(cycle-2, cntr'length);
				else
					input_ena <= '0';
					ad_conv   <= '0';
					dac_shr   := dac_shr sll 1;
					cntr      := cntr - 1;
				end if;
				adin    := adin sll 1;
				adin(0) := spi_miso;

				dac_cs  <= not adcdac_sel or amp_spi;
				dac_sdi <= dac_shr(0);
			end if;
		end process;
	end block;

	ipoe_g : if io_link="io_ipoe" generate
		signal dhcpcd_req : std_logic := '0';
		signal dhcpcd_rdy : std_logic := '0';

		signal miirx_frm  : std_logic;
		signal miirx_irdy : std_logic;
		signal miirx_data : std_logic_vector(e_rxd'range);

		signal miitx_frm  : std_logic;
		signal miitx_irdy : std_logic;
		signal miitx_trdy : std_logic;
		signal miitx_end  : std_logic;
		signal miitx_data : std_logic_vector(si_data'range);

	begin

		sync_b : block

			signal rxc_rxbus : std_logic_vector(0 to e_rxd'length);
			signal txc_rxbus : std_logic_vector(0 to e_rxd'length);
			signal dst_irdy  : std_logic;
			signal dst_trdy  : std_logic;

		begin

			process (e_rx_clk)
			begin
				if rising_edge(e_rx_clk) then
					rxc_rxbus <= e_rx_dv & e_rxd;
				end if;
			end process;

			rxc2txc_e : entity hdl4fpga.fifo
			generic map (
				max_depth  => 4,
				latency    => 0,
				dst_offset => 0,
				src_offset => 2,
				check_sov  => false,
				check_dov  => true)
			port map (
				src_clk  => e_rx_clk,
				src_data => rxc_rxbus,
				dst_clk  => e_tx_clk,
				dst_irdy => dst_irdy,
				dst_trdy => dst_trdy,
				dst_data => txc_rxbus);

			process (e_tx_clk)
			begin
				if rising_edge(e_tx_clk) then
					dst_trdy   <= to_stdulogic(to_bit(dst_irdy));
					miirx_frm  <= txc_rxbus(0);
					miirx_irdy <= txc_rxbus(0);
					miirx_data <= txc_rxbus(1 to e_rxd'length);
				end if;
			end process;
		end block;

		dhcp_p : process(e_tx_clk)
			type states is (s_request, s_wait);
			variable state : states;
		begin
			if rising_edge(e_tx_clk) then
				case state is
				when s_request =>
					if sw0='1' then
						dhcpcd_req <= not dhcpcd_rdy;
						state := s_wait;
					end if;
				when s_wait =>
					if to_bit(dhcpcd_req xor dhcpcd_rdy)='0' then
						if sw0='0' then
							state := s_request;
						end if;
					end if;
				end case;
			end if;
		end process;

		udpdaisy_e : entity hdl4fpga.sio_dayudp
		generic map (
			debug         => debug,
			my_mac        => x"00_40_00_01_02_03",
			default_ipv4a => aton("192.168.0.14"))
		port map (
			tp         => open,

			mii_clk    => sio_clk,
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

			si_frm     => so_frm,
			si_irdy    => so_irdy,
			si_trdy    => so_trdy,
			si_end     => so_end,
			si_data    => so_data,

			so_clk     => sio_clk,
			so_frm     => si_frm,
			so_irdy    => si_irdy,
			so_data    => si_data);

		desser_e: entity hdl4fpga.desser
		port map (
			desser_clk => e_tx_clk,

			des_frm    => miitx_frm,
			des_irdy   => miitx_irdy,
			des_trdy   => miitx_trdy,
			des_data   => miitx_data,

			ser_irdy   => open,
			ser_data   => e_txd);

		e_txen  <= miitx_frm and not miitx_end;

	end generate;

	stactlr_g : if io_link="" generate
		signal tp : std_logic_vector(1 to 32);
		signal miilnk_frm  : std_logic := '0';
		signal miilnk_irdy : std_logic := '0';
		signal miilnk_trdy : std_logic := '1';
		signal miilnk_data : std_logic_vector(si_data'range);
		signal left        : std_logic;
		signal right       : std_logic;
		signal up          : std_logic;
		signal down        : std_logic;

		signal rot         : std_logic_vector(0 to 2-1);
		signal derot       : std_logic_vector(0 to 2-1);
		signal rot_left    : std_logic;
		signal rot_right   : std_logic;
	begin

		e_txen <= 'Z';
		e_txd  <= (others => 'Z');
		rot <= (not rot_a, not rot_b);
		debounce_g : for i in rot'range  generate
			process (sio_clk)
				constant rebounds0 : natural := 6;
				constant rebounds1 : integer := -1;
				type states is (s_pressed, s_released);
				variable state : states;
				variable cntr  : integer range -1 to max(rebounds0, rebounds1);
				variable edge  : std_logic;
			begin
				if rising_edge(sio_clk) then
					case state is
					when s_pressed =>
						derot(i) <= '1';
						if rot(i)='0' then
							if cntr < 0 then
								cntr := 0;
								derot(i) <= '0';
								state := s_released;
							elsif (video_vton and not edge)='1' or debug then
								cntr := cntr - 1;
							end if;
						elsif cntr < rebounds0 then
							if (video_vton and not edge)='1' or debug then
								cntr := cntr + 1;
							end if;
						end if;
					when s_released =>
						derot(i) <= '0';
						if rot(i)='1' then
							if cntr >= rebounds1 then
								cntr := rebounds0;
								derot(i) <= '1';
								state := s_pressed;
							elsif (video_vton and not edge)='1' or debug then
								cntr := cntr + 1;
							end if;
						elsif cntr >= 0 then
							if (video_vton and not edge)='1' or debug then
								cntr := cntr - 1;
							end if;
						end if;
					end case;
					edge := video_vton;
				end if;
			end process;
		end generate;

		process (sio_clk)
			type states is (s_dtnt, s_left01, s_left11, s_left10, s_right10, s_right11, s_right01);
			--                    0       1         2         3         4         5           6          7 
			variable state : states;
			variable edge  : std_logic;
			variable lf : std_logic;
			variable rt : std_logic;
		begin
			if rising_edge(sio_clk) then
				lf := '0';
				rt := '0';
				case state is
				when s_dtnt =>
					case derot is
					when "01" =>
						state := s_left01;
					when "10" =>
						state := s_right10;
					when "11" =>
					when others =>
					end case;
				when s_left01 =>
					case derot is
					when "00" =>
						state := s_dtnt;
					when "10" =>
						lf := '1';
						state := s_dtnt;
					when "11" => 
						state := s_left11;
					when others =>
					end case;
				when s_left11 =>
					case derot is
					when "00" =>
						lf := '1';
						state := s_dtnt;
					when "10" =>
						state := s_left10;
					when "11" =>
					when others =>
						state := s_dtnt;
					end case;
				when s_left10 =>
					case derot is
					when "00" =>
						lf := '1';
						state := s_dtnt;
					when "10" =>
					when others =>
						state := s_dtnt;
					end case;
				when s_right10 =>
					case derot is
					when "00" =>
						state := s_dtnt;
					when "01" =>
						rt := '1';
						state := s_dtnt;
					when "11" => 
						state := s_right11;
					when others =>
					end case;
				when s_right11 =>
					case derot is
					when "00" =>
						rt := '1';
						state := s_dtnt;
					when "01" =>
						state := s_right01;
					when "11" =>
					when others =>
						state := s_dtnt;
					end case;
				when s_right01 =>
					case derot is
					when "00" =>
						rt := '1';
						state := s_dtnt;
					when "01" =>
					when others =>
						state := s_dtnt;
					end case;
				when others =>
				end case;

				if lf='1' then
					rot_left <= '1';
				elsif (video_vton and not edge)='1' then
					rot_left <= '0';
				end if;

				if rt='1' then
					rot_right <= '1';
				elsif (video_vton and not edge)='1' then
					rot_right <= '0';
				end if;

				edge := video_vton;
			end if;
		end process;

		led <= tp(1 to 8);
		-- led <= rot_left & b"000_000" & rot_right;
   		up    <= btn_north or rot_right;
   		down  <= btn_south or rot_left;
   		-- up    <= btn_north;
   		-- down  <= btn_south;
   		left  <= btn_west;
   		right <= btn_east or rot_center;
		stactlr_e : entity hdl4fpga.scopeio_stactlr
		generic map (
			settings => settings)
		port map (
			tp => tp,
			left    => left,
			up      => up,
			down    => down,
			right   => right,
			video_vton => video_vton,
			sio_clk => sio_clk,
			si_frm  => miilnk_frm,
			si_irdy => miilnk_irdy,
			si_trdy => miilnk_trdy,
			si_data => miilnk_data,
			so_frm  => si_frm,
			so_irdy => si_irdy,
			so_data => si_data);
	end generate;

	scopeio_e : entity hdl4fpga.scopeio
	generic map (
		debug       => debug,
		profile     => 1,
		sdram_freq  => sdram_freq,
		settings    => settings)
	port map (
		-- tp => tp,
		sio_clk     => sio_clk,
		si_frm      => si_frm,
		si_irdy     => si_irdy,
		si_data     => si_data,
		so_frm      => so_frm,
		so_irdy     => so_irdy,
		so_trdy     => so_trdy,
		so_end      => so_end,
		so_data     => so_data,
		input_clk   => input_clk,
		input_data  => input_samples,

		ctlr_clk     => ctlr_clk,
		ctlr_rst     => ctlr_rst,
		ctlr_bl      => "001",
		ctlr_cl      => settings**".sdram.cl=000",

		ctlrphy_rst  => ctlrphy_rst,
		ctlrphy_cke  => ctlrphy_cke(0),
		ctlrphy_cs   => ctlrphy_cs(0),
		ctlrphy_ras  => ctlrphy_ras(0),
		ctlrphy_cas  => ctlrphy_cas(0),
		ctlrphy_we   => ctlrphy_we(0),
		ctlrphy_b    => ctlrphy_b,
		ctlrphy_a    => ctlrphy_a,
		ctlrphy_dqst => ctlrphy_dqst,
		ctlrphy_dqso => ctlrphy_dqso,
		ctlrphy_dmi  => ctlrphy_dmi,
		ctlrphy_dmo  => ctlrphy_dmo,
		ctlrphy_dqi  => ctlrphy_dqi,
		ctlrphy_dqt  => ctlrphy_dqt,
		ctlrphy_dqo  => ctlrphy_dqo,
		ctlrphy_dqv  => ctlrphy_dqv,
		ctlrphy_sto  => ctlrphy_sto,
		ctlrphy_sti  => ctlrphy_sti,
		video_clk   => video_clk,
		video_pixel => video_pixel,
		video_hsync => vga_hsync,
		video_vsync => vga_vsync,
		video_vton  => video_vton);

	-- vga_hsync <= '0';
	-- vga_vsync <= '0';
	vga_red   <= video_pixel(3*8-1);
	vga_green <= video_pixel(2*8-1);
	vga_blue  <= video_pixel(1*8-1);

	sdramphy_g : if string'(hdo(settings)**".sdram={}") /= "{}" generate
		signal ctlrphy_wlreq : std_logic;
		signal ctlrphy_wlrdy : std_logic;
		signal ctlrphy_rlreq : std_logic;
		signal ctlrphy_rlrdy : std_logic;
		signal sdram_cke     : std_logic_vector(0 to 0);
		signal sdram_cs      : std_logic_vector(0 to 0);
		signal ddr_odt       : std_logic_vector(0 to 0);
		signal sd_clk        : std_logic_vector(0 downto 0);
	begin
		ctlrphy_wlreq <= to_stdulogic(to_bit(ctlrphy_wlrdy));
		ctlrphy_rlreq <= to_stdulogic(to_bit(ctlrphy_rlrdy));

		sdrphy_e : entity hdl4fpga.xc_sdrphy
		generic map (
			-- dqs_delay   => (0 to 0 => 0 ns),
			-- dqi_delay   => (0 to 0 => 0 ns),
			device      => hdo(settings)**".sdram.phy_data.device",
			bank_size   => sd_ba'length,
			addr_size   => sd_a'length,
			word_size   => sd_dq'length,
			byte_size   => sd_dq'length/sd_dm'length,
			gear        => sdram_gear,
			loopback    => false,
			bypass      => true,
			rd_fifo     => true,
			rd_align    => true)
		port map (
			rst         => ctlr_rst,
			iod_clk     => ctlr_clk,
			clk         => ctlr_clk,
			clk_shift   => ctlr_clk90,

			phy_wlreq   => ctlrphy_wlreq,
			phy_wlrdy   => ctlrphy_wlrdy,
			phy_rlreq   => ctlrphy_rlreq,
			phy_rlrdy   => ctlrphy_rlrdy,
			sys_cke     => ctlrphy_cke,
			sys_cs      => ctlrphy_cs,
			sys_ras     => ctlrphy_ras,
			sys_cas     => ctlrphy_cas,
			sys_we      => ctlrphy_we,
			sys_b       => ctlrphy_b,
			sys_a       => ctlrphy_a,
			sys_dqsi    => ctlrphy_dqso,
			sys_dqst    => ctlrphy_dqst,
			sys_dqso    => ctlrphy_dqsi,
			sys_dmi     => ctlrphy_dmo,
			sys_dmo     => ctlrphy_dmi,
			sys_dqi     => ctlrphy_dqo,
			sys_dqt     => ctlrphy_dqt,
			sys_dqo     => ctlrphy_dqi,
			sys_odt     => ctlrphy_odt,
			sys_dqv     => ctlrphy_dqv,
			sys_sti     => ctlrphy_sto,
			sys_sto     => ctlrphy_sti,

			sdram_clk     => sd_clk,
			sdram_cke     => sdram_cke,
			sdram_cs      => sdram_cs,
			sdram_odt     => ddr_odt,
			sdram_ras     => sd_ras,
			sdram_cas     => sd_cas,
			sdram_we      => sd_we,
			sdram_b       => sd_ba,
			sdram_a       => sd_a,

			sdram_dm      => sd_dm,
			sdram_dq      => sd_dq,
			sdram_dqs     => sd_dqs);

		sdram_clk_i : obufds
		generic map (
			iostandard => "DIFF_SSTL2_I")
		port map (
			i  => sd_clk(0),
			o  => sd_ck_p,
			ob => sd_ck_n);

		sd_cke <= sdram_cke(0);
		sd_cs  <= sdram_cs(0);

	end generate;

	nosdram_g : if string'(hdo(settings)**".sdram={}") = "{}" generate
		ddr_clk_i : obufds
		generic map (
			iostandard => "DIFF_SSTL2_I")
		port map (
			i  => 'Z',
			o  => sd_ck_p,
			ob => sd_ck_n);

		sd_cke    <= 'Z';
		sd_cs     <= 'Z';
		sd_ras    <= 'Z';
		sd_cas    <= 'Z';
		sd_we     <= 'Z';
		sd_ba     <= (others => 'Z');
		sd_a      <= (others => 'Z');
		sd_dm     <= (others => 'Z');
		sd_dqs    <= (others => 'Z');
		sd_dq     <= (others => 'Z');
	end generate;

	-- Ethernet Transceiver --
	--------------------------

	e_txen <= 'Z';
	e_mdc  <= '0';
	e_mdio <= 'Z';
	e_txd_4 <= '0';

	amp_shdn <= '0';
	dac_clr <= '1';
	sf_ce0 <= '1';
	fpga_init_b <= '0';
	spi_ss_b <= '0';

	-- led0 <= '1';
	-- led1 <= '1';
	-- led2 <= '1';
	-- led3 <= '1';
	-- led4 <= '1';
	-- led5 <= '1';
	-- led6 <= '1';
	-- led7 <= '1';

	rs232_dte_txd <= 'Z';
	rs232_dce_txd <= 'Z';
end;
