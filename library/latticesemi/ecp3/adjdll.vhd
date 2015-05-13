library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity adjdll is
	port (
		rst  : in std_logic;
		sclk : in std_logic;
		eclk : in std_logic;
		synceclk : out std_logic;
		rdy  : out std_logic;
		pha  : out std_logic_vector);
		
end;

library ecp3;
use ecp3.components.all;

architecture beh of adjdll is

	signal ph : std_logic_vector(pha'range);
	signal qr, qf : std_logic;
	signal er, ef : std_logic;
	signal kclk : std_logic;
	signal pe : std_logic_vector(0 to 5);
	signal dy : unsigned(pe'range);
	signal dg : unsigned(0 to pha'length+1);
	signal delta : unsigned(0 to 2);
	signal ok : std_logic;
	signal sm : std_logic;

	signal eclksynca_stop : std_logic;
	signal eclksynca_eclk : std_logic;
	alias stop : std_logic is dy(1);
begin

	process (stop, eclk)
		variable q : std_logic_vector(0 to 1);
	begin
		if stop='1' then
			eclksynca_stop <= '1';
			q := (others => '1');
		elsif falling_edge(eclk) then
			eclksynca_stop <= q(0);
			q := q(1) & '0';
		end if;
	end process;

	eclksynca_i : eclksynca
	port map (
		stop  => eclksynca_stop,
		eclki => eclk,
		eclko => eclksynca_eclk);

	synceclk <= eclksynca_eclk;
	kclk <= transport eclksynca_eclk after 0.156 ns;

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
	begin
		if rst='1' then
			dy <= (others => '0');
			dg <= (0 => '1', others => '0');
			pe <= (others => '0');
		elsif rising_edge(sclk) then
			pe <= std_logic_vector(dy and not (dy ror 1));
			if dg(dg'right)='0' then
				dy <= dy(1 to dy'right) & not dy(0);
				if pe(3)='1' then
					dg <= dg srl 1;
				end if;
			elsif stop='1' then
				dy <= dy(1 to dy'right) & not dy(0);
			end if;
		end if;
	end process;

	process(rst, sclk)
		variable aux : unsigned(pha'range);
	begin
		if rst='1' then
			ph <= (others => '0');
		elsif rising_edge(sclk) then
			if dg(dg'right)='0' then
				if pe(3)='1' then
					aux := unsigned(ph);
					aux := aux or dg(0 to ph'length-1);
					if ok='0' then
						aux := aux and not dg(1 to ph'length);
					end if;
					ph <= std_logic_vector(aux);
				end if;
			end if;
		end if;
	end process;

	process (rst, sclk)
	begin
		if rst='1' then
			pha <= (ph'range => '0');
			delta <= (delta'right => '1', others => '0');
		elsif rising_edge(sclk) then
			pha <= ph;
			if dg(dg'right)='1' then
					pha <= std_logic_vector(unsigned(ph) + 2);
			end if;
		end if;
	end process;

	process (rst, sclk)
	begin
		if rst='1' then
		elsif rising_edge(sclk) then
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
