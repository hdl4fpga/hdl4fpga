library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_dayser is
	port (
		chaini_clk  : in  std_logic;
		chaini_frm  : in  std_logic;
		chaini_irdy : in  std_logic;
		chaini_data : in  std_logic_vector;

		chaino_frm  : out std_logic;
		chaino_irdy : out std_logic;
		chaino_data : out std_logic_vector);
end;

architecture def of scopeio_dayser is
begin
	process (chaini_frm, chaini_irdy, chaini_data, chaini_clk)
		variable cntr : unsigned(0 to unsigned_num_bits(chaini_data'length/chaino_data'length-1)-1);
	begin
		if rising_edge(chaini_clk) then
			if chaini_frm='0' then
				cntr := (others => '0');
			else
				if cntr=0 then
					if chaini_irdy='1' then
						cntr := cntr + 1;
					end if;
				elsif 2**cntr'length=chaino_data'length/chaini_data'length then
					cntr := cntr + 1;
				elsif cntr=chaino_data'length/chaini_data'length-1 then
					cntr := (others => '0');
				end if;
			end if;
		end if;
		chaino_irdy <= (chaini_frm and chaini_irdy) or setif(cntr/=0);
		chaino_data <= word2byte(chaini_data, std_logic_vector(not cntr), chaino_data'length);
	end process;

	chaino_frm <= chaini_frm;
end;
