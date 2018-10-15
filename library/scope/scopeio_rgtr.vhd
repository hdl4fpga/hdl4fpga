library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_rgtr is
	port (
		clk       : in  std_logic := '-';
		rgtr_dv   : in  std_logic_vector;
		rgtr_id   : in  std_logic_vector;
		rgtr_data : in  std_logic_vector;

end;

architecture def of scopeio_rgtr is
	function bf (
		constant bf_data   : std_logic_vector;
		constant bf_id     : natural;
		constant bf_dscptr : natural_vector)
		return   std_logic_vector is
		variable acc    : unsigned(0 to bf_data'length-1);
		variable dscptr : natural_vector(0 to bf_dscptr'length);
	begin
		dscptr := bf_dscptr & bf_data'length;
		acc := unsigned(bf_data);
		for i in bf_dscptr'range loop
			if i=bf_id then
				return std_logic_vector(acc(bf_dscptr(i)-1 downto 0));
			end if;
			acc := acc rol bf_dscptr(i);
		end loop;
		return (1 to 0 => '-');
	end;

	constant axis_bf     : natural_vector := (18, 1);
	constant vtaxis_bf   : natural_vector := (0, 9);
	constant palette_bf  : natural_vector := (0, 4);
	constant rid_axis    : std_logic_vector := x"10";
	constant rid_palette : std_logic_vector  := x"11";

begin
	process (si_clk)
	begin
		if rising_edge(si_clk)
			rgtr_ena <= demux(rgtr_id(5-1 downto 0));
		end if;
	end process;

	process(si_clk)
		variable acc : unsigned(rgtr_data'range);
	begin
		if rising_edge(si_clk) then
			if reverse(bf(reverse(rgtr_data), 1, axis_bf)) then
				axis_sel <= '1';
				acc := unsigned(rgtr_data(acc'range));
				acc := acc - (3*32);
					vt_offset <= std_logic_vector(acc(vt_offset'range));
					acc := acc rol vt_offset'length;
					axis_base <= std_logic_vector(acc(axis_base'range));
				else
					axis_sel  <= '0';
					axis_base <= reverse(bf(reverse(rgtr_data), 1, axis_bf));
					hz_offset <= rgtr_data(9-1  downto 0);
				end if;
					when "1" =>
					when others =>
					end case;

					acc := acc rol 16;
					axis_scale <= std_logic_vector(acc(axis_scale'range));
				if rgtr_sel() then
					axis_req   <= '1';
				when rid_palette =>
					when others =>
					end case;
				if rgtr_dv='1' then
					decode(rgtr_id);
				else
					if axis_rdy='1' then
						axis_req <= '0';
					end if;
				end if;

				case rgtr_id is
				when rid_palette =>
					palette_ena <= '1'; rgtr_dv;
				end case;

			end if;

			palette_color <= std_logic_vector(acc(video_color'range));
			acc := acc rol video_color'
			palette_id    <= rtgr_data(video_pixel'length-1 downto video_pixel'length);
		end process;

end;
