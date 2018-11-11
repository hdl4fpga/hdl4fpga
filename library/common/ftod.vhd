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
	signal queue_left     : unsigned(1 to cntr'right);
	signal right    : unsigned(1 to cntr'right);

	signal mem_ptr  : unsigned(1 to cntr'right);
	signal mem_full : std_logic;
	signal rd_data  : std_logic_vector(bcd_do'range);
	signal wr_data  : std_logic_vector(bcd_do'range);

	signal queue_ini   : std_logic;
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

	carry    <= btod_cy when bin_fix='0' else dtof_cy;
	cntr_rst <= not bin_ena;
	cntr_ple <= '1' when queue_full='1' else not carry;
		
	cntr_p : process (clk)
	begin
		if rising_edge(clk) then
			if cntr_rst='1' then
				cntr <= (others => '1');
			elsif cntr(0)='1'then
				if queue_full='1'or carry='0' then
					cntr <= resize(left+right, cntr'length)-1;
				end if;
			else
				cntr <= cntr - 1;
			end if;
		end if;
	end process;

	left_updn <= bin_fix;
	left_ena  <= 
		'1' when bin_fix='0' and cntr(0)='1' and btod_cy='1' else
		'1' when bin_fix='1' and cntr(0)='0' and queue_di=(queue_di'range => '0') and zero else
		'0';

	right_updn <= '0';
	right_ena  <= 
		'1' when cntr(0)='1' and dtof_cy='1' and queue_full='0' else
		'0';

	process (clk)
	begin
		if rising_edge(clk) then
			if bin_ena='0' then
				queue_ini    <= '1';
				btod_dv   <= '1';
			elsif cntr(0)='1' then
				if mem_full='0' and carry='1' then
					btod_dv <= '0';
					queue_ini  <= '1';
				else
					btod_dv  <= '1';
					queue_ini   <= '0';
				end if;
			else
				queue_ini  <= '0';
				btod_dv <= '0';
			end if;
			fix <= bin_fix;
		end if;
	end process;

	process (clk)
	begin
		if rising_edge(clk) then
			if bin_ena='0' then
				queue_ini <= '1';
			elsif cntr(0)='1' then
				if queue_full='0' and carry='1' then
					queue_ini <= '1';
				else
					queue_ini <= '0';
				end if;
			else
				queue_ini <= '0';
			end if;
		end if;
	end process;

	bcd_lst <= cntr(0) and not (carry and not mem_full);
	bcd_di  <= (bcd_di'range => '0') when queue_ini='1' else rd_data;

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

	queue_di <= btod_do when fix='0' else dtof_do;
   		
	queue_addr <=
		queue_left + not cntr(mem_ptr'range) when fix='0' else
		0-not cntr(mem_ptr'range)-right;

	queue_rst <= not bin_ena;
	queue_e : entity hdl4fpga.queue
	port map (
		queue_clk  => queue_clk,
		queue_rst  => queue_rst,
		queue_ena  => queue_ena,
		queue_addr => queue_addr,
		queue_full => queue_full,
		queue_di   => queue_di,
		queue_do   => queue_do,
		head_ena   => left_ena,
		head_updn  => left_updn,
		queue_head => queue_left,
		tail_ena   => tail_ena,
		tail_updn  => tail_updn,
		queue_tail => queue_tail);

	bcd_do <= queue_di;
end;
