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
use hdl4fpga.base.all;
use hdl4fpga.hdo.all;
use hdl4fpga.app_profiles.all;
use hdl4fpga.ecp5_profiles.all;
use hdl4fpga.videopkg.all;
use hdl4fpga.scopeiopkg.all;

library ecp5u;
use ecp5u.components.all;

architecture scopeio of ulx3s is

	--------------------------------------
	--     Set your profile here        --
	constant io_link      : io_comms     := io_usb;
	-- constant video_mode   : video_modes  := mode600p24bpp;
	constant video_mode   : video_modes  := mode720p24bpp;
	-- constant video_mode   : video_modes  := mode900p24bpp;
	-- constant video_mode   : video_modes  := mode1080p24bpp30;
	-- constant video_mode   : video_modes  := mode1080p24bpp;
	-- constant video_mode   : video_modes  := mode1440p24bpp30;
	-- constant sdram_speed  : sdram_speeds := sdram225MHz; 
	--------------------------------------

	constant usb_oversampling : natural := 3;

	constant video_params : video_record := videoparam(video_mode, clk25mhz_freq);

	constant video_gear  : natural      := 2;
	signal video_clk     : std_logic;
	signal video_eclk    : std_logic;
	signal video_shift_clk : std_logic;
	signal videoio_clk   : std_logic;
	signal video_lck     : std_logic;
	signal video_hzsync  : std_logic;
	signal video_vtsync  : std_logic;
	signal video_vton    : std_logic;
	signal video_blank   : std_logic;
	signal video_pixel   : std_logic_vector(0 to 24-1);
	signal dvid_crgb     : std_logic_vector(4*video_gear-1 downto 0);

	alias  sio_clk       is videoio_clk;
	signal si_frm        : std_logic;
	signal si_irdy       : std_logic;
	signal si_data       : std_logic_vector(0 to 8-1);

	signal so_frm        : std_logic;
	signal so_trdy       : std_logic;
	signal so_irdy       : std_logic;
	signal so_end        : std_logic;
	signal so_data       : std_logic_vector(8-1 downto 0);

	constant max_delay   : natural := 2**14;
	constant hzoffset_bits : natural := unsigned_num_bits(max_delay-1);

	constant inputs      : natural := 8;
	signal input_clk     : std_logic;
	signal input_lck     : std_logic;
	signal input_chni    : std_logic_vector(4-1 downto 0);
	signal input_chno    : std_logic_vector(4-1 downto 0);
	signal input_ena     : std_logic;
	signal input_sample  : std_logic_vector(13-1 downto 0);
	constant vt_step     : real := 3.3/2.0**(input_sample'length-1); -- Volts
	signal input_enas    : std_logic;
	signal input_samples : std_logic_vector(0 to inputs*input_sample'length-1);
	signal tp            : std_logic_vector(1 to 32);

	signal usblnk_frm    : std_logic;
	signal usblnk_irdy   : std_logic;
	signal usblnk_trdy   : std_logic := '1';
	signal usblnk_data   : std_logic_vector(si_data'range);

	signal setup_frm    : std_logic;
	signal setup_irdy   : std_logic;
	signal setup_trdy   : std_logic := '1';
	signal setup_data   : std_logic_vector(si_data'range);

	signal iolink_frm    : std_logic;
	signal iolink_irdy   : std_logic;
	signal iolink_trdy   : std_logic;
	signal iolink_data   : std_logic_vector(si_data'range);

	signal adc_clk       : std_logic;

	constant layout      : string := compact(
			"{                             " &   
			"   inputs          : " & natural'image(inputs) & ',' &
			"   num_of_segments :   3,     " &
			"   display : {                " &
			"       width  : 1280,         " &
			"       height : 720},         " &
			"   grid : {                   " &
			"       width  : " & natural'image(32*32+1) & ',' &
			"       height : " & natural'image( 6*32+1) & ',' &
			"       color  : 0xff_ff_00_ff," &
			"       background-color : 0xff_00_00_00}," &
			"   axis : {                   " &
			"       horizontal : {         " &
			"           unit   : 31.25e-6, " &
			"           color  : 0xff_00_00_00," &
			"           background-color : 0xff_00_ff_ff}," &
			"       vertical : {           " &
			"           unit   : 50.00e-3, " &
			"           width  : " & natural'image(6*8) & ','  &
			"           color  : 0xff_00_00_00," &
			"           background-color : 0xff_00_ff_ff}}," &
			"   textbox : {                " &
			"       width      : " & natural'image(6*32) & ','&
			"       color      : 0xff_ff_00_ff," &
			"       background-color : 0xff_00_00_00}," &
			"   main : {                   " &
			"       top        : 27,       " & 
			"       bottom     :  0,       " & 
			"       left       :  5,       " & 
			"       right      :  0,       " & 
			"       vertical   : 27,       " & 
			"       horizontal :  1,       " &
			"       background-color : 0xff_00_00_00}," &
			"   segment : {                " &
			"       top        : 1,        " &
			"       left       : 1,        " &
			"       right      : 1,        " &
			"       bottom     : 1,        " &
			"       vertical   : 1,        " &
			"       horizontal : 1,        " &
			"       background-color : 0xff_ff_ff_ff}," &
			"  vt : [                      " &
			"   { text  : GN14,            " &
			"     step  : " & real'image(vt_step) & "," &
			"     color : 0xff_00_ff_ff},  " & -- vt(0)
			"   { text  : GP14,            " &
			"     step  : " & real'image(vt_step) & "," &
			"     color : 0xff_ff_ff_ff},  " & -- vt(1)
			"   { text  : GN15,            " &
			"     step  : " & real'image(vt_step) & "," &
			"     color : 0xff_00_ff_ff},  " & -- vt(2)
			"   { text  : GP15,            " &
			"     step  : " & real'image(vt_step) & "," &
			"     color : 0xff_ff_ff_ff},  " & -- vt(3)
			"   { text  : GN16,            " &
			"     step  : " & real'image(vt_step) & "," &
			"     color : 0xff_00_ff_ff},  " & -- vt(4)
			"   { text  : GP16,            " &
			"     step  : " & real'image(vt_step) & "," &
			"     color : 0xff_ff_ff_ff},  " & -- vt(5)
			"   { text  : GN17,            " &
			"     step  : " & real'image(vt_step) & "," &
			"     color : 0xff_00_ff_ff},  " & -- vt(6)
			"   { text  : GP17,            " &
			"     step  : " & real'image(vt_step) & "," &
			"     color : 0xff_ff_ff_ff}]}");   -- vt(7)
begin

	videopll_e : entity hdl4fpga.ecp5_videopll
	generic map (
		io_link      => io_link,
		clkio_freq   => 12.0e6*real(usb_oversampling),
		clkref_freq  => clk25mhz_freq,
		default_gear => video_gear,
		video_params => video_params)
	port map (
		clk_ref     => clk_25mhz,
		videoio_clk => videoio_clk,
		video_clk   => video_clk,
		video_shift_clk => video_shift_clk,
		video_eclk  => video_eclk,
		video_lck   => video_lck);

	usb_g : if io_link=io_usb generate
		signal usb_cken : std_logic;
		signal fltr_en : std_logic;
		signal fltr_bs : std_logic;
		signal fltr_d  : std_logic;

	begin

		usb_fpga_pu_dp <= '1'; -- D+ pullup for USB1.1 device mode
		usb_fpga_pu_dn <= 'Z'; -- D- no pullup for USB1.1 device mode
		usb_fpga_dp    <= 'Z'; -- when up='0' else '0';
		usb_fpga_dn    <= 'Z'; -- when up='0' else '0';
		usb_fpga_bd_dp <= 'Z';
		usb_fpga_bd_dn <= 'Z';


		-- led(7) <= tp(4);

		usb_e : entity hdl4fpga.sio_dayusb
		generic map (
			usb_oversampling => usb_oversampling)
		port map (
			usb_clk   => videoio_clk,
			usb_cken  => usb_cken,
			usb_dp    => usb_fpga_dp,
			usb_dn    => usb_fpga_dn,

			sio_clk   => sio_clk,
			si_frm    => so_frm,
			si_irdy   => so_irdy,
			si_trdy   => so_trdy,
			si_end    => so_end,
			si_data   => so_data,
	
			so_frm    => usblnk_frm,
			so_irdy   => usblnk_irdy,
			so_trdy   => usblnk_trdy,
			so_data   => usblnk_data);
	end generate;

	setup_b : block
		port (
			sio_clk : in  std_logic;
			si_frm  : in  std_logic;
			si_irdy : in  std_logic := '1';
			si_trdy : out std_logic;
			si_data : in  std_logic_vector;
			so_frm  : out std_logic;
			so_irdy : out std_logic;
			so_trdy : in  std_logic := '1';
			so_data : out std_logic_vector);
		port map (
			sio_clk => sio_clk,
			si_frm  => usblnk_frm,
			si_irdy => usblnk_irdy,
			si_trdy => usblnk_trdy,
			si_data => usblnk_data,
			so_frm  => setup_frm,
			so_irdy => setup_irdy,
			so_trdy => setup_trdy,
			so_data => setup_data);
			
		signal setup_req : std_logic := '0';
		signal setup_rdy : std_logic := '0';

        signal setup_frm  : std_logic := '0';
        signal setup_irdy : std_logic := '0';
        signal setup_trdy : std_logic := '1';
        signal setup_data : std_logic_vector(si_data'range);

		signal data      : std_logic_vector(0 to 8-1);
		constant bitdata : std_logic_vector := rid_hzaxis & x"02" & x"0" & x"4" & (0 to hzoffset_maxsize-1 => '0');
		constant bitrom_length : natural := data'length*((bitdata'length+data'length-1)/data'length);
		constant bitrom  : std_logic_vector := std_logic_vector(resize(reverse(unsigned(bitdata)), bitrom_length));
		constant addr_length : natural := unsigned_num_bits((bitdata'length+data'length-1)/data'length-1);
		signal  addr     : unsigned(0 to addr_length) := to_unsigned(bitrom'length/data'length-1, addr_length+1);

	begin

		mem_e : entity hdl4fpga.rom 
		generic map (
			bitrom => bitrom)
		port map (
			clk  => sio_clk,
			addr => std_logic_vector(addr(1 to addr'right)),
			data => data);
			
		process(setup_rdy, sio_clk)
		begin
			if rising_edge(sio_clk) then
				if video_lck='0' then
					setup_frm  <= '0';
					setup_irdy <= '0';
					addr <= to_unsigned(bitrom'length/data'length-1, addr'length);
					setup_req <= not setup_rdy;
				elsif si_frm='1' then 
					setup_frm  <= '0';
					setup_irdy <= '0';
					addr <= to_unsigned(bitrom'length/data'length-1, addr'length);
				elsif (setup_rdy xor setup_req)='1' then
					if so_trdy='1' then
					    if addr(0)='0' then
					    	setup_frm  <= '1';
					    	setup_irdy <= '1';
					    	addr <= addr - 1;
					    else
					    	setup_frm  <= '0';
					    	setup_irdy <= '0';
					    	setup_rdy  <= setup_req;
					    	addr <= to_unsigned(bitrom'length/data'length-1, addr'length);
					    end if;
					end if;
				else
					setup_frm  <= '0';
					setup_irdy <= '0';
					addr <= to_unsigned(bitrom'length/data'length-1, addr'length);
				end if;
				setup_data <= data;
			end if;
		end process;

		so_frm  <= si_frm  when si_frm='1' else setup_frm;
		so_irdy <= si_irdy when si_frm='1' else setup_irdy;
		si_trdy <= so_trdy when setup_frm='0' else '0';
		so_data <= si_data when si_frm='1' else setup_data;

	end block;

	-- led <= (left, up, down, right) &tp(1 to 4);
	led <= tp(1 to 8);
	stactlr_e : entity hdl4fpga.scopeio_stactlr
	generic map (
		layout => layout)
	port map (
		tp => tp,
        left    => left,
        up      => up,
        down    => down ,
        right   => right,
		video_vton => video_vton,
		sio_clk => sio_clk,
		si_frm  => setup_frm,
		si_irdy => setup_irdy,
		si_trdy => setup_trdy,
		si_data => setup_data,
		so_frm  => iolink_frm,
		so_irdy => iolink_irdy,
		so_trdy => iolink_trdy,
		so_data => iolink_data);

	inputs_b : block
		constant mux_sampling : natural := 10;

		signal rgtr_id      : std_logic_vector(8-1 downto 0);
		signal rgtr_dv      : std_logic;
		signal rgtr_trdy    : std_logic;
		signal rgtr_data    : std_logic_vector(0 to 32-1);
		signal rgtr_revs    : std_logic_vector(rgtr_data'reverse_range);

		signal hz_dv        : std_logic;
		signal hz_scale     : std_logic_vector(4-1 downto 0);
		signal hz_slider    : std_logic_vector(hzoffset_bits-1 downto 0);
		signal max_input    : natural range 0 to mux_sampling-1;
		signal opacity      : unsigned(0 to inputs-1);
		signal opacity_frm  : std_logic;
		signal opacity_data : std_logic_vector(si_data'range);

	begin

		process (hz_scale)
			variable no_inputs : natural range 0 to mux_sampling-1;
		begin
			case hz_scale is
			when x"0" =>
				no_inputs := hdl4fpga.base.min(inputs-1, 1-1);
			when x"1" =>
				no_inputs := hdl4fpga.base.min(inputs-1, 2-1);
			when x"2" =>
				no_inputs := hdl4fpga.base.min(inputs-1, 4-1);
			when x"3" =>
				no_inputs := hdl4fpga.base.min(inputs-1, 5-1);
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
			max_input <= no_inputs;
		end process;

		process(input_clk)
			variable cntr : unsigned(input_chni'range);
		begin
			if rising_edge(input_clk) then
				if input_ena='1' then
					if cntr >= max_input then
						cntr := (others => '0');
						input_enas <= '1';
					elsif cntr >= mux_sampling-1 then 
						cntr := (others => '0');
						input_enas <= '1';
					else
						cntr := cntr + 1;
						input_enas <= '0';
					end if;
					input_chni <= std_logic_vector(cntr);
				else
					input_enas <= '0';
				end if;
			end if;
		end process;

		sio_sin_e : entity hdl4fpga.sio_sin
		port map (
			sin_clk   => sio_clk,
			sin_frm   => iolink_frm,
			sin_irdy  => iolink_irdy,
			sin_trdy  => iolink_trdy,
			sin_data  => iolink_data,
			rgtr_dv   => rgtr_dv,
			rgtr_id   => rgtr_id,
			rgtr_trdy => rgtr_trdy,
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

		process (opacity, sio_clk)
			variable data : unsigned(0 to inputs*32-1);
			variable cntr : unsigned(0 to unsigned_num_bits((data'length+opacity_data'length-1)/opacity_data'length)-1);
		begin
			if rising_edge(sio_clk) then
				if cntr < (data'length+opacity_data'length-1)/opacity_data'length then
					cntr := cntr + 1;
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

		rgtr_trdy <= '1' when opacity_frm='0' else '0';
		si_frm  <= iolink_frm  when opacity_frm='0' else '1';
		si_irdy <= iolink_irdy when opacity_frm='0' else '1';
		si_data <= iolink_data when opacity_frm='0' else opacity_data;

	end block;

	scopeio_e : entity hdl4fpga.scopeio
	generic map (
		videotiming_id => video_params.timing,
		layout         => layout)
	port map (
		-- tp => tp,
		sio_clk     => sio_clk,
		si_frm      => si_frm,
		si_irdy     => si_irdy,
		si_data     => si_data,
		so_data     => so_data,
		input_clk   => input_clk,
		input_ena   => input_enas,
		input_data  => input_samples,
		video_clk   => video_clk,
		video_pixel => video_pixel,
		video_hsync => video_hzsync,
		video_vsync => video_vtsync,
		video_vton  => video_vton,
		video_blank => video_blank);

	-- HDMI/DVI VGA --
	------------------

	dvi_b : block
		constant red_length   : natural := 8;
		constant green_length : natural := 8;
		constant blue_length  : natural := 8;
		
		signal rgb : std_logic_vector(0 to red_length+green_length+blue_length-1) := (others => '0');
	begin

		process (video_pixel)
			variable urgb  : unsigned(rgb'range);
			variable pixel : unsigned(0 to video_pixel'length-1);
		begin
			pixel := unsigned(video_pixel);

			urgb(0 to red_length-1)  := pixel(0 to red_length-1);
			urgb  := urgb rol 8;
			pixel := pixel sll red_length;

			urgb(0 to green_length-1) := pixel(0 to green_length-1);
			urgb  := urgb rol 8;
			pixel := pixel sll green_length;

			urgb(0 to blue_length-1) := pixel(0 to blue_length-1);
			urgb  := urgb rol 8;
			pixel := pixel sll blue_length;

			rgb <= std_logic_vector(urgb);
		end process;

		dvi_e : entity hdl4fpga.dvi
		generic map (
			fifo_mode => false, --dvid_fifo,
			gear  => video_gear)
		port map (
			clk   => video_clk,
			rgb   => rgb,
			hsync => video_hzsync,
			vsync => video_vtsync,
			blank => video_blank,
			cclk  => video_shift_clk,
			chnc  => dvid_crgb(video_gear*4-1 downto video_gear*3),
			chn2  => dvid_crgb(video_gear*3-1 downto video_gear*2),  
			chn1  => dvid_crgb(video_gear*2-1 downto video_gear*1),  
			chn0  => dvid_crgb(video_gear*1-1 downto video_gear*0));

	end block;

	hdmibrd_g : if video_gear=2 generate 
		signal crgb : std_logic_vector(dvid_crgb'range);
	begin
		reg_e : entity hdl4fpga.latency
		generic map (
			n => dvid_crgb'length,
			d => (dvid_crgb'range => 1))
		port map (
			clk => video_shift_clk,
			di  => dvid_crgb,
			do  => crgb);

		gbx_g : entity hdl4fpga.ecp5_ogbx
		generic map (
			mem_mode  => false,
			lfbt_frst => false,
			interlace => true,
			size      => gpdi_d'length,
			gear      => video_gear)
		port map (
			sclk      => video_shift_clk,
			eclk      => video_eclk,
			d         => crgb,
			q         => gpdi_d);

	end generate;

	process (input_clk)
	begin
		if rising_edge(input_clk) then
			if input_ena='1' then
				for i in 0 to inputs-1 loop
					if unsigned(input_chno)=i then
						assert false
						report integer'image(i) & " : " & to_string(input_chno) & ": " & std_logic'image(input_ena)
						severity WARNING;
						input_samples(i*input_sample'length to (i+1)*input_sample'length-1) <= input_sample;
					end if;
				end loop;
			end if;
		end if;
	end process;

	max1112x_b : block
		port (
			clk_25mhz    : in  std_logic;
			input_clk    : buffer std_logic;
			input_ena    : buffer std_logic;
			input_chni   : in  std_logic_vector( 4-1 downto 0);
			input_chno   : out std_logic_vector( 4-1 downto 0);
			input_sample : buffer std_logic_vector;

			adc_clk      : out std_logic;
			adc_csn      : out std_logic;
			adc_miso     : in  std_logic;
			adc_mosi     : out std_logic);
		port map (
			clk_25mhz    => clk_25mhz,
			input_clk    => input_clk,
			input_ena    => input_ena,
			input_chni   => input_chni,
			input_chno   => input_chno,
			input_sample => input_sample,
			adc_clk      => adc_clk,
			adc_csn      => adc_csn,
			adc_miso     => adc_miso,
			adc_mosi     => adc_mosi);

		constant adc1clkref_freq : real := 64.0e6;
		constant adc1clki_div    : natural := 5;
		constant adc1clkos_div   : natural := 32;
		constant adc1clkos2_div  : natural := 25;
		constant adc1clkos_freq  : real := adc1clkref_freq/real(adc1clki_div);
		constant adc1clkos2_freq : real := (real(adc1clkos_div)*adc1clkref_freq)/(real(adc1clkos2_div)*real(adc1clki_div));

		signal adc1_clkos        : std_logic;
		signal adc1_clkos2       : std_logic;
		signal adc1_lock         : std_logic;
		signal adc_din           : std_logic_vector(16-1 downto 0);
		signal adc_dout          : std_logic_vector(16-1 downto 0);

		attribute FREQUENCY_PIN_CLKOS  : string;
		attribute FREQUENCY_PIN_CLKOS2 : string;
		attribute FREQUENCY_PIN_CLKOS3 : string;
		attribute FREQUENCY_PIN_CLKI   : string;
		attribute FREQUENCY_PIN_CLKOP  : string;

		attribute FREQUENCY_PIN_CLKOS  of adc1_i : label is ftoa( adc1clkos_freq/1.0e6, 10);
		attribute FREQUENCY_PIN_CLKOS2 of adc1_i : label is ftoa(adc1clkos2_freq/1.0e6, 10);

	begin

		assert false
		report CR &
			"MAX1112X" & CR &
			"ADC1_CLKOS     : " & adc1_i'FREQUENCY_PIN_CLKOS  & " MHz " & CR &
			"ADC1_CLKOS2    : " & adc1_i'FREQUENCY_PIN_CLKOS2 & " MHz "
		severity NOTE;

		adc1_i : EHXPLLL
		generic map (
			PLLRST_ENA       => "DISABLED",
			INTFB_WAKE       => "DISABLED",
			STDBY_ENABLE     => "DISABLED",
			DPHASE_SOURCE    => "DISABLED",
			PLL_LOCK_MODE    =>  0,
			FEEDBK_PATH      => "CLKOS",
			CLKOS_ENABLE     => "ENABLED",  CLKOS_FPHASE   => 0, CLKOS_CPHASE  => adc1clkos_div-1,
			CLKOS2_ENABLE    => "ENABLED",  CLKOS2_FPHASE  => 0, CLKOS2_CPHASE => 0,
			CLKOS3_ENABLE    => "DISABLED", CLKOS3_FPHASE  => 0, CLKOS3_CPHASE => 0,
			CLKOP_ENABLE     => "DISABLED", CLKOP_FPHASE   => 0, CLKOP_CPHASE  => 0,
			CLKOS_TRIM_DELAY =>  0,         CLKOS_TRIM_POL => "FALLING",
			CLKOP_TRIM_DELAY =>  0,         CLKOP_TRIM_POL => "FALLING",
			OUTDIVIDER_MUXD  => "DIVD",
			OUTDIVIDER_MUXC  => "DIVC",
			OUTDIVIDER_MUXB  => "DIVB",
			OUTDIVIDER_MUXA  => "DIVA",

			CLKI_DIV         => adc1clki_div,
			CLKOS_DIV        => adc1clkos_div,
			CLKOS2_DIV       => adc1clkos2_div)
		port map (
			clki      => video_clk,
			CLKFB     => adc1_clkos,
			PHASESEL0 => '0', PHASESEL1 => '0',
			PHASEDIR  => '0',
			PHASESTEP => '0', PHASELOADREG => '0',
			STDBY     => '0', PLLWAKESYNC  => '0',
			ENCLKOP   => '0',
			ENCLKOS   => '0',
			ENCLKOS2  => '0',
			ENCLKOS3  => '0',
			CLKOS     => adc1_clkos,
			CLKOS2    => adc1_clkos2,
			LOCK      => adc1_lock,
			INTLOCK   => open,
			REFCLK    => open,
			CLKINTFB  => open);
		
		adc_clk   <= adc1_clkos2;
		input_clk <= adc1_clkos2;

		process (input_clk)
			constant n    : natural := 16;
			variable cntr : unsigned(0 to unsigned_num_bits(n-1)-1);
		begin
			if rising_edge(input_clk) then
				if input_lck='0' then
					cntr := to_unsigned(n-1, cntr'length);
					adc_csn   <= '1';
					input_ena <= '0';
				elsif cntr=0 then
					cntr := to_unsigned(n-1, cntr'length);
					adc_csn   <= '1';
					input_ena <= '1';
				else
					cntr := cntr - 1;
					adc_csn   <= '0';
					input_ena <= '0';
				end if;
			end if;
		end process;

		adccfg_p : process (input_clk)
			constant adc_reset : std_logic_vector := b"0" & b"0000" & b"0000" & b"10" & b"00" & b"0" &  b"1" & "0"; -- ADC Mode Control
			type states is (s_init, s_run);
			variable state : states := s_init;
		begin
			if rising_edge(input_clk) then
				if input_lck='0' then
					adc_din <= adc_reset;
					state   := s_init;
				elsif input_ena='1' then
					case state is
					when s_init =>
						adc_din <= adc_reset;
						state := s_run;
					when s_run =>
						adc_din <= b"0" & b"0001" & input_chni & b"00" & b"00" & b"0" &  b"1" & "0"; -- ADC Mode Control
					end case;
				end if;
			end if;
		end process;

		desser_p : process (input_clk)
			variable shr : unsigned(0 to adc_din'length-1);
		begin
			if rising_edge(input_clk) then
				if input_ena='1' then
					shr := unsigned(adc_din);
				end if;
				adc_mosi <= shr(0);
				shr := shr sll 1;
			end if;
		end process;

		serdes_p : process (adc_din, input_clk)
			variable shr : unsigned(adc_din'range);
			variable chni : std_logic_vector(input_chni'range);
			variable chnm : std_logic_vector(input_chni'range);
			variable chno : std_logic_vector(input_chni'range);
		begin
			if rising_edge(input_clk) then
				shr    := shr rol 1;
				shr(0) := adc_miso;
				if input_ena='1' then
					input_chno <= chno;
					chno := chnm;
					chnm := chni;
					chni := input_chni;
					adc_dout <= std_logic_vector(shr);
				end if;
			end if;
		end process;

		input_sample <= std_logic_vector(resize(shift_right(unsigned(adc_dout), 3), input_sample'length)); -- MAX11120–MAX11128 Pgae 22

	end block;

	adcsclk_i : oddrx1f
	port map(
		sclk => adc_clk,
		rst  => '0',
		d0   => '1',
		d1   => '0',
		q    => adc_sclk);

	process (clk_25mhz)
		variable cntr : unsigned(0 to 20-1);
	begin
		if rising_edge(clk_25mhz) then
			-- (gp(17), gn(17), gp(16), gn(16), gp(15), gn(15), gp(14), gn(14)) <= std_logic_vector(cntr(0 to 8-1));
			(gp(24), gn(24), gp(25), gn(25), gp(26), gn(26), gp(27), gn(27)) <= std_logic_vector(cntr(0 to 8-1));
			cntr := cntr + 1;
		end if;
	end process;

end;