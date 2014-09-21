library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity timers is
	generic (
		n : natural);
	port (
		data : in  std_logic_vector);
		clk  : in  std_logic;
		req  : in  std_logic;
		rdy  : out std_logic);
end;

architecture def of timers is
	
	constant size : natural := (data'length+n-1)/n;

	signal cy : std_logic_vector(n downto 0);

begin

	cntr_g: for i in 0 to n-1 generate
		signal q : std_logic_vector(0 to min(size, data-i*size));
	generate
		cntr_p : process (clk)
		begin
			if rising_edge(clk) then
				if req='1' then

				else
				end if;

			end if;
		end process;

	end generate;

end;
