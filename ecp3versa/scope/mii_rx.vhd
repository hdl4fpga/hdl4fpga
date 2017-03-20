library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ecp3;
use ecp3.components.all;

library hdl4fpga;
use hdl4fpga.cgafont.all;

architecture beh of ecp3versa is

	signal hdr_data  : std_logic_vector(288-1 downto 0);
	signal pld_data  : std_logic_vector(288-1 downto 0);
	signal pll_data  : std_logic_vector(hdr_data'length+pld_data'length-1 downto 0);
	signal ser_data  : std_logic_vector(32/phy1_rx_d'length-1 downto 0);

	signal cga_row   : std_logic_vector(6-1 downto 0);
	signal cga_col   : std_logic_vector(7-1 downto 0);
	signal cga_code  : std_logic_vector(8-1 downto 0);
	signal char_dot  : std_logic;

	signal vga_hsync : std_logic;
	signal vga_vsync : std_logic;
	signal vga_rgb   : std_logic_vector(3-1 downto 0);
	signal vga_vcntr : std_logic_vector(0 to 11-1);
	signal vga_hcntr : std_logic_vector(0 to 11-1);

begin

	miirx_e : entity hdl4fpga.scopeio_miirx
	port map (
		mii_rxc  => phy1_125clk,
		mii_rxdv => phy1_rx_dv,
		mii_rxd  => phy1_rx_d,
		pll_data => pll_data,
		ser_data => ser_data);

	process (ser_data)
		variable data : unsigned(pll_data'range);
	begin
		data     := unsigned(pll_data);
		data     := aux sll hdr_data'length;
		pld_data <= reverse(aux(pld_data'reverse_range));
	end process;

	process (pld_data);
		variable data : unsigned(pld_data'range);
	begin
		data     := pld_data;
		cga_char <= data(cga_char'range);
		data     := data srl cga_char'length;
		cga_row  <= data(cga_row'range);
		data     := data srl cga_row'length;
		cga_col  <= data(cga_col'range);
	end process;

	vga_e : entity hdl4fpga.video_vga
	generic map (
		n => 11);
	port map (
		clk   => vga_clk,
		hsync => vga_hsycn,
		vsync => vga_vsync,
		hcntr => vga_hcntr,
		vcntr => vga_vcntr);

	cga_e : entity hdl4fpga.cga
	generic map (
		bitrom   => psf1cp850x8x16,
		height   => 16,
		width    =>  8)
	port map (
		sys_clk  => phy1_125clk,
		sys_we   => cga_we,
		sys_row  => cga_row,
		sys_col  => cga_col,
		sys_code => cga_code,
		vga_clk  => video_clk,
		vga_row  => video_vcntr(0 to 7-1),
		vga_col  => video_hcntr(0 to 6-1),
		vga_dot  => char_dot);


	expansion(3) <= vga_rgb(1); -- green
	expansion(4) <= vga_rgb(0); -- blue
	expansion(5) <= vga_rgb(2); -- red
	expansion(6) <= vga_hsync;
	expansion(7) <= vga_vsync;
end;
