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
	signal input_clk  : std_logic;
	signal input_ena  : std_logic;

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
		(from => 7*1.00001*10.0**(+1), step => -1.00001*10.0**(+1), mult => (50*2**18)/(512*10**0*2**1*5**0), scale => "1000", deca => to_ascii('m')),
		(from => 7*2.50001*10.0**(+1), step => -2.50001*10.0**(+1), mult => (50*2**18)/(512*10**0*2**0*5**1), scale => "1001", deca => to_ascii('m')),
		(from => 7*5.00001*10.0**(+1), step => -5.00001*10.0**(+1), mult => (50*2**18)/(512*10**0*2**1*5**1), scale => "1010", deca => to_ascii('m')),
                                                                                                                
		(from => 7*1.00001*10.0**(-1), step => -1.00001*10.0**(-1), mult => (50*2**18)/(512*10**1*2**1*5**0), scale => "0000", deca => to_ascii(' ')),
		(from => 7*2.50001*10.0**(-1), step => -2.50001*10.0**(-1), mult => (50*2**18)/(512*10**1*2**0*5**1), scale => "0001", deca => to_ascii(' ')),
		(from => 7*5.00001*10.0**(-1), step => -5.00001*10.0**(-1), mult => (50*2**18)/(512*10**1*2**1*5**1), scale => "0010", deca => to_ascii(' ')),
                                                                                                                
		(from => 7*1.00001*10.0**(+0), step => -1.00001*10.0**(+0), mult => (50*2**18)/(512*10**2*2**1*5**0), scale => "0100", deca => to_ascii(' ')),
		(from => 7*2.50001*10.0**(+0), step => -2.50001*10.0**(+0), mult => (50*2**18)/(512*10**2*2**0*5**1), scale => "0101", deca => to_ascii(' ')),
		(from => 7*5.00001*10.0**(+0), step => -5.00001*10.0**(+0), mult => (50*2**18)/(512*10**2*2**1*5**1), scale => "0110", deca => to_ascii(' ')),
                                                                                                                
		(from => 7*1.00001*10.0**(+1), step => -1.00001*10.0**(+1), mult => (50*2**18)/(512*10**3*2**1*5**0), scale => "1000", deca => to_ascii(' ')),
		(from => 7*2.50001*10.0**(+1), step => -2.50001*10.0**(+1), mult => (50*2**18)/(512*10**3*2**0*5**1), scale => "1001", deca => to_ascii(' ')),
		(from => 7*5.00001*10.0**(+1), step => -5.00001*10.0**(+1), mult => (50*2**18)/(512*10**3*2**1*5**1), scale => "1010", deca => to_ascii(' ')),
                                                                                                              
		(from => 7*1.00001*10.0**(-1), step => -1.00001*10.0**(-1), mult => (50*2**18)/(512*10**4*2**1*5**0), scale => "0000", deca => to_ascii('k')),
		(from => 7*2.50001*10.0**(-1), step => -2.50001*10.0**(-1), mult => (50*2**18)/(512*10**4*2**0*5**1), scale => "0001", deca => to_ascii('k')),
		(from => 7*5.00001*10.0**(-1), step => -5.00001*10.0**(-1), mult => (50*2**18)/(512*10**4*2**1*5**1), scale => "0010", deca => to_ascii('k')),
                                                                                                              
		(from => 7*1.00001*10.0**(+0), step => -1.00001*10.0**(+0), mult => (50*2**18)/(512*10**5*2**0*5**0), scale => "0100", deca => to_ascii('k')));


	signal eth_rxclk_bufg : std_logic;
	signal eth_txclk_bufg : std_logic;
	signal mii_rxdv       : std_logic;
	signal mii_rxd        : std_logic_vector(eth_rxd'range);
	signal mii_txen       : std_logic;
	signal mii_txd        : std_logic_vector(eth_txd'range);
	signal tdiv           : std_logic_vector(0 to 4-1);

begin

	clkin_ibufg : ibufg
	port map (
		I => gclk100,
		O => sys_clk);

	dcm_e : block
		signal vga_clkfb : std_logic;
		signal adc_clkfb : std_logic;
		signal adc_clkin : std_logic;
	begin
		vga_i : mmcme2_base
		generic map (
			clkin1_period    => 10.0,
			clkfbout_mult_f  => 6.0,		-- 200 MHz
			clkout0_divide_f => 4.0,
			clkout1_divide   => 15,
			bandwidth        => "LOW")
		port map (
			pwrdwn   => '0',
			rst      => '0',
			clkin1   => sys_clk,
			clkfbin  => vga_clkfb,
			clkfbout => vga_clkfb,
			clkout0  => vga_clk,
			clkout1  => adc_clkin);

		adc_i : mmcme2_base
		generic map (
			clkin1_period    => 10.0*15.0/6.0,
			clkfbout_mult_f  => 13.0*2.0,		-- 200 MHz
			clkout0_divide_f => 20.0,
			bandwidth        => "LOW")
		port map (
			pwrdwn   => '0',
			rst      => '0',
			clkin1   => adc_clkin,
			clkfbin  => adc_clkfb,
			clkfbout => adc_clkfb,
			clkout0  => input_clk);
	end block;
   
--	samples_e : entity hdl4fpga.rom
--	generic map (
--		bitrom => sinctab(0, 2047, sample_size))
--	port map (
--		clk  => input_clk,
--		addr => input_addr,
--		data => sample(sample_size-1 downto 0));

--	sample(2*sample_size-1 downto sample_size) <= not sample(sample_size-1 downto 0);
--	process (input_clk)
--	begin
--		if rising_edge(input_clk) then
--			input_addr <= std_logic_vector(unsigned(input_addr) + 1);
--		end if;
--	end process;

	xadc_b : block
		signal eoc     : std_logic;
		signal di      : std_logic_vector(0 to 16-1);
		signal dwe     : std_logic;
		signal den     : std_logic;
		signal daddr   : std_logic_vector(0 to 7-1);
		signal channel : std_logic_vector(0 to 5-1);
		signal vauxp   : std_logic_vector(0 to 16-1);
		signal vauxn   : std_logic_vector(0 to 16-1);
	begin
		vauxp(vaux_p'range) <= vaux_p;
--		vauxn(vaux_n'range) <= vaux_n;

		xadc_e : xadc
		generic map (
		
			INIT_40 => X"0403",
			INIT_41 => X"2000",
			INIT_42 => X"0000",
			
			INIT_48 => x"0800",
			INIT_49 => X"0000",

			INIT_4A => X"0000",
			INIT_4B => X"0000",

			INIT_4C => X"0800",
			INIT_4D => X"0000",

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
			INIT_5C => X"0000")
		port map (
			reset     => '0',
			vauxp     => vauxp,
			vauxn     => vauxn,
			vp        => v_p(0),
			vn        => v_n(0),
			convstclk => '-',
			convst    => '-',

			eoc       => eoc,
			dclk      => input_clk,
			drdy      => input_ena,
			channel   => channel,
			daddr     => daddr,
			den       => den,
			dwe       => dwe,
			di        => di,
			do        => sample); 

		process(input_clk)
			variable reset    : std_logic := '1';
			variable den_req  : std_logic;
			variable tdiv_aux : std_logic_vector(tdiv'range);
		begin
			if rising_edge(input_clk) then
				den <= '0';
				if eoc='1' then
					den   <= '1';
					reset := '0';

					daddr <= std_logic_vector(resize(unsigned(channel), daddr'length));
--					if tdiv_aux /= tdiv then
--						dwe   <= '1';
--						daddr <= b"100_1001";
--						case tdiv is
--						when "0000" =>
--							di <= x"0000";
--						when "0001" =>
--							di <= x"0001";
--						when "0010" => 
--							di <= x"0007";
--						when "0011" => 
--							di <= x"08ff";
--						when others => 
--							di <= x"ffff";
--						end case;
--					end if;
--					tdiv_aux := tdiv;
				elsif reset='1' then
--					den   <= '1';
				end if;

				dwe <= '0';
			end if;
		end process;

	end block;

--	sample <= x"00ff";
	scopeio_e : entity hdl4fpga.scopeio
	generic map (
		layout_id    => 0,
		hz_scales    => hz_scales,
		vt_scales    => vt_scales,
		inputs       => inputs,
		gauge_labels => to_ascii(string'(
			"Escala     : " &
			"Posicion   : " &
			"Horizontal : " &
			"Disparo    : ")),
		unit_symbols => to_ascii(string'(
			"V" &
			"V" &
			"s" &
			"V")),
		input_unit   => 100.0*(1.25*64.0)/8192.0,
		channels_fg  => b"110",
		channels_bg  => b"000",
		hzaxis_fg    => b"010",
		hzaxis_bg    => b"000",
		grid_fg      => b"100",
		grid_bg      => b"000")
	port map (
		mii_rxc     => eth_rxclk_bufg,
		mii_rxdv    => mii_rxdv,
		mii_rxd     => mii_rxd,
		input_clk   => input_clk,
		input_ena   => input_ena,
		input_data  => sample,
		tdiv        => tdiv,
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
			ja(4)  <= vga_hsync;
			ja(10) <= vga_vsync;
		end if;
	end process;
  
	process (sys_clk)
		variable div : unsigned(0 to 1) := (others => '0');
	begin
		if rising_edge(sys_clk) then
			div := div + 1;
			eth_ref_clk <= div(0);
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
