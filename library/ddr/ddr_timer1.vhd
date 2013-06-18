library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity ddr_timer is
	generic ( 
		c200u : natural := 9;
		cDLL  : natural := 6;
		cREF  : natural := 4);
	port (
		ddr_timer_clk : in  std_logic;
		ddr_timer_rst : in  std_logic;

		ddr_init_rst : out std_logic;
		ddr_init_cke : out std_logic; 

		dll_timer_rdy : out std_logic;
		ref_timer_rdy : out std_logic);
end;

architecture def of ddr_timer is
	type timer_ids is (tid_200u, tid_500u, tid_xpr, tid_dll, tid_ref);

	type tid_vector is array (timer_id) of timer_ids;
	type tid_2array is array (natural range <>) of tid_vector;
	constant tid_seq : tid_2array(0 to 3-1) := (
		0 => (
			tid_200u => tid_dll,  tid_500u => tid_xpr, tid_xpr => tid_dll,
			tid_dll  => tid_ref,  tid_ref  => tid_ref),
		1 => (
			tid_200u => tid_500u, tid_500u => tid_xpr, tid_xpr => tid_dll,
			tid_dll  => tid_ref,  tid_ref  => tid_ref),
		0 => (
			tid_200u => tid_500u, tid_500u => tid_xpr, tid_xpr => tid_dll,
			tid_dll  => tid_ref,  tid_ref  => tid_ref),
		tid_500u => tid_xpr,
		tid_xpr  => tid_dll,
		tid_dll  => tid_ref);

	signal timer_dll : std_logic;
	signal timer_ref : std_logic;

	signal timer_rdy : std_logic;
	signal timer_req : std_logic;
	signal timer_id  : timer_ids;
	signal next_tid  : timer_ids;
begin

	timers_e : entity hdl4fpga.timers
	port map (
		timer_clk => ddr_timer_clk,
		timer_sel => timer_sel,
		timer_req => timer_req,
		timer_rdy => timer_rdy);

	process (ddr_timer_clk)
	begin
		if rising_edge(ddr_timer_clk) then
			if ddr_timer_rst='1' then
				ddr_init_rst <= '0';
				ddr_init_cke <= '0';
				timer_id  <= tid_200u;
			elsif timer_rdy='1' then
				case timer_id is
				when tid_200u =>
					ddr_init_rst  <= '1';
					ddr_init_cke  <= '0';
					ddl_timer_rdy <= '0';
					ref_timer_rdy <= '0';

					timer_id  <= next_tid;
					timer_req <= '0';
				when tid_500u => 
					ddr_init_rst <= '1';
					ddr_init_cke <= '1';
					timer_id  <= next_tid;
					timer_req <= '0';
				when tid_xpr =>
					ddr_init_rst <= '1';
					ddr_init_cke <= '1';
					timer_id  <= next_tid;
					timer_req <= '0';
				when tid_dll =>
					dll_timer_rdy <= '1';
					timer_id  <= next_tid;
					timer_req <= '0';
				when tid_xpr =>
					timer_id  <= next_tid;
					timer_req <= '0';
				end case;
			else
				case timer_id is
				when tid_200u =>
					next_tid <= (ddr)(tid_200u);
					timer_req <= '1';
				when tid_500u => 
					next_tid <= (ddr)(tid_500u);
					timer_req <= '1';
				when tid_xpr =>
					next_tid <= (ddr)(tid_xpr);
					timer_req <= '1';
				when tid_dll =>
					next_tid <= (ddr)(tid_dll);
					if then
						timer_req <= '1';
					end if;
				when tid_ref =>
					next_ref <= (ddr)(tid_ref);
					timer_req <= '1';
				end case;
			end if;
			ddr_timer_200u <= timer_200u;
			ddr_timer_dll  <= timer_dll;
			ddr_timer_ref  <= timer_ref;
		end if;
	end process;
end;
