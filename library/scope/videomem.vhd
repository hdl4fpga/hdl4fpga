library ieee;
use ieee.std_logic_1164.all;

entity videomem is
	generic (
		bram_num  : natural := 6;
		bram_size : natural := 9;
		data_size : natural := 32);
	port (
		ddrs_clk : in std_logic;
		ddrs_di_rdy : in std_logic;
		ddrs_di : in std_logic_vector(data_size-1 downto 0);

		buff_ini  : in  std_logic;

		page_off  : out std_logic_vector(bram_size-1 downto 0);
		page_addr : out std_logic_vector;

		output_clk  : in  std_logic;
		output_addr : in  std_logic_vector(bram_num*bram_size-1 downto 0);
		output_data : out std_logic_vector(bram_num*data_size-1 downto 0));
end;

library hdl4fpga;
use hdl4fpga.std.all;

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

architecture def of videomem is

	subtype dword is std_logic_vector(data_size-1 downto 0);
	type dword_vector is array(natural range <>) of dword;

	subtype aword is std_logic_vector(bram_size-1 downto 0);
	type aword_vector is array(natural range <>) of aword;

	signal bram_sel_cnt : std_logic_vector(0 to 3) := (others => '0');

	signal addri : std_logic_vector(0 to bram_size) := (others => '0');

	signal wr_address : std_logic_vector(1 to bram_size);
	signal wr_ena  : std_logic_vector(0 to 6-1);
	signal wr_data : dword;

	signal rd_data : dword_vector(0 to bram_num-1);
	signal rd_addr : aword_vector(0 to bram_num-1);

begin
	process (ddrs_clk)
		constant wr_tab : natural_vector(0 to 8-1) := (
			0 => 4, 1 => 3, 2 => 2, 3 => 1,
			4 => 0, 5 => 8, 6 => 8, 7 => 5);
		variable addri0_edge : std_logic;
	begin
		if rising_edge(ddrs_clk) then
			addri <= dec (
				cntr => addri,
				ena  => buff_ini or ddrs_di_rdy,
				load => buff_ini,
				data => std_logic_vector'(buff_ini & to_unsigned(2**bram_size-1,bram_size)));
			page_off  <= addri(1 to addri'right);

			bram_sel_cnt <= dec (
				cntr => bram_sel_cnt,
				ena  => buff_ini or (addri0_edge xor addri(0)),
				load => buff_ini or bram_sel_cnt(0),
				data => wr_ena'length-2);

			addri0_edge := addri(0);
			wr_ena <= (others => '0');
			wr_ena(wr_tab(to_integer(unsigned(bram_sel_cnt(1 to bram_sel_cnt'right))))) <= ddrs_di_rdy;
		end if;
	end process; 
	page_addr <= bram_sel_cnt(1 to bram_sel_cnt'right);

	wr_address_d : entity hdl4fpga.align
	generic map (
		n => wr_address'length,
		d => (wr_address'range => 1))
	port map (
		clk => ddrs_clk,
		di  => addri(wr_address'range),
		do  => wr_address);

	wr_data_d : entity hdl4fpga.align
	generic map (
		n => ddrs_di'length,
		d => (ddrs_di'range => 1))
	port map (
		clk => ddrs_clk,
		di  => ddrs_di,
		do  => wr_data);

	pages_g: for i in 0 to bram_num-1 generate
		sector_e : entity hdl4fpga.dpram
		generic map (
			data_size => data_size,
			address_size => bram_size)
		port map (
			wr_clk => ddrs_clk,
			wr_address => wr_address, 
			wr_ena => wr_ena(i),
			wr_data => wr_data,
			rd_clk => output_clk,
			rd_address => rd_addr(i),
			rd_data => rd_data(i));
	end generate;

	process (output_addr)
		variable addr : std_logic_vector(output_addr'range);
	begin
		addr := output_addr;
		for i in rd_addr'range loop
			rd_addr(i) <= addr(aword'range);
			addr := addr srl bram_size;
		end loop;
	end process;

	process (rd_data)
		variable data : std_logic_vector(output_data'range);
	begin
		data := (others => '-');
		for i in rd_data'reverse_range loop
			data := data sll data_size;
			data(dword'range) := rd_data(i);
		end loop;
		output_data <= data;
	end process;

end;
