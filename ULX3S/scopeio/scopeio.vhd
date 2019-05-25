-- AUTHOR = EMARD
-- LICENSE = BSD

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library ecp5u;
use ecp5u.components.all;

library hdl4fpga;
use hdl4fpga.std.all;
--use work.std.all;

architecture beh of ulx3s is
	alias ps2_clock        : std_logic is usb_fpga_bd_dp;
	alias ps2_data         : std_logic is usb_fpga_bd_dn;
	alias ps2_clock_pullup : std_logic is usb_fpga_pu_dp;
	alias ps2_data_pullup  : std_logic is usb_fpga_pu_dn;

	signal rst        : std_logic := '0';
	signal clk_pll    : std_logic_vector(3 downto 0); -- output from pll
	signal clk        : std_logic;
	signal clk_pixel_shift : std_logic; -- 5x vga clk, in phase

	-- vlayout_id
	-- 0: 1920x1080 @ 60Hz 150MHz 
	-- 1:  800x600  @ 60Hz  40MHz
	-- 2: 1920x1080 @ 30Hz  75MHz
	-- 3: 1280x768  @ 60Hz  75MHz
        constant vlayout_id: integer := 3;

	signal vga_clk    : std_logic;
	signal vga_hsync  : std_logic;
	signal vga_vsync  : std_logic;
	signal vga_blank  : std_logic;
	signal vga_rgb    : std_logic_vector(0 to 3-1);

	signal vga_hsync_test  : std_logic;
	signal vga_vsync_test  : std_logic;
	signal vga_blank_test  : std_logic;
	signal vga_rgb_test: std_logic_vector(0 to 3-1);
        signal dvid_crgb  : std_logic_vector(7 downto 0);
        signal ddr_d      : std_logic_vector(3 downto 0);
	constant sample_size : natural := 9;

	signal clk_oled : std_logic := '0';

	signal clk_adc : std_logic := '0';
	signal adc_data : std_logic_vector(15 downto 0);

	function sinctab (
		constant x0 : integer;
		constant x1 : integer;
		constant n  : natural)
		return std_logic_vector is
		variable y   : real;
		variable aux : std_logic_vector(n*x0 to n*(x1+1)-1);
		constant freq : real := 4*8.0;
	begin
		for i in x0 to x1 loop
			y := real(2**(n-2)-1)*64.0*(8.0/freq);
			if i/=0 then
				y := y*sin((2.0*MATH_PI*real(i)*freq)/real(x1-x0+1))/real(i);
			else
				y := freq*y*(2.0*MATH_PI)/real(x1-x0+1);
			end if;
			y := y - (64.0+24.0);
			aux(i*n to (i+1)*n-1) := std_logic_vector(to_signed(integer(trunc(y)),n));
--			if i < (x0+x1)/2 then
--				aux(i*n to (i+1)*n-1) := ('0', others => '1');
--			else
--				aux(i*n to (i+1)*n-1) := ('1',others => '0');
--			end if;
		end loop;
		return aux;
	end;
	signal input_addr : std_logic_vector(11-1 downto 0); -- for BRAM as internal signal generator

	constant inputs    : natural := 4;

	signal trace_yellow, trace_cyan, trace_green, trace_red, trace_off : std_logic_vector(0 to sample_size-1);
	signal samples     : std_logic_vector(0 to inputs*sample_size-1);

	constant C_uart_original: boolean := false;
	constant baudrate    : natural := 115200;
	constant uart_clk_hz : natural := 25000000; -- Hz

	signal clk_uart : std_logic := '0';
	signal uart_ena : std_logic := '0';

	--signal uart_rxc   : std_logic;
	signal uart_sin   : std_logic;
	signal uart_rxdv  : std_logic;
	signal uart_rxd   : std_logic_vector(0 to 7);
	signal so_null    : std_logic_vector(0 to 7);

	signal fromistreamdaisy_frm  : std_logic;
	signal fromistreamdaisy_irdy : std_logic;
	signal fromistreamdaisy_data : std_logic_vector(8-1 downto 0);
	signal frommousedaisy_frm  : std_logic;
	signal frommousedaisy_irdy : std_logic;
	signal frommousedaisy_data : std_logic_vector(8-1 downto 0);

	signal clk_mouse       : std_logic := '0';

	signal display    : std_logic_vector(7 downto 0);
	
	signal R_adc_slowdown: unsigned(1 downto 0);

	signal fpga_gsrn : std_logic;
	signal reset_counter : unsigned(19 downto 0);
begin
	-- fpga_gsrn <= btn(0);
	fpga_gsrn <= '1';
	
	-- pullups 1.5k for the PS/2 mouse connected to US2 port
	ps2_clock_pullup <= '1';
	ps2_data_pullup  <= '1';

        clk_25M: entity work.clk_verilog
        port map
        (
          clkin       =>  clk_25MHz,
          clkout      =>  clk_pll
        );
        -- 800x600
        clk_pixel_shift <= clk_pll(0); -- 200 MHz
        vga_clk <= clk_pll(1); -- 40 MHz
        clk <= clk_pll(3); -- 25 MHz
        clk_oled <= clk_pll(3); -- 25 MHz
        clk_adc <= clk_pll(3); -- 25 MHz
        clk_uart <= clk_pll(3); -- 25 MHz
        clk_mouse <= clk_pll(3); -- 25 MHz
        -- 1920x1080
        --clk_pixel_shift <= clk_pll(0); -- 375 MHz
        --vga_clk <= clk_pll(1); -- 75 MHz
	
	process(vga_clk)
	begin
          if rising_edge(vga_clk) then
            if btn(0) = '0' then -- BTN0 = 0 when pressed
              if(reset_counter(reset_counter'high) = '0') then
                reset_counter <= reset_counter + 1;
              end if;
            else -- BTN0 = 1 when not pressed
              reset_counter <= (others => '0');
	    end if;
          end if;
	end process;
	rst <= reset_counter(reset_counter'high);

	process (clk)
	begin
		if rising_edge(clk) then
			input_addr <= std_logic_vector(unsigned(input_addr) + 1);
		end if;
	end process;


	process (clk_adc)
	begin
		if rising_edge(clk_adc) then
			if R_adc_slowdown(R_adc_slowdown'high) = '0' then
				R_adc_slowdown <= R_adc_slowdown + 1;
			else
				R_adc_slowdown <= 0;
			end if;
		end if;
	end process;

	adc_e: entity work.max1112x_reader
	generic map
	(
	  C_channels => 8,
	  C_bits => 12
	)
	port map
	(
	  clk => clk_adc, -- 25 MHz
	  clken => R_adc_slowdown(R_adc_slowdown'high),
	  bus_data => adc_data,
	  spi_csn => adc_csn,
	  spi_clk => adc_sclk,
	  spi_mosi => adc_mosi,
	  spi_miso => adc_miso
	);
	
	gn(17 downto 14) <= (others => btn(1));
	gp(17 downto 14) <= (others => btn(2));

	-- internal sine waveform generator
	samples_e : entity hdl4fpga.rom
	generic map (
		bitrom => sinctab(-1024+256, 1023+256, sample_size))
	port map (
		clk  => clk,
		addr => input_addr,
		data => trace_off);

	-- external input: PS/2 data
	trace_yellow(0 to 1) <= (others => '0');  -- MSB (sign), MSB-1
	trace_yellow(2) <= adc_mosi; -- MSB-2
	trace_yellow(3 to trace_yellow'high) <= (others => '0'); -- rest LSB

	-- external input: PS/2 data
	trace_cyan(0 to 1) <= (others => '0');  -- MSB (sign), MSB-1
	trace_cyan(2) <= adc_miso; -- MSB-2
	--trace_cyan(3 to trace_cyan'high) <= (others => '0'); -- rest LSB
	trace_cyan(6) <= '1';

	-- external input: PS/2 clock
	trace_green(0 to 2) <= (others => '0'); -- MSB (sign), MSB-1, MSB-2
	trace_green(3) <= adc_csn; -- MSB-3
	trace_green(5) <= '1';
	--trace_green(4 to trace_green'high) <= (others => '0'); -- rest LSB

	-- internal sine waveform, inverted
	trace_red(0 to 2) <= (others => '0');  -- MSB (sign), MSB-1
	trace_red(3) <= adc_sclk; -- MSB-2
	trace_red(4 to trace_red'high) <= (others => '0'); -- rest LSB
	
	samples(0*sample_size to (0+1)*sample_size-1) <= trace_yellow; -- triggered
	samples(1*sample_size to (1+1)*sample_size-1) <= trace_cyan;
	samples(2*sample_size to (2+1)*sample_size-1) <= trace_green;
	samples(3*sample_size to (3+1)*sample_size-1) <= trace_red;

	process (clk)
	begin
		if rising_edge(clk) then
			input_addr <= std_logic_vector(unsigned(input_addr) + 1);
		end if;
	end process;

	G_uart_miguel: if C_uart_original generate
	process (clk_uart)
		constant max_count : natural := (uart_clk_hz+16*baudrate/2)/(16*baudrate);
		variable cntr      : unsigned(0 to unsigned_num_bits(max_count-1)-1) := (others => '0');
	begin
		if rising_edge(clk_uart) then
			if cntr = max_count-1 then
				uart_ena <= '1';
				cntr := (others => '0');
			else
				uart_ena <= '0';
				cntr := cntr + 1;
			end if;
		end if;
	end process;

	uartrx_e : entity hdl4fpga.uart_rx
	generic map (
		baudrate => baudrate,
		clk_rate => 16*baudrate)
	port map (
		uart_rxc  => clk_uart,
		uart_sin  => ftdi_txd,
		uart_ena  => uart_ena,
		uart_rxdv => uart_rxdv,
		uart_rxd  => uart_rxd);
	end generate;

	G_uart_emard: if not C_uart_original generate
	uartrx_e : entity hdl4fpga.uart_rx_f32c
	generic map
	(
		C_baudrate => baudrate,
		C_clk_freq_hz => uart_clk_hz
	)
	port map
	(
		clk  => clk_uart,
		rxd  => ftdi_txd,
		dv   => uart_rxdv,
		byte => uart_rxd
	);
	end generate;

        -- UART to LED
	process(clk_uart)
	begin
		if rising_edge(clk_uart) then
			if uart_rxdv='1' then
				display <= uart_rxd;
			end if;
		end if;
	end process;
	led <= display;

	istreamdaisy_e : entity hdl4fpga.scopeio_istreamdaisy
	port map (
		stream_clk  => clk_uart,
		stream_dv   => uart_rxdv,
		stream_data => uart_rxd,

		chaini_data => (uart_rxd'range => '-'),

		--chaino_clk  => fromistreamdaisy_clk, 
		-- daisy output
		chaino_frm  => fromistreamdaisy_frm, 
		chaino_irdy => fromistreamdaisy_irdy,
		chaino_data => fromistreamdaisy_data
	);
	
	-- OLED display for debugging
	oled_e: entity work.oled_hex_decoder
	generic map
	(
	  C_data_len => 16 -- number of input bits
	)
	port map
	(
	  clk => clk_oled, -- 25 MHz
	  --data => adc_data,
	  data(15 downto 8) => display, -- uart latch
	  data(7 downto 0) => (others => '0'),
	  spi_clk => oled_clk,
	  spi_mosi => oled_mosi,
	  spi_dc => oled_dc,
	  spi_resn => oled_resn,
	  spi_csn => oled_csn
	);

	ps2mouse2daisy_e: entity hdl4fpga.scopeio_ps2mouse2daisy
	generic map(
		vlayout_id  => vlayout_id
	)
	port map (
		clk         => clk_mouse,
		ps2m_reset  => rst,
		ps2m_clk    => ps2_clock,
		ps2m_dat    => ps2_data,
		-- daisy input
		chaini_frm  => fromistreamdaisy_frm,
		chaini_irdy => fromistreamdaisy_irdy,
		chaini_data => fromistreamdaisy_data,
		-- daisy output
		chaino_frm  => frommousedaisy_frm,
		chaino_irdy => frommousedaisy_irdy,
		chaino_data => frommousedaisy_data
	);

	scopeio_e : entity hdl4fpga.scopeio
	generic map (
	        inputs           => inputs, -- number of input channels
		vlayout_id       => vlayout_id,
		                 --  RGB0_RGB1_...
                default_tracesfg => b"110_011_010_100",
                default_gridfg   => b"100",
                default_gridbg   => b"000",
                default_hzfg     => b"111",
                default_hzbg     => b"000",
                default_vtfg     => b"111",
                default_vtbg     => b"000",
                default_textbg   => b"000",
                default_sgmntbg  => b"100",
                default_bg       => b"000"
	)
	port map (
		si_clk      => clk_mouse,
		si_frm      => frommousedaisy_frm,
		si_irdy     => frommousedaisy_irdy,
		si_data     => frommousedaisy_data,
		so_data     => so_null,
		input_clk   => clk,
		input_data  => samples,
		video_clk   => vga_clk,
		video_pixel => vga_rgb,
		video_hsync => vga_hsync,
		video_vsync => vga_vsync,
		video_blank => vga_blank
	);

    -- test picture video generrator for debug purposes
    vga: entity work.vga
    generic map
    (
      -- 800x600 40 MHz pixel clock, works
--      C_resolution_x => 800,
--      C_hsync_front_porch => 40,
--      C_hsync_pulse => 128,
--      C_hsync_back_porch => 88,
--      C_resolution_y => 600,
--      C_vsync_front_porch => 1,
--      C_vsync_pulse => 4,
--      C_vsync_back_porch => 23,
--      C_bits_x => 12,
--      C_bits_y => 11    

--      -- 1024x768 65 MHz pixel clock, works
--      C_resolution_x => 1024,
--      C_hsync_front_porch => 16,
--      C_hsync_pulse => 96,
--      C_hsync_back_porch => 44,
--      C_resolution_y => 768,
--      C_vsync_front_porch => 10,
--      C_vsync_pulse => 2,
--      C_vsync_back_porch => 31,
--      C_bits_x => 11,
--      C_bits_y => 11    

--      -- 1920x1080 75 MHz pixel clock, doesn't work on lenovo, works on Samsung TV
      C_resolution_x => 1920,
      C_hsync_front_porch => 88,
      C_hsync_pulse => 44,
      C_hsync_back_porch => 133,
      C_resolution_y => 1080,
      C_vsync_front_porch => 4,
      C_vsync_pulse => 5,
      C_vsync_back_porch => 46,
      C_bits_x => 12,
      C_bits_y => 11    
    )
    port map
    (
      clk_pixel => vga_clk,
      test_picture => '1',
      red_byte => (others => '0'),
      green_byte => (others => '0'),
      blue_byte => (others => '0'),
      vga_r(7) => vga_rgb_test(0),
      vga_g(7) => vga_rgb_test(1),
      vga_b(7) => vga_rgb_test(2),
      vga_hsync => vga_hsync_test,
      vga_vsync => vga_vsync_test,
      vga_blank => vga_blank_test
    );    
    
    vga2dvid: entity hdl4fpga.vga2dvid
    generic map
    (
        C_ddr => '1',
    	C_depth => 1
    )
    port map
    (
        clk_pixel => vga_clk,
        clk_shift => clk_pixel_shift,
        in_red => vga_rgb(0 to 0),
        in_green => vga_rgb(1 to 1),
        in_blue => vga_rgb(2 to 2),
        in_hsync => vga_hsync,
        in_vsync => vga_vsync,
        in_blank => vga_blank,
        out_clock => dvid_crgb(7 downto 6),
        out_red => dvid_crgb(5 downto 4),
        out_green => dvid_crgb(3 downto 2),
        out_blue => dvid_crgb(1 downto 0)
    );

    G_ddr_diff: for i in 0 to 3 generate
      gpdi_ddr: ODDRX1F port map(D0=>dvid_crgb(2*i), D1=>dvid_crgb(2*i+1), Q=>ddr_d(i), SCLK=>clk_pixel_shift, RST=>'0');
      gpdi_diff: OLVDS port map(A => ddr_d(i), Z => gpdi_dp(i), ZN => gpdi_dn(i));
    end generate;
end;
