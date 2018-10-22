library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_palette is
	generic (
		traces_fg   : in  std_logic_vector;
		trigger_fg  : in  std_logic_vector;
		grid_fg     : in  std_logic_vector;
		grid_bg     : in  std_logic_vector;
		hz_fg       : in  std_logic_vector;
		hz_bg       : in  std_logic_vector;
		vt_fg       : in  std_logic_vector;
		vt_bg       : in  std_logic_vector;
		bk_gd       : in  std_logic_vector);
	port (
		wr_clk      : in  std_logic;
		wr_req      : in  std_logic;
		wr_palette  : in  std_logic_vector;
		wr_color    : in  std_logic_vector;
		
		video_clk   : in  std_logic;
		trigger_dot : in  std_logic;
		grid_dot    : in  std_logic;
		grid_bgon   : in  std_logic;
		hz_dot      : in  std_logic;
		hz_bgon     : in  std_logic;
		vt_dot      : in  std_logic;
		vt_bgon     : in  std_logic;
		traces_dots : in  std_logic_vector;
		video_color : out std_logic_vector);
end;

architecture beh of scopeio_palette is
	signal traces_on  : std_logic;

	function priencoder (
		constant arg : std_logic_vector)
		return   std_logic_vector is
		variable aux    : std_logic_vector(0 to arg'length-1) := arg;
		variable retval : unsigned(0 to unsigned_num_bits(arg'length-1)-1) := (others => '-');
	begin
		for i in aux'range loop
			if aux(i)='1' then
				retval := to_unsigned(i, retval'length);
				exit;
			end if;
		end loop;
		return std_logic_vector(retval);
	end;

	signal rd_addr : std_logic_vector(wr_palette'range);
	signal rd_data : std_logic_vector(wr_color'range);
begin
	mem_e : entity hdl4fpga.dpram
	generic map (
		bitrom => traces_fg & trigger_fg & grid_fg & grid_bg & hz_fg & hz_bg & vt_fg & vt_bg & bk_gd)
	port map (
		wr_clk  => wr_clk,
		wr_ena  => wr_req,
		wr_addr => wr_palette,
		wr_data => wr_color,

		rd_addr => rd_addr,
		rd_data => rd_data);

	process (video_clk)
	begin
		if rising_edge(video_clk) then
			rd_addr     <= priencoder(traces_dots & trigger_dot & grid_dot & grid_bgon & hz_dot & hz_bgon & vt_dot & vt_bgon & '1');
			video_color <= rd_data;
		end if;
	end process;

end;
