library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity serdes is
	generic (
		rgtr  : boolean := false;
		debug : boolean := false);
	port (
		serdes_clk : in  std_logic;
		serdes_frm : in  std_logic;
		ser_irdy   : in  std_logic;
		ser_data   : in  std_logic_vector;

		des_irdy   : out std_logic;
		des_data   : out std_logic_vector);
end;

architecture def of serdes is
	signal stop : std_logic;
begin

	process (serdes_clk)
		variable cntr : unsigned(0 to unsigned_num_bits(des_data'length/ser_data'length-1)-1);
	begin
		if rising_edge(serdes_clk) then
			if des_data'length=ser_data'length then
				cntr := (others => '0');
				stop <= '1';
			else
				if serdes_frm='1' then
					if ser_irdy='1' then
						if 2**cntr'length=des_data'length/ser_data'length then
							cntr := cntr + 1;
						elsif cntr=des_data'length/ser_data'length-1 then
							cntr := (others => '0');
						end if;
					end if;
				else
					cntr := (others => '0');
				end if;
				stop <= setif(cntr=to_unsigned(des_data'length/ser_data'length-1,cntr'length));
			end if;
		end if;
	end process;

	process (ser_data, serdes_clk)
		function xxx (
			constant des_data : unsigned;
			constant ser_data : std_logic_vector;
			constant debug : boolean := false)
			return unsigned is
			variable des : unsigned(des_data'range);
		begin
			des := des_data;
			if des_data'ascending=ser_data'ascending then
				des(ser_data'range) := unsigned(ser_data);
				if ser_data'ascending then
					des := des rol ser_data'length;
				else
					des := des ror ser_data'length;
				end if;
			else

				if ser_data'ascending then
					des := des rol ser_data'length;
				else
					des := des ror ser_data'length;
				end if;

				-- Possible Xilinx ISE's bug 
				-- The following instruction :

				des(ser_data'reverse_range) := unsigned(ser_data);

				-- is replaced by :
--				if des'ascending then
--					des(ser_data'low to ser_data'high) := unsigned(ser_data);
--				else
--					des(ser_data'high downto ser_data'low) := unsigned(ser_data);
--				end if;

				-- to keep Xilinx ISE's synthesized on legacy FPGAs 

			end if;
			return des;
		end;

		variable des : unsigned(des_data'range);

	begin

		if rising_edge(serdes_clk) then
			if serdes_frm='1' then
				if ser_irdy='1' then
					des := xxx(des, ser_data, debug);
				end if;
			end if;
		end if;

		des_data <= std_logic_vector(xxx(des, ser_data, debug));

	end process;

	des_irdy <= serdes_frm and ser_irdy and stop;
end;
