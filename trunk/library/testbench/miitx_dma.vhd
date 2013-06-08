architecture miitx_dma of testbench is
	constant n : natural := 9;

	signal mii_req  : std_logic;

	signal mii_txc  : std_logic := '0';
	signal mii_txen : std_logic;
	signal mii_txd  : std_logic_vector(4-1 downto 0);
		
	subtype word is std_logic_vector(32-1 downto 0);
	type word_vector is array (natural range <>) of word;

	function ram_init (
		constant size : natural)
		return word_vector is

		variable val : word_vector(size-1 downto 0);

		variable n0 : integer;
		variable n1 : integer;
		variable n2 : integer;
		variable n3 : integer;

		variable n  : integer;

	begin
		n := 0;
		for i in val'range loop
			n0 := ((n + 3) mod 256) * 256**0;
			n1 := ((n + 2) mod 256) * 256**1;
			n2 := ((n + 1) mod 256) * 256**2;
			n3 := ((n + 0) mod 256) * 256**3;

			val(i) := std_logic_vector(to_signed(n3 + n2 + n1 + n0, word'length));

			n := (n + 4) mod 256;
		end loop;
		return val;
	end;
	
	signal ram : word_vector(2**n-1 downto 0) := ram_init(2**n);
	signal sys_addr : std_logic_vector(n-1 downto 0);
	signal sys_data : word;
		
begin

	mii_txc <= not mii_txc after 5 ns;
	mii_req <= '0', '1' after 111 ns, '0' after 4000 ns, '1' after 4045 ns;

	sys_data <= ram(to_integer(unsigned(sys_addr)));
	miitx_dma_e : entity hdl4fpga.miitx_dma
	port map (
		sys_addr => sys_addr,
		sys_data => sys_data,
		mii_req  => mii_req,
		mii_txc  => mii_txc,
		mii_txen => mii_txen,
		mii_txd  => mii_txd);

end;
