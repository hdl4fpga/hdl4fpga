library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ddr2video is
	port (
		ddrios_clk : in std_logic;
		ddrios_rd  : in std_logic;
		ddrios_brst_req : out std_logic;
		vsync_erq  : in std_logic;
		hsync_erq  : in std_logic;
		buff_ini   : out std_logic;
		page_addr  : in  std_logic_vector(0 to 3-1));
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture def of ddr2video is
	type wm_vector is array(natural range <>) of std_logic_vector(page_addr'range);
	constant wm_levels : wm_vector(0 to 3):= (
		2 => "010",
		1 => "001",
		0 => "111",
		3 => "011");

	signal fill_rdy : std_logic := '1';
	signal wm_mark  : std_logic;
	signal wm_level : std_logic_vector(page_addr'range);
	signal wm_cntr  : unsigned(0 to 2);
	signal sync_dat_edge : std_logic;
	signal sync_dat_pdge : std_logic;
	signal sync_dat_val  : std_logic_vector(0 to 1);
	signal sync_ena_edge : std_logic;
	signal sync_ena_ndge : std_logic;
	signal sync_ena_val  : std_logic_vector(0 to 1);
begin

	buff_ini <= sync_ena_ndge;
	process (ddrios_clk)
	begin
		if rising_edge(ddrios_clk) then
			wm_cntr <= dec (
				cntr => wm_cntr,
				ena  => sync_ena_ndge or (wm_mark and not fill_rdy), 
				load => sync_ena_ndge or wm_cntr(0),
				data => to_unsigned(2,wm_cntr'length));

			if sync_ena_ndge='1' then
				wm_level <= wm_levels(2);
				wm_mark  <= '0';
			else
				wm_level <= wm_levels(to_integer(wm_cntr(1 to 2)));
				wm_mark  <= setif(page_addr=wm_level);
			end if;

			sync_ena_val  <= not sync_ena_val(1) & not vsync_erq;
			sync_ena_edge <= sync_ena_val(0);
			sync_ena_ndge <= not sync_ena_val(0) and sync_ena_edge;

			sync_dat_val  <= not sync_dat_val(1) & not hsync_erq;
			sync_dat_edge <= sync_dat_val(0);
			sync_dat_pdge <= sync_dat_val(0) xor sync_dat_edge;

			if ddrios_rd='1' then
				if sync_ena_ndge='1' then
					fill_rdy <= '0';
					ddrios_brst_req <= '0';
				elsif sync_dat_pdge='1' then
					fill_rdy <= '0';
					ddrios_brst_req <= '1';
				elsif fill_rdy='0' then
					fill_rdy <= '0';
					ddrios_brst_req <= '1';
					if wm_mark='1' then
						fill_rdy <= '1';
						ddrios_brst_req <= '0';
					end if;
				else
					fill_rdy <= '1';
					ddrios_brst_req <= '0';
				end if;
			else
				fill_rdy <= '0';
				ddrios_brst_req <= '0';
				sync_ena_ndge <= '1';
			end if;
		end if;
	end process;
end;
