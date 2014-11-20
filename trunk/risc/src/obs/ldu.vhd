
---------------------------
-- Big Endian Store Unit --
---------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ldu is
	port (
		a     : in  std_ulogic_vector(1 downto 0);
		sz    : in  std_ulogic_vector(1 downto 0);
		sign  : in  std_ulogic;
		din   : in  std_ulogic_vector(0 to 31); 
		dout  : out std_ulogic_vector(31 downto 0);
		byteE : out std_ulogic_vector(3 downto 0));
end;

architecture beh of ldu is
	constant BYTE_SIZE : natural := 8;
begin
	process (a,sz,sign,din)
		variable auxIn : std_ulogic_vector(din'range);
		variable auxE  : std_ulogic_vector(byteE'range);
	begin
		auxIn := din;
		auxE  := (auxE'range => '1');

		for i in a'range loop
			for j in 0 to 2**(a'length-(i+1))-1 loop
				if sz(i)='0' and a(i)='0' then
					for k in 0 to 2**i*BYTE_SIZE-1 loop
						auxIn(BYTE_SIZE*2**i*(2**(i+1)*j+1)+k) := 
							auxIn(BYTE_SIZE*2**i*2**(i+1)*j+k);
					end loop;
				end if;
			end loop;
			if sz(i)='0' then
				for k in 0 to auxIn'right-2**i*BYTE_SIZE loop
					auxIn(k) := auxIn(auxIn'right-2**i*BYTE_SIZE+1) and sign;
				end loop;
			end if;
		end loop;

		for i in a'range loop
			for j in 0 to 2**(a'length-(i+1))-1 loop
				if sz(i)='0' then
					for k in 0 to 2**i-1 loop
						auxE(2**(i+1)*j+2**i+k) := '0';
					end loop;
				end if;
			end loop;
		end loop;
		byteE <= auxE;
		dout  <= auxIn;
	end process;
end;
