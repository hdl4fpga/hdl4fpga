library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity adjdll is
	generic (
		period : natural);
	port (
		req   : in std_logic;
		clk0  : in std_logic;
		clk90 : in std_logic;
		rdy   : out std_logic;
		pha   : out std_logic_vector);
		
end;

library ecp3;
use ecp3.components.all;

architecture beh of adjdll is

	signal ph : std_logic_vector(0 to pha'length-1);
	signal kclk : std_logic;
	signal dg : unsigned(0 to pha'length+1);
	signal ok : std_logic;
	signal nxt : std_logic;

	signal smp_rdy : std_logic;
	signal smp_req : std_logic;
begin

	ff_b : block
		signal clk180 : std_logic;
		signal clk270 : std_logic;

		
		signal d0, d90 : std_logic;
		signal q0, q90, q180, q270 : std_logic;
		signal ok_d : std_logic;
		signal ok_q : std_logic;
	begin

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
		ff0_i : entity hdl4fpga.aff
		port map (
			ar  => smp_req,
			clk => clk0,
			d   => d0,
			q   => q0);

		d90 <= not q90;
		ff90_i : entity hdl4fpga.aff
		port map (
			ar  => smp_req,
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
				ok <= ok_q;
			end if;
		end process;

	end block;

	process(req, sclk)
		variable aux : unsigned(ph'range);
		variable smp_rdy1 : std_logic;
	begin
		if req='1' then
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

	process (req, sclk)
	begin
		if req='1' then
			pha <= (pha'range => '0');
		elsif rising_edge(sclk) then
			pha <= ph;
			if dg(dg'right)='1' then
				pha <= std_logic_vector(unsigned(ph) + 1);
			end if;
		end if;
	end process;

	process(req, sclk)
	begin
		if req='1' then
			rdy <= '0';
		elsif rising_edge(sclk) then
			if smp_req='0' then
				rdy <= dg(dg'right);
			end if;
		end if;
	end process;
end;
