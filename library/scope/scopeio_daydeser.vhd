library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_daydeser is
	port (
		chaini_clk  : in  std_logic;
		chaini_frm  : in  std_logic;
		chaini_irdy : in  std_logic;
		chaini_data : in  std_logic_vector;

		chaino_irdy : out std_logic;
		chaino_data : out std_logic_vector);
end;

architecture def of scopeio_daydeser is
begin
	process (chaini_irdy, chaini_data, chaini_clk)
		variable q : unsigned(chaino_data'range);
		variable cntr : unsigned(0 to unsigned_num_bits(chaino_data'length/chaini_data'length-1)-1);
	begin
		q(chaini_data'range) := unsigned(chaini_data);
		if rising_edge(chaini_clk) then
			if chaini_frm='0' then
				cntr := (others => '0');
			elsif chaini_irdy='1' then
				if chaini_data'left <= chaini_data'right then
					q := q rol chaini_data'length;
				else
					q := q ror chaini_data'length;
				end if;
				if 2**cntr'length=chaino_data'length/chaini_data'length then
					cntr := cntr + 1;
				elsif cntr=chaino_data'length/chaini_data'length-1 then
					cntr := (others => '0');
				end if;
			end if;
		end if;
		chaino_irdy <= chaini_irdy and setif(cntr=chaino_data'length/chaini_data'length-1);
		chaino_data <= std_logic_vector(q);
	end process;

end;
