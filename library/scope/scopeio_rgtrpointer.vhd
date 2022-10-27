library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_rgtrpointer is
	generic (
		rgtr       : boolean := true);
	port (
		rgtr_clk   : in  std_logic;
		rgtr_dv    : in  std_logic;
		rgtr_id    : in  std_logic_vector(8-1 downto 0);
		rgtr_data  : in  std_logic_vector;

		pointer_ena : out std_logic;
		pointer_dv : out std_logic;
		pointer_x  : out std_logic_vector;
		pointer_y  : out std_logic_vector);

end;

architecture def of scopeio_rgtrpointer is

	signal dv : std_logic;
	signal x  : std_logic_vector(pointer_x'range);
	signal y  : std_logic_vector(pointer_y'range);
begin

	dv <= setif(rgtr_id=rid_pointer, rgtr_dv);
	x  <= std_logic_vector(resize(unsigned(bitfield(rgtr_data, pointerx_id, pointer_bf)), x'length));
	y  <= std_logic_vector(resize(unsigned(bitfield(rgtr_data, pointery_id, pointer_bf)), y'length));

	process (rgtr_clk)
	begin
		if rising_edge(rgtr_clk) then
			pointer_dv <= dv;
		end if;
	end process;

	rgtr_e : if rgtr generate
		process (rgtr_clk)
		begin
			if rising_edge(rgtr_clk) then
				if dv='1' then
					pointer_x <= x;
					pointer_y <= y;
				end if;
			end if;
		end process;
	end generate;

	norgtr_e : if not rgtr generate
		pointer_x  <= x;
		pointer_y  <= y;
	end generate;

	pointer_ena <= dv;
end;
