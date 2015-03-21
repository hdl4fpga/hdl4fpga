library ieee;
use ieee.std_logic_1164.all;

entity miitxmem is
	generic (
		bram_size : natural := 9;
		data_size : natural := 32);
	port (
		ddrs_clk   : in  std_logic;
		ddrs_gnt   : in  std_logic;
		ddrs_req   : in  std_logic := '1';
		ddrs_rdy   : out std_logic;
		ddrs_direq : out std_logic;
		ddrs_dirdy : in  std_logic;
		ddrs_di    : in  std_logic_vector(data_size-1 downto 0);

		miitx_clk : in  std_logic;
		miitx_req : in  std_logic := '1';
		miitx_ena : out std_logic;
		miitx_rdy : out std_logic;
		miitx_dat : out std_logic_vector);
end;

library hdl4fpga;
use hdl4fpga.std.all;

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

architecture def of miitxmem is
	constant bram_num : natural := (unsigned_num_bits(ddrs_di'length-1)+bram_size)-(unsigned_num_bits(1024*8-1));

	subtype aword is std_logic_vector(bram_size-1 downto 0);
	type aword_vector is array(natural range <>) of aword;

	subtype dword is std_logic_vector(data_size-1 downto 0);
	type dword_vector is array(natural range <>) of dword;

	signal addri : unsigned(0 to bram_size-1);
	signal addro : unsigned(0 to bram_size-1);

	signal wr_address : std_logic_vector(0 to bram_size-1);
	signal wr_ena  : std_logic;
	signal wr_data : dword;

	signal miitx_addr : std_logic_vector(0 to bram_size-1);
	signal rd_address : std_logic_vector(0 to bram_size-1);
	signal rd_data : dword;
	signal bysel : std_logic_vector(1 to unsigned_num_bits(ddrs_di'length/miitx_dat'length-1));

	signal addri_edge : std_logic;
	signal addro_edge : std_logic;
	signal rdy : std_logic;

begin

	process (ddrs_clk)
	begin
		if rising_edge(ddrs_clk) then
			if ddrs_gnt='1' then
				if ddrs_req='1' then
					if (addri(bram_num-1) xor addri_edge)='1' then
						ddrs_rdy   <= '1';
						ddrs_direq <= '0';
					else
						ddrs_direq <= '1';
						ddrs_rdy   <= '0';
					end if;
				else
					ddrs_rdy   <= '0';
					ddrs_direq <= '0';
				end if;
			else
				ddrs_rdy   <= '0';
				ddrs_direq <= '0';
			end if;
		end if;
	end process;

	process (ddrs_clk)
	begin
		if rising_edge(ddrs_clk) then
			if ddrs_gnt='0' then
				addri <= to_unsigned(2**addri'length-1, addri'length);
			elsif ddrs_dirdy='1' then
				addri <= addri - 1;
			end if;
			wr_ena <= ddrs_dirdy;
			addri_edge <= addri(bram_num-1);
		end if;
	end process; 

	process (miitx_clk)
		variable bycnt : unsigned(0 to bysel'right);
		variable bydly : std_logic_vector(bysel'range);
	begin
		if rising_edge(miitx_clk) then
			if ddrs_gnt='0' then
				addro <= to_unsigned(2**addro'length-1, addro'length);
				addro_edge <= '1';
				bycnt := to_unsigned(2**(bycnt'length-1)-4, bycnt'length); 
				bydly := to_unsigned(2**(bycnt'length-1)-3, bydly'length); 
				bysel <= to_unsigned(2**(bycnt'length-1)-2, bysel'length); 
				miitx_rdy <= '0';
				rdy <= '0';
			elsif miitx_req='0' then
				addro_edge <= addro(bram_num-1);
				bycnt := to_unsigned(2**(bycnt'length-1)-4, bycnt'length); 
				bydly := to_unsigned(2**(bycnt'length-1)-3, bydly'length); 
				bysel <= to_unsigned(2**(bycnt'length-1)-2, bysel'length); 
				miitx_rdy <= '0';
				rdy <= '0';
			else
				miitx_rdy <= rdy;
				rdy <= addro(bram_num-1) xor addro_edge;
				bysel <= bydly;
				bydly := std_logic_vector(bycnt(bydly'range));
				if bycnt(0)='1' then
					addro_edge <= addro(bram_num-1);
					bycnt := to_unsigned(2**(bycnt'length-1)-2, bycnt'length); 
					if (addro(bram_num-1) xor addro_edge)='0' then
						addro <= addro - 1;
					end if;
				else
					bycnt := bycnt - 1;
				end if;
			end if;
		end if;
	end process;
	miitx_ena_p : process (miitx_clk, miitx_req)
	begin
		if miitx_req='0' then
			miitx_ena <= '0';
		elsif rising_edge(miitx_clk) then
			miitx_ena <= not rdy;
		end if;
	end process;

	wr_address_i : entity hdl4fpga.align
	generic map (
		n => wr_address'length,
		d => (wr_address'range => 1))
	port map (
		clk => ddrs_clk,
		di  => std_logic_vector(addri(wr_address'range)),
		do  => wr_address);

	wr_data_i : entity hdl4fpga.align
	generic map (
		n => ddrs_di'length,
		d => (ddrs_di'range => 1))
	port map (
		clk => ddrs_clk,
		di  => ddrs_di,
		do  => wr_data);

	rd_address_i : entity hdl4fpga.align
	generic map (
		n => rd_address'length,
		d => (rd_address'range => 1))
	port map (
		clk => miitx_clk,
		ena => '1',-- miitx_req, --miitx_ena,
		di  => std_logic_vector(addro),
		do  => rd_address);

	bram_e : entity hdl4fpga.dpram
	port map (
		wr_clk => ddrs_clk,
		wr_addr => wr_address, 
		wr_ena => wr_ena,
		wr_data => wr_data,
		rd_clk => miitx_clk,
		rd_ena => '1', --miitx_req, --miitx_ena,
		rd_addr => rd_address,
		rd_data => rd_data);

	miitx_dat <= reverse (
		word2byte (
			word => rd_data ror miitx_dat'length,
			addr => bysel));
end;
