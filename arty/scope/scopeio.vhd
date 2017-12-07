library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library unisim;
use unisim.vcomponents.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.cgafont.all;

architecture beh of arty is

	signal sys_clk    : std_logic;
	signal vga_clk    : std_logic;
	signal vga_hsync  : std_logic;
	signal vga_vsync  : std_logic;
	signal vga_rgb    : std_logic_vector(0 to 3-1);

	constant sample_size : natural := 16;

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
			aux(i*n to (i+1)*n-1) := std_logic_vector(to_signed(integer((2.0**(n-1)-1.0)*sin(2.0*MATH_PI*real(i)/real(x1-x0+1))), n));
		end loop;
		return aux;
	end;

	constant inputs : natural := 1;
	signal sample   : std_logic_vector(inputs*sample_size-1 downto 0);

	signal input_addr : std_logic_vector(11-1 downto 0);


	constant hz_scales : scale_vector(0 to 16-1) := (
		(from => 0.0, step => 2.50001*5.0*10.0**(-1), mult => 10**0*2**0*5**0, scale => "0001", deca => x"E6"),
		(from => 0.0, step => 5.00001*5.0*10.0**(-1), mult => 10**0*2**0*5**0, scale => "0010", deca => x"E6"),
                                                                                                 
		(from => 0.0, step => 1.00001*5.0*10.0**(+0), mult => 10**0*2**1*5**0, scale => "0100", deca => x"E6"),
		(from => 0.0, step => 2.50001*5.0*10.0**(+0), mult => 10**0*2**0*5**1, scale => "0101", deca => x"E6"),
		(from => 0.0, step => 5.00001*5.0*10.0**(+0), mult => 10**1*2**0*5**0, scale => "0110", deca => x"E6"),
                                                   
		(from => 0.0, step => 1.00001*5.0*10.0**(+1), mult => 10**1*2**1*5**0, scale => "1000", deca => x"E6"),
		(from => 0.0, step => 2.50001*5.0*10.0**(+1), mult => 10**1*2**0*5**1, scale => "1001", deca => x"E6"),
		(from => 0.0, step => 5.00001*5.0*10.0**(+1), mult => 10**2*2**0*5**0, scale => "1010", deca => x"E6"),
                                                   
		(from => 0.0, step => 1.00001*5.0*10.0**(-1), mult => 10**2*2**1*5**0, scale => "0000", deca => to_ascii('m')),
		(from => 0.0, step => 2.50001*5.0*10.0**(-1), mult => 10**2*2**0*5**1, scale => "0001", deca => to_ascii('m')),
		(from => 0.0, step => 5.00001*5.0*10.0**(-1), mult => 10**3*2**0*5**0, scale => "0010", deca => to_ascii('m')),

		(from => 0.0, step => 1.00001*5.0*10.0**(+0), mult => 10**3*2**1*5**0, scale => "0100", deca => to_ascii('m')),
		(from => 0.0, step => 2.50001*5.0*10.0**(+0), mult => 10**3*2**0*5**1, scale => "0101", deca => to_ascii('m')),
		(from => 0.0, step => 5.00001*5.0*10.0**(+0), mult => 10**4*2**0*5**0, scale => "0110", deca => to_ascii('m')),

		(from => 0.0, step => 1.00001*5.0*10.0**(+1), mult => 10**4*2**1*5**0, scale => "1000", deca => to_ascii('m')),
		(from => 0.0, step => 2.50001*5.0*10.0**(+1), mult => 10**4*2**0*5**1, scale => "1001", deca => to_ascii('m')));

	constant vt_scales : scale_vector(0 to 16-1) := (
		(from => 7*1.00001*10.0**(+1), step => -1.00001*10.0**(+1), mult => (100*2**18)/(128*10**0*2**1*5**0), scale => "1000", deca => to_ascii('m')),
		(from => 7*2.50001*10.0**(+1), step => -2.50001*10.0**(+1), mult => (100*2**18)/(128*10**0*2**0*5**1), scale => "1001", deca => to_ascii('m')),
		(from => 7*5.00001*10.0**(+1), step => -5.00001*10.0**(+1), mult => (100*2**18)/(128*10**0*2**1*5**1), scale => "1010", deca => to_ascii('m')),
                                                                                                                
		(from => 7*1.00001*10.0**(-1), step => -1.00001*10.0**(-1), mult => (100*2**18)/(128*10**1*2**1*5**0), scale => "0000", deca => to_ascii(' ')),
		(from => 7*2.50001*10.0**(-1), step => -2.50001*10.0**(-1), mult => (100*2**18)/(128*10**1*2**0*5**1), scale => "0001", deca => to_ascii(' ')),
		(from => 7*5.00001*10.0**(-1), step => -5.00001*10.0**(-1), mult => (100*2**18)/(128*10**1*2**1*5**1), scale => "0010", deca => to_ascii(' ')),
                                                                                                                
		(from => 7*1.00001*10.0**(+0), step => -1.00001*10.0**(+0), mult => (100*2**18)/(128*10**2*2**1*5**0), scale => "0100", deca => to_ascii(' ')),
		(from => 7*2.50001*10.0**(+0), step => -2.50001*10.0**(+0), mult => (100*2**18)/(128*10**2*2**0*5**1), scale => "0101", deca => to_ascii(' ')),
		(from => 7*5.00001*10.0**(+0), step => -5.00001*10.0**(+0), mult => (100*2**18)/(128*10**2*2**1*5**1), scale => "0110", deca => to_ascii(' ')),
                                                                                                                
		(from => 7*1.00001*10.0**(+1), step => -1.00001*10.0**(+1), mult => (100*2**18)/(128*10**3*2**1*5**0), scale => "1000", deca => to_ascii(' ')),
		(from => 7*2.50001*10.0**(+1), step => -2.50001*10.0**(+1), mult => (100*2**18)/(128*10**3*2**0*5**1), scale => "1001", deca => to_ascii(' ')),
		(from => 7*5.00001*10.0**(+1), step => -5.00001*10.0**(+1), mult => (100*2**18)/(128*10**3*2**1*5**1), scale => "1010", deca => to_ascii(' ')),
                                                                                                              
		(from => 7*1.00001*10.0**(-1), step => -1.00001*10.0**(-1), mult => (100*2**18)/(128*10**4*2**1*5**0), scale => "0000", deca => to_ascii('k')),
		(from => 7*2.50001*10.0**(-1), step => -2.50001*10.0**(-1), mult => (100*2**18)/(128*10**4*2**0*5**1), scale => "0001", deca => to_ascii('k')),
		(from => 7*5.00001*10.0**(-1), step => -5.00001*10.0**(-1), mult => (100*2**18)/(128*10**4*2**1*5**1), scale => "0010", deca => to_ascii('k')),
                                                                                                              
		(from => 7*1.00001*10.0**(+0), step => -1.00001*10.0**(+0), mult => (125*2**18)/(128*10**5*2**0*5**0), scale => "0100", deca => to_ascii('k')));


	signal eth_rxclk_bufg : std_logic;
	signal eth_txclk_bufg : std_logic;
	signal mii_rxdv       : std_logic;
	signal mii_rxd        : std_logic_vector(eth_rxd'range);
	signal mii_txen       : std_logic;
	signal mii_txd        : std_logic_vector(eth_txd'range);

begin

	clkin_ibufg : ibufg
	port map (
		I => gclk100,
		O => sys_clk);

	videodcm_e : block
		signal clkfb : std_logic;
	begin
		mmcme2base_i : mmcme2_base
		generic map (
			clkin1_period    => 10.0,
			clkfbout_mult_f  => 6.0,		-- 200 MHz
			clkout0_divide_f => 4.0,
			bandwidth        => "LOW")
		port map (
			pwrdwn   => '0',
			rst      => '0',
			clkin1   => sys_clk,
			clkfbin  => clkfb,
			clkfbout => clkfb,
			clkout0  => vga_clk);
	end block;
   
--	samples_e : entity hdl4fpga.rom
--	generic map (
--		bitrom => sinctab(0, 2047, sample_size))
--	port map (
--		clk  => adc_clkout,
--		addr => input_addr,
--		data => sample(sample_size-1 downto 0));
--
--	sample(2*sample_size-1 downto sample_size) <= not sample(sample_size-1 downto 0);
--	process (adc_clkout)
--	begin
--		if rising_edge(adc_clkout) then
--			input_addr <= std_logic_vector(unsigned(input_addr) + 1);
--		end if;
--	end process;

	xadc_b : block
		signal vauxp : std_logic_vector(0 downto 16-1);
		signal vauxn : std_logic_vector(0 downto 16-1);
		signal convstclk : std_logic;
		signal convst : std_logic;
		signal busy : std_logic;
		signal eoc : std_logic;
		signal eos : std_logic;
		signal den : std_logic;
	begin
		vauxp(ck_an_p'range) <= ck_an_p;
		vauxn(ck_an_n'range) <= ck_an_n;

		xadc_e : xadc
		port map (
			reset     => '0',
			vauxp     => vauxp,
			vauxn     => vauxn,
			vp        => v_p(0),
			vn        => v_n(0),
			convstclk => convstclk,
			convst    => convst,
			busy      => busy,
			eoc       => eoc,
			eos       => eos,

			dclk      => sys_clk,
			daddr     => b"000_0011",
			den       => den,
			dwe       => '0',
			di        => (others => '0'),
			do        => sample); 

	end block;

	scopeio_e : entity hdl4fpga.scopeio
	generic map (
		layout_id    => 0,
		hz_scales    => hz_scales,
		vt_scales    => vt_scales,
		inputs       => inputs,
		gauge_labels => to_ascii(string'(
			"Escala     : " &
			"Posicion   : " &
			"Escala     : " &
			"Posicion   : " &
			"Horizontal : " &
			"Disparo    : ")),
		unit_symbols => to_ascii(string'(
			"V" &
			"V" &
			"V" &
			"V" &
			"s" &
			"V")),
		input_unit   => 100.0*(1.25*64.0)/8192.0,
		channels_fg  => b"110" & b"011",
		channels_bg  => b"000" & b"000",
		hzaxis_fg    => b"010",
		hzaxis_bg    => b"000",
		grid_fg      => b"100",
		grid_bg      => b"000")
	port map (
		mii_rxc     => eth_rxclk_bufg,
		mii_rxdv    => mii_rxdv,
		mii_rxd     => mii_rxd,
		input_clk   => sys_clk,
		input_data  => sample,
		video_clk   => vga_clk,
		video_rgb   => vga_rgb,
		video_hsync => vga_hsync,
		video_vsync => vga_vsync,
		video_blank => open);

	process (vga_clk)
	begin
		if rising_edge(vga_clk) then
			ja(1)  <= word2byte(vga_rgb, std_logic_vector(to_unsigned(0,2)), 1)(0);
			ja(2)  <= word2byte(vga_rgb, std_logic_vector(to_unsigned(1,2)), 1)(0);
			ja(3)  <= word2byte(vga_rgb, std_logic_vector(to_unsigned(2,2)), 1)(0);
			ja(9)  <= vga_hsync;
			ja(10) <= vga_vsync;
		end if;
	end process;
  
	eth_rx_clk_ibufg : ibufg
	port map (
		I => eth_rx_clk,
		O => eth_rxclk_bufg);

	eth_tx_clk_ibufg : ibufg
	port map (
		I => eth_tx_clk,
		O => eth_txclk_bufg);

	mii_iob_e : entity hdl4fpga.mii_iob
	generic map (
		xd_len => 4)
	port map (
		mii_rxc  => eth_rxclk_bufg,
		iob_rxdv => eth_rx_dv,
		iob_rxd  => eth_rxd,
		mii_rxdv => mii_rxdv,
		mii_rxd  => mii_rxd,

		mii_txc  => eth_txclk_bufg,
		mii_txen => mii_txen,
		mii_txd  => mii_txd,
		iob_txen => eth_tx_en,
		iob_txd  => eth_txd);

	eth_rstn <= '1';
	eth_mdc  <= '0';
	eth_mdio <= '0';

	ddr3_reset <= 'Z';
	ddr3_clk_p <= 'Z';
	ddr3_clk_n <= 'Z';
	ddr3_cke   <= 'Z';
	ddr3_cs    <= 'Z';
	ddr3_ras   <= 'Z';
	ddr3_cas   <= 'Z';
	ddr3_we    <= 'Z';
	ddr3_ba    <= (others => '1');
	ddr3_a     <= (others => '1');
	ddr3_dm    <= (others => 'Z');
	ddr3_dq    <= (others => 'Z');
	ddr3_odt   <= 'Z';

	ddr3_dqs_p <= (others => 'Z');
	ddr3_dqs_n <= (others => 'Z');


end;
