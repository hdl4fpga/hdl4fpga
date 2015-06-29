library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity adjpha is
	generic (
		period : natural);
	port (
		clk : in  std_logic;
		req : in  std_logic;
		rdy : in  std_logic;
		hld : in  std_logic;
		smp : in  std_logic;
		dg  : in  std_logic_vector;
		pha : out std_logic_vector);
end;

library ecp3;
use ecp3.components.all;

architecture beh of adjpha is
	subtype phi is unsigned (0 to pha'length-1);
	type phi_vector is array (natural range <>) of phi;
	
	impure function phi_table0 (
		constant period : natural)
		return phi_vector is
		variable retval : phi_vector(0 to pha'length-1) := (others => (others => '0'));
		constant step_delay : natural := 27;
	begin
		retval(0) := (0 => '1', others => '0');
		for i in 1 to pha'length-1 loop
			retval(i) := to_unsigned(period / (2**(i+1)*step_delay), pha'length);
		end loop;
		return retval;
	end;

	impure function phi_table1 (
		constant phi_tab1 : phi_vector)
		return phi_vector is
		variable retval : phi_vector(0 to pha'length-1) := (others => (others => '0'));
	begin
		retval(0) := phi_tab1(0);
		for i in 1 to pha'length-1 loop
			retval(i) := phi_tab1(i) - phi_tab1(i-1);
		end loop;
		return retval;
	end;

	constant phi_rom0 : phi_vector(0 to pha'length-1) := phi_table0(period-140);
	constant phi_rom1 : phi_vector(0 to pha'length-1) := phi_table1(phi_rom0);

begin

	process(clk)
		variable aux  : unsigned(pha'range);
		variable val  : unsigned(pha'range);
		variable addr : unsigned(0 to unsigned_num_bits(pha'length-1)-1);
	begin
		if rising_edge(clk) then
			if req='0' then
				aux  := (others => '0');
				pha  <= (pha'range => '0');
				addr := (others => '0');
			elsif rdy='1' then
				pha <= std_logic_vector(aux + 0);
			elsif hld='1' then
				if smp='0' then
					val := phi_rom0(to_integer(addr));
				else
					val := phi_rom1(to_integer(addr));
				end if;
				aux  := aux + val;
				addr := addr + 1;
				pha <= std_logic_vector(aux);
			end if;
		end if;
	end process;

end;
