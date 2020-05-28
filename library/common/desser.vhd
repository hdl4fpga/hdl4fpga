library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity desser is
	port (
		desser_clk : in  std_logic;
		desser_frm : in  std_logic;
		des_irdy   : in  std_logic;
		des_data   : in  std_logic_vector;

		ser_irdy : out std_logic;
		ser_data : out std_logic_vector);
end;

architecture def of desser is
begin
	process (desser_frm, des_irdy, des_data, desser_clk)
		variable des  : unsigned(des_data'range);
		variable cntr : unsigned(0 to unsigned_num_bits(des_data'length/ser_data'length-1)-1);
	begin
		des(ser_data'range) := unsigned(des_data(ser_data'range));
		if rising_edge(desser_clk) then
			if desser_frm='0' then
				cntr := (others => '0');
			else
				if cntr=0 then
					if des_irdy='1' then
						cntr := cntr + 1;
					end if;
				else
					if 2**cntr'length=des_data'length/ser_data'length then
						cntr := cntr + 1;
					elsif cntr=des_data'length/ser_data'length-1 then
						cntr := (others => '0');
					end if;
				end if;
				if des'left <= des'right then
					des := des rol ser_data'length;
				else
					des := des rol ser_data'length;
				end if;
			end if;
		end if;
		ser_irdy <= (desser_frm and des_irdy) or setif(cntr/=0);
		ser_data <= std_logic_vector(des(ser_data'range));
	end process;

end;
