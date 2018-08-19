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
	signal btod_dv  : std_logic;
	signal rd_data  : std_logic_vector(bcd_do'range);
	signal wr_data  : std_logic_vector(bcd_do'range);
	signal mem_ptr  : std_logic_vector(1 to bcd_sz1'length);
	signal bcd_ena  : std_logic;
	signal right    : signed(1 to bcd_sz1'length);
	signal btod_cy  : std_logic;
begin

	process (clk)
		variable left_zero : std_logic;
	begin
		if rising_edge(clk) then
			if bin_ena='0' then
				bcd_dv    <= '1';
				btod_dv   <= '1';
				bcd_cntr  <= to_signed(-1, bcd_cntr'length);
				right      <= to_signed( 0, right'length);
				left_zero := '0';
			elsif bin_fix='0' then
				if bcd_cntr(0)='1' then
					left_zero := '0';
					if btod_cy='1' then
						right    <= right + 1;
						btod_dv  <= '0';
						bcd_dv   <= '1';
					else
						btod_dv  <= '1';
						bcd_dv   <= '0';
						bcd_cntr <= resize(right, bcd_cntr'length)-1;
					end if;
				else
					bcd_cntr <= bcd_cntr - 1;
					btod_dv  <= '0';
				end if;
			else
				if bcd_cntr(0)='1' then
					left_zero := '0';
					bcd_dv    <= '0';
					bcd_cntr  <= resize(right, bcd_cntr'length)-1;
				elsif wr_data/=(wr_data'range => '0') then
					left_zero := '1';
					bcd_cntr  <= bcd_cntr - 1;
				elsif left_zero='1' then
					bcd_cntr <= bcd_cntr - 1;
				else
					right <= right - 1;
				end if;
				btod_dv  <= '0';
			end if;
		end if;
	end process;

	bin_dv  <= btod_dv;
	bcd_lst <= bcd_cntr(0) and not btod_cy;
	bcd_di  <= (bcd_di'range => '0') when bcd_dv='1' else rd_data;

	btod_e : entity hdl4fpga.btod
	port map (
		clk    => clk,
		bin_dv => btod_dv,
		bin_di => bin_di,

		bcd_dv => '1',
		bcd_di => bcd_di,
		bcd_do => btod_do,
		bcd_cy => btod_cy);

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
   		
	mem_ptr <= std_logic_vector(right + not bcd_cntr(mem_ptr'range));

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
