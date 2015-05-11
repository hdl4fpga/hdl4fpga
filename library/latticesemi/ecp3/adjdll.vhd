library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

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
	signal qr : std_logic;
	signal qf : std_logic;
	signal ok : std_logic;
	signal prdy : std_logic_vector(5 downto 0);
	signal dy : unsigned(prdy'range);
	signal dg : unsigned(0 to pha'length+1);
	signal q : std_logic_vector(0 to 1);
	signal sm : std_logic;

begin

	process (stop, kclk)
	begin
		if stop='1' then
			qf <= '0';
		elsif falling_edge(kclk) then
			qf <= not setif(qf='1');
		end if;
	end process;

	process (stop, kclk)
	begin
		if stop='1' then
			qr <= '0';
		elsif rising_edge(kclk) then
			qr <= not setif(qr='1');
		end if;
	end process;
	sm <= qr xnor qf;

	process (stop, sclk)
	begin
		if stop='1' then
			ok <= '0';
			q <= (others => '0');
		elsif rising_edge(sclk) then
			if prdy(0)='1' then
--				ok <= not q(0) and q(1);
				ok <= qr xnor qf;
			end if;

			q(0) <= eclk;
		end if;
	end process;

	process(rst, sclk)
		variable aux : unsigned(pha'range);
		variable ok1 : std_logic;
	begin
		if rst='1' then
			ph <= (others => '0');
			dg <= (0 => '1', others => '0');
			dy <= (others => '0');
			prdy <= (others => '0');
			ok1 := '1';
		elsif rising_edge(sclk) then
			if dg(dg'right)='0' or stop='1' then
				if prdy(2)='1' then
					aux := unsigned(ph);
					aux := aux or dg(0 to ph'length-1);
					if ok=ok1 then
						aux := aux and not dg(1 to ph'length);
					else
					--	ok1 := ok;
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
