
-------------------------------------
-- Big Endian Alignment Store Unit --
-------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stu is
	generic (
		WORDSZ : std_ulogic_vector(0 to 1) := "00";
		HALFSZ : std_ulogic_vector(0 to 1) := "01";
		BYTESZ : std_ulogic_vector(0 to 1) := "10");
	port (
		a0   : in  std_ulogic;
		a1   : in  std_ulogic;
		sz   : in  std_ulogic_vector( 0   to   1);
		din  : in  std_ulogic_vector(31 downto 0); 
		dout : out std_ulogic_vector(31 downto 0);
		memE : out std_ulogic_vector( 0   to   3));
end;

architecture beh of stu is
	constant BYTE_LEN : natural := 8;

	type mux_matrix is array (natural range <>, natural range <>) of std_ulogic_vector(3 downto 0);

	constant byteSel : mux_matrix(0 to 3, 0 to 6) :=
		(("1000","0010","0000","0001","0000","0000","0000"),
		 ("0100","0001","0000","0000","0001","0000","0000"),
		 ("0010","0000","0010","0000","0000","0001","0000"),
         ("0001","0000","0001","0000","0000","0000","0001"));
	                                       
begin

	process (a0,a1,sz,din)

		variable sel    : natural range 0 to 6;
		variable aux : std_ulogic;

	begin

		dout <= (dout'range => '-');
		memE <= (memE'range => '0');

		if sz=WORDSZ or sz=HALFSZ or sz=BYTESZ then
			sel := 0;
			if sz=WORDSZ then
				sel := 0;
			elsif sz=HALFSZ then
				sel := 1;
				if a1='1' then
					sel := sel + 1;
				end if;
			elsif sz=BYTESZ then
				sel := 3;
				if a1='1' then
					sel := sel + 2;
				end if;
				if a0='1' then
					sel := sel + 1;
				end if;
			end if;

			for memN in byteSel'range(1) loop
				for byteN in byteSel(memN,sel)'range loop
					
					if byteSel(memN,sel)(byteN)='1' then
						memE(memN) <= '1';
						dout(BYTE_LEN*(memN+1)-1 downto BYTE_LEN*memN) <= 
							din(BYTE_LEN*(byteN+1)-1 downto BYTE_LEN*byteN);
					end if;
				end loop;
			end loop;
			
		end if;

	end process;
end;
