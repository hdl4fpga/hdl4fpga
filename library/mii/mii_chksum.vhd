entity mii_chksum is
	generic (
		size : natural);
	port (
		mii_txc  : in  std_logic;
		mii_rxdv : in  std_logic;
		mii_rxd  : in  std_logic_vector;
		mii_txdv : in  std_logic;
		mii_txd  : in  std_logic_vector);
end;

architecture of mii_chksum is
begin
	process (mii_txc)
		variable aux : unsigned(0 to mii_txd'length+1);
		variable sum : unsigned(0 to size-1);
	begin
		if rising_edge(mii_txc) then
			if mii_rxdv='0' then
				sum := (others => '0');
			else
				sum := sum ror mii_txd'length;
				aux := aux rol 1;
				aux(mii_txd'range) := sum(mii_txd'range);
				aux := aux srl 1;
				aux := aux + ("0" & unsigned(reverse(mii_txd)) & "1");
				aux := aux rol 1;
				sum(mii_txd'range) := aux(mii_txd'range);
			end if;
		end if;
	end process;
end;
