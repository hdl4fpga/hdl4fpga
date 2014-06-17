library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xdr_rd_fifo is
	generic (
		data_delay : natural := 1;
		data_bytes : natural := 2;
		data_edges : natural := 2;
		data_phases : natural := 1;
		byte_size  : natural := 8);
	port (
		sys_clk : in std_logic;
		sys_rdy : out std_logic;
		sys_rea : in std_logic;
		sys_do  : out std_logic_vector(data_edges*data_phases*data_bytes*byte_size-1 downto 0);

		xdr_win_dq  : in std_logic;
		xdr_win_dqs : in std_logic_vector(data_bytes-1 downto 0);
		xdr_dqsi : in std_logic_vector(data_edges*data_phases*data_bytes-1 downto 0);
		xdr_dqi  : in std_logic_vector(data_bytes*byte_size-1 downto 0));

	constant data_bits : natural := data_bytes*byte_size;
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture mix of xdr_rd_fifo is
	subtype byte is std_logic_vector(byte_size-1 downto 0);
	type byte_vector is array (natural range <>) of byte;

	signal xdr_fifo_di : byte_vector(data_bytes-1 downto 0);
	signal xdr_fifo_do : byte_vector(data_phases*data_edges*data_bytes-1 downto 0);

	subtype axdr_word is std_logic_vector(0 to 4-1);
	signal sys_do_win : std_logic;
	signal xdr_fifo_rdy : std_logic_vector(xdr_dqsi'length/data_edges-1 downto 0);

	function to_bytevector (
		arg : std_logic_vector) 
		return byte_vector is
		variable dat : unsigned(arg'length-1 downto 0);
		variable val : byte_vector(arg'length/byte_size-1 downto 0);
	begin	
		dat := unsigned(arg);
		for i in val'reverse_range loop
			val(i) := std_logic_vector(dat(byte'range));
			dat := dat srl byte_size;
		end loop;
		return val;
	end;

	function to_stdlogicvector (
		arg : byte_vector)
		return std_logic_vector is
		variable dat : byte_vector(arg'length-1 downto 0);
		variable val : std_logic_vector(arg'length-1 downto 0);
	begin
		dat := arg;
		for i in arg'reverse_range loop
			val(byte'range) := arg(i);
			val := val sll byte_size;
		end loop;
		return val;
	end;

begin
	xdr_fifo_di <= to_bytevector(xdr_dqi);
		
	process (sys_clk)
		variable acc_rea_dly : std_logic;
	begin
		if rising_edge(sys_clk) then
			sys_do_win  <= acc_rea_dly;
			acc_rea_dly := not sys_rea;
		end if;
	end process;

	fifo_bytes_g : for k in xdr_fifo_rdy'range generate
		signal xdr_delayed_dqs : std_logic_vector(0 to data_edges-1);
		signal xdr_dlyd_dqs : std_logic_vector(0 to data_edges-1);

		signal axdr_o_d : axdr_word;
		signal axdr_o_q : axdr_word;
		signal axdr_o_set : std_logic;
		signal axdr_i_set : std_logic;
		signal xdr_win_dqsi : std_logic;

	begin

		xdr_win_dqsi <= xdr_win_dqs(k);

		process (sys_clk)
			variable q : std_logic_vector(0 to data_delay);
		begin 
			if rising_edge(sys_clk) then
				q := q(1 to q'right) & xdr_win_dq;
				axdr_o_set <= not q(0);
				axdr_i_set <= sys_do_win;
				xdr_fifo_rdy(k) <= q(0);
			end if;
		end process;

		dqs_delayed_e : entity hdl4fpga.pgm_delay
		port map (
			xi => xdr_dqsi(k),
			x_p => xdr_delayed_dqs(0),
			x_n => xdr_delayed_dqs(1));

		xdr_dlyd_dqs(0) <= transport xdr_delayed_dqs(0) after 1 ps;
		xdr_dlyd_dqs(1) <= transport xdr_delayed_dqs(1) after 1 ps;

		axdr_o_d <= inc(gray(axdr_o_q));
		o_cntr_g: for j in axdr_word'range generate
			signal axdr_o_set : std_logic;
		begin
			axdr_o_set <= not xdr_fifo_rdy(k);
			ffd_i : entity hdl4fpga.sff
			port map (
				clk => sys_clk,
				sr  => axdr_o_set,
				d   => axdr_o_d(j),
				q   => axdr_o_q(j));
		end generate;

		xdr_fifo: for l in 0 to data_edges-1 generate
			signal ph_sel : std_logic_vector(data_phases-1 downto 0);
		begin
			process (axdr_i_set, xdr_dlyd_dqs(l))
			begin
				if axdr_i_set='1' then
					ph_sel <= (others => '0');
				elsif rising_edge(xdr_dlyd_dqs(l)) then
					ph_sel <= inc(gray(ph_sel));
				end if;
			end process;

			phase_g : for j in data_phases-1 downto 0 generate
				signal axdr_i_d : axdr_word;
				signal axdr_i_q : axdr_word;
				signal we : std_logic;
			begin

				we <=
				xdr_win_dqsi when data_phases=1 else
				xdr_win_dqsi when ph_sel=to_unsigned(j, ph_sel'length) else
				'0';

				axdr_i_d <= inc(gray(axdr_i_q));
				i_cntr_g: for j in axdr_i_q'range  generate
					ffd_i : entity hdl4fpga.aff
					port map (
						ar  => axdr_i_set,
						clk => xdr_dlyd_dqs(l),
						ena => we,
						d   => axdr_i_d(j),
						q   => axdr_i_q(j));
				end generate;

				ram_b : entity hdl4fpga.dbram
				generic map (
					n => byte_size)
				port map (
					clk => xdr_dlyd_dqs(l),
					we  => we,
					wa  => axdr_i_q,
					di  => xdr_fifo_di(k),
					ra  => axdr_o_q,
					do  => xdr_fifo_do(data_edges*data_phases*l+data_edges*j+k));
			end generate;

		end generate;
	end generate;

	process (sys_clk)
	begin
		if rising_edge(sys_clk) then
			sys_rdy <= xdr_fifo_rdy(0);
			sys_do <= to_stdlogicvector(xdr_fifo_do);
		end if;
	end process;

end;
