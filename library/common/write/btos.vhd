library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity btos is
	port (
		clk       : in  std_logic;
		bin_frm   : in  std_logic;
		bin_irdy  : in  std_logic := '1';
		bin_trdy  : out std_logic;
		bin_flt   : in  std_logic;
		bin_di    : in  std_logic_vector;

		bcd_rst   : in  std_logic;
		bcd_addr  : in  std_logic_vector;
		bcd_left  : out std_logic_vector;
		bcd_right : out std_logic_vector;
		bcd_do    : out std_logic_vector);
end;

architecture def of btos is

	signal vector_rst     : std_logic;
	signal vector_ena     : std_logic;
	signal vector_full    : std_logic;
	signal vector_left    : std_logic_vector(bcd_addr'length-1 downto 0);
	signal vector_right   : std_logic_vector(bcd_addr'length-1 downto 0);
	signal vector_addr    : std_logic_vector(bcd_addr'length-1 downto 0);
	signal vector_do      : std_logic_vector(bcd_do'length-1 downto 0);
	signal vector_di      : std_logic_vector(vector_do'range);
	signal left_up        : std_logic;
	signal left_ena       : std_logic;
	signal right_up       : std_logic;
	signal right_ena      : std_logic;

	signal btod_left_up   : std_logic;
	signal btod_left_ena  : std_logic;
	signal btod_right_up  : std_logic;
	signal btod_right_ena : std_logic;
	signal btod_trdy      : std_logic;
	signal btod_mena      : std_logic;
	signal btod_addr      : std_logic_vector(vector_addr'range);
	signal btod_do        : std_logic_vector(bcd_do'range);

	signal dtos_left_up   : std_logic;
	signal dtos_left_ena  : std_logic;
	signal dtos_right_up  : std_logic;
	signal dtos_right_ena : std_logic;
	signal dtos_frm       : std_logic;
	signal dtos_trdy      : std_logic;
	signal dtos_addr      : std_logic_vector(vector_addr'range);
	signal dtos_do        : std_logic_vector(bcd_do'range);
	signal dtos_cy        : std_logic;
	signal dtos_mena      : std_logic;

	constant btod_id      : natural := 0;
	constant dtos_id      : natural := 1;

	signal dev_trdy       : std_logic_vector(0 to 2-1);
	signal dev_frm        : std_logic_vector(dev_trdy'range);

begin

	dev_trdy(btod_id) <= btod_trdy;
	dev_trdy(dtos_id) <= dtos_trdy;

	gnt_p : process (clk, bin_frm, dev_trdy, bin_flt)
		variable gnt : std_logic_vector(dev_frm'range);
		variable req : std_logic_vector(dev_frm'range);
	begin

		if bin_frm='0' then
			req := (others => '0');
		else
			if bin_flt='0' then
				req := "10";
			else
				req := "01";
			end if;
		end if;

		if rising_edge(clk) then
			if bin_frm='0' then
				gnt := req;
			elsif gnt=(gnt'range => '0') then
				gnt := req;
			elsif (dev_trdy and gnt)=(gnt'range => '0') then
				gnt := (others => '0');
			end if;
		end if;

		if bin_frm='0' then
			dev_frm <= (others => '0');
		elsif gnt=(gnt'range => '0') then
			dev_frm <= req;
		elsif (dev_trdy and gnt)=(gnt'range => '0') then
			dev_frm <= req;
		else
			dev_frm <= gnt;
		end if;

	end process;
	
	btod_e : entity hdl4fpga.btod
	port map (
		clk           => clk,
		bin_frm       => dev_frm(btod_id),
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
		bcd_frm       => dev_frm(dtos_id),
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


	left_up    <= wirebus(btod_left_up  & dtos_left_up,  dev_frm)(0);
	left_ena   <= wirebus(btod_left_ena & dtos_left_ena, dev_frm)(0);

	right_up   <= wirebus(btod_right_up  & dtos_right_up,  dev_frm)(0);
	right_ena  <= wirebus(btod_right_ena & dtos_right_ena, dev_frm)(0);


	vector_rst  <= bcd_rst;
	vector_addr <= wirebus(btod_addr & dtos_addr & bcd_addr, dev_frm & setif(dev_frm=(dev_frm'range => '0')));
	vector_di   <= wirebus(btod_do   & dtos_do,   dev_frm);
	vector_ena  <= wirebus(btod_mena & dtos_mena, dev_frm)(0);

	vector_e : entity hdl4fpga.vector
	port map (
		vector_clk   => clk,
		vector_rst   => vector_rst,
		vector_ena   => vector_ena,
		vector_addr  => std_logic_vector(vector_addr),
		vector_full  => vector_full,
		vector_di    => vector_di,
		vector_do    => vector_do,
		left_ena     => left_ena,
		left_up      => left_up,
		vector_left  => vector_left,
		right_ena    => right_ena,
		right_up     => right_up,
		vector_right => vector_right);

	bcd_do    <= wirebus(btod_do   & dtos_do & vector_do, dev_frm & setif(dev_frm=(dev_frm'range => '0')));
	bin_trdy  <= wirebus(btod_trdy & dtos_trdy, dev_frm)(0);
	bcd_left  <= vector_left;
	bcd_right <= vector_right;

end;
