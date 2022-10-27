library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity dbdbbl is
	port (
		clk     : in  std_logic := '0';
		ena     : in  std_logic := '1';

		bin_di  : in  std_logic_vector;

		bcd_ini : in  std_logic;
		bcd_di  : in  std_logic_vector;
		bcd_do  : out std_logic_vector;
		bcd_cy  : out std_logic);
end;

architecture def of dbdbbl is

	procedure dbdbbl_p(
		variable shtio : inout std_logic;
		variable digit : inout unsigned) is
		variable save  : std_logic;
	begin
		if digit >= "0101" then
			digit := digit + "0011";
		end if;
		digit    := digit rol 1;
		save     := digit(0);
		digit(0) := shtio;
		shtio    := save;
	end;

	signal shtio_d : unsigned(bin_di'length-1 downto 0);
	signal shtio_q : unsigned(bin_di'length-1 downto 0);

begin

	reg_p : process (clk)
	begin
		if rising_edge(clk) then
			if ena='1' then
				shtio_q <= shtio_d;
			end if;
		end if;
	end process;

	comb_p : process (bcd_ini, bin_di, bcd_di, shtio_q)
		variable tmp_value : unsigned(bcd_di'length-1 downto 0);
		variable tmp_shtio : unsigned(bin_di'length-1 downto 0);
	begin
		tmp_value := unsigned(bcd_di);

		if bcd_ini='1' then
			tmp_shtio := unsigned(bin_di);
		else
			tmp_shtio := shtio_q;
		end if;

		for k in tmp_shtio'range loop
			tmp_shtio := tmp_shtio rol 1;
			for i in 0 to tmp_value'length/4-1 loop
				dbdbbl_p(tmp_shtio(0), tmp_value(4-1 downto 0));
				tmp_value := tmp_value ror 4;
			end loop;
		end loop;

		bcd_do  <= std_logic_vector(tmp_value);
		shtio_d <= tmp_shtio;
	end process;
	bcd_cy <= setif(shtio_d /= (shtio_d'range => '0'));

end;
