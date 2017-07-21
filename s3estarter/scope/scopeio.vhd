library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library unisim;
use unisim.vcomponents.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.cgafont.all;

architecture beh of s3estarter is

	signal sys_clk    : std_logic;
	signal vga_clk    : std_logic;

	constant sample_size : natural := 14;

	function sinctab (
		constant x0 : integer;
		constant x1 : integer;
		constant n  : integer)
		return std_logic_vector is
		variable y   : real;
		variable aux : std_logic_vector(0 to n*(x1-x0+1)-1);
	begin
		for i in 0 to x1-x0 loop
			y := sin(2.0*MATH_PI*real((i+x0))/64.0); --/(real((i+x0))/100.0);
			aux(i*n to (i+1)*n-1) := std_logic_vector(to_unsigned(integer(real(2**(n-2))*y),n));
--			if i=1599 then
--				aux(i*n to (i+1)*n-1) := (others => '0');
--			else
--				aux(i*n to (i+1)*n-1) := ('1',others => '0');
--			end if;
		end loop;
		return aux;
	end;

	signal sample    : std_logic_vector(2*sample_size-1 downto 0);
	signal spi_clk   : std_logic;
	signal spiclk_rd : std_logic;
	signal spiclk_fd : std_logic;
	signal sckamp_rd : std_logic;
	signal sckamp_fd : std_logic;
	signal amp_sdi   : std_logic;
	signal amp_spi   : std_logic;
	signal amp_rdy   : std_logic;
	signal adc_spi   : std_logic;
	signal adconv    : std_logic;
	signal ampcs     : std_logic;
	signal spi_rst   : std_logic;
begin

	clkin_ibufg : ibufg
	port map (
		I => xtal,
		O => sys_clk);

	videodcm_e : entity hdl4fpga.dfs
	generic map (
		dcm_per => 20.0,
		dfs_mul => 3,
		dfs_div => 1)
	port map(
		dcm_rst => '0',
		dcm_clk => sys_clk,
		dfs_clk => vga_clk);

	spidcm_e : entity hdl4fpga.dfs2dfs
	generic map (
		dcm_per => 20.0,
		dfs1_mul => 32,
		dfs1_div => 25,
		dfs2_mul => 4,
		dfs2_div => 5)
	port map(
		dcm_rst => '0',
		dcm_clk => sys_clk,
		dfs_clk => spi_clk,
		dcm_lck => spi_rst);

	spiclk_rd <= sckamp_rd when amp_spi='1' else '1' ;
	spiclk_fd <= sckamp_fd when amp_spi='1' else '0' ;
	spi_mosi  <= amp_sdi;

	spi_sck_e : entity hdl4fpga.ddro
	port map (
		clk => spi_clk,
		dr  => spiclk_rd,
		df  => spiclk_fd,
		q   => spi_sck);

	ampclkr_p : process (spi_rst, spi_clk)
		variable cntr : unsigned(0 to 4-1);
	begin
		if spi_rst='0' then
			cntr := (others => '0');
			sckamp_rd <= cntr(0);
			adc_spi <= '1';
		elsif rising_edge(spi_clk) then
			cntr := cntr + 1;
			sckamp_rd <= cntr(0);
		end if;
	end process;

	ampclkf_p: process (spi_clk)
	begin
		if spi_rst='0' then
			sckamp_fd <= '0';
		elsif falling_edge(spi_clk) then
			sckamp_fd <= sckamp_rd;
		end if;
	end process;

	ampp2sr_p : process (spi_rst, sckamp_fd)
	begin
		if spi_rst='0' then
			ampcs <= '1';
		elsif falling_edge(sckamp_fd) then
			ampcs <= not amp_rdy;
		end if;
	end process;
	amp_cs <= ampcs;

	ampp2sf_p : process (spi_rst, sckamp_fd)
		variable cntr : unsigned(0 to 3);
		variable val  : unsigned(0 to 8-1) := B"0001_0001";
	begin
		if spi_rst='0' then
			amp_spi <= '0';
			amp_rdy <= '0';
			amp_sdi <= '0';
			cntr    := "0001";
		elsif falling_edge(sckamp_fd) then
			if ampcs='0' then
				if cntr(0)='0' then
					cntr := cntr + 1;
					val  := val sll 1;
				end if;
			end if;
			amp_sdi <= val(0);
			amp_rdy <= not cntr(0);
			amp_spi <= not cntr(0) or not ampcs;
		end if;
	end process;

	adcs2p_p : process (spi_clk)
		variable cntr : unsigned(0 to 5) := (others => '0');
		variable adin : unsigned(0 to 2*16);
		variable aux  : unsigned(adin'range);
		variable aux1 : unsigned(sample'range);
	begin
		if rising_edge(spi_clk) then
			adconv  <= cntr(0);
			aux     := adin;
			aux1    := unsigned(sample);
			if cntr(0)='1' then
				for i in 0 to 2-1 loop
					aux := aux sll ((adin'length-sample'length)/2);
					aux1(sample_size-1 downto 0) := aux(0 to sample_size-1);
					aux1 := aux1 sll sample_size;
					aux  := aux  srl 16;
				end loop;
				sample <= std_logic_vector(aux1);
				cntr   := to_unsigned(2**cntr'right-2, cntr'length);
			else
				cntr := cntr - 1;
			end if;
			adin    := adin sll 1;
			adin(0) := spi_miso;
		end if;
	end process;
	ad_conv <= '0' when amp_spi='1' else adconv;

	scopeio_e : entity hdl4fpga.scopeio
	port map (
		mii_rxc     => e_rx_clk,
		mii_rxdv    => e_rx_dv,
		mii_rxd     => e_rxd,
		input_clk   => spi_clk,
		input_ena   => adconv,
		input_data  => sample,
		video_clk   => vga_clk,
		video_red   => vga_red,
		video_green => vga_green,
		video_blue  => vga_blue,
		video_hsync => vga_hsync,
		video_vsync => vga_vsync);

	-- Ethernet Transceiver --
	--------------------------

	e_txen <= 'Z';
	e_txd  <= (others => 'Z');
	e_mdc  <= '0';
	e_mdio <= 'Z';
	e_txd_4 <= '0';

	-- DDR --
	---------

	ddr_clk_i : obufds
	generic map (
		iostandard => "DIFF_SSTL2_I")
	port map (
		i  => 'Z',
		o  => sd_ck_p,
		ob => sd_ck_n);

	sd_cke    <= 'Z';
	sd_cs     <= 'Z';
	sd_ras    <= 'Z';
	sd_cas    <= 'Z';
	sd_we     <= 'Z';
	sd_ba     <= (others => 'Z');
	sd_a      <= (others => 'Z');
	sd_dm     <= (others => 'Z');
	sd_dqs    <= (others => 'Z');
	sd_dq     <= (others => 'Z');

	amp_shdn <= '1';
	dac_clr <= '0';
	dac_cs <= '0';

end;
