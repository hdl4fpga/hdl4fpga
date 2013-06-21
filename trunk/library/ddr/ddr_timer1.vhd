library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity ddr_timer is
	generic ( 
		c200u : natural := 9;
		cDLL  : natural := 6;
		cREF  : natural := 4;
		c500u : natural := 1;
		cxpr  : natural := 1);
	port (
		ddr_timer_clk : in  std_logic;
		ddr_timer_rst : in  std_logic;

		ddr_init_rst : out std_logic;
		ddr_init_cke : out std_logic; 
		ddr_init_cfg : out std_logic;

		dll_timer_req : in  std_logic;
		dll_timer_rdy : out std_logic;
		ref_timer_req : in  std_logic;
		ref_timer_rdy : out std_logic);
end;

architecture def of ddr_timer is
	type timer_ids is (tid_200u, tid_dll, tid_ref, tid_500u, tid_xpr, tid_rst);

	type tidtab_row is record
		q : timer_ids;
		z : std_logic_vector(0 to 4);
		s : std_logic_vector(0 to 2);
	end record;
	type tid_table is array (timer_ids) of tidtab_row;
	type tidtab_vector is array (natural range <>) of tid_table;
	constant ddr : natural := 3;
	constant timer_tab : tidtab_vector(1 to 3) := (
		1 => (                  --  rcgdf
			tid_rst  => (tid_200u,  "-0000", "000"),
			tid_200u => (tid_dll,  "-1100", "001"),
			tid_dll  => (tid_ref,  "-1110", "010"),
			tid_ref  => (tid_ref,  "-1111", "010"),
			tid_500u => (tid_200u, "-----", "---"),
			tid_xpr  => (tid_200u, "-----", "---")),
		2 => (
			tid_rst  => (tid_200u, "-0000", "000"),
			tid_200u => (tid_500u, "-1000", "011"),
			tid_dll  => (tid_ref,  "-1110", "010"),
			tid_ref  => (tid_ref,  "-1111", "010"),
			tid_500u => (tid_dll,  "-1100", "001"),
			tid_xpr  => (tid_200u, "-----", "---")),
		3 => (
			tid_rst  => (tid_200u,  "00000", "000"),
			tid_200u => (tid_500u, "10000", "011"),
			tid_dll  => (tid_ref,  "11110", "010"),
			tid_ref  => (tid_ref,  "11111", "010"),
			tid_500u => (tid_xpr,  "11000", "100"),
			tid_xpr  => (tid_dll,  "11100", "001")));

	signal timer_dll : std_logic;
	signal timer_ref : std_logic;

	signal timer_rdy : std_logic;
	signal timer_req : std_logic;
	signal timer_id : timer_ids;
	signal timer_sel : std_logic_vector(0 to 2);

begin

	timers_e : entity hdl4fpga.timers
	generic map (
		timer_len  => 15,
		timer_data => (
			timer_ids'pos(tid_200u) => c200u,
			timer_ids'pos(tid_dll)  => cDLL,
			timer_ids'pos(tid_ref)  => cREF,
			timer_ids'pos(tid_500u) => c500u,
			timer_ids'pos(tid_xpr)  => cxpr))
	port map (
		timer_clk => ddr_timer_clk,
		timer_sel => timer_sel,
		timer_req => timer_req,
		timer_rdy => timer_rdy);

	process (ddr_timer_clk)
		variable next_tid  : timer_ids;
		variable o : timer_ids;
	begin
		if rising_edge(ddr_timer_clk) then
			if ddr_timer_rst='1' then
				timer_id <= tid_rst;
				o := timer_id;
				next_tid  := timer_tab (ddr)(timer_id).q;
				timer_req <= '0';
			elsif timer_rdy='1' then
				timer_req <= '0';
				if next_tid=tid_dll then
					if dll_timer_req='0' then
						timer_req <= '1';
					end if;
				end if;
				o := timer_id;
				timer_id <= next_tid;
			else
				timer_req <= '1';
				if timer_id=tid_ref then
					if ref_timer_req='0' then
						timer_req <= '0';
					end if;
				end if;

				next_tid := timer_tab(ddr)(timer_id).q;
			end if;

			timer_sel <= timer_tab(ddr)(next_tid).s;
			ddr_init_rst  <= timer_tab(ddr)(o).z(0);
			ddr_init_cke  <= timer_tab(ddr)(o).z(1);
			ddr_init_cfg  <= timer_tab(ddr)(o).z(2);
			dll_timer_rdy <= timer_tab(ddr)(o).z(3);
			ref_timer_rdy <= timer_tab(ddr)(o).z(4);
		end if;
	end process;
end;
