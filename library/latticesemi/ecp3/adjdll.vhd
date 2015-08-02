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

	signal kclk : std_logic;
	signal ok : std_logic;
	signal er_q, ef_q : std_logic;
	signal sr_q, sf_q : std_logic;
	signal adj_rdy : std_logic;
	signal adj_req : std_logic;
	signal adj_edge : std_logic;
	signal adjdll_rdy : std_logic;
	signal adjdll_eclk : std_logic;
	signal adjdll_pha  : std_logic;

	signal eclksynca_stop : std_logic;
	signal eclksynca_eclk : std_logic;
	signal eclksynca_rst  : std_logic;

	signal ph, ph_r, ph_f : unsigned(0 to pha'length-1);
	signal smp_rdy : std_logic;
	signal smp_req : std_logic;

begin

	eclksynca_rst <= smp_rdy or adjdll_eclk;
	process (eclksynca_rst, eclk)
		variable q : std_logic_vector(0 to 2);
	begin
		if eclksynca_rst='1' then
			q := (others => '1');
			eclksynca_stop <= q(0);
		elsif falling_edge(eclk) then
			q := q(1 to 2) & '0';
			eclksynca_stop <= q(0);
		end if;
	end process;

	eclksynca_i : eclksynca
	port map (
		stop  => eclksynca_stop,
		eclki => eclk,
		eclko => eclksynca_eclk);

	synceclk <= kclk;
	kclk <= transport eclksynca_eclk after 0.75 ns + 0.056 ns;

	process (sclk)
	begin
		if rising_edge(sclk) then
			if rst='1' then
				adjdll_rdy  <= '0';
				adjdll_pha  <= '0';
				adjdll_eclk <= '0';
				adj_req  <= '0';
				adj_edge <= '0';
			elsif adjdll_pha='0' then
				if adj_edge='0' then
					adj_req <= '1';
					if adj_rdy='1' then
						adj_req  <= '0';
						adj_edge <= '1';
					end if;
				elsif adj_req='0' then
					if adj_rdy='0' then
						adj_req <= '1';
					end if;
				elsif adj_rdy='1' then
					adjdll_pha  <= '1';
					adjdll_eclk <= '1';
				end if;
			else
				adjdll_eclk <= '0';
				adjdll_rdy  <= '1';
			end if;
		end if;
	end process;

	seclk_b : block
		signal kclk_n : std_logic;
		signal sclk_n : std_logic;
		signal ef_d   : std_logic;
		signal sf_d   : std_logic;
		signal ok_d,  ok_q : std_logic;
		attribute HGROUP : string;
		attribute PBBOX : string;
		attribute HGROUP of ef_i: label is "ef_i";
		attribute HGROUP of er_i: label is "er_i";
		attribute HGROUP of sf_i: label is "sf_i";
		attribute PBBOX of ef_i: label is "1,1";
		attribute PBBOX of er_i: label is "1,1";
		attribute PBBOX of sf_i: label is "1,1";
	begin

		process (sclk)
			variable cntr : unsigned(0 to 3);
		begin
			if rising_edge(sclk) then
				if smp_req='0' then
					cntr := (others => '0');
				elsif smp_rdy='1' then
					cntr := (others => '0');
				elsif cntr(0)='0' then
					cntr := cntr + 1;
				end if;
				smp_rdy <= cntr(0);
			end if;
		end process;

		kclk_n <= not kclk;
		ef_d <= not ef_q;
		ef_i : fd1s3dx
		port map (
			cd => '0',
			ck => kclk,
			d  => ef_d,
			q  => ef_q);

		er_i : fd1s3dx
		port map (
			cd => '0',
			ck => sclk,
			d  => ef_q,
			q  => er_q);

		sclk_n <= not eclk;
		sf_d <= not sf_q;
		sf_i : fd1s3dx
		port map (
			cd => '0',
			ck => sclk,
			d  => eclk,
			q  => sf_q);

		ok_d <= ef_q xor er_q xor sf_q;
		ok_i : entity hdl4fpga.ff
		port map (
			clk => sclk,
			d   => ok_d,
			q   => ok_q);

		process (sclk)
		begin
			if rising_edge(sclk) then
				ok <= ok_q;
			end if;
		end process;

	end block;

	process(sclk)
		variable dg  : unsigned(0 to pha'length+1);
		variable aux : unsigned(ph'range);
	begin
		if rising_edge(sclk) then
			if adj_req='0' then
				ph  <= (others => '0');
				dg  := (0 => '1', others => '0');
				smp_req  <= '0';
			else
				if dg(dg'right)='0' then
					if smp_rdy='1' then
						aux := ph or dg(0 to aux'length-1);
						if ok=adj_edge then
							aux := aux and not dg(1 to aux'length);
						end if;
						ph <= aux;
						smp_req <= '0';
						dg := dg srl 1;
					else
						smp_req <= '1';
					end if;
				else
					smp_req <= '0';
				end if;
			end if;
			adj_rdy <= dg(dg'right);
		end if;
	end process;

	process (sclk)
		variable aux : unsigned(pha'range);
	begin
		if rising_edge(sclk) then
			if rst='1' then
				pha <= (pha'range => '0');
			else
				pha <= std_logic_vector(ph);
				if adjdll_pha='1' then
					pha <= std_logic_vector(ph_f-ph_r);
				elsif adj_edge='1' then
					ph_r <= ph;
				else
					ph_f <= ph;
				end if;
			end if;
		end if;
	end process;

	rdy <= adjdll_rdy;
end;
