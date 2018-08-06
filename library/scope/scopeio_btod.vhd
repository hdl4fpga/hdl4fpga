library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;

entity scopeio_btod is
	port (
		clk     : in  std_logic;
		bin_ena : in  std_logic;
		bin_dv  : out std_logic;
		bin_di  : in  std_logic_vector;

		bcd_sz1 : in  std_logic_vector;
		bcd_lst : out std_logic;
		bcd_do  : out std_logic_vector);
end;

architecture def of scopeio_btod is

	signal bcd_dv   : std_logic;
	signal bcd_di   : std_logic_vector(bcd_do'range);
	signal bcd_do1  : std_logic_vector(bcd_do'range);
	signal bcd_cntr : signed(0 to 4);
	signal bin_dv1  : std_logic;
	signal rd_data  : std_logic_vector(bcd_do'range);
	signal mem_ptr  : std_logic_vector(1 to bcd_sz1'length);
begin

	process (clk)
	begin
		if rising_edge(clk) then
			if bin_ena='0' then
				bcd_cntr <= not (-signed(resize(unsigned(bcd_sz1), bcd_cntr'length)));
				bcd_dv   <= '1';
				bin_dv1  <= '1';
			elsif bcd_cntr(0)='1' then
				bcd_cntr <= not (-signed(resize(unsigned(bcd_sz1), bcd_cntr'length)));
				bin_dv1  <= '1';
				bcd_dv   <= '0';
			else
				bcd_cntr <= bcd_cntr - 1;
				bin_dv1  <= '0';
			end if;
		end if;
	end process;

	bin_dv  <= bin_dv1;
	bcd_lst <= bcd_cntr(0);
	bcd_di  <= (bcd_di'range => '0') when bcd_dv='1' else rd_data;

	btod_e : entity hdl4fpga.btod
	generic map (
		registered_output => false)
	port map (
		clk    => clk,
		bin_dv => bin_dv1,
		bin_di => bin_di,

		bcd_dv => '1',
		bcd_di => bcd_di,
		bcd_do => bcd_do1);

	mem_ptr <= std_logic_vector(bcd_cntr(mem_ptr) + 1);
	ram_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => clk,
		wr_ena  => bin_ena,
		wr_addr => mem_ptr,
		wr_data => bcd_do1,
		rd_addr => mem_ptr,
		rd_data => rd_data);
	bcd_do <= bcd_do1;

end;
