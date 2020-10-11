library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity sio_rgtr is
	generic (
		rid       : std_logic_vector(8-1 downto 0);
		rgtr      : boolean := true);
	port (
		rgtr_clk  : in  std_logic;
		rgtr_dv   : in  std_logic;
		rgtr_id   : in  std_logic_vector(8-1 downto 0);
		rgtr_data : in  std_logic_vector;

		ena       : buffer std_logic;
		dv        : out std_logic;
		data      : out std_logic_vector);

end;

architecture def of sio_rgtr is

begin

	ena <= setif(rgtr_id=rid, rgtr_dv);

	dv_p : process (rgtr_clk)
	begin
		if rising_edge(rgtr_clk) then
			dv <= ena;
		end if;
	end process;

	process (rgtr_clk, rgtr_data)
	begin
		if rising_edge(rgtr_clk) then
			if ena='1' then
				data <= std_logic_vector(resize(unsigned(rgtr_data), data'length));
			end if;
		end if;
		if rgtr=false then
			data <= std_logic_vector(resize(unsigned(rgtr_data), data'length));
		end if;
	end process;

end;
