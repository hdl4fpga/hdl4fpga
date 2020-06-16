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
		des_trdy   : out std_logic;
		des_data   : in  std_logic_vector;

		ser_irdy   : out std_logic;
		ser_trdy   : in  std_logic := '1';
		ser_data   : out std_logic_vector);
end;

architecture mux of desser is

	signal cntr : unsigned(0 to unsigned_num_bits(des_data'length/ser_data'length-1)-1);

begin

	process (desser_clk)
	begin
		if rising_edge(desser_clk) then
			if des_data'length=ser_data'length then
				cntr <= (others => '0');
			elsif desser_frm='0' then
				cntr <= (others => '0');
			elsif ser_trdy='1' then
				if cntr=0 then
					if des_irdy='1' then
						cntr <= cntr + 1;
					end if;
				elsif 2**cntr'length=des_data'length/ser_data'length then
					cntr <= cntr + 1;
				end if;
			elsif cntr=des_data'length/ser_data'length-1 then
				cntr <= (others => '0');
			end if;
		end if;
	end process;

	ser_data <= 
		word2byte(reverse(reverse(des_data), ser_data'length), std_logic_vector(cntr), ser_data'length) when des_data'ascending else
		word2byte(des_data, std_logic_vector(cntr), ser_data'length);

	ser_irdy <= desser_frm and (des_irdy or setif(cntr/=0 and des_data'length/=ser_data'length));
	des_trdy <= desser_frm and (setif(cntr=des_data'length/ser_data'length-1 or des_data'length=ser_data'length) and ser_trdy);

end;

architecture rgtr of desser is

	signal start : std_logic;

begin

	process (desser_clk)
		variable cntr : unsigned(0 to unsigned_num_bits(des_data'length/ser_data'length-1)-1);
	begin
		if rising_edge(desser_clk) then
			if des_data'length=ser_data'length then
				cntr := (others => '0');
			elsif desser_frm='0' then
				cntr := (others => '0');
			elsif ser_trdy='1' then
				if cntr=0 then
					if des_irdy='1' then
						cntr := cntr + 1;
					end if;
				elsif 2**cntr'length=des_data'length/ser_data'length then
					cntr := cntr + 1;
				end if;
			elsif cntr=des_data'length/ser_data'length-1 then
				cntr := (others => '0');
			end if;
		end if;
		start <= setif(cntr=0);
	end process;

	process (start, des_data, desser_clk)
		variable des : unsigned(des_data'range);
	begin
		if rising_edge(desser_clk) then
			if desser_frm='1' then
				if des_irdy='1' then
					if start='1' then
						des := unsigned(des_data);
					end if;
					if des'ascending then
						des := des sll ser_data'length;
					else
						des := des srl ser_data'length;
					end if;
				end if;
			end if;
		end if;
		ser_data <= setif(start='1', des_data(ser_data'range), std_logic_vector(des(ser_data'range)));
	end process;

	ser_irdy <= desser_frm and (des_irdy or setif(start='0'));
	des_trdy <= desser_frm and (setif(start='0'));

end;
