library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity serdes is
	port (
		serdes_clk : in  std_logic;
		serdes_frm : in  std_logic;
		ser_irdy   : in  std_logic;
		ser_data   : in  std_logic_vector;

		des_irdy   : out std_logic;
		des_data   : out std_logic_vector);
end;

architecture def of serdes is
begin
	process (ser_irdy, ser_data, serdes_clk)
		variable des  : unsigned(des_data'range);
		variable cntr : unsigned(0 to unsigned_num_bits(des_data'length/ser_data'length-1)-1);
	begin
		des(ser_data'range) := unsigned(ser_data);
		if rising_edge(serdes_clk) then
			if serdes_frm='0' then
				cntr := (others => '0');
			elsif ser_irdy='1' then
				if des_data'left <= des_data'right then
					des := des rol des_data'length;
				else
					des := des ror des_data'length;
				end if;
				if 2**cntr'length=des_data'length/ser_data'length then
					cntr := cntr + 1;
				elsif cntr=des_data'length/ser_data'length-1 then
					cntr := (others => '0');
				end if;
			end if;
		end if;
		des_irdy <= ser_irdy and setif(cntr=des_data'length/ser_data'length-1);
		des_data <= std_logic_vector(des);
	end process;

end;
