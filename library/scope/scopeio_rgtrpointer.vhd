library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_rgtrpointer is
	port (
		clk             : in  std_logic;
		rgtr_dv         : in  std_logic;
		rgtr_id         : in  std_logic_vector(8-1 downto 0);
		rgtr_data       : in  std_logic_vector;

		pointer_dv      : out std_logic;
		pointer_x       : out std_logic_vector;
		pointer_y       : out std_logic_vector);

end;

architecture def of scopeio_rgtrpointer is

	signal pointer_ena : std_logic;

begin

	pointer_ena <= rgtr_dv when rgtr_id=rid_pointer else '0';
	pointer_p : process(clk)
	begin
		if rising_edge(clk) then
			if pointer_ena='1' then
				pointer_x <= std_logic_vector(resize(unsigned(bitfield(rgtr_data, pointerx_id, pointer_bf)), pointer_x'length));
				pointer_y <= std_logic_vector(resize(unsigned(bitfield(rgtr_data, pointery_id, pointer_bf)), pointer_y'length));
			end if;
			pointer_dv <= pointer_ena;
		end if;
	end process;

end;
