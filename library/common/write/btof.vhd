library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity btof is
	port (
		clk       : in  std_logic;
		bin_frm   : in  std_logic;
		bin_irdy  : in  std_logic := '1';
		bin_trdy  : out std_logic;
		bin_flt   : in  std_logic;
		bin_di    : in  std_logic_vector;

		bcd_left  : out std_logic_vector;
		bcd_right : out std_logic_vector;
		bcd_do    : out std_logic_vector);
end;

architecture def of btof is

	signal vector_rst     : std_logic;
	signal vector_full    : std_logic;
	signal vector_addr    : std_logic_vector(4-1 downto 0);
	signal vector_left    : std_logic_vector(vector_addr'length-1 downto 0);
	signal vector_right   : std_logic_vector(vector_addr'length-1 downto 0);
	signal vector_do      : std_logic_vector(bcd_do'length-1 downto 0);
	signal vector_di      : std_logic_vector(vector_do'range);
	signal vector_ena     : std_logic_vector(0 to 0);
	signal left_up        : std_logic_vector(0 to 0);
	signal left_ena       : std_logic_vector(0 to 0);
	signal right_up       : std_logic_vector(0 to 0);
	signal right_ena      : std_logic_vector(0 to 0);

	signal btod_frm      : std_logic;
	signal btod_left_up   : std_logic;
	signal btod_left_ena  : std_logic;
	signal btod_right_up  : std_logic;
	signal btod_right_ena : std_logic;
	signal btod_trdy      : std_logic;
	signal btod_mena      : std_logic;
	signal btod_addr      : std_logic_vector(vector_addr'range);
	signal btod_do        : std_logic_vector(bcd_do'range);

	signal dtos_frm       : std_logic;
	signal dtos_left_up   : std_logic;
	signal dtos_left_ena  : std_logic;
	signal dtos_right_up  : std_logic;
	signal dtos_right_ena : std_logic;
	signal dtos_trdy      : std_logic;
	signal dtos_addr      : std_logic_vector(vector_addr'range);
	signal dtos_do        : std_logic_vector(bcd_do'range);
	signal dtos_cy        : std_logic;
	signal dtos_mena      : std_logic;

	signal stof_frm       : std_logic;
	signal stof_trdy      : std_logic;
	signal stof_addr      : std_logic_vector(vector_addr'range);
	signal stof_do        : std_logic_vector(bcd_do'range);
begin

	process (clk, bin_frm)
		type states is (btod, dtos);
		variable state : states;
	begin
		if bin_frm='0' then
			state := btod;
		elsif rising_edge(clk) then
			case state is
			when btod =>
				if btod_trdy = '1' then
					state := dtos;
				end if;
			when dtos =>
			end case;
		end if;

		case state is
		when btod =>
			btod_frm <= bin_frm;
			dtos_frm <= '0';
		when dtos  =>
			btod_frm <= '0';
			dtos_frm <= bin_frm;
		end case;
	end process;
	
	btod_e : entity hdl4fpga.btod
	port map (
		clk           => clk,
		bin_frm       => btod_frm,
		bin_irdy      => bin_irdy,
		bin_trdy      => btod_trdy,
		bin_di        => bin_di,

		mem_full      => vector_full,
		mem_ena       => btod_mena,

		mem_left      => vector_left,
		mem_left_up   => btod_left_up,
		mem_left_ena  => btod_left_ena,

		mem_right     => vector_right,
		mem_right_up  => btod_right_up,
		mem_right_ena => btod_right_ena,

		mem_addr      => btod_addr,
		mem_di        => btod_do,
		mem_do        => vector_do);

	dtos_e : entity hdl4fpga.dtos
	port map (
		clk           => clk,
		bcd_frm       => dtos_frm,
		bcd_irdy      => bin_irdy,
		bcd_trdy      => dtos_trdy,
		bcd_di        => bin_di,

		mem_full      => vector_full,
		mem_ena       => dtos_mena,

		mem_left      => vector_left,
		mem_left_up   => dtos_left_up,
		mem_left_ena  => dtos_left_ena,

		mem_right     => vector_right,
		mem_right_up  => dtos_right_up,
		mem_right_ena => dtos_right_ena,

		mem_addr      => dtos_addr,
		mem_di        => dtos_do,
		mem_do        => vector_do);

	stof_e : entity hdl4fpga.stof
	port map (
		clk       => clk,
		frm       => stof_frm,
		bcd_left  => vector_left,
		bcd_right => vector_right,
		bcd_di    => vector_do,
		bcd_trdy  => stof_trdy,

		mem_addr  => stof_addr,
		mem_do    => stof_do);

	left_up    <= wirebus(btod_left_up  & dtos_left_up,  btod_frm & dtos_frm);
	left_ena   <= wirebus(btod_left_ena & dtos_left_ena, btod_frm & dtos_frm);

	right_up   <= wirebus(btod_right_up  & dtos_right_up,  btod_frm & dtos_frm);
	right_ena  <= wirebus(btod_right_ena & dtos_right_ena, btod_frm & dtos_frm);

	vector_rst  <= not bin_frm;
	vector_addr <= wirebus(btod_addr & dtos_addr & stof_addr, btod_frm & dtos_frm & '1');
	vector_di   <= wirebus(btod_do   & dtos_do,    btod_frm & dtos_frm);
	vector_ena  <= wirebus(btod_mena & dtos_mena,  btod_frm & dtos_frm);

	vector_e : entity hdl4fpga.vector
	port map (
		vector_clk   => clk,
		vector_rst   => vector_rst,
		vector_ena   => vector_ena(0),
		vector_addr  => std_logic_vector(vector_addr),
		vector_full  => vector_full,
		vector_di    => vector_di,
		vector_do    => vector_do,
		left_ena     => left_ena(0),
		left_up      => left_up(0),
		vector_left  => vector_left,
		right_ena    => right_ena(0),
		right_up     => right_up(0),
		vector_right => vector_right);

	bin_trdy  <= stof_trdy;
	bcd_left  <= vector_left;
	bcd_right <= vector_right;

end;
