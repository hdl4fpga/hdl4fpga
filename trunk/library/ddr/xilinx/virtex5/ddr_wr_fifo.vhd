library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ddr_wr_fifo is
	generic (
		data_bytes : natural := 2;
		byte_bits  : natural := 8);
	port (
		sys_clk : in std_logic;
		sys_req : in std_logic;
		sys_di  : in std_logic_vector(0 to 2*data_bytes*byte_bits-1);
		sys_rst : in std_logic;

		ddr_ena_p : in std_logic_vector;
		ddr_ena_n : in std_logic_vector;
		ddr_clk_p : in std_logic;
		ddr_clk_n : in std_logic;
		ddr_do    : out std_logic_vector(0 to 2*data_bytes*byte_bits-1));

	constant data_bits : natural := byte_bits*data_bytes;
end;


library unisim;
use unisim.vcomponents.all;

library hdl4fpga;
use hdl4fpga.std.all;

architecture mix of ddr_wr_fifo is
	subtype addr_word is std_logic_vector(0 to 4-1);
	signal ddr_clk : std_logic_vector(0 to 1);
	signal ddr_ena : std_logic_vector(0 to 1);
	type addrword_vector is array (natural range <>) of addr_word;
begin

	ddr_clk <= (0 => ddr_clk_p, 1 => ddr_clk_n);
	ddr_ena <= (0 => ddr_ena_p(0), 1 => ddr_ena_n(0));

	data_byte_g: for l in 0 to data_bytes-1 generate
		signal sys_addr_q : addr_word;
		signal sys_addr_d : addr_word;
	begin
		sys_addr_d <= inc(gray(sys_addr_q));
		sys_cntr_g: for j in addr_word'range  generate
		begin
			ffd_i : fdcpe
			port map (
				clr => sys_rst,
				pre => '0',
				c  => sys_clk,
				ce => sys_req,
				d  => sys_addr_d(j),
				q  => sys_addr_q(j));
		end generate;

		ddr_data_g: for i in 0 to 1 generate
			signal ddr_addr_q : addrword_vector(0 to 1);
		begin
--			ddr_word_g : if l=0 generate
			ddr_word_g :block
				signal ddr_addr_d : addr_word;
			begin
				ddr_addr_d <= inc(gray(ddr_addr_q(i)));
				cntr_g: for j in addr_word'range generate

					ffd_i : fdcpe
					port map (
						clr  => sys_rst,
						pre  => '0',
						c  => ddr_clk(i),
						ce => ddr_ena(i),
						d  => ddr_addr_d(j),
						q  => ddr_addr_q(i)(j));
				end generate;
--			end generate;
			end block;

			ram_g: for j in 0 to byte_bits-1 generate
			signal x : std_logic;
begin
				ram16x1d_i : ram16x1d
				port map (
					wclk => sys_clk,
					we => sys_req,
					a0 => sys_addr_q(0),
					a1 => sys_addr_q(1),
					a2 => sys_addr_q(2),
					a3 => sys_addr_q(3),
					d  => sys_di(data_bits*i+byte_bits*l+j),
					dpra0 => ddr_addr_q(i)(0),
					dpra1 => ddr_addr_q(i)(1),
					dpra2 => ddr_addr_q(i)(2),
					dpra3 => ddr_addr_q(i)(3),
--					dpo => ddr_do(data_bits*i+byte_bits*l+j),
					dpo => x,
					spo => open);
					process (ddr_clk(i))
					begin
						if rising_edge (ddr_clk(i)) then
							ddr_do(data_bits*i+byte_bits*l+j) <= x;
						end if;
					end process;
			end generate;
		end generate;
	end generate;
end;
