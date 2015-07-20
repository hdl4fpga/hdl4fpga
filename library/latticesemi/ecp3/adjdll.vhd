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
	signal er_q, e, ef_q : std_logic;
	signal adj_rdy, adj_req : std_logic;
	signal adjdll_rdy : std_logic;

	signal eclksynca_stop : std_logic;
	signal eclksynca_eclk : std_logic;

	signal ph : std_logic_vector(0 to pha'length-1);
	signal smp_rdy : std_logic;
	signal smp_req : std_logic;
	constant delay : natural := 0;

begin

	adj_req <= not rst;
	process (eclk)
		variable q : std_logic_vector(0 to 1);
	begin
		if falling_edge(eclk) then
			eclksynca_stop <= q(0);
			q := q(1) & '0';
			if adjdll_rdy='0' then
				if smp_req='0' then
					eclksynca_stop <= '1';
					q := (others => '1');
				end if;
			end if;
		end if;
	end process;

	eclksynca_i : eclksynca
	port map (
		stop  => eclksynca_stop,
		eclki => eclk,
		eclko => eclksynca_eclk);

	synceclk <= kclk;
	kclk <= transport eclksynca_eclk after 0.75 ns + 0.056 ns;

	seclk_b : block
		signal kclk_n : std_logic;
		signal er_d : std_logic;
		signal ok_d, ok_q : std_logic;
	begin

		process (sclk)
			variable cntr : unsigned(0 to 3);
		begin
			if rising_edge(sclk) then
				if smp_req='0' then
					cntr := (others => '0');
				elsif cntr(0)='0' then
					cntr := cntr + 1;
				end if;
				smp_rdy <= cntr(0);
			end if;
		end process;

		er_d <= not er_q;
		er_i : entity hdl4fpga.ff
		port map (
			clk => kclk,
			d   => er_d,
			q   => er_q);

		kclk_n <= not kclk;
		ef_i : entity hdl4fpga.ff
		port map (
			clk => kclk_n,
			d   => er_q,
			q   => ef_q);

		ok_d <= er_q xor ef_q;
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
		variable dg  : unsigned(0 to pha'length+2);
		variable nxt : std_logic;
		variable aux : unsigned(ph'range);
		variable smp_rdy1 : std_logic;
	begin
		if rising_edge(sclk) then
			if adj_req='0' then
				ph  <= (others => '0');
				dg  := (0 => '1', others => '0');
				nxt := '0';
				smp_req  <= '0';
				smp_rdy1 := '1';
			else
				if dg(dg'right)='0' then
					if nxt='1' then
						aux := unsigned(ph) or dg(0 to aux'length-1);
						if ok='0' then
							aux := aux and not dg(1 to aux'length);
						end if;
						ph <= std_logic_vector(aux);
						smp_req <= '0';
						dg := dg srl 1;
					else
						smp_req <= '1';
					end if;
				else
					smp_req <= '0';
				end if;
				nxt := smp_rdy and not smp_rdy1;
				smp_rdy1 := smp_rdy;
			end if;
			adj_rdy <= dg(dg'right-1) or dg(dg'right);
			adjdll_rdy <=  dg(dg'right);
		end if;
	end process;

	process (sclk)
		variable aux : unsigned(pha'range);
	begin
		if rising_edge(sclk) then
			if rst='1' then
				pha <= (pha'range => '0');
			else
				pha <= ph;
				if adj_rdy='1' then
					pha <= std_logic_vector(unsigned(ph)+1+((delay mod period)*2**pha'length)/period);
				end if;
			end if;
		end if;
	end process;

	rdy <= adjdll_rdy;
end;
