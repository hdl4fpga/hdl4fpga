library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity scopeio_tracer is
	generic (
		vt_height : natural);
	port (
		clk     : in  std_logic;
		ena     : in  std_logic;
		vline   : in  std_logic_vector;
		offsets : in  std_logic_vector;
		ys      : in  std_logic_vector;
		dots    : out std_logic_vector);
end;

architecture def of scopeio_tracer is
begin

	trace_g : for i in dots'range generate

		signal y0   : signed(0 to ys'length/2/dots'length-1);
		signal y1   : signed(0 to ys'length/2/dots'length-1);
		signal bias : signed(0 to offsets'length/dots'length-1);
		signal row  : signed(bias'range);
		signal dena : std_logic;

	begin

		process (clk)
		begin
			if rising_edge(clk) then
				dena <= ena;
--				y0   <= signed(multiplex(multiplex(ys, i, ys'length/dots'length), 0, y0'length));
--				y1   <= signed(multiplex(multiplex(ys, i, ys'length/dots'length), 1, y1'length));
				y0   <= signed(multiplex(multiplex(ys,'0'), i, y0'length));
				y1   <= signed(multiplex(multiplex(ys,'1'), i, y1'length));
				bias <= signed(multiplex(offsets, i, bias'length));
				row  <= signed(vline)-vt_height/2+bias;
			end if;
		end process;

		draw_vline_e : entity hdl4fpga.draw_vline
		generic map (
			sync => true)
		port map (
			clk => clk,
			ena => dena,
			row => std_logic_vector(row),
			y1  => std_logic_vector(y0),
			y2  => std_logic_vector(y1),
			dot => dots(i));

	end generate;

end;
