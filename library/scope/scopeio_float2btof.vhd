library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity scopeio_float2btof is
	port (
		clk      : in  std_logic;
		frac     : in  signed;
		exp      : in  signed;
		bin_frm  : in  std_logic;
		bin_irdy : out std_logic;
		bin_trdy : in  std_logic;
		bin_exp  : out std_logic;
		bin_neg  : out std_logic;
		bin_di   : out std_logic_vector);
end;

architecture def of scopeio_float2btof is
begin

	process (clk)
		variable sel : unsigned(0 to unsigned_num_bits(frac'length/bin_di'length)-1);
	begin
		if rising_edge(clk) then
			if bin_frm='0' then
				sel := (others => '0');
			elsif bin_trdy='1' then
				sel := sel + 1;
			end if;
			bin_di <= multiplex(
				std_logic_vector(neg(frac, frac(frac'left)) & exp),
				std_logic_vector(sel), 
				bin_di'length);
			bin_exp <= setif(sel >= frac'length/bin_di'length);
		end if;
	end process;

	bin_neg <= frac(frac'left);
	bin_irdy <= bin_frm;
end;
