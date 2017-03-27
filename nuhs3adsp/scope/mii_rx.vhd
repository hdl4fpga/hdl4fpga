library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.cgafont.all;

architecture beh of nuhs3adsp is

	signal hdr_data  : std_logic_vector(288-1 downto 0);
	signal pld_data  : std_logic_vector(288-1 downto 0);
	signal pll_data  : std_logic_vector(0 to hdr_data'length+pld_data'length-1);
	signal ser_data  : std_logic_vector(32-1 downto 0);

	signal cga_we    : std_logic;
	signal cga_row   : std_logic_vector(5-1 downto 0);
	signal cga_col   : std_logic_vector(7-1 downto 0);
	signal cga_code  : std_logic_vector(8-1 downto 0);
	signal char_dot  : std_logic;

	signal vga_clk   : std_logic;
	signal vga_hsync : std_logic;
	signal vga_vsync : std_logic;
	signal vga_frm   : std_logic;
	signal vga_don   : std_logic;
	signal vga_vld   : std_logic;
	signal vga_rgb   : std_logic_vector(3-1 downto 0);
	signal vga_vcntr : std_logic_vector(11-1 downto 0);
	signal vga_hcntr : std_logic_vector(11-1 downto 0);

	signal vga_io    : std_logic_vector(0 to 3-1);
begin

	videodcm_e : entity hdl4fpga.dfs
	generic map (
		dcm_per => 50.0,
		dfs_mul => 15,
		dfs_div => 2)
	port map(
		dcm_rst => '0',
		dcm_clk => xtal,
		dfs_clk => vga_clk);

	mii_dfs_e : entity hdl4fpga.dfs
	generic map (
		dcm_per => 50.0,
		dfs_mul => 5,
		dfs_div => 4)
	port map (
		dcm_rst => '0',
		dcm_clk => xtal,
		dfs_clk => mii_refclk);

	miirx_e : entity hdl4fpga.scopeio_miirx
	port map (
		mii_rxc  => mii_rxc,
		mii_rxdv => mii_rxdv,
		mii_rxd  => mii_rxd,
		pll_data => pll_data,
		ser_data => ser_data);

	process (ser_data)
		variable data : unsigned(pll_data'range);
	begin
		data     := unsigned(pll_data);
		data     := data sll hdr_data'length;
		pld_data <= reverse(std_logic_vector(data(pld_data'reverse_range)));
	end process;

	process (pld_data)
		variable data : unsigned(pld_data'range);
	begin
		data     := unsigned(pld_data);
		cga_code <= std_logic_vector(data(cga_code'range));
		data     := data srl cga_code'length;
		cga_row  <= std_logic_vector(data(cga_row'range));
		data     := data srl cga_row'length;
		cga_col  <= std_logic_vector(data(cga_col'range));
	end process;

	vga_e : entity hdl4fpga.video_vga
	generic map (
		n => 11)
	port map (
		clk   => vga_clk,
		hsync => vga_hsync,
		vsync => vga_vsync,
		hcntr => vga_hcntr,
		vcntr => vga_vcntr,
		don   => vga_don,
		frm   => vga_frm);

	vga_vld <= vga_don and vga_frm;
	cga_e : entity hdl4fpga.cga
	generic map (
		bitrom   => psf1cp850x8x16,
		height   => 16,
		width    =>  8)
	port map (
		sys_clk  => vga_clk, --phy1_125clk,
		sys_we   => '1', --cga_we,
		sys_row  => vga_vcntr(10-1 downto 10-cga_row'length), --(cga_row'range => '0'),
		sys_col  => vga_hcntr(11-1 downto 11-cga_col'length), --(cga_col'range => '0'),
		sys_code => vga_hcntr(11-1 downto 11-8), --(cga_col'range => '0'),
		vga_clk  => vga_clk,
		vga_row  => vga_vcntr(10-1 downto 1),
		vga_col  => vga_hcntr(11-1 downto 1),
		vga_dot  => char_dot);

	vgaio_e : entity hdl4fpga.align
	generic map (
		n => vga_io'length,
		i => (vga_io'range => '-'),
		d => (vga_io'range => 3))
	port map (
		clk   => vga_clk,
		di(0) => vga_hsync,
		di(1) => vga_vsync,
		di(2) => vga_vld,
		do    => vga_io);

	vga_rgb <= (others => vga_io(2) and char_dot);

	process (vga_clk)
	begin
		if rising_edge(vga_clk) then
			red   <= (others => vga_rgb(2));
			green <= (others => vga_rgb(1));
			blue  <= (others => vga_rgb(0));
			hsync <= vga_io(0);
			vsync <= vga_io(1);
		end if;
	end process;

end;
