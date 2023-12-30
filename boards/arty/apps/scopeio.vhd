library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library unisim;
use unisim.vcomponents.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.profiles.all;
use hdl4fpga.ipoepkg.all;
use hdl4fpga.videopkg.all;
use hdl4fpga.textboxpkg.all;
use hdl4fpga.scopeiopkg.all;
use hdl4fpga.app_profiles.all;

architecture scopeio of arty is

	type layout_mode is (
		mode600p, 
		mode1080p,
		mode480p);

	--------------------------------------
	--     Set your profile here        --
	constant video_mode : layout_mode := mode1080p;
	constant io_link    : io_comms := io_ipoe;
	--------------------------------------
	constant tsttab : boolean := false;

	constant max_delay     : natural := 2**14;
	constant hzoffset_bits : natural := unsigned_num_bits(max_delay-1);
	constant vt_step       : real := 1.0e3*milli/2.0**16; -- Volts

	constant inputs        : natural := 9;
	signal input_clk       : std_logic;
	signal input_lck       : std_logic;
	signal input_ena       : std_logic;
	signal input_sample    : std_logic_vector(16-1 downto 0);
	signal input_samples   : std_logic_vector(0 to inputs*input_sample'length-1);
	signal input_maxchn    : std_logic_vector(4-1 downto 0);

	signal sys_clk         : std_logic;
	signal video_clk       : std_logic;
	signal video_hzsync    : std_logic;
	signal video_vtsync    : std_logic;
	signal video_blank     : std_logic;
	signal video_pixel     : std_logic_vector(0 to 3-1);

	alias  sio_clk         is eth_tx_clk;
	signal si_frm          : std_logic;
	signal si_irdy         : std_logic;
	signal si_data         : std_logic_vector(eth_rxd'range);

	signal so_frm          : std_logic;
	signal so_irdy         : std_logic;
	signal so_trdy         : std_logic;
	signal so_end          : std_logic;
	signal so_data         : std_logic_vector(eth_txd'range);

	signal udpip_frm       : std_logic;
	signal udpip_irdy      : std_logic;
	signal udpip_data      : std_logic_vector(eth_rxd'range);

	signal xadccfg_req     : bit;
	signal xadccfg_rdy     : bit;

	type display_param is record
		timing_id : videotiming_ids;
		mul       : natural;
		div       : natural;
	end record;

	type displayparam_vector is array (layout_mode) of display_param;
	constant video_params : displayparam_vector := (
		mode480p  => (timing_id => pclk25_00m640x480at60,       mul => 3, div => 5),
		mode600p  => (timing_id => pclk40_00m800x600at60,       mul => 4, div => 5),
		mode1080p => (timing_id => pclk150_00m1920x1080at60,    mul => 3, div => 1));

begin

	clkin_ibufg : ibufg
	port map (
		I => gclk100,
		O => sys_clk);

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

		adc1_rst <= not video_lck or btn(1);
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
   
	ipoe_e : if io_link=io_ipoe generate
		signal mii_txd    : std_logic_vector(eth_txd'range);
		signal mii_txen   : std_logic;
		signal dhcpcd_req : std_logic := '0';
		signal dhcpcd_rdy : std_logic := '0';

		signal miirx_frm  : std_logic;
		signal miirx_irdy : std_logic;
		signal miirx_data : std_logic_vector(eth_rxd'range);

		signal miitx_frm  : std_logic;
		signal miitx_irdy : std_logic;
		signal miitx_trdy : std_logic;
		signal miitx_end  : std_logic;
		signal miitx_data : std_logic_vector(si_data'range);

	begin

		process (sys_clk)
			variable div : unsigned(0 to 1) := (others => '0');
		begin
			if rising_edge(sys_clk) then
				div := div + 1;
				eth_ref_clk <= div(0);
			end if;
		end process;

		dhcp_p : process(eth_tx_clk)
			type states is (s_request, s_wait);
			variable state : states;
		begin
			if rising_edge(eth_tx_clk) then
				case state is
				when s_request =>
					if btn(0)='1' then
						dhcpcd_req <= not dhcpcd_rdy;
						state := s_wait;
					end if;
				when s_wait =>
					if to_bit(dhcpcd_req xor dhcpcd_rdy)='0' then
						if btn(0)='0' then
							state := s_request;
						end if;
					end if;
				end case;
			end if;
		end process;

		sync_b : block

			signal rxc_rxbus : std_logic_vector(0 to eth_rxd'length);
			signal txc_rxbus : std_logic_vector(0 to eth_rxd'length);
			signal dst_irdy  : std_logic;
			signal dst_trdy  : std_logic;

		begin

			process (eth_rx_clk)
			begin
				if rising_edge(eth_rx_clk) then
					rxc_rxbus <= eth_rx_dv & eth_rxd;
				end if;
			end process;

			rxc2txc_e : entity hdl4fpga.fifo
			generic map (
				max_depth  => 4,
				latency    => 0,
				dst_offset => 0,
				src_offset => 2,
				check_sov  => false,
				check_dov  => true,
				gray_code  => false)
			port map (
				src_clk  => eth_rx_clk,
				src_data => rxc_rxbus,
				dst_clk  => eth_tx_clk,
				dst_irdy => dst_irdy,
				dst_trdy => dst_trdy,
				dst_data => txc_rxbus);

			process (eth_tx_clk)
			begin
				if rising_edge(eth_tx_clk) then
					dst_trdy   <= to_stdulogic(to_bit(dst_irdy));
					miirx_frm  <= txc_rxbus(0);
					miirx_irdy <= txc_rxbus(0);
					miirx_data <= txc_rxbus(1 to eth_rxd'length);
				end if;
			end process;
		end block;

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
			so_frm     => udpip_frm,
			so_irdy    => udpip_irdy,
			so_data    => udpip_data);

		desser_e: entity hdl4fpga.desser
		port map (
			desser_clk => eth_tx_clk,

			des_frm    => miitx_frm,
			des_irdy   => miitx_irdy,
			des_trdy   => miitx_trdy,
			des_data   => miitx_data,

			ser_irdy   => open,
			ser_data   => mii_txd);

		mii_txen <= miitx_frm and not miitx_end;
		process (eth_tx_clk)
		begin
			if rising_edge(eth_tx_clk) then
				eth_tx_en <= mii_txen;
				eth_txd   <= mii_txd;
			end if;
		end process;

	end generate;

	inputs_b : block
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
			sin_frm   => udpip_frm,
			sin_irdy  => udpip_irdy,
			sin_data  => udpip_data,
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
			hz_slider => hz_slider);

		process (hz_scale)
		begin
			case hz_scale is
			when x"0" =>
				opacity <= b"1_0000_0000";
			when x"1" =>
				opacity <= b"1_1000_0000";
			when x"2" =>
				opacity <= b"1_1110_0000";
			when x"3" =>
				opacity <= b"1_1111_0000";
			when others =>
				opacity <= b"1_1111_1111";
			end case;
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
						opacity_frm <= not udpip_frm;
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

		si_frm  <= udpip_frm  when opacity_frm='0' else '1';
		si_irdy <= udpip_irdy when opacity_frm='0' else '1';
		si_data <= udpip_data when opacity_frm='0' else opacity_data;

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
		videotiming_id   => video_params(video_mode).timing_id,
		hz_unit          => 31.25*micro,
		vt_steps         => (0 to 3 => vt_step, 4 to inputs-1 => 3.32 * vt_step),
		vt_unit          => 500.0*micro,
		inputs           => inputs,
		input_names      => (
			text(id => "vt(0).text", content => "V_P(+) V_N(-)"),
			text(id => "vt(1).text", content => "A6(+)  A7(-)"),
			text(id => "vt(2).text", content => "A8(+)  A9(-)"),
			text(id => "vt(3).text", content => "A10(+) A11(-)"),
			text(id => "vt(4).text", content => "A0(+)"),
			text(id => "vt(5).text", content => "A1(+)"),
			text(id => "vt(6).text", content => "A2(+)"),
			text(id => "vt(7).text", content => "A3(+)"),
			text(id => "vt(8).text", content => "A4(+)")),
		layout => "",
		hz_factors       => (
			 0 => 2**(0+0)*5**(0+0),  1 => 2**(0+0)*5**(0+0),  2 => 2**(0+0)*5**(0+0),  3 => 2**(0+0)*5**(0+0),
			 4 => 2**(0+0)*5**(0+0),  5 => 2**(1+0)*5**(0+0),  6 => 2**(2+0)*5**(0+0),  7 => 2**(0+0)*5**(1+0),
			 8 => 2**(0+1)*5**(0+1),  9 => 2**(1+1)*5**(0+1), 10 => 2**(2+1)*5**(0+1), 11 => 2**(0+1)*5**(1+1),
			12 => 2**(0+2)*5**(0+2), 13 => 2**(1+2)*5**(0+2), 14 => 2**(2+2)*5**(0+2), 15 => 2**(0+2)*5**(1+2)),

		default_tracesfg => b"1_110" & b"0_011" & b"0_101" & b"0_111" & b"0_110" & b"0_011" & b"0_101" & b"0_111" & b"0_001",
		default_gridfg   => b"1_100",
		default_gridbg   => b"1_000",
		default_hzfg     => b"1_111",
		default_hzbg     => b"1_001",
		default_vtfg     => b"0_111",
		default_vtbg     => b"1_001",
		default_textfg   => b"1_111",
		default_textbg   => b"1_000",
		default_sgmntbg  => b"1_011",
		default_bg       => b"1_111")
	port map (
		sio_clk     => sio_clk,
		si_frm      => si_frm,
		si_irdy     => si_irdy,
		si_data     => si_data,
		so_data     => so_data,
		input_clk   => input_clk,
		input_ena   => input_ena,
		input_data  => input_samples,
		video_clk   => video_clk,
		video_pixel => video_pixel,
		video_hsync => video_hzsync,
		video_vsync => video_vtsync,
		video_blank => video_blank);

	process (video_clk)
	begin
		if rising_edge(video_clk) then
			ja(1)  <= multiplex(video_pixel, std_logic_vector(to_unsigned(0,2)), 1)(0);
			ja(2)  <= multiplex(video_pixel, std_logic_vector(to_unsigned(1,2)), 1)(0);
			ja(3)  <= multiplex(video_pixel, std_logic_vector(to_unsigned(2,2)), 1)(0);
			ja(4)  <= video_hzsync;
			ja(10) <= video_vtsync;
		end if;
	end process;
  
	synth_g : if tsttab generate
		constant size : natural := 256;

		function sintab (
			constant size       : natural;
			constant resolution : natural := 16;
			constant unipolar   : boolean := false)
			return std_logic_vector  is
			constant pi     : real := 4.0*arctan(1.0);
			variable retval : std_logic_vector(0 to size*resolution-1);
		begin
			for i in 0 to size-1 loop
				retval(resolution*i to resolution*(i+1)-1) := std_logic_vector(to_signed(integer((2.0**(resolution-1)-1.0)*sin(2.0*pi*real(i)/real(size))), resolution));
			end loop;
			return retval;
		end;

		signal addr : unsigned(0 to unsigned_num_bits(size-1)-1);

	begin
		process (input_clk)
		begin
			if rising_edge(input_clk) then
				addr <= addr + 1;
			end if;
		end process;

		rom_e : entity hdl4fpga.rom
		generic map (
			bitrom => sintab(size => 2**addr'length, resolution => input_sample'length))
		port map (
			addr => std_logic_vector(addr),
			data => input_sample);

		input_ena <= '1';
		input_samples(0*input_sample'length to (0+1)*input_sample'length-1) <= input_sample;

	end generate;

	xadcctlr_b : if not tsttab generate
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
						input_samples(4*input_sample'length to (4+1)*input_sample'length-1) <= input_sample;
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

	ddr3_reset <= 'Z';
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

	ddr_ck_i   : obufds  generic map ( iostandard => "DIFF_SSTL135") port map ( i => '0', o => ddr3_clk_p, ob => ddr3_clk_n);
	ddr_dqs0_i : iobufds generic map ( iostandard => "DIFF_SSTL135") port map ( t => '1', i => '0', io => ddr3_dqs_p(0), iob => ddr3_dqs_n(0));
	ddr_dqs1_i : iobufds generic map ( iostandard => "DIFF_SSTL135") port map ( t => '1', i => '0', io => ddr3_dqs_p(1), iob => ddr3_dqs_n(1));

end;
