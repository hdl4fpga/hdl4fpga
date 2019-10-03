library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity btof is
	port (
		clk        : in  std_logic;
		frm        : in  std_logic;
		bin_irdy   : in  std_logic := '1';
		bin_trdy   : out std_logic;
		bin_neg    : in  std_logic;
		bin_flt    : in  std_logic;
		bin_di     : in  std_logic_vector;

		bcd_irdy   : in  std_logic := '1';
		bcd_trdy   : out std_logic;

		bcd_sign   : in  std_logic;
		bcd_width  : in  std_logic_vector;
		bcd_unit   : in  std_logic_vector;
		bcd_prec   : in  std_logic_vector;
		bcd_endian : in  std_logic := '0';
		bcd_align  : in  std_logic := '0';

		bcd_end    : out std_logic;
		bcd_do     : out std_logic_vector);
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
	signal stof_irdy      : std_logic;
	signal stof_trdy      : std_logic;
	signal stof_neg       : std_logic;
	signal stof_sign      : std_logic;
	signal stof_end       : std_logic;
	signal stof_addr      : std_logic_vector(vector_addr'range);
	signal stof_do        : std_logic_vector(bcd_do'range);
	type   states is (init_s, btod_s, dtos_s, stof_s);
	signal state : states;
begin

	process (clk)
	begin
		if frm='0' then
			state <= init_s;
		elsif rising_edge(clk) then
			case state is
			when init_s =>
				state <= btod_s;
				stof_sign <= bcd_sign or bin_neg;
				stof_neg  <= bin_neg;
			when btod_s =>
				if bin_irdy = '1' then
					if bin_flt = '1' then
						state <= dtos_s;
					end if;
				end if;
			when dtos_s =>
				if dtos_trdy = '1' then
					state <= stof_s;
				end if;
			when stof_s =>
			end case;
		end if;
	end process;

	btod_frm <= 
		frm when state=btod_s and bin_flt='0' else
		'0';
	dtos_frm <= 
		frm when state=dtos_s else
		frm when state=btod_s and bin_flt='1' else
		'0';
	stof_frm <= 
		frm when state=stof_s else
		'0';

	bin_trdy <= 
	   btod_trdy when state=btod_s and bin_flt='0' else
	   stof_trdy when state=stof_s and stof_end='1' else
	   '0';
	
	btod_e : entity hdl4fpga.btod
	port map (
		clk           => clk,
		frm           => btod_frm,
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
		frm           => dtos_frm,
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

	stof_irdy <= bcd_irdy;
	stof_e : entity hdl4fpga.stof
	port map (
		clk       => clk,
		frm       => stof_frm,
		bcd_width  => bcd_width, 
		bcd_sign   => stof_sign,
		bcd_neg    => stof_neg,
		bcd_unit   => bcd_unit,  
		bcd_prec   => bcd_prec,  
		bcd_align  => bcd_align, 
		bcd_endian => bcd_endian,
		bcd_left  => vector_left,
		bcd_right => vector_right,
		bcd_di    => vector_do,
		bcd_irdy  => stof_irdy,
		bcd_trdy  => stof_trdy,
		bcd_end   => stof_end,

		mem_addr  => stof_addr,
		mem_do    => stof_do);

	left_up    <= wirebus(btod_left_up   & dtos_left_up,   btod_frm & dtos_frm);
	left_ena   <= wirebus(btod_left_ena  & dtos_left_ena,  btod_frm & dtos_frm);

	right_up   <= wirebus(btod_right_up  & dtos_right_up,  btod_frm & dtos_frm);
	right_ena  <= wirebus(btod_right_ena & dtos_right_ena, btod_frm & dtos_frm);

	vector_rst  <= not frm;
	vector_addr <= wirebus(btod_addr & dtos_addr & stof_addr, btod_frm & dtos_frm & stof_frm);
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

	bcd_trdy <= stof_trdy and frm;
	bcd_end  <= stof_end and frm;
	bcd_do   <= stof_do;

end;