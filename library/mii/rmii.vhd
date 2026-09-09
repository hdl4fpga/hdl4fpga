	
entity rmii is
	port (
		rmii_clk   : in  std_logic;
		rmii_crsdv : in  std_logic;
		rmii_rxd   : in  std_logic_vector;
		rmii_txen  : out std_logic;
		rmii_txd   : out std_logic_vector;

		mii_rxc    : out std_logic;
		mii_rxdv   : out std_logic;
		mii_rxd    : out std_logic_vector;

		mii_txc    : out std_logic;
		mii_txen   : in  std_logic;
		mii_txd    : in  std_logic_vector);
end;

architecture beh of rmii is
begin

	process(rmii_crsdv, rmii_clk)
		variable shr_dv  : unsigned(0 to 2-1);
		variable shr_rxd : unsigned(0 to shr_dv'length*rmii_rxd'length-1);
	begin
		if rising_edge(rmii_clk) then
			case std_logic_vector'(shr_dv(0), shr_dv(1), rmii_crsdv) is
			when "000"|"001"|"011" =>
				rmii_rxdv <= '0';
			when others =>
				rmii_rxdv <=  '1';
			end case;
			rmii_rxd <= std_logic_vector(shr_rxd(0 to rmii_rxd'length-1));

			shr_rxd(0 to 2-1) := unsigned'(rmii_rxd);
			shr_rxd   := rotate_left(shr_rxd, rmii_rxd'length);
			shr_dv(0) := rmii_crsdv;
			shr_dv    := rotate_left(shr_dv, 1);
		end if;
	end process;

	rmii_txen <= mii_txen;
	rmii_txd  <= mii_txd;
end;
