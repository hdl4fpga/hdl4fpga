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

	constant sample_size : natural := 9;

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

	signal samples_doa : std_logic_vector(sample_size-1 downto 0);
	signal samples_dib : std_logic_vector(sample_size-1 downto 0);
	signal sample      : std_logic_vector(sample_size-1 downto 0);

	signal input_addr : std_logic_vector(11-1 downto 0);

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
	port map (
		mii_rxc     => e_rx_clk,
		mii_rxdv    => e_rx_dv,
		mii_rxd     => e_rxd,
		input_clk   => sys_clk,
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

end;
