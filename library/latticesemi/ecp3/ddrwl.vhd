library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ddrwl is
	port (
		clk : in  std_logic;
		req : in  std_logic;
		rdy : out std_logic;
		nxt : out std_logic;
		dg  : out std_logic_vector);
end;

library hdl4fpga;

architecture beh of ddrwl is
	signal aph_dg  : unsigned(0 to dg'length);
	signal aph_req : std_logic;
begin

	process (clk)
		variable cntr : std_logic_vector(0 to 3-1);
	begin
		if rising_edge(clk) then
			if req='0' then
				cntr := (0 => '1', others => '0');
				aph_dg <= (0 => '1', others => '0');
			else
				cntr := cntr(cntr'left) & cntr(0 to cntr'right-1);
				aph_dg <= aph_dg srl 1;
			end if;
			nxt <= cntr(0) and not aph_dg(aph_dg'right);
		end if;
	end process;

	dg  <= std_logic_vector(aph_dg(0 to dg'length-1));
	rdy <= aph_dg(aph_dg'right);

end;
