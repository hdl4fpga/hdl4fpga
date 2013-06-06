architecture miitx_udp of testbench is
	signal mii_req  : std_logic;

	signal mii_txc  : std_logic := '0';
	signal mii_txen : std_logic;
	signal mii_txd  : std_logic_vector(4-1 downto 0);
		
begin

	mii_txc <= not mii_txc after 5 ns;
	mii_req <= '0', '1' after 111 ns, '0' after 4000 ns, '1' after 4045 ns;

	miitx_udp_e : entity work.miitx_udp
	port map (
		mii_req  => mii_req,
		mii_txc  => mii_txc,
		mii_txen => mii_txen,
		mii_txd  => mii_txd);

end;
