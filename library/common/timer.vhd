library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity timer is
	generic (
		n : natural := 3);
	port (
		data : in  std_logic_vector;
		clk  : in  std_logic;
		req  : in  std_logic;
		rdy  : out std_logic);
end;

architecture def of timer is
	constant size : natural := (data'length+n-1)/n;
	signal cy : std_logic_vector(n downto 0) := (0 => '1', others => '0');
	signal q  : std_logic_vector(n-1 downto 0);
	signal stop : std_logic;
begin

	process (clk)
	begin
		if rising_edge(clk) then
			for i in 0 to n-1 loop
				if req='1' then
					cy(i+1) <= '0';
				elsif cy(n)='0' then
					cy(i+1) <= q(i) and cy(i);
				end if;
			end loop;
		end if;
	end process;

	cntr_g: for i in 0 to n-1 generate
		signal cntr : unsigned(0 to hdl4fpga.std.min(size, data'length-i*size));
	begin
		cntr_p : process (clk)
		begin
			if rising_edge(clk) then
				if req='1' then
					cntr <= resize(resize(shift_right(unsigned(data), size*i), size), size+1);
				elsif cy(i)='1' then
					if cntr(0)='1' then
						cntr <= to_unsigned((2**size-2), size+1);
					else
						cntr <= cntr - 1;
					end if;
				end if;
			end if;
		end process;
		q(i) <= cntr(0);
	end generate;
	rdy <= cy(n);
end;
