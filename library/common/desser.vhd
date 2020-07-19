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

	signal mux_sel : std_logic_vector(1 to mux_length;
	signal mux_ena : std_logic;

begin

	assert des_data'length/ser_data'length=2**mux_length
	report "Length of des_data is not a multiple of power of 2 of length of ser_data"
	severity FAILURE;

	process (desser_clk)
		variable cntr : unsigned(0 to mux_length);
	begin
		if rising_edge(desser_clk) then
			if ser_data'length=des_data'length then
				cntr := (others => '1');
			elsif des_data'length=ser_data'length then
				cntr := (others => '1');
			elsif des_frm='0' then
				cntr := (others => '1');
			elsif ser_trdy='1' then
				if cntr(0)='0' then
					cntr := cntr - 1;
				elsif des_irdy='1' then
					cntr := to_unsigned(des_data'length/ser_data'length-2);
				end if;
			end if;
			mux_sel <= cntr(mux_range);
			mux_ena <= not cntr(0);
		end if;
	end process;

	ser_data <= 
		word2byte(std_logic_vector(rotate_right(unsigned(reverse(reverse(des_data), ser_data'length)))), mux_sel) when des_data'ascending else
		word2byte(std_logic_vector(rotate_right(unsigned(des_data), ser_data'length)), mux_sel);

	ser_irdy <= des_frm and (des_irdy or  mux_ena);
	des_trdy <= des_frm and (ser_trdy and not mux_ena);

end;

