library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pipe_le is
	generic (
		n : natural:= 64);
	port (
		clk : in std_logic;
		a : in unsigned(0 to n-1);
		b : in unsigned(0 to n-1);
		eq : out std_logic;
		le : out std_logic);
end;

architecture def of pipe_le is
	signal ple : std_logic_vector(0 to n-1);
	signal peq : std_logic_vector(0 to n-1);
begin
	process(clk)
	begin
		if rising_edge(clk) then
			peq(0) <= a(0) xnor b(0);
			if a(0)/=b(0) then
				ple(0) <= b(0);
			else
				ple(0) <= '1';
			end if;
		end if;
	end process;

	g1ton_g : for i in 1 to n-1 generate
		signal ar : std_logic_vector(0 to i-1);
		signal br : std_logic_vector(0 to i-1);
	begin
		process(clk)
		begin
			if rising_edge(clk) then
				ar <= ar(1 to i-1) & a(i);
				br <= br(1 to i-1) & b(i);
				if ar(0)=br(0) then
					peq(i) <= peq(i-1);
				else
					peq(i) <= '0';
				end if;
				ple(i) <= ple(i-1);
				if peq(i-1)='1' then
					if ar(0)/=br(0) then
						ple(i) <= br(0);
					end if;
				end if;
			end if;
		end process;
	end generate;
	eq <= peq(n-1);
	le <= ple(n-1);
end;
