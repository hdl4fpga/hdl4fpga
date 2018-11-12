library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity ftod is
	generic (
		size    : natural := 4);
	port (
		clk     : in  std_logic;
		bin_cnv : in  std_logic;
		bin_ena : in  std_logic := '1';
		bin_dv  : out std_logic;
		bin_di  : in  std_logic_vector;

		bcd_do  : out std_logic_vector);
end;

architecture def of ftod is

	constant up : std_logic := '0';
	constant dn : std_logic := '1';

	signal queue_rst  : std_logic;
	signal queue_full : std_logic;
	signal queue_head : std_logic_vector(size-1 downto 0);
	signal queue_tail : std_logic_vector(size-1 downto 0);
	signal queue_addr : std_logic_vector(size-1 downto 0);
	signal queue_do   : std_logic_vector(bcd_do'range);
	signal queue_di   : std_logic_vector(queue_do'range);
	signal head_updn  : std_logic;
	signal head_ena   : std_logic;
	signal tail_updn  : std_logic;
	signal tail_ena   : std_logic;

	signal btod_ini   : std_logic;
	signal btod_dcy   : std_logic;
	signal btod_bdv   : std_logic;
	signal btod_ddi   : std_logic_vector(bcd_do'range);
	signal btod_ddo   : std_logic_vector(bcd_do'range);
	
begin

	btod_ddi_p : process(clk)
	begin
		if rising_edge(clk) then
			if bin_cnv='0' then
				btod_ini <= '1';
			elsif queue_addr=queue_head(queue_addr'range) then
				if btod_dcy='1' then
					btod_ini <= '1';
				else
					btod_ini <= '0';
				end if;
			end if;
		end if;
	end process;

	btod_ddi <= (others => '0') when btod_ini='1' else queue_do;
	btod_e : entity hdl4fpga.btod
	port map (
		clk     => clk,
		bin_dv  => btod_bdv,
		bin_ena => bin_ena,
		bin_di  => bin_di,

		bcd_di  => btod_ddi,
		bcd_do  => btod_ddo,
		bcd_cy  => btod_dcy);
   		

	binbdv_p : process(clk)
	begin
		if rising_edge(clk) then
			if bin_cnv='0' then
				btod_bdv  <= '1';
			else
				btod_bdv  <= not btod_dcy;
			end if;
		end if;
	end process;
	bin_dv <= btod_bdv and bin_cnv;

	addr_p : process(clk)
	begin
		if rising_edge(clk) then
			if bin_cnv='0' then
				queue_addr <= (others => '0');
			elsif queue_addr = queue_head(queue_addr'range) then
				if btod_dcy='1' then
					queue_addr <= std_logic_vector(unsigned(queue_addr) + 1);
				else
					queue_addr <= queue_tail(queue_addr'range);
				end if;
			else
				queue_addr <= std_logic_vector(unsigned(queue_addr) + 1);
			end if;
		end if;
	end process;

	head_p : process(queue_addr, queue_head, btod_dcy)
	begin
		head_updn <= '-';
		head_ena  <= '0';
		if queue_addr=queue_head(queue_addr'range) then
			if btod_dcy='1' then
				head_updn <= up;
				head_ena  <= '1';
			end if;
		end if;
	end process;

	queue_rst <= not bin_cnv;
	queue_di  <= btod_ddo; -- when bin_fix='0' else dtof_do;
	queue_e : entity hdl4fpga.queue
	port map (
		queue_clk  => clk,
		queue_rst  => queue_rst,
		queue_ena  => bin_ena,
		queue_addr => std_logic_vector(queue_addr),
		queue_full => queue_full,
		queue_di   => queue_di,
		queue_do   => queue_do,
		head_ena   => head_ena,
		head_updn  => head_updn,
		queue_head => queue_head,
		tail_ena   => tail_ena,
		tail_updn  => tail_updn,
		queue_tail => queue_tail);
end;
