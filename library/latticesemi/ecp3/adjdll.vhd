library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adjdll is
	port (
		rst  : in  std_logic;
		sclk : in  std_logic;
		eclk : in  std_logic;
		kclk : in  std_logic;
		stop : buffer std_logic;
		rdy  : out std_logic;
		pha  : out std_logic_vector);
		
end;

architecture beh of adjdll is

	signal ph : std_logic_vector(pha'range);
	signal qk : std_logic;
	signal ok : std_logic;
	signal prdy : std_logic_vector(4 downto 0);
	signal dy : unsigned(prdy'range);
	signal dg : unsigned(0 to pha'length+1);
	signal q : std_logic_vector(0 to 1);

begin

	process (stop, kclk)
	begin
		if stop='1' then
			qk <= '0';
		elsif rising_edge(kclk) then
			qk <= not qk;
		end if;
	end process;

	process (stop, sclk)
	begin
		if stop='1' then
			ok <= '0';
			q <= (others => '0');
		elsif rising_edge(sclk) then
			if prdy(0)='1' then
--				ok <= not q(0) and q(1);
				ok <= q(1);
			end if;

			q(0) <= eclk;
			q(1) <= qk;
		end if;
	end process;

	process(rst, sclk)
		variable aux : unsigned(pha'range);
	begin
		if rst='1' then
			ph <= (others => '0');
			dg <= (0 => '1', others => '0');
			dy <= (others => '0');
			prdy <= (others => '0');
		elsif rising_edge(sclk) then
			if dg(dg'right)='0' or stop='1' then
				if prdy(2)='1' then
					aux := unsigned(ph);
					aux := aux or dg(0 to ph'length-1);
					if ok='1' then
						aux := aux and not dg(1 to ph'length);
					end if;
					ph <= std_logic_vector(aux);
					dg <= dg srl 1;
				end if;
				prdy <= std_logic_vector(dy and not (dy ror 1));
				dy <= dy(dy'left-1 downto 0) & not dy(dy'left);
			end if;
		end if;
	end process;

	stop <= dy(2+2);
	pha <= ph;

	process(rst, sclk)
	begin
		if rst='1' then
			rdy <= '0';
		elsif rising_edge(sclk) then
			if stop='0' then
				rdy <= dg(dg'right);
			end if;
		end if;
	end process;
end;
