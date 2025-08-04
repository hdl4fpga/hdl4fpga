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
use ieee.math_real.all;

library ecp3;
use ecp3.components.all;

library hdl4fpga;
use hdl4fpga.hdo.all;
use hdl4fpga.base.all;
use hdl4fpga.sdrampkg.all;
use hdl4fpga.ipoepkg.all;
use hdl4fpga.videopkg.all;
use hdl4fpga.ecp3_profiles.all;

architecture graphics of ecp3versa is

	constant settings : string := "{"                                                              &
		"io_link: io_usb,"                                                                         &
		"video:{"                                                                                  &
			"dcm:"          & string'(hdl4fpga.ecp3_profiles.video_dcm(".'100mhz'.'40mhz'")) & ',' &
			"gear:"         & "4"                                                                  & ',' &
			"timings:"      & string'(hdl4fpga.videopkg.timings_db**".'800x600'.'@60'.'40mhz'")    & ',' &
			"pixel:{"                                                                              &
				"R:8,"                                                                             &
				"G:8,"                                                                             &
				"B:8}},"                                                                           &
		"sdram:{"                                                                                  &
			"dcm:"       & string'(hdl4fpga.ecp3_profiles.sdram_dcm(".'100mhz'.'400mhz'"))         & ',' &
			"chip_data:" & string'(hdo(sdram_db)**".MT41J64M16-15E")                               & ',' &
			"phy_data:"  & string'(hdo(phy_db)**".ecp3g4")                                         & ',' &
			"cwl:"       & "'001'"                                                                 & ',' &                             
			"cl:"        & "'0010'}}";

	constant io_link      : string  := settings**".io_link";

	signal sys_rst       : std_logic;
	alias sys_clk is clk;

	constant mem_size : natural := 8*(1024*8);
	alias sio_clk is phy1_125clk;
	signal so_frm          : std_logic;
	signal so_irdy         : std_logic;
	signal so_trdy         : std_logic;
	signal so_data         : std_logic_vector(0 to 8-1);
	signal si_frm          : std_logic;
	signal si_irdy         : std_logic;
	signal si_trdy         : std_logic;
	signal si_end          : std_logic;
	signal si_data         : std_logic_vector(0 to 8-1);

	constant video_gear    : natural := 4; --video_params.gear;
	signal video_clk       : std_logic;
	signal video_lck       : std_logic;
	signal video_shift_clk : std_logic;
	signal video_eclk      : std_logic;
	signal video_pixel     : std_logic_vector(settings**".video.pixel.R=8"+settings**".video.pixel.G=8"+settings**".video.pixel.B=8"-1 downto 0);
	signal dvid_crgb       : std_logic_vector(4*video_gear-1 downto 0);
	signal videoio_clk     : std_logic;

	constant sdram_freq    : real := sdram_freq(settings**".sdram.dcm");
	constant sdram_gear    : natural := hdo(settings)**".sdram.phy_data.orgz.gear";
	constant ba_latency    : natural := 1;

	signal ctlrdcm_clkok   : std_logic;
	signal ctlrdcm_clkop   : std_logic;
	signal ctlrdcm_clkos   : std_logic;
	signal ctlrdcm_lock    : std_logic;
	signal ctlrdcm_phase   : std_logic_vector(4-1 downto 0);
	signal ctlrdcm_eclk    : std_logic;
	signal ctlrdcm_sclk    : std_logic;
	signal ctlrdcm_sclk2x  : std_logic;

	signal ctlr_rst        : std_logic;
	alias ctlr_clk         : std_logic is ctlrdcm_sclk;
	signal ctlr_eclk       : std_logic;
	signal ctlr_lck        : std_logic;

	signal ctlrphy_rst     : std_logic_vector(0 to 2-1);
	signal ctlrphy_cke     : std_logic_vector(0 to 2-1);
	signal ctlrphy_cs      : std_logic_vector(0 to 2-1);
	signal ctlrphy_ras     : std_logic_vector(0 to 2-1);
	signal ctlrphy_cas     : std_logic_vector(0 to 2-1);
	signal ctlrphy_we      : std_logic_vector(0 to 2-1);
	signal ctlrphy_odt     : std_logic_vector(0 to 2-1);
	signal ctlrphy_cmd     : std_logic_vector(0 to 3-1);
	signal ctlrphy_b       : std_logic_vector(sdram_gear/2*ddr3_b'length-1 downto 0);
	signal ctlrphy_a       : std_logic_vector(sdram_gear/2*ddr3_a'length-1 downto 0);
	signal ctlrphy_dqsi    : std_logic_vector(sdram_gear*ddr3_dqs'length-1 downto 0);
	signal ctlrphy_dqst    : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_dqso    : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_dmi     : std_logic_vector(sdram_gear*ddr3_dm'length-1 downto 0);
	signal ctlrphy_dmo     : std_logic_vector(sdram_gear*ddr3_dm'length-1 downto 0);
	signal ctlrphy_dqt     : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_dqi     : std_logic_vector(sdram_gear*ddr3_dq'length-1 downto 0);
	signal ctlrphy_dqo     : std_logic_vector(sdram_gear*ddr3_dq'length-1 downto 0);
	signal ctlrphy_dqv     : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_sto     : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_sti     : std_logic_vector(sdram_gear*ddr3_dm'length-1 downto 0);

	signal ctlrphy_frm     : std_logic;
	signal ctlrphy_trdy    : std_logic;
	signal ctlrphy_ini     : std_logic;
	signal ctlrphy_rw      : std_logic;
	signal ctlrphy_wlreq   : std_logic;
	signal ctlrphy_wlrdy   : std_logic;
	signal ctlrphy_rlreq   : std_logic;
	signal ctlrphy_rlrdy   : std_logic;
	signal sdrphy_rst      : std_logic;

	signal physys_clk    : std_logic;

	signal ddr_b        : std_logic_vector(ddr3_b'length-1 downto 0);
	signal ddr_a         : std_logic_vector(ddr3_a'length-1 downto 0);

	signal tp             : std_logic_vector(1 to 32);
	alias  sin_clk        : std_logic is phy1_125clk;

	attribute oddrapps : string;
	attribute oddrapps of phy1_gtxclk_i : label is "SCLK_ALIGNED";
	attribute oddrapps of phy1_txc_i    : label is "SCLK_ALIGNED";

begin

	sys_rst <= '0';
	videodcm_e : entity hdl4fpga.ecp3_videodcm
	generic map (
		settings     => settings**".video")
	port map (
		clk         => sys_clk,
		video_clk   => video_clk,
		video_shift_clk => video_shift_clk,
		video_lck   => video_lck);

	sdramdcm_e  : entity hdl4fpga.ecp3_sdramdcm
	generic map (
		settings => "{dcm:" & string'(settings**".sdram.dcm") & '}')
	port map (
		clk   => clk,
		clkop => ctlrdcm_clkop,
		clkos => ctlrdcm_clkos,
		clkok => ctlrdcm_clkok,
		phase => ctlrdcm_phase,
		lock  => ctlrdcm_lock);

	gmii_e : entity hdl4fpga.link_mii
	generic map (
		rmii          => false,
		default_mac   => x"00_40_00_01_02_03",
		default_ipv4a => aton("192.168.0.14"),
		n             => phy1_rx_d'length)
	port map (
		si_frm     => si_frm,
		si_irdy    => si_irdy,
		si_trdy    => si_trdy,
		si_end     => si_end,
		si_data    => si_data,
	
		so_frm     => so_frm,
		so_irdy    => so_irdy,
		so_trdy    => so_trdy,
		so_data    => so_data,
		dhcp_btn   => '0',
		mii_txc    => phy1_125clk,
		mii_txen   => phy1_tx_en,
		mii_txd    => phy1_tx_d,

		mii_rxc    => phy1_rxc,
		mii_rxdv   => phy1_rx_dv,
		mii_rxd    => phy1_rx_d);   

	graphics_e : entity hdl4fpga.app_graphics
	generic map (
		debug        => debug, -- true,
		profile      => 2,
		burst_length => 8,
		sdram_freq   => sdram_freq/2.0,
		settings     => settings,
		fifo_size    => mem_size)
	port map (
		tp => tp,
		sin_clk      => sio_clk,
		sin_frm      => so_frm,
		sin_irdy     => so_irdy,
		sin_trdy     => so_trdy,
		sin_data     => so_data,
		sout_clk     => sio_clk,
		sout_frm     => si_frm,
		sout_irdy    => si_irdy,
		sout_trdy    => si_trdy,
		sout_end     => si_end,
		sout_data    => si_data,

		video_clk    => video_clk,
		video_shift_clk => video_shift_clk,
		video_pixel  => video_pixel,
		dvid_crgb    => dvid_crgb,

		ctlr_clk     => ctlr_clk,
		ctlr_rst     => ctlr_rst,
		ctlr_bl      => "00",
		ctlr_cl      => settings**".sdram.cl",
		ctlr_cwl     => settings**".sdram.cwl",
		ctlr_rtt     => "001",
		ctlr_cmd     => ctlrphy_cmd,

		ctlrphy_wlreq => ctlrphy_wlreq,
		ctlrphy_wlrdy => ctlrphy_wlrdy,
		ctlrphy_rlreq => ctlrphy_rlreq,
		ctlrphy_rlrdy => ctlrphy_rlrdy,

		ctlrphy_irdy => ctlrphy_frm,
		ctlrphy_trdy => ctlrphy_trdy,
		ctlrphy_ini  => ctlrphy_ini,
		ctlrphy_rw   => ctlrphy_rw,

		ctlrphy_rst  => ctlrphy_rst(0),
		ctlrphy_cke  => ctlrphy_cke(0),
		ctlrphy_cs   => ctlrphy_cs(0),
		ctlrphy_ras  => ctlrphy_ras(0),
		ctlrphy_cas  => ctlrphy_cas(0),
		ctlrphy_we   => ctlrphy_we(0),
		ctlrphy_odt  => ctlrphy_odt(0),
		ctlrphy_b    => ddr_b,
		ctlrphy_a    => ddr_a,
		ctlrphy_dqst => ctlrphy_dqst,
		ctlrphy_dqso => ctlrphy_dqso,
		ctlrphy_dmo  => ctlrphy_dmo,
		ctlrphy_dqi  => ctlrphy_dqi,
		ctlrphy_dqt  => ctlrphy_dqt,
		ctlrphy_dqo  => ctlrphy_dqo,
		ctlrphy_dqv  => ctlrphy_dqv,
		ctlrphy_sto  => ctlrphy_sto,
		ctlrphy_sti  => ctlrphy_sti);

	tp(2) <= (ctlrphy_wlreq xor ctlrphy_wlrdy);
	tp(3) <= (ctlrphy_rlreq xor ctlrphy_rlrdy);
	tp(4) <= ctlrphy_ini;

	process (ddr_b)
	begin
		for i in ddr_b'range loop
			for j in 0 to sdram_gear/2-1 loop
				ctlrphy_b(j*ddr_b'length+i) <= ddr_b(i);
			end loop;
		end loop;
	end process;

	process (ddr_a)
	begin
		for i in ddr_a'range loop
			for j in 0 to sdram_gear/2-1 loop
				ctlrphy_a(j*ddr_a'length+i) <= ddr_a(i);
			end loop;
		end loop;
	end process;

	ctlrphy_rst(1) <= ctlrphy_rst(0);
	ctlrphy_cke(1) <= ctlrphy_cke(0);
	ctlrphy_cs(1)  <= ctlrphy_cs(0);
	ctlrphy_ras(1) <= '1';
	ctlrphy_cas(1) <= '1';
	ctlrphy_we(1)  <= '1';
	ctlrphy_odt(1) <= ctlrphy_odt(0);

	sdrphy_rst <= not ctlr_lck;
	process (ctlr_lck, ctlr_clk)
	begin
		if ctlr_lck='0' then
			ctlr_rst <= '1';
		elsif rising_edge(ctlr_clk) then
			ctlr_rst <= '0';
		end if;
	end process;
	
	sdrphy_b : block
		port (
			rst    : in  std_logic;
			sclk   : in  std_logic;
			sclk2x : in  std_logic;
			eclk   : in  std_logic);
		port map (
			rst    => sdrphy_rst,
			sclk   => ctlrdcm_clkok,
			sclk2x => ctlrdcm_clkop,
			eclk   => ctlrdcm_clkos);
		signal eclksynca_clk  : std_logic;

		signal dqsbuf_rst : std_logic;
		signal dqsdel     : std_logic;
		signal all_lock   : std_logic;
		signal uddcntln   : std_logic;

		signal reset : std_logic;
		signal reset_datapath : std_logic := '0';

		component ecp3_csa
			generic (
				period_eclk        : real);
			port  (
				reset              : in  std_logic;
				reset_datapath     : in  std_logic;
				refclk             : in  std_logic;
				clkop              : in  std_logic;
				clkos              : in  std_logic;
				clkok              : in  std_logic;
				uddcntln           : in  std_logic;
				pll_phase          : out std_logic_vector(4-1 downto 0);
				pll_lock           : in std_logic;
				eclk               : out std_logic;
				sclk               : out std_logic;
				sclk2x             : out std_logic;
				reset_datapath_out : out std_logic;
				dqsdel             : out std_logic;
				all_lock           : out std_logic;
				align_status       : out std_logic_vector(2-1 downto 0);
				good               : out std_logic;
				err                : out std_logic);
		end component;

		signal locked : std_logic_vector(ddr3_dqs'range);
	begin

		dqsdll_uddcntln_b : block
			signal update : std_logic;
		begin
			process (sclk)
				variable q : std_logic_vector(0 to 4-1);
			begin
				if rising_edge(sclk) then
					if rst='1' then
						q := (others => '0');
					elsif q(0)='0' then
						if all_lock='1' then
							q := std_logic_vector((unsigned(gray2bin(q))+1));
						end if;
					end if;
					update <= not q(0);
				end if;
			end process;

			process (sclk2x)
			begin
				if rising_edge(sclk2x) then
					uddcntln <= update;
				end if;
			end process;
		end block;

		reset <= not ctlrdcm_lock;
		ecp3_csa_e : ecp3_csa
		generic map (
			period_eclk => 1.0/sdram_freq)
		port map (
			reset              => reset,
			reset_datapath     => reset_datapath,
			refclk             => sys_clk, 
			clkop              => ctlrdcm_clkop,
			clkos              => ctlrdcm_clkos, 
			clkok              => ctlrdcm_clkok, 
			uddcntln           => uddcntln,
			pll_phase          => ctlrdcm_phase, 
			pll_lock           => ctlrdcm_lock, 
			eclk               => ctlrdcm_eclk,
			sclk               => ctlrdcm_sclk,
			sclk2x             => ctlrdcm_sclk2x, 
			reset_datapath_out => dqsbuf_rst,
			dqsdel             => dqsdel,
			all_lock           => all_lock,
			align_status       => open, 
			good               => ctlr_lck, 
			err                => open);

		sdrphy_e : entity hdl4fpga.ecp3_sdrphy
		generic map (
			taps      => natural(floor(26.0e12/sdram_freq)),
			gear      => sdram_gear,
			bank_size => ddr3_b'length,
			addr_size => ddr3_a'length,
			word_size  => ddr3_dq'length,
			byte_size  => ddr3_dq'length/ddr3_dm'length)
		port map (
			rst       => dqsbuf_rst,
			sclk      => ctlrdcm_clkok,
			sclk2x    => ctlrdcm_clkop,
			eclk      => ctlrdcm_eclk,
			dqsdel    => dqsdel,
			phy_locked    => locked,
			phy_frm   => ctlrphy_frm,
			phy_trdy  => ctlrphy_trdy,
			phy_cmd   => ctlrphy_cmd,
			phy_rw    => ctlrphy_rw,
			phy_ini   => ctlrphy_ini,

			phy_wlreq => ctlrphy_wlreq,
			phy_wlrdy => ctlrphy_wlrdy,

			phy_rlreq => ctlrphy_rlreq,
			phy_rlrdy => ctlrphy_rlrdy,

			sys_rst   => ctlrphy_rst,
			sys_cs    => ctlrphy_cs,
			sys_cke   => ctlrphy_cke,
			sys_ras   => ctlrphy_ras,
			sys_cas   => ctlrphy_cas,
			sys_we    => ctlrphy_we,
			sys_odt   => ctlrphy_odt,
			sys_b     => ctlrphy_b,
			sys_a     => ctlrphy_a,
			sys_dqsi  => ctlrphy_dqso,
			sys_dqst  => ctlrphy_dqst,
			sys_dqso  => ctlrphy_dqsi,
			sys_dmi   => ctlrphy_dmo,
			sys_dmo   => ctlrphy_dmi,
			sys_dqi   => ctlrphy_dqo,
			sys_dqt   => ctlrphy_dqt,
			sys_dqo   => ctlrphy_dqi,
			sys_sti   => ctlrphy_sto,
			sys_sto   => ctlrphy_sti,

			sdram_rst => ddr3_rst,
			sdram_ck  => ddr3_clk,
			sdram_cke => ddr3_cke,
			sdram_cs  => ddr3_cs,
			sdram_ras => ddr3_ras,
			sdram_cas => ddr3_cas,
			sdram_we  => ddr3_we,
			sdram_odt => ddr3_odt,
			sdram_b   => ddr3_b,
			sdram_a   => ddr3_a,

			sdram_dm  => ddr3_dm,
			sdram_dq  => ddr3_dq,
			sdram_dqs => ddr3_dqs);

	end block;

	-- VGA --
	---------

	phy1_txc_i : oddrxd1
	port map (
		sclk => phy1_rxc,
		da   => '0',
		db   => '1',
		q    => phy1_txc);

	phy1_gtxclk_i : oddrxd1
	port map (
		sclk => phy1_125clk,
		da   => '0',
		db   => '1',
		q    => phy1_gtxclk);

	phy1_rst <= '1';

end;
