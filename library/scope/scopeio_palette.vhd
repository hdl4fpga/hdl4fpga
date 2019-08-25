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

	function palette_ids (
		constant statics : natural;
		constant traces  : natural;
		constant trigger_chanid : std_logic_vector)
		return std_logic_vector is
		constant n       : natural := statics+traces;
		constant size    : natural := unsigned_num_bits(n-1);
		variable retval : unsigned(0 to n*size-1);
	begin
		for i in 0 to statics-1 loop
			retval(0 to size-1) := to_unsigned(i, size);
			retval := retval rol size;
		end loop;
		retval(0 to size-1) := resize(unsigned(trigger_chanid)+statics, size);
		retval := retval rol size;
		for i in statics to statics+traces-2 loop
			retval(0 to size-1) := to_unsigned(i, size);
			retval := retval rol size;
		end loop;
		return std_logic_vector(retval);
	end;

	function reshuffle (
		constant queue    : std_logic_vector;
		constant priority : natural_vector)
		return std_logic_vector is
		constant size   : natural := queue'length/priority'length;
		variable temp   : unsigned(0 to queue'length-1);
		variable retval : unsigned(0 to queue'length-1);
	begin
		for i in priority'range loop
			temp   := unsigned(queue) rol (priority(i)*size);
			retval(0 to size-1) := temp(0 to size-1);
			retval := retval rol size;
		end loop;
		return std_logic_vector(retval);
	end;

	signal palette_dv    : std_logic;
	signal palette_id    : std_logic_vector(0 to unsigned_num_bits(max_inputs+9-1)-1);
	signal palette_color : std_logic_vector(max_pixelsize-1 downto 0);

	signal palette_addr  : std_logic_vector(0 to unsigned_num_bits(trace_dots'length+9-1)-1);
	signal palette_data  : std_logic_vector(video_color'range);
	signal color_addr    : std_logic_vector(palette_addr'range);
	signal dll           : std_logic_vector(palette_data'range);

	signal pp : std_logic_vector(0 to 13*4-1);
	signal ppp : std_logic_vector(0 to 13-1);

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

--	pp  <= reshuffle(palette_ids(pltid_scopeiobg+1, trace_dots'length+1, trigger_chanid), layer_priority(trace_dots'length));
--	ppp <= reshuffle(grid_dot & grid_bgon & vt_dot & vt_bgon & hz_dot & hz_bgon & text_dot & text_bgon & sgmnt_bgon & scopeio_bgon & trace_dots & trigger_dot, layer_priority(trace_dots'length));

	color_addr <= primux(
		reshuffle(palette_ids(pltid_scopeiobg+1, trace_dots'length+1, trigger_chanid), layer_priority(trace_dots'length)),
		reshuffle(grid_dot & grid_bgon & vt_dot & vt_bgon & hz_dot & hz_bgon & text_dot & text_bgon & sgmnt_bgon & scopeio_bgon & trigger_dot & trace_dots, layer_priority(trace_dots'length)));
	lookup_b : block
		signal rd_addr : std_logic_vector(palette_addr'range);
		signal rd_data : std_logic_vector(palette_data'range);
	begin

		mem_e : entity hdl4fpga.dpram
		generic map (
			bitrom => dflt_gridfg & dflt_vtfg & dflt_vtbg & dflt_hzfg & dflt_hzbg & dflt_textbg & dflt_gridbg & dflt_sgmntbg & dflt_bg & dflt_tracesfg)
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