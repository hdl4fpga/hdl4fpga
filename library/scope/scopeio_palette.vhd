library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_palette is
	generic (
		dflt_tracesfg : in  std_logic_vector;
		dflt_gridfg   : in  std_logic_vector;
		dflt_gridbg   : in  std_logic_vector;
		dflt_hzfg     : in  std_logic_vector;
		dflt_hzbg     : in  std_logic_vector;
		dflt_vtfg     : in  std_logic_vector;
		dflt_vtbg     : in  std_logic_vector;
		dflt_textfg   : in  std_logic_vector;
		dflt_textbg   : in  std_logic_vector;
		dflt_sgmntbg  : in  std_logic_vector;
		dflt_bg       : in  std_logic_vector);
	port (
		rgtr_clk    : in  std_logic;
		rgtr_dv     : in  std_logic;
		rgtr_id     : in  std_logic_vector(8-1 downto 0);
		rgtr_data   : in  std_logic_vector;
		
		trigger_chanid : in std_logic_vector;

		video_clk   : in  std_logic;
		trigger_dot : in  std_logic;
		grid_dot    : in  std_logic;
		grid_bgon   : in  std_logic;
		hz_dot      : in  std_logic;
		hz_bgon     : in  std_logic;
		vt_dot      : in  std_logic;
		vt_bgon     : in  std_logic;
		text_dot    : in  std_logic;
		text_bgon   : in  std_logic;
		sgmnt_bgon  : in  std_logic;
		trace_dots  : in  std_logic_vector;
		video_color : out std_logic_vector);
end;

architecture beh of scopeio_palette is

	constant scopeio_bgon     : std_logic := '1';

	impure function palette_ids (
		constant trigger_chanid : std_logic_vector)
		return std_logic_vector is
		constant n       : natural := pltid_order'length+trace_dots'length+1;
		constant size    : natural := unsigned_num_bits(n-1);
		variable retval : unsigned(0 to n*size-1);
	begin
		for i in 0 to trace_dots'length-1 loop
			retval(0 to size-1) := to_unsigned(pltid_order'length+i, size);
			retval := retval rol size;
		end loop;
		retval(0 to size-1) := resize(unsigned(trigger_chanid), size)+pltid_order'length;
		retval := retval rol size;
		for i in pltid_order'range loop
			retval(0 to size-1) := to_unsigned(pltid_order(i), size);
			retval := retval rol size;
		end loop;
		return std_logic_vector(retval);
	end;

	impure function shuffle (
		constant arg : std_logic_vector)
		return std_logic_vector is
		variable temp   : std_logic_vector(0 to arg'length-1) := arg;
		variable retval : unsigned(0 to temp'length-1);
	begin
		for i in 0 to trace_dots'length-1 loop
			retval(0) := temp(pltid_order'length+i);
			retval := retval rol 1;
		end loop;
		retval(0) := temp(pltid_order'length+trace_dots'length);
		retval := retval rol 1;
		for i in pltid_order'range loop
			retval(0) := temp(pltid_order(i));
			retval := retval rol 1;
		end loop;
		return std_logic_vector(retval);
	end;

	signal palette_dv    : std_logic;
	signal palette_id    : std_logic_vector(0 to unsigned_num_bits(max_inputs+1+pltid_order'length-1)-1);
	signal palette_color : std_logic_vector(max_pixelsize-1 downto 0);

	signal palette_addr  : std_logic_vector(0 to unsigned_num_bits(trace_dots'length+1+pltid_order'length-1)-1);
	signal palette_data  : std_logic_vector(video_color'range);
	signal color_addr    : std_logic_vector(palette_addr'range);

begin

	scopeio_rgtrpalette_e : entity hdl4fpga.scopeio_rgtrpalette
	port map (
		rgtr_clk      => rgtr_clk,
		rgtr_dv       => rgtr_dv,
		rgtr_id       => rgtr_id,
		rgtr_data     => rgtr_data,

		palette_dv    => palette_dv,
		palette_id    => palette_id,
		palette_color => palette_color);

	palette_data <= std_logic_vector(resize(unsigned(palette_color), palette_data'length));
	palette_addr <= std_logic_vector(resize(unsigned(palette_id),    palette_addr'length));

	color_addr <= primux(
		palette_ids(trigger_chanid),
		shuffle((
			pltid_gridfg    => grid_dot,
			pltid_gridbg    => grid_bgon,
			pltid_vtfg      => vt_dot,
			pltid_vtbg      => vt_bgon,
			pltid_hzfg      => hz_dot,
			pltid_hzbg      => hz_bgon,
			pltid_textfg    => text_dot,
			pltid_textbg    => text_bgon,
			pltid_sgmntbg   => sgmnt_bgon,
			pltid_scopeiobg => scopeio_bgon) & trace_dots & trigger_dot));
	
	lookup_b : block
		signal rd_addr : std_logic_vector(palette_addr'range);
		signal rd_data : std_logic_vector(palette_data'range);
	begin

		mem_e : entity hdl4fpga.dpram
		generic map (
			bitrom => dflt_gridfg & dflt_vtfg & dflt_vtbg & dflt_hzfg & dflt_hzbg & dflt_textbg & dflt_gridbg & dflt_sgmntbg & dflt_bg & dflt_textfg & dflt_tracesfg)
		port map (
			wr_clk  => rgtr_clk,
			wr_addr => palette_addr,
			wr_ena  => palette_dv,
			wr_data => palette_data,

			rd_addr => rd_addr,
			rd_data => rd_data);

		rd_rgtr_p : process (video_clk)
		begin
			if rising_edge(video_clk) then
				rd_addr <= color_addr;
				video_color <= rd_data;
			end if;
		end process;

	end block;

end;