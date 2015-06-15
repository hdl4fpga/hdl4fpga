entity ddrwl is
	port (
		clk : in  std_logic;
		req : in  std_logic;
		rdy : out std_logic;
		dqt : out std_logic_vector(0 to 4-1);
		dqs : out std_logic_vector(0 to 4-1);
		dqi : in  std_logic_vector(0 to 4-1);
		pha : out std_logic_vector);
end;

architecture beh of ddrwl is
	signal nxt : std_logic;
begin
	dqt <= (others => wle);
	ok <= dqi(dqi'left);

	process (wle)
		variable aux : unsigned(dqs'length-1 downto 0);
	begin
		aux := (others => '0');
		if req='1' then
			for i in 0 to dqs'length/2-1 loop
				aux := sll 2;
				aux(2-1 to 0) := "01";
			end loop;
		end if;
	end process;

	process (clk)
		variable cntr : std_logic_vector(0 to 3-1);
	begin
		if rising_edge(clk) then
			if req='1' then
				cntr := (0 => '1', others => '0');
			else
				cntr := cntr(cntr'left) & cntr(0 to cntr'left-1);
			end if;
			nxt <= cntr(0);
		end if;
	end process;

	adjpha_e : entity hdl4fpga.adjpha
	port map (
		clk => clk,
		req => req,
		rdy => rdy,
		nxt => nxt,
		ok  => ok,
		pha => pha);

end;
