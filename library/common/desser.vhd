library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity desser is
	port (
		desser_clk : in  std_logic;

		des_frm    : in  std_logic;
		des_irdy   : in  std_logic := '1';
		des_trdy   : out std_logic;
		des_data   : in  std_logic_vector;

		ser_irdy   : out std_logic;
		ser_trdy   : in  std_logic := '1';
		ser_data   : out std_logic_vector);
end;

architecture mux of desser is

	constant mux_length : natural := unsigned_num_bits(des_data'length/ser_data'length-1);
	subtype mux_range is natural range 1 to mux_length;

begin

	assert des_data'length=2**mux_length*ser_data'length
	report "des_data'length is not a multiple of power of 2 of ser_data'length"
	severity FAILURE;

	process (desser_clk)
		variable cntr : unsigned(0 to mux_length);
	begin
		if rising_edge(desser_clk) then
			if des_data'length=ser_data'length then
				cntr := (0 => '1', mux_range => '0');
			elsif des_frm='0' then
				cntr := (0 => '1', mux_range => '0');
			elsif ser_trdy='1' then
				if ser_data'length /= des_data'length then
					if cntr(0)='0' then
						cntr := cntr + 1;
					elsif des_irdy='1' then
						cntr := '0' & (cntr(mux_range) + 1);
					end if;
				else
				end if;
			end if;
		end if;
	end process;

	ser_data <= 
		word2byte(reverse(reverse(des_data), ser_data'length), std_logic_vector(cntr), ser_data'length) when des_data'ascending else
		word2byte(des_data, std_logic_vector(cntr), ser_data'length);

	ser_irdy <= des_frm and (des_irdy or setif(cntr/=0 and des_data'length/=ser_data'length));
	des_trdy <= des_frm and (setif(cntr=des_data'length/ser_data'length-1 or des_data'length=ser_data'length) and ser_trdy);

end;

