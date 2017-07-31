library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library unisim;
use unisim.vcomponents.all;

library hdl4fpga;
use hdl4fpga.std.all;

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

	signal sample    : std_logic_vector(1*sample_size-1 downto 0);
	signal spi_clk   : std_logic;
	signal spiclk_rd : std_logic;
	signal spiclk_fd : std_logic;
	signal sckamp_rd : std_logic;
	signal sckamp_fd : std_logic;
	signal amp_spi   : std_logic;
	signal amp_sdi   : std_logic;
	signal amp_rdy   : std_logic;
	signal adc_spi   : std_logic;
	signal adconv    : std_logic;
	signal ampcs     : std_logic;
	signal spi_rst   : std_logic;
	signal dac_sdi   : std_logic;
	signal rot_cwse  : std_logic;
	signal rot_rdy   : std_logic;
	signal input_ena : std_logic;
	signal xx : std_logic;
	signal ppp : std_logic_vector(32-1 downto 0);
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
		dcm_rst => btn_north,
		dcm_clk => sys_clk,
		dfs_clk => vga_clk);

	spi_b: block
	begin
		spidcm_e : entity hdl4fpga.dfs
		generic map (
			dcm_per => 20.0,
			dfs_mul => 25,
			dfs_div => 32)
		port map(
			dcm_rst => btn_north ,
			dcm_clk => sys_clk,
			dfs_clk => spi_clk,
			dcm_lck => spi_rst);


		spiclk_rd <= '0' when spi_rst='0' else sckamp_rd when amp_spi='1' else '0' ;
		spiclk_fd <= '0' when spi_rst='0' else sckamp_fd when amp_spi='1' else '1' ;
		spi_mosi  <= amp_sdi   when amp_spi='1' else dac_sdi;

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
				amp_cs <= ampcs;
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
				ampcs <= not amp_rdy or not amp_spi;
			end if;
		end process;

		ampp2sf_p : process (spi_rst, sckamp_fd)
			variable cntr : unsigned(0 to 4);
			variable val  : unsigned(0 to 8-1);
		begin
			if spi_rst='0' then
				amp_spi <= '1';
				amp_rdy <= '0';
				amp_sdi <= '0';
				cntr    := to_unsigned(val'length-2,cntr'length);
				val     := B"0001_0001";
			elsif falling_edge(sckamp_fd) then
				if ampcs='0' then
					if cntr(0)='0' then
						cntr := cntr - 1;
						val  := val rol 1;
					end if;
				end if;
				amp_sdi <= val(0);
				amp_rdy <= not cntr(0);
				amp_spi <= not cntr(0) or not ampcs;
			end if;
		end process;

		adcs2p_p : process (amp_spi, spi_clk)
			variable cntr : unsigned(0 to 6) := (others => '0');
			variable adin : unsigned(33-1 downto 0) := (others => '0');
			variable aux  : unsigned(0 to 33-1);
			variable aux1 : unsigned(sample'range);
			variable aux2 : unsigned(0 to 34-1);
			variable adac : std_logic;
			variable pp   : unsigned(0 to 12-1);
			variable pppp  : unsigned(1 to 12-1);
		begin
			if amp_spi='1' then
				cntr    := to_unsigned(35-2, cntr'length);
				aux2    := "-1--------00110000100000000000----";
				adac    := not setif(adac/='0');
				dac_sdi <= '0';
				dac_cs  <= '1';
			elsif rising_edge(spi_clk) then
				aux     := adin;
				if cntr(0)='1' then
					for i in 0 to 2-1 loop
						aux1 := aux1 sll sample_size;
						aux1(sample_size-1 downto 0) := aux(0 to sample_size-1);
						aux  := aux sll 16;
					end loop;
					if adac='0' then
						sample <= std_logic_vector(aux1(sample_size-1 downto 0));
						ppp <= std_logic_vector(adin(32-1 downto 0));
						ppp <= std_logic_vector(resize(unsigned(sample),32));
						ppp <= std_logic_vector(resize(aux1(sample_size-1 downto 0),32));
					end if;
					cntr   := to_unsigned(35-2, cntr'length);
					aux2   := b"10_1000_1000_1000_1000_1000_1000_1000_1001";
					aux2   := "-1--------00110000" & pp & "-00-";
					if adac='1' then
						pp  := resize(pppp, pp'length) + unsigned'(b"0100_0000_0000"); 
						pppp := pppp + 1;
					end if;
					adac   := not setif(adac/='0');
				else
					cntr := cntr - 1;
					aux2 := aux2 sll 1;
				end if;
				adin    := adin sll 1;
				adin(0) := spi_miso;
				adconv  <= adac and (setif(cntr=(cntr'range =>'0'))) and not amp_spi;
				input_ena  <= not adac and cntr(0) and not amp_spi;

				dac_cs  <= (not adac or cntr(0)) or amp_spi;
				dac_sdi <= aux2(0);
			end if;
		end process;

		ad_conv <= adconv;

	end block;

	process (e_rx_clk, rot_a, rot_b)
		variable cntr : unsigned(0 to 12);
	begin
		if (rot_a or rot_b)='1' then
			if cntr(0)='1' then
				cntr := (others => '0');
			end if;
			rot_cwse <= rot_a;
		elsif rising_edge(xtal) then
			if cntr(0)='0' then
				cntr := cntr + 1;
			end if;
			rot_rdy <= cntr(0);
		end if;
	end process;

	scopeio_e : entity hdl4fpga.scopeio
	port map (
		mii_rxc     => e_rx_clk,
		mii_rxdv    => e_rx_dv,
		mii_rxd     => e_rxd,
		data => ppp,
		input_clk   => spi_clk,
		input_ena   => input_ena,
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

	amp_shdn <= '0';
	dac_clr <= '1';
	sf_ce0 <= '1';
	fpga_init_b <= '0';
	spi_ss_b <= '0';

	led0 <= '1';
	led1 <= '1';
	led2 <= '1';
	led3 <= '1';
	led4 <= '1';
	led5 <= '1';
	led6 <= '1';
	led7 <= '1';
end;
