library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adjdll is
	port (
		rst  : in  std_logic;
		sclk : in  std_logic;
		eclk : in  std_logic;
		kclk : in  std_logic;
		lck  : in  std_logic;
		stop : out std_logic;
		rdy  : out std_logic;
		pha  : out std_logic_vector);
		
end;

architecture beh of adjdll is

	signal ph : std_logic_vector(pha'range);
	signal qk : std_logic;
	signal ok : std_logic;
	signal nx : std_logic;

begin

	process (rst, kclk)
	begin
		if rst='1' then
			qk <= '0';
		elsif rising_edge(kclk) then
			qk <= not qk;
		end if;
	end process;

	process (rst, sclk)
		variable q : std_logic_vector(0 to 1);
	begin
		if rst='1' then
			ok <= '0';
			q := (others => '0');
		elsif rising_edge(sclk) then
			ok <= not q(0) and q(1);
			q(0) := eclk;
			q(1) := qk;
		end if;
	end process;

	process(rst, sclk)
		variable dg : unsigned(0 to pha'length);
	begin
		if rst='1' then
			ph <= (others => '0');
			dg := (0 => '1', others => '0');
			rdy <= dg(dg'right);
		elsif rising_edge(sclk) then
			if lck='1' then
				if dg(dg'right)='0' then
					if nx='1' then
						ph <= ph or  std_logic_vector(dg(0 to ph'length-1));
					else
						ph <= ph and not std_logic_vector(dg(0 to ph'length-1));
						dg := dg srl 1;
						stop <= '0';
					end if;
				end if;
			end if;
			rdy <= dg(dg'right);
		end if;
	end process;
	pha <= ph;
end;
