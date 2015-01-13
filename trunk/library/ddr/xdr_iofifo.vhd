library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity iofifo is
	generic (
		pll2ser : boolean;
		registered_output : boolean := false;
		data_phases : natural;
		word_size   : natural;
		byte_size   : natural);
	port (
		pll_clk : in  std_logic;
		pll_rdy : out std_logic;
		pll_req : in  std_logic := '-';

		ser_clk : in  std_logic_vector(0 to data_phases-1);
		ser_req : in  std_logic_vector(0 to data_phases-1) := (others => '-');
		ser_rdy : out std_logic;
		ser_ena : in  std_logic_vector(0 to data_phases*word_size/byte_size-1);

		di  : in  std_logic_vector(data_phases*word_size-1 downto 0);
		do  : out std_logic_vector(data_phases*word_size-1 downto 0));
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture mix of iofifo is
	subtype byte is std_logic_vector(byte_size-1 downto 0);
	type byte_vector is array (natural range <>) of byte;

	signal fifo_do : byte_vector(data_phases*word_size/byte_size-1 downto 0);
	signal fifo_di : byte_vector(fifo_do'range);
	signal dqo : byte_vector(fifo_do'range);

	subtype aword is std_logic_vector(0 to 4-1);
	signal pll_do_win : std_logic;
	signal ser_fifo_rdy : std_logic;

	function to_stdlogicvector (
		arg : byte_vector)
		return std_logic_vector is
		variable dat : byte_vector(arg'length-1 downto 0);
		variable val : std_logic_vector(arg'length*byte'length-1 downto 0);
	begin
		dat := arg;
		for i in arg'range loop
			val := val sll byte'length;
			val(byte'range) := arg(i);
		end loop;
		return val;
	end;

	function to_bytevector (
		arg : std_logic_vector)
		return byte_vector is
		variable dat : std_logic_vector(arg'length-1 downto 0);
		variable val : byte_vector(arg'length/byte'length-1 downto 0);
	begin
		dat := arg;
		for i in val'reverse_range loop
			val(i) := dat(byte'range);
			dat := dat srl byte'length;
		end loop;
		return val;
	end;

	signal apll_d : aword;
	signal apll_q : aword;

begin

	apll_d <= inc(gray(apll_q));
	apll_g: for j in apll_d'range generate
		signal apll_set : std_logic;
	begin
		apll_set <= not pll_req;
		ffd_i : entity hdl4fpga.sff
		port map (
			clk => pll_clk,
			sr  => apll_set,
			d   => apll_d(j),
			q   => apll_q(j));
	end generate;

	fifo_di <= to_bytevector(di);

	phases_g : for l in 0 to data_phases-1 generate
		byte_ena_g : for j in word_size/byte_size-1 downto 0 generate
			signal aser_d : aword;
			signal aser_q : aword;
			signal fifo_we : std_logic;
			signal fifo_wa : aword;
			signal fifo_ra : aword;
		begin

			aser_d <= inc(gray(aser_q));
			aser_g: for k in aser_q'range  generate
				sr_g : if pll2ser generate
					signal aser_set : std_logic;
				begin
					aser_set <= not ser_ena(l*word_size/byte_size+j);

					ffd_i : entity hdl4fpga.sff
					port map (
						clk => ser_clk(l),
						sr  => aser_set,
						d   => aser_d(k),
						q   => aser_q(k));
				end generate;	

				ar_g : if not pll2ser generate
					signal aser_set : std_logic;
				begin
					aser_set <= not ser_req(l);
					ffd_i : entity hdl4fpga.aff
					port map (
						ar  => aser_set,
						clk => ser_clk(l),
						ena => ser_ena(l*word_size/byte_size+j),
						d   => aser_d(k),
						q   => aser_q(k));
				end generate;
			end generate;

			fifo_wa <=
		   		apll_q when pll2ser else
				aser_q;

			fifo_we <=
		   		pll_req when pll2ser else
				ser_ena(l*word_size/byte_size+j);

			ram_b : entity hdl4fpga.dbram
			generic map (
				n => byte'length)
			port map (
				clk => ser_clk(l),
				we  => fifo_we,
				wa  => fifo_wa,
				di  => fifo_di(data_phases*j+l),
				ra  => fifo_ra,
				do  => fifo_do(data_phases*j+l));

			fifo_ra <=
		   		aser_q when pll2ser else
				apll_q;


			ro_g : if registered_output generate
				signal clk : std_logic;
			begin
				clk <= 
					ser_clk(l) when pll2ser else
					pll_clk;

				dqo_g: for k in byte'range generate
					ffd_i : entity hdl4fpga.ff
					port map (
						clk => clk,
						d => fifo_do(data_phases*j+l)(k),
						q => dqo(data_phases*j+l)(k));
				end generate;
			end generate;
		end generate;

	end generate;

	do <= 
		to_stdlogicvector(dqo) when registered_output else
		to_stdlogicvector(fifo_do);
end;
