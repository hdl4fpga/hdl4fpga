library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

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

	signal mux_sel : std_logic_vector(mux_range);
	signal mux_ena : std_logic;

begin

	assert des_data'length/ser_data'length=2**mux_length or des_data'length=ser_data'length 
	report "Length of des_data is not a multiple of power of 2 of length of ser_data"
	severity FAILURE;

	process (desser_clk)
		variable cntr : unsigned(0 to mux_length);
	begin
		if rising_edge(desser_clk) then
			if ser_data'length=des_data'length then
				cntr := (others => '1');
			elsif des_frm='0' then
				cntr := to_unsigned(des_data'length/ser_data'length-2, cntr'length);
			elsif des_irdy='1' and ser_trdy='1' then
				if cntr(0)='0' then
					cntr := cntr - 1;
				elsif des_irdy='1' then
					cntr := to_unsigned(des_data'length/ser_data'length-2, cntr'length);
				end if;
			end if;
			mux_sel <= std_logic_vector(cntr(mux_range));
			mux_ena <= cntr(0);
		end if;
	end process;

	ser_data <= 
	   des_data when des_data'length=ser_data'length else
	   multiplex(std_logic_vector(rotate_right(unsigned(des_data), ser_data'length)), mux_sel) when not  des_data'ascending else
	   multiplex(std_logic_vector(rotate_left(unsigned(reverse(reverse(des_data),ser_data'length)), ser_data'length)), mux_sel) when des_data'ascending;

	ser_irdy <= des_frm  and des_irdy;
	des_trdy <= ser_trdy and mux_ena;

end;

