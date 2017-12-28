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
	constant gauge_labels : string(1 to 9*26) := 
			"Escala     : Posicion   : " & "Escala     : Posicion   : " &
			"Escala     : Posicion   : " & "Escala     : Posicion   : " &
			"Escala     : Posicion   : " & "Escala     : Posicion   : " &
			"Escala     : Posicion   : " & "Escala     : Posicion   : " &
			"Escala     : Posicion   : ";
	constant unit_symbols : string(1 to 9*2) := (
   			"VV" & "VV" & "VV" & "VV" &
   			"VV" & "VV" & "VV" & "VV" & "VV");


	constant inputs : natural := 4;
	signal samples  : std_logic_vector(0 to 9*sample_size-1);
	constant channels_bg : std_logic_vector(0 to 9*vga_rgb'length-1) := (others => '0');
	constant channels_fg : std_logic_vector(0 to 9*vga_rgb'length-1) := b"110_011_101_111_001_110_011_101_111";
	signal channel_ena : std_logic_vector(0 to 9-1) := b"1111_1111_1";


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

	process (sys_clk)
		variable cntr : unsigned(0 to 18-1);
	begin
		if rising_edge(sys_clk) then
			cntr := cntr + 1;
			jd(1 to 4) <= std_logic_vector(cntr(0 to 4-1));
		end if;
	end process;
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
			clkout0_divide_f => 10.0,
			bandwidth        => "LOW")
		port map (
			pwrdwn   => '0',
			rst      => '0',
			clkin1   => adc_clkin,
			clkfbin  => adc_clkfb,
			clkfbout => adc_clkfb,
			clkout0  => input_clk);
	end block;
   
	xadc_b : block
		signal eoc     : std_logic;
		signal di      : std_logic_vector(0 to 16-1);
		signal dwe     : std_logic;
		signal den     : std_logic;
		signal daddr   : std_logic_vector(0 to 7-1);
		signal channel : std_logic_vector(0 to 5-1);
		signal vauxp   : std_logic_vector(16-1 downto 0);
		signal vauxn   : std_logic_vector(16-1 downto 0);
		signal sample  : std_logic_vector(sample_size-1 downto 0);
	begin
		vauxp <= vaux_p(16-1 downto 12) & "0000" & vaux_p(8-1 downto 4) & "0000";
		vauxn <= vaux_n(16-1 downto 12) & "0000" & vaux_n(8-1 downto 4) & "0000";

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
			reset     => '0',
			vauxp     => vauxp,
			vauxn     => vauxn,
			vp        => v_p(0),
			vn        => v_n(0),
			convstclk => '0',
			convst    => '0',

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
			constant mp  : std_logic_vector(0 to 9*32-1) := (
				(1 to 3*9 => '0') & b"1000_0000_0" & (1 to 12*9 => '0') &
				(1 to 4*9 => '0') & b"0000_0100_0" & b"0000_0010_0" & b"0000_0001_0" & b"0000_0000_1" &
				(1 to 4*9 => '0') & b"0100_0000_0" & b"0010_0000_0" & b"0001_0000_0" & b"0000_1000_0");
			variable pp : std_logic_vector(0 to 9-1);

		begin
			if rising_edge(input_clk) then
				if input_ena='1' then
					samples <= byte2word(samples, sample, word2byte(fill(mp, 9*128) ,daddr));
				end if;
			end if;
		end process;

		process(input_clk)
			variable reset     : std_logic := '1';
			variable den_req   : std_logic := '1';
			variable tdiv_aux  : std_logic_vector(tdiv'range);
			variable cfg_req   : std_logic := '0';
			variable cfg_state : unsigned(0 to 1) := "00";
			variable drp_rdy   : std_logic;
			variable aux : std_logic_vector(tdiv_aux'range);
		begin
			if rising_edge(input_clk) then
				if reset='0' then 
					den <= '0';
					dwe <= '0';
					if cfg_req='1' then
						dwe <= '0';
						den <= '0';
						if drp_rdy='1' then
							case cfg_state is 
							when "00" => 
								den       <= '1';
								daddr     <= b"100_0001";
								dwe       <= '1';
								di        <= x"0000";
								cfg_state := "01";
								cfg_req   := '1';
							when "01" =>
								den       <= '1';
								daddr     <= b"100_1001";
								dwe       <= '1';
								case tdiv is
								when "000" =>
									di <= x"0000";
									channel_ena <= b"1000_0000_0";
								when "0001" =>
									di <= x"1000";
									channel_ena <= b"1100_0000_0";
								when "0010" =>
									di <= x"7000";
									channel_ena <= b"1111_0000_0";
								when others =>
									di <= x"f0f0";
									channel_ena <= b"1111_1111_1";
								end case;
								cfg_state := "10";
								cfg_req   := '1';
							when "10" =>
								den       <= '1';
								daddr     <= b"100_0001";
								dwe       <= '1';
								di        <= x"2000";
								cfg_state := "00";
								cfg_req   := '0';
							when others =>
							end case;
							drp_rdy := '0';
						end if;
					elsif eoc='1' then
						daddr <= std_logic_vector(resize(unsigned(channel), daddr'length));
						if drp_rdy='1' then
							den     <= '1';
							drp_rdy := '0';
						end if;
						if tdiv_aux /= tdiv then
							cfg_req := '1';
						end if;
						tdiv_aux := tdiv;
					end if;
				else
					den <= '1';
					drp_rdy := '1';
					reset   := '0';
				end if;
				if input_ena='1' then
					drp_rdy := '1';
				end if;

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
		gauge_labels => to_ascii(gauge_labels(1 to inputs*26) & "Horizontal : " & "Disparo    : "),
		unit_symbols => to_ascii(unit_symbols(1 to inputs*2) & "s" & "V"),
		input_unit   => 100.0*(1.25*64.0)/8192.0,
		channels_fg  => channels_fg(0 to vga_rgb'length*inputs-1),
		channels_bg  => channels_bg(0 to vga_rgb'length*inputs-1),
		hzaxis_fg    => b"010",
		hzaxis_bg    => b"000",
		grid_fg      => b"100",
		grid_bg      => b"000")
	port map (
		mii_rxc     => eth_rxclk_bufg,
		mii_rxdv    => mii_rxdv,
		mii_rxd     => mii_rxd,
		channel_ena => channel_ena(0 to inputs-1),
		input_clk   => input_clk,
		input_ena   => input_ena,
		input_data  => samples(0 to sample_size*inputs-1),
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
