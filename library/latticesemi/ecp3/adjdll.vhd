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
	signal qr, qf : std_logic;
	signal er, ef : std_logic;
	signal ok : std_logic;
	signal prdy : std_logic_vector(5 downto 0);
	signal dy : unsigned(prdy'range);
	signal dg : unsigned(0 to pha'length+1);
	signal sm : std_logic;

begin

	process (stop, kclk)
	begin
		if stop='1' then
			er <= '0';
		elsif rising_edge(kclk) then
			er <= not setif(er='1');
		end if;
	end process;

	process (stop, kclk)
	begin
		if stop='1' then
			ef <= '0';
		elsif falling_edge(kclk) then
			ef <= not setif(ef='1');
		end if;
	end process;

	process (stop, sclk)
		variable dr : std_logic_vector(0 to 1);
		variable df : std_logic_vector(0 to 1);
	begin
		if stop='1' then
			qr <= '0';
			qf <= '0';
			dr := (others => '0');
			df := (others => '0');
			ok <= '0';
		elsif rising_edge(sclk) then
			ok <= qr xor qf;
			dr := dr(1) & er;
			df := df(1) & ef;
			qr <= dr(0);
			qf <= df(0);
		end if;
	end process;
	sm <= qf xor er;

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
					if ok='0' then
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
	process (rst, sclk)
		variable ok1 : std_logic;
	begin
		if rst='1' then
			pha <= (ph'range => '0');
			ok1 := '0';
		elsif rising_edge(sclk) then
			if dg(dg'right)='1' then
				if ok1='1' then
					if stop='1' then
						if ph(ph'right)='1' then
							pha <= std_logic_vector(unsigned(ph) + 1);
						end if;
					end if;
				end if;
			else
				pha <= ph;
			end if;
			ok1 := ok;
		end if;
	end process;

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
