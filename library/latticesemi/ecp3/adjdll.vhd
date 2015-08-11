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
		dqsdel : out std_logic;
		dqsbuf_rst : out std_logic;
		pha  : out std_logic_vector);
		
end;

library ecp3;
use ecp3.components.all;

architecture beh of adjdll is

	signal dqsdll_rst : std_logic;
	signal kclk, kclk_n : std_logic;
	signal ok : std_logic;
	signal adj_rdy : std_logic;
	signal adj_req : std_logic;
	signal dqsbuf_clr : std_logic;
	signal dqsbuf_rdy : std_logic;

	signal eclksynca_stop : std_logic;
	signal eclksynca_eclk : std_logic;
	signal eclksynca_rst  : std_logic;

	signal ph : unsigned(0 to pha'length-1);
	signal smp_rdy : std_logic;
	signal smp_req : std_logic;
	signal n_q : std_logic;
	signal dqsdll_uddcntln : std_logic;
	signal dqsdll_uddcntln_rdy : std_logic;
	signal dqsdll_lock : std_logic;
	signal ddrdqphy_rst : std_logic;

begin

	process (sclk)
		variable cntr : unsigned(0 to 4);
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

	dqsdll_rst <= smp_rdy;
	dqsdll_b : block
		signal lock : std_logic;
	begin

		dqsdllb_i : dqsdllb
		port map (
			rst => dqsdll_rst,
			clk => eclk,
			uddcntln => dqsdll_uddcntln,
			dqsdel => dqsdel,
			lock => lock);

		process (dqsdll_rst, eclk)
			variable sr : std_logic_vector(0 to 4);
		begin
			if dqsdll_rst='1' then
				sr := (others => '0');
			elsif rising_edge(eclk) then
				sr := sr(1 to 4) & lock;
			end if;
			dqsdll_lock <= sr(0);
		end process;

		process (eclk)
			variable counter : unsigned(0 to 3);
		begin
			if rising_edge(eclk) then
				if dqsdll_lock='0' then
					counter := (others => '0');
					dqsdll_uddcntln_rdy <= counter(0);
					dqsdll_uddcntln <= '0';
				else
					if counter(0)='0' then
						counter := counter + 1;
					end if;
					dqsdll_uddcntln_rdy <= counter(0);
					dqsdll_uddcntln <= counter(0);
				end if;
			end if;
		end process;

	end block;

	process(sclk, smp_rdy)
	begin
		if smp_rdy='1' then
			eclksynca_rst <= '1';
		elsif rising_edge(sclk) then
			eclksynca_rst <= not dqsdll_uddcntln_rdy;
		end if;
	end process;

	process (eclksynca_rst, eclk)
		variable q : std_logic_vector(0 to 2);
	begin
		if eclksynca_rst='1' then
			q := (others => '1');
		elsif falling_edge(eclk) then
			q := q(1 to 2) & '0';
		end if;
		eclksynca_stop <= q(0);
	end process;

	eclksynca_i : eclksynca
	port map (
		stop  => eclksynca_stop,
		eclki => eclk,
		eclko => eclksynca_eclk);

	synceclk <= kclk;
	kclk <= transport eclksynca_eclk after 0.75 ns + 0.056 ns;

	seclk_b : block
		signal ok_q : std_logic;
	begin

		ok_i : entity hdl4fpga.ff
		port map (
			clk => sclk,
			d   => kclk,
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
		variable adj_edge : std_logic;
	begin
		if rising_edge(sclk) then
			if adj_req='0' then
				ph  <= (others => '0');
				dg  := (0 => '1', others => '0');
				adj_edge := dg(dg'right);
				smp_req  <= '0';
			else
				if dg(dg'right)='0' then
					if smp_rdy='1' then
						aux := ph or dg(0 to aux'length-1);
						if ok='0' then
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
				adj_edge := adj_rdy;
			end if;
			adj_rdy  <= dg(dg'right);
		end if;
	end process;

	process (sclk)
	begin
		if rising_edge(sclk) then
			if rst='1' then
				pha <= (pha'range => '0');
			else
				pha <= std_logic_vector(ph);
				if adj_rdy='1' then
					pha <= std_logic_vector(ph+1);
				end if;
			end if;

		end if;
	end process;

	dqsbuf_clr <= not adj_rdy;
	kclk_n <= kclk;
	ff1 : entity hdl4fpga.aff
	port map (
		ar  => dqsbuf_clr,
		clk => kclk_n,
		d   => '1',
		q   => n_q);

	ff2 : entity hdl4fpga.aff
	port map (
		ar  => dqsbuf_clr,
		clk => kclk,
		d   => n_q,
		q   => dqsbuf_rdy);
	dqsbuf_rst <= not dqsbuf_rdy;

end;
