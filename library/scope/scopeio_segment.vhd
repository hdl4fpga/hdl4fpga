library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_segment is
	generic(
		latency       : natural;
		inputs        : natural);
	port (
		in_clk        : in  std_logic;

		hz_req        : in  std_logic;
		hz_rdy        : out std_logic;
		hz_sel        : in  std_logic_vector(0 to 2-1);

		vt_req        : in  std_logic;
		vt_rdy        : out std_logic;
		vt_sel        : in  std_logic_vector;

		video_clk     : in  std_logic;
		x             : in  std_logic_vector;
		y             : in  std_logic_vector;

		hz_offset     : in  std_logic_vector;
		vt_offset     : in  std_logic_vector := std_logic_vector'(b"0000");
		hz_on         : in  std_logic;
		vt_on         : in  std_logic;
		grid_on       : in  std_logic;

		trigger_level : in  std_logic_vector;
		samples       : in  std_logic_vector;

		hz_dot        : out std_logic;
		vt_dot        : out std_logic;
		grid_dot      : out std_logic;
		trigger_dot   : out std_logic;
		traces_dots   : out std_logic_vector);
end;

architecture def of scopeio_segment is
	signal hz_from  : std_logic_vector(8-1 downto 0) := b"1111_0000";
	signal hz_step  : std_logic_vector(8-1 downto 0) := b"0000_1000";
	signal hz_point : std_logic_vector(3-1 downto 0) := b"111";
	signal vt_from  : std_logic_vector(8-1 downto 0) := b"0001_1000";
	signal vt_step  : std_logic_vector(8-1 downto 0) := b"1111_1000";
	signal vt_point : std_logic_vector(3-1 downto 0) := b"111";
begin


--	process (hz_sel)
--	begin
--		case hz_sel is
--		when "00" =>
--			hz_from <= b"0000_0000";
--			hz_step <= b"0000_0010";
--		when "01" =>
--			hz_from <= b"0000_0000";
--			hz_step <= b"0000_0110";
--		when "11" =>
--			hz_from <= b"0000_0000";
--			hz_step <= b"0000_1010";
--		when others =>
--		end case;
--	end process;

	grid_e : entity hdl4fpga.scopeio_grid
	generic map (
		latency => latency-2)
	port map (
		clk  => video_clk,
		ena  => grid_on,
		x    => x,
		y    => y,
		dot  => grid_dot);

--	trigger_e : entity hdl4fpga.scopeio_hline
--	generic map (
--		latency   => latency)
--	port map (
--		row => trigger_level,
--		clk => video_clk,
--		ena => grid_on,
--		x   => win_x,
--		y   => win_y,
--		dot => trigger_dot);

	axis_e : entity hdl4fpga.scopeio_axis
	generic map (
		latency => latency-2)
	port map (
		in_clk      => in_clk,

		hz_on       => hz_on,
		hz_req      => hz_req,
		hz_rdy      => hz_rdy,
		hz_unit     => hz_step,
		hz_from     => hz_from,
		hz_point    => hz_point,
		hz_dot      => hz_dot,
		hz_offset   => hz_offset,

		vt_on       => vt_on,
		vt_req      => vt_req,
		vt_rdy      => vt_rdy,
		vt_unit     => vt_step,
		vt_from     => vt_from,
		vt_point    => vt_point,
		vt_dot      => vt_dot,
		vt_offset   => vt_offset,

		video_clk   => video_clk,
		video_hcntr => x,
		video_vcntr => y);

	tracer_e : entity hdl4fpga.scopeio_tracer
	generic map (
		latency => latency-2,
		inputs  => inputs)
	port map (
		clk     => video_clk,
		ena     => grid_on,
		y       => y,
		samples => samples,
		dots    => traces_dots);

end;
