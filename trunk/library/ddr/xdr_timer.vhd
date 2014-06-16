library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity xdr_timer is
	generic ( 
		cPreRST : natural := 40000;
		cPstRST : natural := 100000;
		cDLL : natural := 200;
		cREF : natural := 1440;
		cxpr : natural := 10;
		std  : natural := 3);
	port (
		sys_timer_clk : in  std_logic;
		sys_timer_rst : in  std_logic;

		sys_cfg_rst : out std_logic;
		sys_cfg_cke : out std_logic; 
		sys_cfg_req : out std_logic;

		dll_timer_req : in  std_logic;
		dll_timer_rdy : out std_logic;
		ref_timer_req : in  std_logic;
		ref_timer_rdy : out std_logic);

--	attribute fsm_encoding : string;
--	attribute fsm_encoding of xdr_timer : entity is "compact";
end;

architecture def of xdr_timer is
	type timer_ids is (tid_PreRST, tid_dll, tid_ref, tid_PstRST, tid_xpr);

	type tidtab_row is record
		q : timer_ids;
		z : std_logic_vector(0 to 4);
		s : std_logic_vector(0 to 2);
	end record;
	type tid_table is array (timer_ids) of tidtab_row;
	type tidtab_vector is array (natural range <>) of tid_table;
	constant timer_tab : tidtab_vector(1 to 3) := (
		1 => (                  --  rcgdf
			tid_PreRST => (tid_dll,    "-1100", "000"),
			tid_dll    => (tid_ref,    "-1111", "001"),
			tid_ref    => (tid_ref,    "-1111", "010"),
			tid_PstRST => (tid_PreRST, "-----", "---"),
			tid_xpr    => (tid_PreRST, "-----", "---")),
		2 => (
			tid_PreRST => (tid_PstRST, "-1000", "000"),
			tid_dll    => (tid_ref,    "-1111", "001"),
			tid_ref    => (tid_ref,    "-1111", "010"),
			tid_PstRST => (tid_dll,    "-1100", "011"),
			tid_xpr    => (tid_PreRST, "-----", "---")),
		3 => (
			tid_PreRST => (tid_PstRST, "10000", "000"),
			tid_dll    => (tid_ref,    "11111", "001"),
			tid_ref    => (tid_ref,    "11111", "010"),
			tid_PstRST => (tid_xpr,    "11000", "011"),
			tid_xpr    => (tid_dll,    "11100", "100")));

	signal timer_rdy : std_logic;
	signal timer_req : std_logic;
	signal timer_id : timer_ids;
	signal timer_sel : std_logic_vector(0 to 2);
	signal z : std_logic_vector(0 to 4);

	signal timer_div : unsigned(0 to 4-1) := (others => '0');
	signal treq : std_logic;
	signal trdy : std_logic;
	signal timer : unsigned(0 to 15);
begin

	process (sys_timer_clk)
	begin
		if rising_edge(sys_timer_clk) then
			timer_div <= timer_div + 1;
		end if;
	end process;

	process (timer_div(0), sys_timer_rst)
		variable q : std_logic;
	begin
		if sys_timer_rst='1' then
			treq <= '0';
			q := '0';
		elsif rising_edge(timer_div(0)) then
			treq <= q;
			q := timer_req;
		end if;
	end process;

	process (timer_div(0), sys_timer_rst)
		type tword_vector is array(natural range <>) of natural range 0 to 2**(timer'length-1)-1;
		constant time_data : tword_vector(0 to 5-1) := (
			timer_ids'pos(tid_PreRST) => (cPreRST+2**timer_div'length-1)/2**timer_div'length,
			timer_ids'pos(tid_dll) => (cDLL+2**timer_div'length-1)/2**timer_div'length,
			timer_ids'pos(tid_ref) => (cREF/2**timer_div'length)-5,
			timer_ids'pos(tid_PstRST) => (cPstRST+2**timer_div'length-1)/2**timer_div'length,
			timer_ids'pos(tid_xpr) => (cxpr+2**timer_div'length-1)/2**timer_div'length);
	begin
		if sys_timer_rst='1' then
			timer <= to_unsigned(time_data(to_integer(unsigned(timer_sel))), timer'length);
		elsif rising_edge(timer_div(0)) then
			if treq='0' then
				timer <= to_unsigned(time_data(to_integer(unsigned(timer_sel))), timer'length);
			end if;
			if trdy='0' then
				timer <= timer - 1;
			end if;
		end if;
	end process;
	trdy <= timer(0);

	process (sys_timer_clk)
		variable q : std_logic_vector(0 to 3);
	begin
		if rising_edge(sys_timer_clk) then
			if sys_timer_rst='1' then
				timer_rdy <= '0';
				q := (others => '0');
			else
				timer_rdy <= q(0);	
				case q(1 to q'right) is
				when "000"|"100" =>
					q(0) := '0';	
				when "011"|"111" =>
					q(0) := '1';	
				when others =>
				end case;
				q(1 to q'right) := q(2 to q'right) & trdy;
			end if;
		end if;
	end process;

	process (sys_timer_clk, sys_timer_rst)
		variable next_tid  : timer_ids;
		variable o_tid  : timer_ids;
	begin
		if sys_timer_rst='1' then
			timer_id <= tid_PreRST;
			z <= (others => '0');
			next_tid  := timer_tab(std)(timer_id).q;
			timer_req <= '0';
			timer_sel <= timer_tab(std)(timer_id).s;
		elsif rising_edge(sys_timer_clk) then
			if timer_rdy='1' then
				timer_req <= '0';
				if next_tid=tid_dll then
					if dll_timer_req='0' then
						timer_req <= '1';
					end if;
				end if;
				timer_id <= next_tid;
				z <= timer_tab(std)(o_tid).z;
			else
				timer_req <= '1';
				if timer_id=tid_ref then
					if ref_timer_req='0' then
						timer_req <= '0';
					end if;
				end if;

				o_tid := timer_id;
				next_tid := timer_tab(std)(timer_id).q;
			end if;

			if timer_req='1' then
				timer_sel <= timer_tab(std)(next_tid).s;
			end if;

			ref_timer_rdy <= z(4) and timer_rdy and timer_req;
		end if;
	end process;

	sys_cfg_rst  <= z(0);
	sys_cfg_cke  <= z(1);
	sys_cfg_req  <= z(2);
	dll_timer_rdy <= z(3);
end;
