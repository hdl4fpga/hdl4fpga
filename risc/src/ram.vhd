library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is 
	generic (
		M : natural;
		N : natural;
		DATA : std_ulogic_vector);
	port (
		addr : in  std_ulogic_vector(M-1 downto 0);
		dout : out std_ulogic_vector(0 to N-1));
end;

architecture beh of rom is
	signal RAM : std_ulogic_vector(0 to 2**M*N-1) := DATA;
begin
	process (addr)
		variable int_addr : natural;
	begin
		int_addr := TO_INTEGER(UNSIGNED(addr));
		for i in 0 to N-1 loop
			dout(i) <= RAM(int_addr*N+i);
		end loop;
	end process;
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spram is 
	generic (
		M : natural;
		N : natural;
		SYNC_ADDRESS : boolean;
		READ_FIRST : boolean);
	port (
		clk  : in  std_ulogic;
		we   : in  std_ulogic;
		addr : in  std_ulogic_vector(M-1 downto 0);
		din  : in  std_ulogic_vector(N-1 downto 0);
		dout : out std_ulogic_vector(N-1 downto 0));
end;

architecture beh of spram is
	type ram_type is array (0 to 2**M-1) of	std_ulogic_vector(N-1 downto 0);
	signal RAM : ram_type := (others => (others => '0')) ;
	signal addr_q : std_ulogic_vector(M-1 downto 0);
begin
	process (clk)
	begin
		if rising_edge(clk) then
			addr_q <= addr;
			if we='1' then
				RAM(TO_INTEGER(UNSIGNED(addr))) <= din;
			end if;
			if SYNC_ADDRESS and READ_FIRST then
				dout <= RAM(TO_INTEGER(UNSIGNED(addr)));
			end if;
		end if;
	end process;
	sync_address_g: if SYNC_ADDRESS and not READ_FIRST generate
		dout <= RAM(TO_INTEGER(UNSIGNED(addr_q)));
	end generate;
	async_address_g: if not SYNC_ADDRESS generate
		dout <= RAM(TO_INTEGER(UNSIGNED(addr)));
	end generate;
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dpram is 
	generic (
		M : natural;
		N : natural);
	port (
		clk   : in  std_ulogic;
		we    : in  std_ulogic;
		wAddr : in  std_ulogic_vector(M-1 downto 0);
		rAddr : in  std_ulogic_vector(M-1 downto 0);
		din   : in  std_ulogic_vector(N-1 downto 0);
		dout  : out std_ulogic_vector(N-1 downto 0));
end;

architecture beh of dpram is
	type ram_type is array (0 to 2**M-1) of	std_ulogic_vector(N-1 downto 0);
	signal RAM : ram_type := (others => (others => '0')) ;
begin
	process (clk)
	begin
		if rising_edge(clk) then
			if we='1' then
				RAM(TO_INTEGER(UNSIGNED(wAddr))) <= din;
			end if;
		end if;
	end process;
	dout <= RAM(TO_INTEGER(UNSIGNED(rAddr)));
end;
