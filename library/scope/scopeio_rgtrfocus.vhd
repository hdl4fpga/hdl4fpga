library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_rgtrfocus is
	generic (
		rgtr       : boolean := true);
	port (
		rgtr_clk   : in  std_logic;
		rgtr_dv    : in  std_logic;
		rgtr_id    : in  std_logic_vector(8-1 downto 0);
		rgtr_data  : in  std_logic_vector;

		focus_ena  : out std_logic;
		focus_dv   : out std_logic;
		widget_id  : out std_logic_vector);

end;

architecture def of scopeio_rgtrfocus is

	signal dv : std_logic;
	signal id : std_logic_vector(widget_id'range);
begin

	dv <= setif(rgtr_id=rid_focus, rgtr_dv);
	id <= std_logic_vector(resize(unsigned(bitfield(rgtr_data, focus_id, focus_bf)), id'length));

	process (rgtr_clk)
	begin
		if rising_edge(rgtr_clk) then
			focus_dv <= dv;
		end if;
	end process;

	rgtr_e : if rgtr generate
		process (rgtr_clk)
		begin
			if rising_edge(rgtr_clk) then
				if dv='1' then
					widget_id <= id;
				end if;
			end if;
		end process;
	end generate;

	norgtr_e : if not rgtr generate
		widget_id <= id;
	end generate;

	focus_ena <= dv;
end;
