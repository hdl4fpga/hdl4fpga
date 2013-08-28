library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity ddr_rd_fifo is
	generic (
		data_delay : positive := 1;
		data_bytes : natural := 2;
		byte_bits  : natural := 8);
	port (
		sys_clk : in std_logic;
		sys_rdy : out std_logic;
		sys_rea : in std_logic;
		sys_do  : out std_logic_vector(2*data_bytes*byte_bits-1 downto 0);

		ddr_win_dq  : in std_logic;
		ddr_win_dqs : in std_logic_vector(data_bytes-1 downto 0);
		ddr_dqs : in std_logic_vector(data_bytes-1 downto 0);
		ddr_dqi : in std_logic_vector(data_bytes*byte_bits-1 downto 0));

	constant data_bits : natural := data_bytes*byte_bits;
end;

library hdl4fpga;
use hdl4fpga.std.all;

library ecp3;
use ecp3.components.all;

architecture mix of ddr_rd_fifo is
	subtype byte is std_logic_vector(byte_bits-1 downto 0);
	type byte_vector is array (natural range <>) of byte;
	type natural_vector is array (natural range <>) of natural;

	signal ddr_fifo_di : byte_vector(data_bytes-1 downto 0);
	signal ddr_fifo_do : byte_vector(2*data_bytes-1 downto 0);

	subtype addr_word is std_logic_vector(0 to 4-1);
	signal sys_do_win : std_logic;
	signal ddr_fifo_rdy : std_logic_vector(ddr_dqs'range);
begin
	ddr_fifo_di(0) <= ddr_dqi(data_bits/2-1 downto 0);
	ddr_fifo_di(1) <= ddr_dqi(data_bits-1 downto data_bits/2);
		
	process (sys_clk)
		variable acc_rea_dly : std_logic;
	begin
		if rising_edge(sys_clk) then
			sys_do_win  <= acc_rea_dly;
			acc_rea_dly := not sys_rea;
		end if;
	end process;

	fifo_bytes_g : for k in ddr_dqs'range generate
		signal ddr_delayed_dqs : std_logic_vector(0 to 1);
		signal ddr_dlyd_dqs : std_logic_vector(0 to 1);

		signal addr_o_d : addr_word;
		signal addr_o_q : addr_word;
		signal addr_o_set : std_logic;
		signal addr_i_set : std_logic;
		signal ddr_win_dqsi : std_logic;
	begin
		ddr_win_dqsi <= ddr_win_dqs(k);

		process (sys_clk)
			variable q : std_logic_vector(0 to data_delay);
		begin 
			if rising_edge(sys_clk) then
				q := q(1 to q'right) & ddr_win_dq;
				addr_o_set <= not q(0);
				addr_i_set <= sys_do_win;
				ddr_fifo_rdy(k) <= q(0);
			end if;
		end process;

		dqs_delayed_e : entity hdl4fpga.pgm_delay
		generic map (
			n => 5)
		port map (
			xi => ddr_dqs(k),
			ena => "00001",
			x_p => ddr_delayed_dqs(0),
			x_n => ddr_delayed_dqs(1));

		ddr_dlyd_dqs(0) <= transport ddr_delayed_dqs(0) after 1 ps;
		ddr_dlyd_dqs(1) <= transport ddr_delayed_dqs(1) after 1 ps;

		addr_o_d <= inc(gray(addr_o_q));
		o_cntr_g: for j in addr_word'range generate
			signal addr_o_r : std_logic;
		begin
			addr_o_r <= not ddr_fifo_rdy(k);
			ffd_i : entity hdl4fpga.ddr_sffd
			port map (
				sr  => addr_o_r,
				clk => sys_clk,
				d   => addr_o_d(j),
				q   => addr_o_q(j));
		end generate;

		ddr_fifo: for l in ddr_dlyd_dqs'range generate
			signal addr_i_d : addr_word;
			signal addr_i_q : addr_word;
		begin
			addr_i_d <= inc(gray(addr_i_q));
			i_cntr_g: for j in addr_i_q'range  generate
				signal addr_i_clr : std_logic;
			begin
				addr_i_clr <= addr_i_set;
				ffd_i : entity hdl4fpga.ddr_affd
				port map (
					ar  => addr_i_clr,
					clk => ddr_dlyd_dqs(l),
					d   => addr_i_d(j),
					q   => addr_i_q(j));
			end generate;

			ram_b : entity hdl4fpga.ddr_ram
			generic map (
				n => byte_bits)
			port map (
				clk => ddr_dlyd_dqs(l),
				we  => ddr_win_dqsi,
				wa  => addr_i_q(0),
				di  => ddr_fifo_di(k),
				ra  => addr_o_q,
				do  => ddr_fifo_do(2*k+l));
		end generate;
	end generate;

	process (sys_clk)
	begin
		if rising_edge(sys_clk) then
			sys_rdy <= ddr_fifo_rdy(0);
			sys_do <= 
				ddr_fifo_do(0) & ddr_fifo_do(2) & 
				ddr_fifo_do(1) & ddr_fifo_do(3);
		end if;
	end process;

end;
