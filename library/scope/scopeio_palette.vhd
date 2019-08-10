library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_palette is
	generic (
		default_tracesfg : in  std_logic_vector;
		default_gridfg   : in  std_logic_vector;
		default_gridbg   : in  std_logic_vector;
		default_hzfg     : in  std_logic_vector;
		default_hzbg     : in  std_logic_vector;
		default_vtfg     : in  std_logic_vector;
		default_vtbg     : in  std_logic_vector;
		default_textbg   : in  std_logic_vector;
		default_sgmntbg  : in  std_logic_vector;
		default_bg       : in  std_logic_vector);
	port (
		rgtr_clk    : in  std_logic;
		rgtr_dv     : in  std_logic;
		rgtr_id     : in  std_logic_vector(8-1 downto 0);
		rgtr_data   : in  std_logic_vector;
		
		video_clk   : in  std_logic;
		trigger_chanid : in std_logic_vector;
		trigger_dot : in  std_logic;
		grid_dot    : in  std_logic;
		grid_bgon   : in  std_logic;
		hz_dot      : in  std_logic;
		hz_bgon     : in  std_logic;
		vt_dot      : in  std_logic;
		vt_bgon     : in  std_logic;
		text_bgon   : in  std_logic;
		sgmnt_bgon  : in  std_logic;
		trace_dots  : in  std_logic_vector;
		video_color : out std_logic_vector);
end;

architecture beh of scopeio_palette is

	function id_codes (
		constant n : natural)
		return std_logic_vector is
		constant size   : natural := unsigned_num_bits(n-1);
		variable retval : unsigned(0 to n*size-1);
	begin
		for i in 0 to n-1 loop
			retval(0 to size-1) := to_unsigned(i, size);
			retval := retval rol size;
		end loop;
		return std_logic_vector(retval);
	end;

	signal palette_dv       : std_logic;
	signal palette_id       : std_logic_vector(0 to unsigned_num_bits(max_inputs+9-1)-1);
	signal palette_color    : std_logic_vector(max_pixelsize-1 downto 0);

	constant paletteid_size : natural := unsigned_num_bits(trace_dots'length + 9 - 1); 
	constant paletteid_data : std_logic_vector := std_logic_vector(unsigned(id_codes(trace_dots'length + 9)) ror paletteid_size*trace_dots'length); 
	constant palette_ids    : std_logic_vector(0 to paletteid_data'length-1) := paletteid_data;

	signal trace_on   : std_logic;
	signal trigger_on : std_logic;
	signal fgbg_on    : std_logic;
	signal trace_id   : std_logic_vector(0 to paletteid_size-1);
	signal trigger_id : std_logic_vector(trace_id'range);
	signal fgbg_id    : std_logic_vector(trace_id'range);


	signal wr_addr    : std_logic_vector(0 to unsigned_num_bits(trace_dots'length+9-1)-1);
	signal wr_data    : std_logic_vector(video_color'range);
	signal rd_addr    : std_logic_vector(wr_addr'range);
	signal rd_data    : std_logic_vector(wr_data'range);

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
		
	wr_data <= std_logic_vector(resize(unsigned(palette_color), wr_data'length));
	wr_addr <= std_logic_vector(resize(unsigned(palette_id),    wr_addr'length));
	mem_e : entity hdl4fpga.dpram
	generic map (
		bitrom => default_gridfg & default_vtfg & default_vtbg & default_hzfg & default_hzbg & default_textbg & default_gridbg & default_sgmntbg & default_bg & default_tracesfg)
	port map (
		wr_clk  => rgtr_clk,
		wr_ena  => palette_dv,
		wr_addr => wr_addr,
		wr_data => wr_data,

		rd_addr => rd_addr,
		rd_data => rd_data);

	traceid_p : process (video_clk)
	begin
		if rising_edge(video_clk) then
			trace_id <= primux(palette_ids(0 to paletteid_size*trace_dots'length-1), trace_dots);
			trace_on <= setif(trace_dots/=(trace_dots'range => '0'));
		end if;
	end process;

	triggerio_p : process (video_clk)
	begin
		if rising_edge(video_clk) then
			trigger_id <= word2byte(palette_ids(0 to paletteid_size*trace_dots'length-1), trigger_chanid, paletteid_size);
			trigger_on <= trigger_dot;
		end if;
	end process;

	fgbg_p : process (video_clk)
		variable aux : std_logic_vector(palette_ids'range);
	begin
		if rising_edge(video_clk) then
			aux     := std_logic_vector(unsigned(palette_ids) rol paletteid_size*trace_dots'length);
--			fgbg_id <= primux(aux(0 to 9*paletteid_size-1), grid_dot & grid_bgon & hz_dot & hz_bgon & vt_dot & vt_bgon & text_bgon & sgmnt_bgon & '1');
			fgbg_id <= primux(aux(0 to 9*paletteid_size-1), grid_dot & vt_dot & vt_bgon & hz_dot & hz_bgon & text_bgon & grid_bgon & sgmnt_bgon & '1');
		end if;
	end process;

	process (video_clk)
	begin
		if rising_edge(video_clk) then
			fgbg_on     <= '1';
			rd_addr     <= primux(trace_id & trigger_id & fgbg_id, trace_on & trigger_on & fgbg_on);
			video_color <= rd_data;
		end if;
	end process;
--
--	process (video_clk)
--	begin
--		if rising_edge(video_clk) then
--			rd_addr     <= priencoder(trace_dots & trigger_dot & grid_dot & grid_bgon & hz_dot & hz_bgon & vt_dot & vt_bgon & '1');
--			video_color <= rd_data;
--		end if;
--	end process;

end;
