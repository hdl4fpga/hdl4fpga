library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datai is
	generic (
		fifo_size : natural := 5);
	port (
		input_clk : in std_logic;
		input_dat : in std_logic_vector;
		input_req : in std_logic;
		input_rdy : out std_logic;

		output_clk  : in std_logic;
		output_rdy  : out std_logic;
		output_req  : in std_logic;
		output_dat  : out std_logic_vector);
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture def of datai is

	subtype input_word  is std_logic_vector(input_dat'length-1 downto 0);
	type input_vector is array (natural range <>) of input_word;

	signal addro : std_logic_vector(0 to fifo_size-1) := (others => '0');
	signal rd_data : input_vector(0 to output_dat'length/input_dat'length-1);

	signal wr_sel  : std_logic_vector(0 to unsigned_num_bits(output_dat'length/input_dat'length-1)) := (others => '0');
	signal wr_ena  : std_logic_vector(0 to output_dat'length/input_dat'length-1);
	signal wr_addr : std_logic_vector(0 to fifo_size-1);
	signal wr_data : input_word;

	signal rd_addr : std_logic_vector(0 to fifo_size-1);

begin

	process (input_clk)
		variable addr : std_logic_vector(0 to fifo_size-1) := (others => '0');
	begin
		if rising_edge(input_clk) then
			if input_req='1' then
				wr_addr <= (others => '0');
				wr_sel  <= (others => '0');
				addr    := (others => '0');
			else
				wr_addr <= addr;
				wr_sel  <= wr_sel + 1;
				if wr_sel(0)='1' then
					wr_sel(0) <= '0';
					addr := inc(gray(addr));
				end if;
			end if;
		end if;
	end process;

	process (output_clk)
		variable addr : std_logic_vector(0 to fifo_size-1) := (others => '0');
	begin
		if rising_edge(output_clk) then
				addr := (others => '0');
			if output_req='1' then
				if wr_addr /= rd_addr then
					addr := inc(gray(addro));
				end if;
			end if;
		end if;
	end process;

	wr_dec_e: entity hdl4fpga.demux 
	port map (
		s => wr_sel,
		o => wr_ena);

	ram_g : for i in 0 to output_dat'length/input_dat'length-1 generate
		fifo_e : entity hdl4fpga.dpram
		port map (
			wr_clk  => input_clk,
			wr_addr => wr_addr, 
			wr_data => wr_data,
			wr_ena  => wr_ena(i),
			rd_clk  => output_clk,
			rd_ena  => output_req,
			rd_addr => rd_addr,
			rd_data => rd_data(i));
	end generate;

	process (rd_data)
		variable data : std_logic_vector(output_dat'length-1 downto 0);
	begin
		data := (others => '-');
		for i in rd_data'range loop
			data := data sll wr_data(0)'length;
			data(wr_data(0)'range) := wr_data(i);
		end loop;
		output_dat <= data;
	end process;

	output_rdy <= wr_addr = rd_addr;

end;
