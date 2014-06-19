library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xdr_wr_fifo is
	generic (
		data_edges  : natural := 2;
		data_phases : natural := 1;
		byte_size   : natural := 8);
	port (
		sys_clk : in  std_logic;
		sys_req : in  std_logic;
		sys_di  : in  std_logic_vector(data_phases*byte_size-1 downto 0);

		xdr_clk : in  std_logic_vector(data_phases-1 downto 0);
		xdr_ena : in  std_logic_vector(data_phases-1 downto 0);
		xdr_dq  : out std_logic_vector(data_phases*byte_size-1 downto 0));
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture mix of xdr_wr_fifo is
	subtype axdr_word is std_logic_vector(0 to 4-1);

	type aw_vector is array (natural range <>) of axdr_word;

	type byte_vector is array (natural range <>) of std_logic_vector(byte_size-1 downto 0);
	type dme_vector  is array (natural range <>) of std_logic_vector(data_phases*data_bytes-1 downto 0);

	signal xdr_axdr_q : aw_vector(data_phases-1 downto 0);
	signal sys_axdr_q : axdr_word;

	signal sys_axdr_d : axdr_word;
begin

	xdr_dq <= to_stdlogicvector(dqe);

	sys_axdr_d <= inc(gray(sys_axdr_q(l)));
	sys_cntr_g: for j in axdr_word'range  generate
		signal axdr_set : std_logic;
	begin
		axdr_set <= not sys_req;
		ffd_i : entity hdl4fpga.sff
		port map (
			clk => sys_clk,
			sr  => axdr_set,
			d   => sys_axdr_d(j),
			q   => sys_axdr_q(l)(j));
	end generate;

	xdr_fifo_g : for l in 0 to data_edges-1 generate

		xdr_axdr_d <= inc(gray(xdr_axdr_q));
		cntr_g: for j in axdr_word'range generate
			signal axdr_set : std_logic;
		begin
			axdr_set <= not xdr_ena(i*data_bytes);
			ffd_i : entity hdl4fpga.sff
			port map (
				clk => xdr_clk((i*data_edges+k)),
				sr  => axdr_set,
				d   => xdr_axdr_d(j),
				q   => xdr_axdr_q(j));
		end generate;

		phase_g: for j in 0 to data_phases-1 generate
			signal dpo : std_logic_vector(byte_size-1 downto 0);
			signal qpo : std_logic_vector(byte_size-1 downto 0);
			signal xdr_axdr_d : axdr_word;
		begin
			ram_i : entity hdl4fpga.dbram
			generic map (
				n => byte_size)
			port map (
				clk => sys_clk,
				we  => sys_req,
				wa  => sys_axdr_q(l),
				di  => dqi((i*data_edges+k)+l),
				ra  => xdr_axdr_q,
				do  => dpo);

				ram_g: for j in byte_size-1 downto 0 generate
					ffd_i : entity hdl4fpga.ff
					port map (
						clk => xdr_clk((i*data_edges+k)),
						d   => dpo(j),
						q   => qpo(j));
				end generate;

				dqe(data_bytes*(i*data_edges+k)+l) <= dpo when std=1 else qpo;
			end generate;
		end generate;
end;
