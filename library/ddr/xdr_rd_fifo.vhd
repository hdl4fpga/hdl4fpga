library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xdr_rd_fifo is
	generic (
		data_delay  : natural := 1;
		data_edges  : natural := 2;
		data_phases : natural := 2;
		byte_size   : natural := 8);
	port (
		sys_clk : in  std_logic;
		sys_rdy : out std_logic;
		sys_rea : in  std_logic;
		sys_do  : out std_logic_vector(byte_size*data_phases-1 downto 0);

		xdr_win_dq  : in std_logic;
		xdr_win_dqs : in std_logic;
		xdr_dqsi : in std_logic;
		xdr_dqi  : in std_logic_vector(byte_size-1 downto 0));
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture mix of xdr_rd_fifo is
	subtype byte is std_logic_vector(byte_size-1 downto 0);
	type byte_vector is array (natural range <>) of byte;

	signal xdr_fifo_do : byte_vector(data_phases-1 downto 0);

	subtype axdr_word is std_logic_vector(0 to 4-1);
	signal sys_do_win : std_logic;
	signal xdr_fifo_rdy : std_logic;

	function to_stdlogicvector (
		arg : byte_vector)
		return std_logic_vector is
		variable dat : byte_vector(arg'length-1 downto 0);
		variable val : std_logic_vector(arg'length*byte'length-1 downto 0);
	begin
		dat := arg;
		for i in arg'reverse_range loop
			val := val sll byte_size;
			val(byte'range) := arg(i);
		end loop;
		return val;
	end;

	signal xdr_delayed_dqs : std_logic_vector(0 to data_edges-1);
	signal xdr_dlyd_dqs : std_logic_vector(0 to data_edges-1);

	signal axdr_o_d : axdr_word;
	signal axdr_o_q : axdr_word;
	signal axdr_o_set : std_logic;
	signal axdr_i_set : std_logic;
	signal xdr_win_dqsi : std_logic;
	signal axdr_we : std_logic_vector(0 to data_phases-1);

begin
	process (sys_clk)
		variable acc_rea_dly : std_logic;
	begin
		if rising_edge(sys_clk) then
			sys_do_win  <= acc_rea_dly;
			acc_rea_dly := not sys_rea;
		end if;
	end process;

	xdr_win_dqsi <= xdr_win_dqs;

	process (sys_clk)
		variable q : std_logic_vector(0 to data_delay);
	begin 
		if rising_edge(sys_clk) then
			q := q(1 to q'right) & xdr_win_dq;
			axdr_o_set <= not q(0);
			axdr_i_set <= sys_do_win;
			xdr_fifo_rdy <= q(0);
		end if;
	end process;

	dqs_delayed_e : entity hdl4fpga.pgm_delay
	port map (
		xi  => xdr_dqsi,
		x_p => xdr_delayed_dqs(1),
		x_n => xdr_delayed_dqs(0));

	xdr_dlyd_dqs(0) <= transport xdr_delayed_dqs(0) after 1 ps;
	xdr_dlyd_dqs(1) <= transport xdr_delayed_dqs(1) after 1 ps;

	axdr_o_d <= inc(gray(axdr_o_q));
	o_cntr_g: for j in axdr_word'range generate
		signal axdr_o_set : std_logic;
	begin
		axdr_o_set <= not xdr_fifo_rdy;
		ffd_i : entity hdl4fpga.sff
		port map (
			clk => sys_clk,
			sr  => axdr_o_set,
			d   => axdr_o_d(j),
			q   => axdr_o_q(j));
	end generate;

	xdr_fifo: for l in 0 to data_edges-1 generate
		signal ph_sel : std_logic_vector(data_phases/data_edges-1 downto 0);
	begin
		process (axdr_i_set, xdr_dlyd_dqs(l))
		begin
			if axdr_i_set='1' then
				ph_sel <= ('1', others => '0');
			elsif rising_edge(xdr_dlyd_dqs(l)) then
				ph_sel <= ph_sel ror 1;
			end if;
		end process;

		phase_g : for j in data_phases/data_edges-1 downto 0 generate
			signal axdr_i_d : axdr_word;
			signal axdr_i_q : axdr_word;
			signal we : std_logic;
		begin

			axdr_we(data_edges*j+l) <= we;
			we <=
			xdr_win_dqsi when data_phases/data_edges=1 else
			xdr_win_dqsi when ph_sel(j)='1' else
			'0';

			axdr_i_d <= inc(gray(axdr_i_q));
			i_cntr_g: for k in axdr_i_q'range  generate
				ffd_i : entity hdl4fpga.aff
				port map (
					ar  => axdr_i_set,
					clk => xdr_dlyd_dqs(l),
					ena => we,
					d   => axdr_i_d(k),
					q   => axdr_i_q(k));
			end generate;

			ram_b : entity hdl4fpga.dbram
			generic map (
				n => byte_size)
			port map (
				clk => xdr_dlyd_dqs(l),
				we  => we,
				wa  => axdr_i_q,
				di  => xdr_dqi,
				ra  => axdr_o_q,
				do  => xdr_fifo_do(data_edges*j+l));
		end generate;

	end generate;

	process (sys_clk)
	begin
		if rising_edge(sys_clk) then
			sys_rdy <= xdr_fifo_rdy;
			sys_do  <= to_stdlogicvector(xdr_fifo_do);
		end if;
	end process;

end;
