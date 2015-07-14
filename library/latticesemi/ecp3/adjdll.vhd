library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity adjdll is
	generic (
		period : natural);
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

	signal ph180 : std_logic;
	signal ph90 : std_logic;
	signal ph : std_logic_vector(1 to pha'length-1);
	signal er, ef : std_logic;
	signal sr, sf : std_logic;
	signal qr, qf : std_logic;
	signal kclk : std_logic;
	signal dg : unsigned(0 to pha'length);
	signal ok : std_logic;
	signal sm : std_logic;
	signal nxt : std_logic;
	signal tst : std_logic := '-';

	signal eclksynca_stop : std_logic;
	signal eclksynca_eclk : std_logic;

	signal smp_rdy : std_logic;
	signal smp_req : std_logic;
begin

	eclksynca_i : eclksynca
	port map (
		stop  => eclksynca_stop,
		eclki => eclk,
		eclko => eclksynca_eclk);

	synceclk <= kclk;
	kclk <= transport eclksynca_eclk after 0.056 ns;

	seclk_b : block
		signal kclk_n : std_logic;
		signal er_n   : std_logic;
		signal ef_n   : std_logic;
	begin

		process (smp_req, eclk)
			variable q : std_logic_vector(0 to 1);
		begin
			if smp_req='1' then
				eclksynca_stop <= '1';
				q := (others => '1');
			elsif falling_edge(eclk) then
				eclksynca_stop <= q(0);
				q := q(1) & '0';
			end if;
		end process;

		process (sclk)
			variable shtr : std_logic_vector(0 to 3);
		begin
			if rising_edge(sclk) then
				if smp_req='1' then
					shtr := (others => '0');
				else
					shtr := shtr(1 to shtr'right) & '1';
				end if;
				smp_rdy <= shtr(0);
			end if;
		end process;

		er_n <= not er;
		er_i : entity hdl4fpga.aff
		port map (
			ar  => smp_req,
			clk => kclk,
			d   => er_n,
			q   => er);

		ef_n   <= not ef;
		kclk_n <= not kclk;
		ef_i : entity hdl4fpga.aff
		port map (
			ar  => smp_req,
			clk => kclk_n,
			d   => er,
			q   => ef);

		sr_i : entity hdl4fpga.ff
		port map (
			clk => sclk,
			d   => er,
			q   => sr);

		sf_i : entity hdl4fpga.aff
		port map (
			ar  => smp_req,
			clk => sclk,
			d   => ef,
			q   => sf);

		process (smp_req, sclk)
		begin
			if smp_req='1' then
				qr <= '0';
				qf <= '0';
				ok <= '0';
			elsif rising_edge(sclk) then
				ok <= qr xor qf;
				qr <= sr;
				qf <= sf;
			end if;
		end process;
		sm <= qf xor er;

	end block;

	process(rst, sclk)
		variable aux : unsigned(ph'range);
		variable smp_rdy1 : std_logic;
	begin
		if rst='1' then
			ph  <= (others => '0');
			dg  <= (0 => '1', others => '0');
			nxt <= '0';
			smp_req <= '1';
		elsif rising_edge(sclk) then
			if dg(dg'right)='0' then
				if nxt='1' then
					aux := unsigned(ph) or dg(0 to aux'length-1);
					if ok='0' then
						aux := aux and not dg(1 to aux'length);
					end if;
					ph <= std_logic_vector(aux);
					smp_req <= '1';
					dg <= dg srl 1;
				else
					smp_req <= '0';
				end if;
			else
				smp_req <= '0';
			end if;
			nxt <= smp_rdy and not smp_rdy1;
			smp_rdy1 := smp_rdy;
		end if;
	end process;

	process (rst, sclk)
		variable ok0 : std_logic;
	begin
		if rst='1' then
			ph180 <= '0';
			ph90  <= '0';
			tst   <= '0';
		elsif rising_edge(sclk) then
			if dg(0)='1' then
				if nxt='1' then
					ok0 := ok;
				end if;
			end if;
			if dg(1)='1' then
				if nxt='1' then
					tst <= '1';
				end if;
			elsif tst='1' then
				ph90  <= ok0;
				ph180 <= ;
			else
				ph90  <= ph(1);
				ph180 <= '0';
			end if;
		end if;
	end process;

	process (rst, sclk)
	begin
		if rst='1' then
			pha <= (pha'range => '0');
		elsif rising_edge(sclk) then
			pha <= ph180 & ph90 & ph(2 to ph'right);
			if dg(dg'right)='1' then
				pha <= std_logic_vector(unsigned(ph180 & ph90 & ph(2 to ph'right)) + 1);
			end if;
		end if;
	end process;

	process(rst, sclk)
	begin
		if rst='1' then
			rdy <= '0';
		elsif rising_edge(sclk) then
			if smp_req='0' then
				rdy <= dg(dg'right);
			end if;
		end if;
	end process;
end;
