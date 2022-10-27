library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bcddiv2e is
	generic (
		max     : in  natural := 5);
	port (
		clk     : in  std_logic := '0';
		bcd_exp : in  std_logic_vector;
		bcd_ena : in  std_logic := '1';
		bcd_ini : in  std_logic := '1';
		bcd_di  : in  std_logic_vector;
		bcd_do  : out std_logic_vector;
		bcd_cy  : out std_logic);
end;

library hdl4fpga;
use hdl4fpga.base.all;

architecture def of bcddiv2e is

	procedure dbdbbl_p(
		variable shtio : inout std_logic;
		variable digit : inout unsigned) is
		variable save  : std_logic;
	begin
		save     := digit(0);
		digit(0) := shtio;
		shtio    := save;
		digit    := digit ror 1;
		if digit >= "0101" then
			digit := digit - "0011";
		end if;
	end;

	constant size  : natural := setif(max=0, 2**bcd_exp'length, max);
	signal shtio_d : unsigned(size-1 downto 0);
	signal shtio_q : unsigned(size-1 downto 0);

begin

	reg_p : process (clk)
	begin
		if rising_edge(clk) then
			if bcd_ena='1' then
				shtio_q <= shtio_d;
			end if;
		end if;
	end process;

	process (bcd_exp, bcd_di, bcd_ini, shtio_q)
		variable tmp_value : unsigned(bcd_di'length-1 downto 0);
		variable tmp_shtio : unsigned(size-1 downto 0);
		variable carry     : std_logic;
	begin
		tmp_value := unsigned(bcd_di);
		if bcd_ini='1' then
			tmp_shtio := (others => '0');
		else
			tmp_shtio := shtio_q;
		end if;

		carry := '0';
		for k in 0 to size-1 loop
			if k <= to_integer(unsigned(not bcd_exp)) then
				for i in 0 to tmp_value'length/4-1 loop
					tmp_value := tmp_value rol 4;
					dbdbbl_p (tmp_shtio(0), tmp_value(4-1 downto 0));
				end loop;
				carry := carry or tmp_shtio(0);
			end if;
			tmp_shtio := tmp_shtio rol 1;
		end loop;

		shtio_d <= tmp_shtio;
		bcd_do  <= std_logic_vector(tmp_value);
		bcd_cy  <= carry;
	end process;

end;
