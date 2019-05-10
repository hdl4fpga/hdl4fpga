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

library ecp5u;
use ecp5u.components.all;

library hdl4fpga;
use hdl4fpga.std.all;
--use work.std.all;

architecture beh of ulx3s is
	signal rst        : std_logic := '0';
	signal clk_pll    : std_logic_vector(3 downto 0); -- output from pll
	signal clk        : std_logic;
	signal clk_pixel_shift : std_logic; -- 5x vga clk, in phase
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

	signal sample      : std_logic_vector(0 to sample_size-1);

	signal input_addr : std_logic_vector(11-1 downto 0);
	signal ipcfg_req  : std_logic;
	signal phy1_rst, phy1_rxc, phy1_rx_dv, phy1_125clk, phy1_tx_en : std_logic;
	signal phy1_rx_d, phy1_tx_d : std_logic_vector(0 to 8-1);
	signal fpga_gsrn : std_logic;
	signal reset_counter : unsigned(19 downto 0);
begin

	-- fpga_gsrn <= btn(0);
	fpga_gsrn <= '1';
	
	-- pullups 1.5k for the PS/2 mouse connected to US2 port
	usb_fpga_pu_dp <= '1';
	usb_fpga_pu_dn <= '1';

        clk_25M: entity work.clk_verilog
        port map
        (
          clkin       =>  clk_25MHz,
          clkout      =>  clk_pll
        );
        -- 800x600
        clk_pixel_shift <= clk_pll(0); -- 200 MHz
        vga_clk <= clk_pll(1); -- 40 MHz
        clk <= clk_pll(1); -- 40 MHz
	phy1_rxc <= clk_pll(1); -- 40 MHz
        -- 1920x1080
        --clk_pixel_shift <= clk_pll(0); -- 375 MHz
        --vga_clk <= clk_pll(1); -- 75 MHz
        --clk <= clk_pll(1); -- 75 MHz
	--phy1_rxc <= clk_pll(2); -- 125 MHz
	
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

	samples_e : entity hdl4fpga.rom
	generic map (
		bitrom => sinctab(-1024+256, 1023+256, sample_size))
	port map (
		clk  => clk,
		addr => input_addr,
		data => sample);

	process (clk)
	begin
		if rising_edge(clk) then
			input_addr <= std_logic_vector(unsigned(input_addr) + 1);
		end if;
	end process;

	phy1_rst <= not rst;

	ipcfg_req <= not fpga_gsrn;
	

	scopeio_e : entity hdl4fpga.scopeio
	generic map (
		vlayout_id  => 1 -- 0:1920x1080, 1:800x600
	)
	port map (
		si_clk      => phy1_rxc,
		si_frm      => phy1_rx_dv,
		si_data     => phy1_rx_d,
		so_clk      => phy1_125clk,
		so_dv       => phy1_tx_en,
		so_data     => phy1_tx_d,
		ipcfg_req   => ipcfg_req,
		mscoreclk   => clk,
		mscorereset => rst,
		msclk       => usb_fpga_bd_dp,
		msdat       => usb_fpga_bd_dn,
		input_clk   => clk,
		input_data  => sample,
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
