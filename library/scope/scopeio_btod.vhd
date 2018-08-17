library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;

entity scopeio_btod is
	port (
		clk     : in  std_logic;
		bin_ena : in  std_logic;
		bin_dv  : out std_logic;
		bin_fix : in  std_logic := '0';
		bin_di  : in  std_logic_vector;

		bcd_sz1 : in  std_logic_vector;
		bcd_lst : out std_logic;
		bcd_do  : out std_logic_vector);
end;

architecture def of scopeio_btod is

	signal bcd_dv   : std_logic;
	signal bcd_di   : std_logic_vector(bcd_do'range);
	signal btod_do  : std_logic_vector(bcd_do'range);
	signal dtof_do  : std_logic_vector(bcd_do'range);
	signal bcd_cntr : signed(0 to 4);
	signal bin_dv1  : std_logic;
	signal rd_data  : std_logic_vector(bcd_do'range);
	signal wr_data  : std_logic_vector(bcd_do'range);
	signal mem_ptr  : std_logic_vector(1 to bcd_sz1'length);
	signal bcd_ena  : std_logic;
	signal base  : signed(1 to bcd_sz1'length);
begin

	process (clk)
		variable xxx : std_logic;
	begin
		if rising_edge(clk) then
			if bin_ena='0' then
				bcd_cntr <= not (-signed(resize(unsigned(bcd_sz1), bcd_cntr'length)));
				bcd_dv   <= '1';
				bin_dv1  <= '1';
				base     <= signed(bcd_sz1);
				xxx := '0';
			elsif bcd_cntr(0)='1' then
				bcd_cntr <= not (-signed(resize(unsigned(bcd_sz1), bcd_cntr'length)));
				bin_dv1  <= '1';
				bcd_dv   <= '0';
				xxx := '0';
			else
				if bin_fix='0' then
					bcd_cntr <= bcd_cntr - 1;
				elsif wr_data/=(wr_data'range => '0') then
					xxx := '1';
					bcd_cntr <= bcd_cntr - 1;
				elsif xxx = '1' then
					bcd_cntr <= bcd_cntr - 1;
				else
					base <= base + 1;
				end if;
				bin_dv1  <= '0';
			end if;
		end if;
	end process;

	bin_dv  <= bin_dv1;
	bcd_lst <= bcd_cntr(0);
	bcd_di  <= (bcd_di'range => '0') when bcd_dv='1' else rd_data;

--	process (clk)
--		variable xxx : unsigned(btod_do'length-1 downto 0);
--	begin
--		if rising_edge(clk) then
--			xxx := unsigned(btod_do);
--			for i in 0 to xxx'length/4-1 loop
--				if xxx(4-1 downto 0)/=(4-1 downto 0 => '0') then
--					ptr1 <= mem_ptr;
--				end if;
--				xxx := xxx ror 4;
--			end loop;
--		end if;
--	end process;

	btod_e : entity hdl4fpga.btod
	port map (
		clk    => clk,
		bin_dv => bin_dv1,
		bin_di => bin_di,

		bcd_dv => '1',
		bcd_di => bcd_di,
		bcd_do => btod_do);

	process (clk, bin_fix)
		variable ena : std_logic;
	begin
		if rising_edge(clk) then
			ena := bcd_cntr(0);
		end if;
		bcd_ena <= bin_fix and ena;
	end process;

	dtof_e : entity hdl4fpga.dtof
	port map (
		clk     => clk,
		bcd_ena => bcd_ena,
		point   => b"0",
		bcd_di  => rd_data,
		bcd_do  => dtof_do);

	wr_data <= btod_do when bin_fix='0' else dtof_do;
   		
	mem_ptr <= 
		std_logic_vector(bcd_cntr(mem_ptr'range) + 1) when bin_fix='0' else
		std_logic_vector(not bcd_cntr(mem_ptr'range) + base);

	ram_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => clk,
		wr_ena  => bin_ena,
		wr_addr => mem_ptr,
		wr_data => wr_data,
		rd_addr => mem_ptr,
		rd_data => rd_data);

	bcd_do <= wr_data;

end;
