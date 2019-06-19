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
	-- vlayout_id
	-- 0: 1920x1080 @ 60Hz 150MHz unreachable
	-- 1:  800x600  @ 60Hz  40MHz
	-- 2: 1920x1080 @ 30Hz  75MHz
	-- 3: 1280x768  @ 60Hz  75MHz
	-- 4: 1280x1024 @ 60Hz 108MHz NOTE: HARD OVERCLOCK
        constant vlayout_id: integer := 3;
        constant C_adc: boolean := true; -- true: normal ADC use, false: soft replacement
        constant C_adc_analog_view: boolean := true; -- true: normal use, false: SPI digital debug
        constant C_adc_view_low_bits: boolean := false; -- false: 3.3V, true: 200mV (to see ADC noise)
        constant C_adc_slowdown: boolean := false; -- true: ADC 2x slower, use for more detailed detailed SPI digital view
	constant C_adc_timing_exact: integer range 0 to 1 := 1; -- 0 for adc_slowdown = true, 1 for adc_slowdown = false
	constant C_adc_channels: integer := 4; -- don't touch
	constant C_adc_bits: integer := 12; -- don't touch
        constant C_buttons_test: boolean := true; -- false: normal use, true: pressing buttons will test ADC channels
        constant C_oled: boolean := true; -- true: use OLED, false: no oled - can save some LUTs

	alias ps2_clock        : std_logic is usb_fpga_bd_dp;
	alias ps2_data         : std_logic is usb_fpga_bd_dn;
	alias ps2_clock_pullup : std_logic is usb_fpga_pu_dp;
	alias ps2_data_pullup  : std_logic is usb_fpga_pu_dn;

	signal rst        : std_logic := '0';
	signal clk_pll    : std_logic_vector(3 downto 0); -- output from pll
	signal clk        : std_logic;
	signal clk_pixel_shift : std_logic; -- 5x vga clk, in phase

	signal vga_clk    : std_logic;
	signal vga_hsync  : std_logic;
	signal vga_vsync  : std_logic;
	signal vga_blank  : std_logic;
	signal vga_rgb    : std_logic_vector(0 to 6-1);

	signal vga_hsync_test  : std_logic;
	signal vga_vsync_test  : std_logic;
	signal vga_blank_test  : std_logic;
	signal vga_rgb_test: std_logic_vector(0 to 6-1);
        signal dvid_crgb  : std_logic_vector(7 downto 0);
        signal ddr_d      : std_logic_vector(3 downto 0);
	constant sample_size : natural := 9;

	signal clk_oled : std_logic := '0';

	signal clk_adc : std_logic := '0';

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

	constant inputs: natural := 4; -- number of input channels (traces)
	-- assign default colors to the traces
	constant C_tracesfg: std_logic_vector(0 to inputs*vga_rgb'length-1) :=
        --b"111100";
          b"111100_001111_001100_110101";
        --b"111100_001111_001100_110101_111111";
        --  RRGGBB RRGGBB RRGGBB RRGGBB RRGGBB
        --  trace0 trace1 trace2 trace3 trace4
        --  yellow cyan   green  red    white

        -- technically it can be the same as C_tracesfg but for visibility tuning
        -- it is different for red color to make it less bright
	constant C_tracesfg_gui: std_logic_vector(0 to inputs*vga_rgb'length-1) :=
        --b"111100";
          b"111100_001111_001100_110000";
        --b"111100_001111_001100_110000_111111";
        --  RRGGBB RRGGBB RRGGBB RRGGBB RRGGBB
        --  trace0 trace1 trace2 trace3 trace4
        --  yellow cyan   green  red    white

	signal trace_yellow, trace_cyan, trace_green, trace_red, trace_white, trace_sine: std_logic_vector(0 to sample_size-1);
	signal S_input_ena : std_logic := '1';
	signal samples     : std_logic_vector(0 to inputs*sample_size-1);

	constant C_uart_original: boolean := false; -- true: use Miguel's, false: use EMARD's uart core
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

	signal R_adc_slowdown: unsigned(1 downto 0) := (others => '1');
	signal S_adc_dv: std_logic;
	signal S_adc_data: std_logic_vector(C_adc_channels*C_adc_bits-1 downto 0);

	signal R_test_counter: unsigned(15 downto 0); -- 64MHz -> 1kHz to ADC for buttons test
	signal S_test_p, S_test_n: std_logic;

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
        clk_pixel_shift <= clk_pll(0); -- 200/375 MHz
        vga_clk <= clk_pll(1); -- 40 MHz
        clk <= clk_pll(3); -- 25 MHz
        clk_oled <= clk_pll(3); -- 25 MHz
        --clk_adc <= clk_pll(2); -- 62.5 MHz (ADC clock 15.625MHz)
        clk_adc <= clk_pll(3); -- 75 MHz (same as vga_clk, ADC overclock 18.75MHz > 16MHz)
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

        -- replacement for ADC that manifests the problem
	G_not_adc: if not C_adc generate
	  B_slow_pulse_generator: block
	    signal R_pulse_counter: unsigned(10 downto 0);
	    signal R_pulse_ena: std_logic;
	  begin
	    process(clk_adc)
	    begin
	      if rising_edge(clk_adc) then
	        if R_pulse_counter <= 2040 then
		  R_pulse_counter <= R_pulse_counter + 1;
		else
		  R_pulse_counter <= (others => '0');
		end if;
	        if R_pulse_counter(5 downto 0) = "00000" then -- every 64
	          R_pulse_ena <= '1';
	        else
	          R_pulse_ena <= '0';
	        end if;
	      end if;
	    end process;
	    -- ch0
	    S_adc_data(10+C_adc_bits*0) <= R_pulse_counter(R_pulse_counter'high); -- wave
	    S_adc_data( 6+C_adc_bits*0 downto 5+C_adc_bits*0) <= "10"; -- small y offset
	    -- ch1
	    S_adc_data( 9+C_adc_bits*1) <= not R_pulse_counter(R_pulse_counter'high); -- wave
	    S_adc_data( 6+C_adc_bits*1 downto 5+C_adc_bits*1) <= "01"; -- small y offset
	    -- ch2
	    S_adc_data( 8+C_adc_bits*2) <= R_pulse_counter(R_pulse_counter'high-1); -- wave
	    S_adc_data( 6+C_adc_bits*2 downto 5+C_adc_bits*2) <= "11"; -- small y offset
	    -- ch3
	    S_adc_data( 7+C_adc_bits*3) <= not R_pulse_counter(R_pulse_counter'high-1); -- wave
	    S_adc_data( 6+C_adc_bits*3 downto 5+C_adc_bits*3) <= "00"; -- small y offset
	    --S_adc_dv <= R_pulse_ena;
	    S_adc_dv <= '1';
	  end block;
	end generate;

	G_yes_adc: if C_adc generate
	G_yes_adc_slowdown: if C_adc_slowdown generate
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
	end generate;

	adc_e: entity work.max1112x_reader
	generic map
	(
	  C_timing_exact => C_adc_timing_exact,
	  C_channels => C_adc_channels,
	  C_bits => C_adc_bits
	)
	port map
	(
	  clk => clk_adc,
	  clken => R_adc_slowdown(R_adc_slowdown'high),
	  reset => rst,
	  spi_csn => adc_csn,
	  spi_clk => adc_sclk,
	  spi_mosi => adc_mosi,
	  spi_miso => adc_miso,
	  dv => S_adc_dv,
	  data => S_adc_data
	);
	end generate;
	
	-- press buttons to test ADC
	-- for normal use disable this
	G_btn_test: if C_buttons_test generate
	  process(clk_adc)
	  begin
	    if rising_edge(clk_adc) then
	      R_test_counter <= R_test_counter + 1;
	    end if;
	  end process;
	  S_test_p <= R_test_counter(R_test_counter'high);
	  S_test_n <= R_test_counter(R_test_counter'high) xor R_test_counter(R_test_counter'high-1);
	  -- each pressed button will apply a logic level '1'
	  -- to FPGA pin shared with ADC channel which should
	  -- read something from 12'h000 to 12'hFFF with some
	  -- conversion noise
          gn(14) <= S_test_n when btn(3) = '1' else 'Z';
          gp(14) <= S_test_p when btn(3) = '1' else 'Z';
          gn(15) <= S_test_n when btn(4) = '1' else 'Z';
          gp(15) <= S_test_p when btn(4) = '1' else 'Z';
          gn(16) <= S_test_p when btn(5) = '1' else 'Z';
          gp(16) <= S_test_n when btn(5) = '1' else 'Z';
          gn(17) <= S_test_p when btn(6) = '1' else 'Z';
          gp(17) <= S_test_n when btn(6) = '1' else 'Z';
	end generate;

	process (clk)
	begin
		if rising_edge(clk) then
			input_addr <= std_logic_vector(unsigned(input_addr) + 1);
		end if;
	end process;

	-- internal sine waveform generator
	samples_e : entity hdl4fpga.rom
	generic map (
		bitrom => sinctab(-1024+256, 1023+256, sample_size))
	port map (
		clk  => clk,
		addr => input_addr,
		data => trace_sine);
	
	G_not_analog_view: if not C_adc_analog_view generate
	S_input_ena <= '1';
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
	end generate;

	G_yes_analog_view: if C_adc_analog_view generate
	  S_input_ena  <= S_adc_dv;
	  -- without sign bit
	  G_not_view_low_bits: if not C_adc_view_low_bits generate
	  trace_yellow(0 to trace_yellow'high) <= S_adc_data(1*C_adc_bits-1) & S_adc_data(1*C_adc_bits-1 downto 1*C_adc_bits-sample_size+1);
	  trace_cyan  (0 to trace_cyan'high)   <= S_adc_data(2*C_adc_bits-1) & S_adc_data(2*C_adc_bits-1 downto 2*C_adc_bits-sample_size+1);
	  trace_green (0 to trace_green'high)  <= S_adc_data(3*C_adc_bits-1) & S_adc_data(3*C_adc_bits-1 downto 3*C_adc_bits-sample_size+1);
	  trace_red   (0 to trace_red'high)    <= S_adc_data(4*C_adc_bits-1) & S_adc_data(4*C_adc_bits-1 downto 4*C_adc_bits-sample_size+1);
	  end generate;
	  G_yes_view_low_bits: if C_adc_view_low_bits generate
	  trace_yellow(0 to trace_yellow'high) <= S_adc_data(0*C_adc_bits-1+sample_size downto 1*C_adc_bits-C_adc_bits);
	  trace_cyan  (0 to trace_cyan'high)   <= S_adc_data(1*C_adc_bits-1+sample_size downto 2*C_adc_bits-C_adc_bits);
	  trace_green (0 to trace_green'high)  <= S_adc_data(2*C_adc_bits-1+sample_size downto 3*C_adc_bits-C_adc_bits);
	  trace_red   (0 to trace_red'high)    <= S_adc_data(3*C_adc_bits-1+sample_size downto 4*C_adc_bits-C_adc_bits);
	  end generate;
	end generate;
	
	G_inputs1: if inputs >= 1 generate
	samples(0*sample_size to (0+1)*sample_size-1) <= trace_yellow; -- by default triggered
	end generate;
	G_inputs2: if inputs >= 2 generate
	samples(1*sample_size to (1+1)*sample_size-1) <= trace_cyan;
	end generate;
	G_inputs3: if inputs >= 3 generate
	samples(2*sample_size to (2+1)*sample_size-1) <= trace_green;
	end generate;
	G_inputs4: if inputs >= 4 generate
	samples(3*sample_size to (3+1)*sample_size-1) <= trace_red;
	end generate;
	G_inputs5: if inputs >= 5 generate
	--samples(4*sample_size to (4+1)*sample_size-1) <= trace_white;
	samples(4*sample_size to (4+1)*sample_size-1) <= trace_sine; -- internally generated demo waveform
	end generate;

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

	led <= uart_rxd;

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

	G_oled: if C_oled generate
	-- OLED display for debugging
	oled_e: entity work.oled_hex_decoder
	generic map
	(
	  C_data_len => 64 -- number of input bits
	)
	port map
	(
	  clk => clk_oled, -- 25 MHz
	  data(47 downto 0) => S_adc_data(47 downto 0),
	  --data(15 downto 8) => uart_rxd, -- uart latch
	  --data(7 downto 0) => (others => '0'),
	  spi_clk => oled_clk,
	  spi_mosi => oled_mosi,
	  spi_dc => oled_dc,
	  spi_resn => oled_resn,
	  spi_csn => oled_csn
	);
	end generate;

	ps2mouse2daisy_e: entity hdl4fpga.scopeio_ps2mouse2daisy
	generic map(
		C_inputs    => inputs,
		C_tracesfg  => C_tracesfg,
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
                default_tracesfg => C_tracesfg,
                default_gridfg   => b"110000",
                default_gridbg   => b"000000",
                default_hzfg     => b"111111",
                default_hzbg     => b"000000",
                default_vtfg     => b"111111",
                default_vtbg     => b"000000",
                default_textbg   => b"000000",
                default_sgmntbg  => b"110000",
                default_bg       => b"000000"
	)
	port map (
		si_clk      => clk_mouse,
		si_frm      => frommousedaisy_frm,
		si_irdy     => frommousedaisy_irdy,
		si_data     => frommousedaisy_data,
		so_data     => so_null,
		input_clk   => clk_adc,
		input_ena   => S_input_ena,
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
      vga_r(7 downto 6) => vga_rgb_test(0 to 1),
      vga_g(7 downto 6) => vga_rgb_test(2 to 3),
      vga_b(7 downto 6) => vga_rgb_test(4 to 5),
      vga_hsync => vga_hsync_test,
      vga_vsync => vga_vsync_test,
      vga_blank => vga_blank_test
    );    
    
    vga2dvid: entity hdl4fpga.vga2dvid
    generic map
    (
        C_shift_clock_synchronizer => '0',
        C_ddr => '1',
        C_depth => 2
    )
    port map
    (
        clk_pixel => vga_clk,
        clk_shift => clk_pixel_shift,
        in_red => vga_rgb(0 to 1),
        in_green => vga_rgb(2 to 3),
        in_blue => vga_rgb(4 to 5),
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
