entity scopeio_ftod is
	port (
		clk     : in  std_logic;
		bin_loa : in  std_logic;
		bin_pnt : in  std_logic_vector;
		bin_di  : in  std_logic_vector;

		bcd_lst : out std_logic;
		bcd_do  : out std_logic_vector);
end;

architecture def of scopeio_btod is
	signal rst     : std_logic;
	signal clk     : std_logic := '0';
	signal bin_ena : std_logic;
    signal bin_dv  : std_logic;
    signal bin_di  : std_logic_vector(0 to 16-1);

    signal bcd_ena : std_logic;
    signal bcd_lst : std_logic;
    signal bcd_do  : std_logic_vector(0 to 4-1);

	signal bin_fix : std_logic;
begin


	process (clk)
		variable cntr : unsigned(0 to bin_pnt'length);
	begin
		if rising_edge(clk) then
			if bcd_lst='1' then
				if bin_fix='0' then
				if cntr(0)='1' then
					cntr := cntr - 1;
				end if;
			end if;
		end if;
	end process;

	du: entity hdl4fpga.scopeio_btod
	port map (
		clk     => clk,
		bin_ena => bin_ena,
		bin_di  => bin_di,
		bin_fix => bin_fix,
                           
		bcd_lst => bcd_lst,
		bcd_do  => bcd_do);

end;
