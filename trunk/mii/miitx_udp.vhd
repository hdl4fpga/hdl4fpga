use hdl4fpga.std.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity miitx_udp is
    port (
		sys_addr : out std_logic_vector;
		sys_data : in  std_logic_vector;

        mii_txc  : in  std_logic;
        mii_treq : in  std_logic;
		mii_trdy : out std_logic;
        mii_txen : out std_logic;
        mii_txd  : out nibble);
end;

architecture mix of miitx_udp is
	subtype nibble is std_logic_vector(mii_txd'range);
	type nibble_vector is array (natural range <>) of nibble;

	constant n : natural := 3;

	constant txpre : natural := 0;
	constant txmac : natural := 1;
	constant txpld : natural := 2;
	constant txcrc : natural := 3;

	signal txdat : nibble_vector(n downto 0);
	signal txena : std_logic_vector(n   downto 0);
	signal txreq : std_logic_vector(n+1 downto 0);

	signal txen : std_logic;
	signal txd : nibble;
	signal rdy : std_logic_vector(n downto 0);
	signal dat : nibble_vector(n downto 0);
	signal ena : std_logic_vector(n downto 0);
	signal crc_ted : std_logic;
begin

	miitx_pre_e  : entity hdl4fpga.miitx_mem
	generic map (
		mem_data =>  x"5555_5555_5555_55d5")
	port map (
		mii_txc  => mii_txc,
		mii_treq  => txreq(txpre),
		mii_txen => txena(txpre),
		mii_txd  => txdat(txpre));

	miitx_macudp_e  : entity hdl4fpga.miitx_mem
	generic map (
		mem_data => 
			x"ffffffffffff" &	-- MAC Destination Address
			x"000000010203"	&	-- MAC Source Address
			x"0800"         &   -- MAC Protocol ID
			x"4500"         &	-- IP  Version, header length, TOS
			x"041c"         &	-- IP  Length
			x"0000"         &	-- IP  Identification
			x"0000"         &	-- IP  Fragmentation
			x"0511"         &	-- IP  TTL, protocol
			x"ee61"         &	-- IP  Checksum
			x"c0a802c8"     &	-- IP  Source address
			x"ffffffff"     &	-- IP  Destination address
			x"00000400"     &	-- UDP Source port, Destination port
			x"04080000")	   	-- UDP Length, Checksum
	port map (
		mii_txc  => mii_txc,
		mii_treq => txreq(txmac),
		mii_txen => txena(txmac),
		mii_txd  => txdat(txmac));

	miitx_pld_e : entity hdl4fpga.miitx_dma
	port map (
		sys_addr => sys_addr,
		sys_data => sys_data,
		mii_txc  => mii_txc,
		mii_treq => txreq(txpld),
		mii_txen => txena(txpld),
		mii_txd  => txdat(txpld));

	miitx_crc_e : entity hdl4fpga.miitx_crc
	port map (
		mii_txc  => mii_txc,
		mii_treq => mii_treq,
		mii_ted  => crc_ted,
		mii_txi  => txd,
		mii_txen => txena(txcrc),
		mii_txd  => txdat(txcrc));

	crc_ted  <= rdy(0) and not rdy(n-1);
	txen <= (ena(0) or rdy(0)) and not rdy(n) and mii_treq; 
	mii_txen <= txen;

	txreq(0) <= mii_treq;
	miitx_cat_g : for i in 0 to n generate
	begin
		txreq(i+1) <= (not txena(i) and ena(i)) or rdy(i);
		process (mii_txc)
		begin
			if rising_edge(mii_txc) then
				if mii_treq='0' then
					rdy(i) <= '0';
					ena(i) <= '0';
				elsif txena(i)='0' then
					if ena(i)='1' then
						rdy(i) <= '1';
					end if;
				end if;
				ena(i) <= txena(i);
				dat(i) <= txdat(i);
			end if;
		end process;
	end generate;

	process (dat, rdy)
	begin
		txd <= (others => '-');
		for i in n-1 downto 0 loop
			if rdy(i)/='1' then
				txd <= dat(i);
			end if;
		end loop;
	end process;

	mii_trdy <= rdy(n);
	mii_txd  <= txdat(n) when rdy(n-1)='1' else txd;
end;
