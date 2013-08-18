library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ddr_wr_fifo is
	generic (
		device : string := "NONE";
		data_bytes : natural := 2;
		byte_bits  : natural := 8);
	port (
		sys_clk : in std_logic;
		sys_req : in std_logic;
		sys_dm  : in std_logic_vector(2*data_bytes-1 downto 0) := (others => '-');
		sys_di  : in std_logic_vector(2*data_bytes*byte_bits-1 downto 0);
		sys_rst : in std_logic;

		ddr_clk : in std_logic;
		ddr_ena_r : in std_logic_vector(data_bytes-1 downto 0) := (others => '-');
		ddr_ena_f : in std_logic_vector(data_bytes-1 downto 0) := (others => '-');
		ddr_dm_r : out std_logic_vector(data_bytes-1 downto 0) := (others => '-');
		ddr_dm_f : out std_logic_vector(data_bytes-1 downto 0) := (others => '-');
		ddr_dq_r : out std_logic_vector(data_bytes*byte_bits-1 downto 0);
		ddr_dq_f : out std_logic_vector(data_bytes*byte_bits-1 downto 0));

	constant data_bits : natural := byte_bits*data_bytes;
end;


library unisim;
use unisim.vcomponents.all;

library hdl4fpga;
use hdl4fpga.std.all;

architecture mix of ddr_wr_fifo is
	subtype addr_word is std_logic_vector(0 to 4-1);
	signal ddr_clks : std_logic_vector(0 to 1);
	signal ddr_ena : std_logic_vector(0 to 1);

	type addrword_vector is array (natural range <>) of addr_word;

	type dword_vector is array (natural range <>) of std_logic_vector(ddr_dq_r'range);
	signal ddr_dq : dword_vector(0 to 1);

	type dm_vector is array (natural range <>) of std_logic_vector(ddr_dm_r'range);
	signal ddr_dm : dm_vector(0 to 1);

begin

	ddr_clks <= (0 => ddr_clk, 1 => not ddr_clk);
	ddr_ena <= (0 => ddr_ena_r(0), 1 => ddr_ena_f(0));
	ddr_dq_r <= ddr_dq(0);
	ddr_dq_f <= ddr_dq(1);

	ddr_dm_r <= ddr_dm(0);
	ddr_dm_f <= ddr_dm(1);

	data_byte_g: for l in ddr_dm_r'range generate
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
			signal ddr_addr_q : addr_word;
		begin
			ddr_word_g : block
				signal ddr_addr_d : addr_word;
			begin
				ddr_addr_d <= inc(gray(ddr_addr_q));
				cntr_g: for j in addr_word'range generate

					ffd_i : fdcpe
					port map (
						clr  => sys_rst,
						pre  => '0',
						c  => ddr_clks(i),
						ce => ddr_ena(i),
						d  => ddr_addr_d(j),
						q  => ddr_addr_q(j));
				end generate;
			end block;

			dm_ram_g : block
				signal dmo : std_logic;
				signal qmo : std_logic;
			begin
				ram16x1d_i : ram16x1d
				port map (
					wclk => sys_clk,
					we => sys_req,
					a0 => sys_addr_q(0),
					a1 => sys_addr_q(1),
					a2 => sys_addr_q(2),
					a3 => sys_addr_q(3),
					d  => sys_dm(data_bytes*i+l),
					dpra0 => ddr_addr_q(0),
					dpra1 => ddr_addr_q(1),
					dpra2 => ddr_addr_q(2),
					dpra3 => ddr_addr_q(3),
					dpo => dmo,
					spo => open);

--				process (ddr_clk(i))
--				begin
--					if rising_edge (ddr_clk(i)) then
--						qmo <= dmo;
--					end if;
--				end process;
--
				ddr_dm(i)(l) <= 
--					qmo when device="virtex5" else
					dmo;
					
			end block;

			ram_g: for j in byte_bits-1 downto 0 generate
				signal dpo : std_logic;
				signal qpo : std_logic;
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
					dpra0 => ddr_addr_q(0),
					dpra1 => ddr_addr_q(1),
					dpra2 => ddr_addr_q(2),
					dpra3 => ddr_addr_q(3),
					dpo => dpo,
					spo => open);

				ffd_i : fdcpe
				port map (
					clr => '0',
					pre => '0',
					c  => ddr_clks(i),
					ce => '1',
					d  => dpo,
					q  => qpo);

				ddr_dq(i)(byte_bits*l+j) <= 
					qpo when device="virtex5" else
					dpo;
					
			end generate;
		end generate;
	end generate;
end;
