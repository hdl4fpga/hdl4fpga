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
		miitx_ena : in std_logic;
		miitx_rdy : out std_logic;
		miitx_dat : out std_logic_vector);
end;

library hdl4fpga;
use hdl4fpga.std.all;

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

architecture def of miitxmem is
	constant bram_num : natural := 2;

	subtype aword is std_logic_vector(bram_size-1 downto 0);
	type aword_vector is array(natural range <>) of aword;

	subtype dword is std_logic_vector(data_size-1 downto 0);
	type dword_vector is array(natural range <>) of dword;

	signal addri : std_logic_vector(0 to bram_size-1);
	signal addro : std_logic_vector(0 to bram_size-1);

	signal wr_address : std_logic_vector(0 to bram_size-1);
	signal wr_ena  : std_logic;
	signal wr_data : dword;

	signal miitx_addr : std_logic_vector(0 to bram_size-1);
	signal rd_address : std_logic_vector(0 to bram_size-1);
	signal rd_data : dword;
	signal bysel : std_logic_vector(1 to unsigned_num_bits(data_size/miitx_data'length-1));

	signal baddro : std_logic_vector;
begin

	process (ddrs_clk)
		variable edge : std_logic;
	begin
		if rising_edge(ddrs_clk) then
			if ddrs_gnt='1' then
				if ddrs_req='1' then
					if (addri(0) xor edge)='1' then
						ddrs_rdy   <= '1';
						ddrs_direq <= '0';
					else
						ddrs_direq <= '1';
						ddrs_rdy   <= '0';
					end if;
				else
					ddrs_rdy   <= '0';
					ddrs_direq <= '0';
					baddro <= addri();
				end if;
			else
				ddrs_rdy   <= '0';
				ddrs_direq <= '0';
			end if;
			edge := addri(0);
		end if;
	end process;

	process (ddrs_clk)
	begin
		if rising_edge(ddrs_clk) then
			if ddrs_gnt='0' then
				addri <= to_unsigned(2**(addri'length-1)-1, addri'length);
			elsif addr(0)='1' then
				addri <= to_unsigned(2**(addri'length-1)-1, addri'length);
			else
				addri <= addri - 1;
			end if;
			wr_ena <= ddrs_dirdy;
		end if;
	end process; 

	process (miitx_clk)
		variable bycnt : unsigned(0 to bysel'right);
		variable bydly : std_logic_vector(bysel'range);
	begin
		if rising_edge(miitx_clk) then
			if miitx_req='0' then
				addro <= to_unsigned(2**(addro'length-1)-1, addro'length);
				bycnt := to_unsigned(2**(bycnt'length-1)-4, bycnt'length); 
				bydly := to_unsigned(2**(bycnt'length-1)-3, bycnt'length); 
				bysel <= to_unsigned(2**(bycnt'length-1)-2, bycnt'length); 
			elsif miitx_ena='1' then
				if bycnt(0)='1' then
					if addro(0)='0' then
						addro <= addro - 1;
						bycnt <= to_unsigned(2**(bycnt'length-1)-2, bycnt'length); 
					end if;
				else
					bycnt <= bycnt - 1;
				end if;
				bysel <= bydly;
				bydly := std_logic_vector(bycnt(bydly'range));
			end if;
		end if;
	end process;
	miitx_rdy <= addro(0);

	wr_address_i : entity hdl4fpga.align
	generic map (
		n => wr_address'length,
		d => (wr_address'range => 1))
	port map (
		clk => ddrs_clk,
		di  => addri(wr_address'range),
		do  => wr_address);

	wr_data_i : entity hdl4fpga.align
	generic map (
		n => ddrs_di'length,
		d => (ddrs_di'range => 1))
	port map (
		clk => ddrs_clk,
		di  => ddrs_di,
		do  => wr_data);

	miitx_addr <= baddro & addro();
	rd_address_i : entity hdl4fpga.align
	generic map (
		n => rd_address'length,
		d => (rd_address'range => 1))
	port map (
		clk => miitx_clk,
		ena => miitx_ena,
		di  => miitx_addr,
		do  => rd_address);

	bram_e : entity hdl4fpga.dpram
	port map (
		wr_clk => ddrs_clk,
		wr_addr => wr_address, 
		wr_ena => wr_ena,
		wr_data => wr_data,
		rd_clk => miitx_clk,
		rd_ena => miitx_ena,
		rd_addr => rd_address,
		rd_data => rd_data);

	miitx_dat <=  reverse (
		word2byte (
			word => mii_data ror miitx_dat'length,
			addr => bysel));
end;
