
---------------------------
-- Big Endian Store Unit --
---------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stu is
	port (
		a    : in  std_ulogic_vector(1 downto 0);
		sz   : in  std_ulogic_vector(1 downto 0);
		din  : in  std_ulogic_vector(31 downto 0); 
		dout : out std_ulogic_vector(0 to 31);
		memE : out std_ulogic_vector(0 to 3));
end;

architecture beh of stu is
	constant BYTE_SIZE : natural := 8;
begin
	process (sz,din)
		variable auxIn : std_ulogic_vector(din'range);
	begin
		auxIn := din;
		for i in sz'range loop
			for j in 0 to 2**(sz'length-(i+1))-1  loop
				if sz(i)='0' then
					for k in 0 to 2**i*BYTE_SIZE-1 loop
						auxIn(BYTE_SIZE*2**i*(2**(i+1)*j+1)+k) :=
							auxIn(BYTE_SIZE*2**i*2**(i+1)*j+k);
					end loop;
				end if;
			end loop;
		end loop;
		dout <= auxIn;
	end process;
	
	process (sz,a)
	begin
		memE <= (memE'range => '1');
		for i in sz'range loop
			for j in 0 to 2**(sz'length-(i+1))-1 loop
				if sz(i)='0' then
					for k in 0 to 2**i-1 loop
						if a(i)='1' then
							memE(2**i*2**(i+1)*j+k) <= '0';
						else 
							memE(2**i*(2**(i+1)*j+1)+k) <= '0';
						end if;
					end loop;
				end if;
			end loop;
		end loop;
	end process;
end;
