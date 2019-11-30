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

	function color (
		constant arg : std_logic_vector)
		return std_logic_vector
	is
		variable retval : std_logic_vector(0 to arg'length-1);
	begin
		retval := arg;
		return retval(1 to retval'right);
	end ;

	function colors (
		constant arg : std_logic_vector)
		return std_logic_vector
	is
		constant n : natural := arg'length/(video_color'length+1);
		variable aux    : std_logic_vector(0 to arg'length-1);
		variable retval : unsigned(0 to n*video_color'length-1);
	begin
		aux := arg;
		for i in 0 to n-1 loop
			retval(0 to video_color'length-1) := unsigned(color(aux(0 to video_color'length)));
			retval := retval rol video_color'length;
			aux    := std_logic_vector(unsigned(aux) rol (video_color'length+1));
		end loop;
		return std_logic_vector(retval);
	end;

	function init_opacity (
		constant dflt_tracesfg :  std_logic_vector;
		constant dflt_gridfg   :  std_logic_vector;
		constant dflt_gridbg   :  std_logic_vector;
		constant dflt_hzfg     :  std_logic_vector;
		constant dflt_hzbg     :  std_logic_vector;
		constant dflt_vtfg     :  std_logic_vector;
		constant dflt_vtbg     :  std_logic_vector;
		constant dflt_textfg   :  std_logic_vector;
		constant dflt_textbg   :  std_logic_vector;
		constant dflt_sgmntbg  :  std_logic_vector;
		constant dflt_bg       :  std_logic_vector)
		return std_logic_vector
	is
		variable tracesfg      : std_logic_vector(0 to dflt_tracesfg'length-1);
		variable retval        : std_logic_vector(0 to pltid_order'length+trace_dots'length-1);
	begin
		retval(pltid_gridfg)    := dflt_gridfg(dflt_gridfg'left);
		retval(pltid_gridbg)    := dflt_gridbg(dflt_gridbg'left);
		retval(pltid_vtfg)      := dflt_vtfg(dflt_vtfg'left);
		retval(pltid_vtbg)      := dflt_vtbg(dflt_vtbg'left);
		retval(pltid_hzfg)      := dflt_hzfg(dflt_hzfg'left);
		retval(pltid_hzbg)      := dflt_hzbg(dflt_hzbg'left);
		retval(pltid_textfg)    := dflt_textfg(dflt_textfg'left);
		retval(pltid_textbg)    := dflt_textbg(dflt_textbg'left);
		retval(pltid_sgmntbg)   := dflt_sgmntbg(dflt_sgmntbg'left);
		retval(pltid_scopeiobg) := dflt_bg(dflt_bg'left);
		tracesfg := dflt_tracesfg;
		for i in 0 to tracesfg'length/(video_color'length+1)-1 loop
			retval(pltid_order'length+i) := tracesfg(i*(video_color'length+1));
		end loop;
		return retval;
	end;
		
	signal trigger_opacity : std_logic := '1';
	signal color_opacity   : std_logic_vector(0 to pltid_order'length+trace_dots'length-1) := init_opacity (
		dflt_tracesfg => dflt_tracesfg,
		dflt_gridfg   => dflt_gridfg,
		dflt_gridbg   => dflt_gridbg,
		dflt_hzfg     => dflt_hzfg,
		dflt_hzbg     => dflt_hzbg,
		dflt_vtfg     => dflt_vtfg,
		dflt_vtbg     => dflt_vtbg,
		dflt_textfg   => dflt_textfg,
		dflt_textbg   => dflt_textbg,
		dflt_sgmntbg  => dflt_sgmntbg,
		dflt_bg       => dflt_bg);

	signal palette_dv       : std_logic;
	signal palette_id       : std_logic_vector(0 to unsigned_num_bits(pltid_order'length+max_inputs+1-1)-1);
	signal palette_color    : std_logic_vector(max_pixelsize-1 downto 0);
	signal palette_colorena : std_logic;
	signal palette_opacity  : std_logic;

	signal palette_addr     : std_logic_vector(0 to unsigned_num_bits(pltid_order'length+trace_dots'length+1-1)-1);
	signal palette_data     : std_logic_vector(0 to video_color'length);
	signal color_addr       : std_logic_vector(palette_addr'range);

begin

	scopeio_rgtrpalette_e : entity hdl4fpga.scopeio_rgtrpalette
	port map (
		rgtr_clk         => rgtr_clk,
		rgtr_dv          => rgtr_dv,
		rgtr_id          => rgtr_id,
		rgtr_data        => rgtr_data,

		palette_dv       => palette_dv,
		palette_id       => palette_id,
		palette_opacity  => palette_opacity,
		palette_colorena => palette_colorena,
		palette_color    => palette_color);

	opacity_p : process (rgtr_clk)
	begin
		if rising_edge(rgtr_clk) then
			if palette_dv='1' then
				color_opacity(to_integer(resize(unsigned(palette_id), palette_addr'length))) <= palette_data(0);
			end if;
		end if;
	end process;

	palette_data <= std_logic_vector(resize(unsigned(palette_color), palette_data'length));
	palette_addr <= std_logic_vector(resize(unsigned(palette_id),    palette_addr'length));

	trigger_opacity <= word2byte(color_opacity(pltid_order'length to pltid_order'length+trace_dots'length-1), trigger_chanid);
	color_addr <= primux(
		palette_ids(trigger_chanid),
		shuffle((
			pltid_gridfg    => grid_dot     and color_opacity(pltid_gridfg),
			pltid_gridbg    => grid_bgon    and color_opacity(pltid_gridbg),
			pltid_vtfg      => vt_dot       and color_opacity(pltid_vtfg),
			pltid_vtbg      => vt_bgon      and color_opacity(pltid_vtbg),
			pltid_hzfg      => hz_dot       and color_opacity(pltid_hzfg),
			pltid_hzbg      => hz_bgon      and color_opacity(pltid_hzbg),
			pltid_textfg    => text_dot     and color_opacity(pltid_textfg),
			pltid_textbg    => text_bgon    and color_opacity(pltid_textbg),
			pltid_sgmntbg   => sgmnt_bgon   and color_opacity(pltid_sgmntbg),
			pltid_scopeiobg => scopeio_bgon and color_opacity(pltid_scopeiobg)) & 
		(trace_dots  and color_opacity(pltid_order'length to pltid_order'length+trace_dots'length-1)) & 
		(trigger_dot and trigger_opacity)));
	
	lookup_b : block
		signal wr_ena  : std_logic;
		signal wr_data : std_logic_vector(video_color'range);
		signal rd_addr : std_logic_vector(palette_addr'range);
		signal rd_data : std_logic_vector(video_color'range);
	begin

		wr_data <= color(palette_data);
		wr_ena <= palette_colorena and palette_dv;
		mem_e : entity hdl4fpga.dpram
		generic map (
			bitrom => colors(dflt_gridfg & dflt_vtfg & dflt_vtbg & dflt_hzfg & dflt_hzbg & dflt_textbg & dflt_gridbg & dflt_sgmntbg & dflt_bg & dflt_textfg & dflt_tracesfg))
		port map (
			wr_clk  => rgtr_clk,
			wr_addr => palette_addr,
			wr_ena  => wr_ena,
			wr_data => wr_data,

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
