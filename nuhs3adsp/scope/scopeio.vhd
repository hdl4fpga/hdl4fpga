library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library unisim;
use unisim.vcomponents.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.cgafont.all;

architecture beh of nuhs3adsp is

	signal sys_clk    : std_logic;
	signal vga_clk    : std_logic;
	signal vga_hsync  : std_logic;
	signal vga_vsync  : std_logic;
	signal vga_rgb    : std_logic_vector(0 to 3*8-1);
	signal vga_blank  : std_logic;

	constant sample_size : natural := 14;

	function sinctab (
		constant x0 : integer;
		constant x1 : integer;
		constant n  : integer)
		return std_logic_vector is
		variable pp  : std_logic_vector(0 to n-1) := ('1', others => '0');
		variable aux : std_logic_vector(0 to n*(x1-x0+1)-1);
	begin
		for i in 0 to x1-x0 loop
			if i mod 64 = 63 then
				pp := not pp;
			end if;
			aux(i*n to (i+1)*n-1) := pp;
		end loop;
		return aux;
	end;

	signal samples_doa : std_logic_vector(sample_size-1 downto 0);
	signal samples_dib : std_logic_vector(sample_size-1 downto 0);
	signal sample      : std_logic_vector(sample_size-1 downto 0);

	signal input_addr : std_logic_vector(11-1 downto 0);

	constant hz_scales : scale_vector(0 to 16-1) := (
		(from => 0.0, step => 2.50001*5.0*10.0**(-1), mult => 'm'),
		(from => 0.0, step => 5.00001*5.0*10.0**(-1), mult => 'm'),

		(from => 0.0, step => 1.00001*5.0*10.0**(+0), mult => 'm'),
		(from => 0.0, step => 2.50001*5.0*10.0**(+0), mult => 'm'),
		(from => 0.0, step => 5.00001*5.0*10.0**(+0), mult => 'm'),
                                     
		(from => 0.0, step => 1.00001*5.0*10.0**(+1), mult => 'm'),
		(from => 0.0, step => 2.50001*5.0*10.0**(+1), mult => 'm'),
		(from => 0.0, step => 5.00001*5.0*10.0**(+1), mult => 'm'),
                                     
		(from => 0.0, step => 1.00001*5.0*10.0**(+2), mult => 'm'),
		(from => 0.0, step => 2.50001*5.0*10.0**(+2), mult => 'm'),
		(from => 0.0, step => 5.00001*5.0*10.0**(+2), mult => 'm'),
                                     
		(from => 0.0, step => 1.00001*5.0*10.0**(+3), mult => 'm'),
		(from => 0.0, step => 2.50001*5.0*10.0**(+3), mult => 'm'),
		(from => 0.0, step => 5.00001*5.0*10.0**(+3), mult => 'm'),

		(from => 0.0, step => 1.00001*5.0*10.0**(+4), mult => 'm'),
		(from => 0.0, step => 2.50001*5.0*10.0**(+4), mult => 'm'));

	constant vt_scales : scale_vector(0 to 16-1) := (
		(from => 7*1.00001*10.0**(+1), step => -1.00001*10.0**(+1), mult => 'u'),
		(from => 7*2.50001*10.0**(+1), step => -2.50001*10.0**(+1), mult => 'u'),
		(from => 7*5.00001*10.0**(+1), step => -5.00001*10.0**(+1), mult => 'u'),

		(from => 7*1.00001*10.0**(-1), step => -1.00001*10.0**(-1), mult => 'u'),
		(from => 7*2.50001*10.0**(-1), step => -2.50001*10.0**(-1), mult => 'u'),
		(from => 7*5.00001*10.0**(-1), step => -5.00001*10.0**(-1), mult => 'u'),

		(from => 7*1.00001*10.0**(+0), step => -1.00001*10.0**(+0), mult => 'u'),
		(from => 7*2.50001*10.0**(+0), step => -2.50001*10.0**(+0), mult => 'u'),
		(from => 7*5.00001*10.0**(+0), step => -5.00001*10.0**(+0), mult => 'u'),

		(from => 7*1.00001*10.0**(+1), step => -1.00001*10.0**(+1), mult => 'u'),
		(from => 7*2.50001*10.0**(+1), step => -2.50001*10.0**(+1), mult => 'u'),
		(from => 7*5.00001*10.0**(+1), step => -5.00001*10.0**(+1), mult => 'u'),

		(from => 7*1.00001*10.0**(-1), step => -1.00001*10.0**(-1), mult => 'u'),
		(from => 7*2.50001*10.0**(-1), step => -2.50001*10.0**(-1), mult => 'u'),
		(from => 7*5.00001*10.0**(-1), step => -5.00001*10.0**(-1), mult => 'u'),

		(from => 7*1.00001*10.0**(+0), step => -1.00001*10.0**(+0), mult => 'u'));

begin

	clkin_ibufg : ibufg
	port map (
		I => xtal,
		O => sys_clk);

	videodcm_e : entity hdl4fpga.dfs
	generic map (
		dcm_per => 50.0,
		dfs_mul => 15,
		dfs_div => 2)
	port map(
		dcm_rst => '0',
		dcm_clk => sys_clk,
		dfs_clk => vga_clk);

	mii_dfs_e : entity hdl4fpga.dfs
	generic map (
		dcm_per => 50.0,
		dfs_mul => 5,
		dfs_div => 4)
	port map (
		dcm_rst => '0',
		dcm_clk => sys_clk,
		dfs_clk => mii_refclk);

	samples_e : entity hdl4fpga.rom
	generic map (
		bitrom => sinctab(0, 2047, sample_size))
	port map (
		clk  => sys_clk,
		addr => input_addr,
		data => sample);

	process (sys_clk)
	begin
		if rising_edge(sys_clk) then
			input_addr <= std_logic_vector(unsigned(input_addr) + 1);
		end if;
	end process;

	scopeio_e : entity hdl4fpga.scopeio
	generic map (
		layout_id    => 0,
		hz_scales    => hz_scales,
		vt_scales    => vt_scales,
		inputs       => 1,
		gauge_labels => 
			"Escala     : " &
			"Posicion   : " &
			"Horizontal : " &
			"Disparo    : ",
		input_unit   => 100.0*(1.25*64.0)/8192.0,
		channels_fg  => b"11111111_11111111_00000000",
		channels_bg  => b"00000000_00000000_00000000",
		hzaxis_fg    => b"00000000_11111111_00000000",
		hzaxis_bg    => b"00000000_00000000_00000000",
		grid_fg      => b"11111111_00000000_00000000",
		grid_bg      => b"00000000_00000000_00000000")
	port map (
		mii_rxc     => mii_rxc,
		mii_rxdv    => mii_rxdv,
		mii_rxd     => mii_rxd,
		input_clk   => sys_clk,
		input_data  => sample,
		video_clk   => vga_clk,
		video_rgb   => vga_rgb,
		video_hsync => vga_hsync,
		video_vsync => vga_vsync,
		video_blank => vga_blank);

	process (vga_clk)
	begin
		if rising_edge(vga_clk) then
			red   <= word2byte(vga_rgb, std_logic_vector(to_unsigned(0,2)), 8);
			green <= word2byte(vga_rgb, std_logic_vector(to_unsigned(1,2)), 8);
			blue  <= word2byte(vga_rgb, std_logic_vector(to_unsigned(2,2)), 8);
			blank <= vga_blank;
			hsync <= vga_hsync;
			vsync <= vga_vsync;
			sync  <= not vga_hsync and not vga_vsync;
		end if;
	end process;
	psave <= '1';

	clk_videodac_e : entity hdl4fpga.ddro
	port map (
		clk => vga_clk,
		dr => '0',
		df => '1',
		q => clk_videodac);

	adc_clkab <= '0';
	hd_t_data <= 'Z';

	-- LEDs DAC --
	--------------
		
	led18 <= '0';
	led16 <= '0';
	led15 <= '0';
	led13 <= '0';
	led11 <= '0';
	led9  <= '0';
	led8  <= '0';
	led7  <= '0';

	-- RS232 Transceiver --
	-----------------------

	rs232_rts <= '0';
	rs232_td  <= '0';
	rs232_dtr <= '0';

	-- Ethernet Transceiver --
	--------------------------

	mii_rst  <= '1';
	mii_txen <= 'Z';
	mii_txd  <= (others => 'Z');
	mii_mdc  <= '0';
	mii_mdio <= 'Z';

	-- LCD --
	---------

	lcd_e <= 'Z';
	lcd_rs <= 'Z';
	lcd_rw <= 'Z';
	lcd_data <= (others => 'Z');
	lcd_backlight <= 'Z';

	-- DDR --
	---------

	ddr_clk_i : obufds
	generic map (
		iostandard => "DIFF_SSTL2_I")
	port map (
		i  => 'Z',
		o  => ddr_ckp,
		ob => ddr_ckn);

	ddr_st_dqs <= 'Z';
	ddr_cke    <= 'Z';
	ddr_cs     <= 'Z';
	ddr_ras    <= 'Z';
	ddr_cas    <= 'Z';
	ddr_we     <= 'Z';
	ddr_ba     <= (others => 'Z');
	ddr_a      <= (others => 'Z');
	ddr_dm     <= (others => 'Z');
	ddr_dqs    <= (others => 'Z');
	ddr_dq     <= (others => 'Z');

end;
