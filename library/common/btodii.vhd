library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity ftod is
	generic (
		n       : natural := 4);
	port (
		clk     : in  std_logic;
		bin_ena : in  std_logic;
		bin_fix : in  std_logic := '0';
		bin_di  : in  std_logic_vector;

		bcd_lst : out std_logic;
		bcd_lft : out std_logic_vector(n-1 downto 0);
		bcd_rgt : out std_logic_vector(n-1 downto 0);
		bcd_do  : out std_logic_vector);
end;

architecture def of ftod is

	signal cntr_ple : std_logic;
	signal cntr_rst : std_logic;
	signal cntr     : unsigned(0 to n);
	signal left     : unsigned(1 to cntr'right);
	signal right    : unsigned(1 to cntr'right);

	signal mem_ptr  : unsigned(1 to cntr'right);
	signal mem_full : std_logic;
	signal rd_data  : std_logic_vector(bcd_do'range);
	signal wr_data  : std_logic_vector(bcd_do'range);

	signal bcd_dv   : std_logic;
	signal bcd_di   : std_logic_vector(bcd_do'range);
	signal btod_do  : std_logic_vector(bcd_do'range);
	signal btod_dv  : std_logic;

	signal dtof_ena : std_logic;
	signal dtof_do  : std_logic_vector(bcd_do'range);

	signal btod_cy  : std_logic;
	signal dtof_cy  : std_logic;
	signal carry    : std_logic;

	signal fix      : std_logic;
begin

	mem_full <= setif(left+right=(left'range =>'1'));
	carry    <= btod_cy when bin_fix='0' else dtof_cy;
	cntr_rst <= not bin_ena;
	cntr_ple <= '1' when mem_full='1' else not carry;
		
	cntr_p : process (clk)
	begin
		if rising_edge(clk) then
			if cntr_rst='1' then
				cntr <= (others => '1');
			elsif cntr(0)='1'then
				if cntr_ple='1' then
					cntr <= resize(left+right, cntr'length)-1;
				end if;
			else
				cntr <= cntr - 1;
			end if;
		end if;
	end process;

	left_p : process(clk)
		variable zero : boolean;
	begin
		if rising_edge(clk) then
			if bin_ena='0' then
				zero := TRUE;
				left <= (others => '0');
			elsif bin_fix='0' then
				zero := TRUE;
				if cntr(0)='1' then
					if btod_cy='1' then
						left <= left + 1;
					end if;
				end if;
			else
				if cntr(0)='1' then
					zero  := TRUE;
				elsif wr_data/=(wr_data'range => '0') then
					zero  := FALSE;
				elsif zero then
					left <= left - 1;
				end if;
			end if;
		end if;
	end process;
	bcd_lft <= std_logic_vector(left);

	right_p : process(clk)
	begin
		if rising_edge(clk) then
			if bin_ena='0' then
				right  <= (others => '0');
			elsif bin_fix='1' then
				if cntr(0)='1' then
					if dtof_cy='1' then
						if mem_full='0' then
							right <= right  + 1 ;
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;
	bcd_rgt <= std_logic_vector(right);

	process (clk)
	begin
		if rising_edge(clk) then
			if bin_ena='0' then
				bcd_dv    <= '1';
				btod_dv   <= '1';
			elsif cntr(0)='1' then
				if mem_full='0' and carry='1' then
					btod_dv <= '0';
					bcd_dv  <= '1';
				else
					btod_dv  <= '1';
					bcd_dv   <= '0';
				end if;
			else
				bcd_dv  <= '0';
				btod_dv <= '0';
			end if;
			fix <= bin_fix;
		end if;
	end process;

	bcd_lst <= cntr(0) and not (carry and not mem_full);
	bcd_di  <= (bcd_di'range => '0') when bcd_dv='1' else rd_data;

	btod_e : entity hdl4fpga.btod
	port map (
		clk    => clk,
		bin_dv => btod_dv,
		bin_di => bin_di,

		bcd_di => bcd_di,
		bcd_do => btod_do,
		bcd_cy => btod_cy);

	process (clk, fix)
		variable ena : std_logic;
	begin
		if rising_edge(clk) then
			if mem_full='0' then
				ena := cntr(0) and not dtof_cy;
			else
				ena := cntr(0);
			end if;
		end if;
		dtof_ena <= fix and ena;
	end process;

	dtof_e : entity hdl4fpga.dtof
	port map (
		clk     => clk,
		bcd_ena => dtof_ena,
		point   => b"1",
		bcd_di  => bcd_di,
		bcd_do  => dtof_do,
		bcd_cy  => dtof_cy);

	wr_data <= btod_do when fix='0' else dtof_do;
   		
	mem_ptr <=
		left + not cntr(mem_ptr'range) when fix='0' else
		0-not cntr(mem_ptr'range)-right;

	ram_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => clk,
		wr_ena  => '1',
		wr_addr => std_logic_vector(mem_ptr),
		wr_data => wr_data,
		rd_addr => std_logic_vector(mem_ptr),
		rd_data => rd_data);

	bcd_do <= wr_data;

end;
