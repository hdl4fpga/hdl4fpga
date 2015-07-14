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

	signal ph : std_logic_vector(0 to pha'length-1);
	signal kclk : std_logic;
	signal dg : unsigned(0 to pha'length+1);
	signal oka : std_logic;
	signal okb : std_logic;
	signal nxt : std_logic;
	signal er_q, e, ef_q : std_logic;

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
	kclk <= transport eclksynca_eclk after 0.5 ns + 0.056 ns;

	process (sclk)
	begin
		if rising_edge(sclk) then
			if rst then
			end if;
		end if;
	end process;

	ff_b : block
		signal clk0, clk90, clk180, clk270 : std_logic;
		signal q0,   q90,   q180,   q270   : std_logic;
		signal d0,   d90  : std_logic;
		signal ok_d, ok_q : std_logic;
	begin

		clk0   <= er_q;
		clk90  <= ef_q;
		clk180 <= not clk0;
		clk270 <= not clk90;

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

		d0 <= not q0;
		ff0_i : entity hdl4fpga.ff
		port map (
			clk => clk0,
			d   => d0,
			q   => q0);

		d90 <= not q90;
		ff90_i : entity hdl4fpga.ff
		port map (
			clk => clk90,
			d   => d90,
			q   => q90);

		ff180_i : entity hdl4fpga.ff
		port map (
			ar  => smp_req,
			clk => clk180,
			d   => q0,
			q   => q180);

		ff270_i : entity hdl4fpga.ff
		port map (
			clk => sclk,
			d   => q90,
			q   => q270);

		ok_d <= q0 xor q90 xor q180 xor q270;
		ok_i : entity hdl4fpga.ff
		port map (
			clk => sclk,
			d   => ok_d,
			q   => ok_q);

		process (sclk)
		begin
			if rising_edge(sclk) then
				okb <= ok_q;
			end if;
		end process;

	end block;

	seclk_b : block
		signal kclk_n : std_logic;
		signal er_d : std_logic;
		signal ok_d, ok_q : std_logic;
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
			variable cntr : unsigned(0 to 3);
		begin
			if rising_edge(sclk) then
				if smp_req='1' then
					cntr := (others => '0');
				elsif cntr(0)='1' then
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

		process (smp_req, sclk)
		begin
			if rising_edge(sclk) then
				oka <= ok_q;
			end if;
		end process;

	end block;

	with xxx select
	ok <=
   		oka when '0',
		okb when others;

	with select 
	smp_rdy <=
   		smpa_rdy when '0',
		smpb_rdy when others;

	process(rst, sclk)
		variable aux : unsigned(ph'range);
		variable smp_rdy1 : std_logic;
	begin
		if rising_edge(sclk) then
			if rst='1' then
				ph  <= (others => '0');
				dg  <= (0 => '1', others => '0');
				nxt <= '0';
				smp_req  <= '1';
				smp_rdy1 := '1';
			else
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
		end if;
	end process;

	with select
	ph <=
		ph_a when '0',
		ph_b when others;

	process (rst, sclk)
	begin
		if rising_edge(sclk) then
			if rst='1' then
				pha <= (pha'range => '0');
			else
				pha <= ph;
				if dg(dg'right)='1' then
					pha <= std_logic_vector(unsigned(ph) + 1);
				end if;
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
