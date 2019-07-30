-- AUTHOR=EMARD
-- LICENSE=GPL

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_storage is
	generic (
		inputs                 : natural;
		-- use "align_to_grid" to compensate latency of "storage_mark_t0" signal.
		align_to_grid          : integer := 0  -- -left, +right shift T=0 triggered edge
	);
	port (
		storage_clk            : in  std_logic;
		storage_reset_addr     : in  std_logic;
		storage_increment_addr : in  std_logic;
		storage_mark_t0        : in  std_logic;
		storage_write          : in  std_logic;
		storage_data           : in  std_logic_vector;
		storage_addr           : out std_logic_vector; -- for LUT saver deflickering
		downsampling           : in  std_logic;
		captured_clk           : in  std_logic;
		captured_addr          : in  std_logic_vector;
		captured_scroll        : in  std_logic_vector;
		captured_data          : out std_logic_vector
	);
end;

architecture beh of scopeio_storage is
	constant sample_bits: natural := storage_data'length / inputs / 2;
	signal t0_addr      : unsigned(storage_addr'range);
	signal scrolled_addr: unsigned(t0_addr'range);
	signal rd_addr      : unsigned(t0_addr'range);
	signal wr_addr      : unsigned(t0_addr'range);
	signal wr_ena       : std_logic;
	signal null_data    : std_logic_vector(storage_data'range);
	signal rd_addr_ds   : unsigned(t0_addr'range);
	signal rd_data_ds   : std_logic_vector(captured_data'range);
	signal pr_data_ds   : std_logic_vector(captured_data'range);
	signal rd_data_0, rd_data_1: std_logic_vector(captured_data'range);
begin
	P_write_address:
	process(storage_clk)
	begin
		if rising_edge(storage_clk) then
			if storage_reset_addr = '1' then
				wr_addr <= (others => '0');
			else
				if storage_increment_addr = '1' then
					wr_addr <= wr_addr + 1;
				end if;
			end if;
			if storage_mark_t0 = '1' then
				t0_addr <= unsigned(wr_addr); -- mark triggering point in the buffer
			end if;
		end if;
	end process;

	-- "captured_scroll" is horizontal scrolling offset, requested by display system
	-- Latency is allowed so we can offload arithmetic stage with a register:
	P_horizontal_scroll:
	process(storage_clk)
	begin
		if rising_edge(storage_clk) then
			scrolled_addr <= t0_addr + resize(unsigned(captured_scroll),scrolled_addr'length)
			               + to_unsigned(-align_to_grid,scrolled_addr'length);
		end if; -- rising_edge
	end process;

	-- "scrolled_addr" is triggering point T=0 displaced by "storage_scroll".
	-- "captured_addr" is addr for drawing traces, requested by display system
	-- No latency is allowed for "captured_addr", therefore combinatorial logic here:
	-- Registered latency will cause display artefacts.
	rd_addr <= scrolled_addr + unsigned(captured_addr);
	
	-- if downsampling = 0 special case: right shift rd_addr value
	rd_addr_ds <= rd_addr when downsampling = '1' 
	         else ('0' & rd_addr(0 to rd_addr'high-1));

	mem_e : entity hdl4fpga.bram(inference)
	port map (
		clka  => storage_clk,
		addra => std_logic_vector(wr_addr),
		wea   => storage_write,
		dia   => storage_data,
		doa   => null_data,

		clkb  => captured_clk,
		addrb => std_logic_vector(rd_addr_ds),
		dib   => null_data,
		dob   => rd_data_ds);

	-- HACK reconstruct special case of downsampling=0
	-- where 2 samples are stored at address
	-- it works if readout is sequential 
	
	process(captured_clk)
	begin
		if rising_edge(captured_clk) then
			pr_data_ds <= rd_data_ds;
		end if; -- rising_edge
	end process;

	G_inputs_data0:
	for i in 0 to inputs-1 generate
	  rd_data_0(i*(2*sample_bits) to (i+1)*(2*sample_bits)-1)
	  <= pr_data_ds((2*i+1)*sample_bits to (2*i+2)*sample_bits-1)
	   & rd_data_ds((2*i+0)*sample_bits to (2*i+1)*sample_bits-1);
	  rd_data_1(i*(2*sample_bits) to (i+1)*(2*sample_bits)-1)
	  <= rd_data_ds((2*i+0)*sample_bits to (2*i+1)*sample_bits-1)
	   & rd_data_ds((2*i+1)*sample_bits to (2*i+2)*sample_bits-1);
	end generate;

	captured_data <= rd_data_ds when downsampling = '1'
	            else rd_data_0  when rd_addr(rd_addr'high) = '0'
                    else rd_data_1;

-- can we avoid passing number of inputs to this module?
-- code would be more readable if captured data were
-- structured to allow handling special case downsampling=0
-- without knowing number of inputs, something like this:

--	captured_data <= rd_data_ds when downsampling = '1'
--                  else pr_data_ds(rd_data_ds'length/2 to rd_data_ds'high)
--                     & rd_data_ds(0 to rd_data_ds'length/2-1)
--                  when rd_addr(rd_addr'high) = '0'
--                  else rd_data_ds(0 to rd_data_ds'length/2-1)
--                     & rd_data_ds(rd_data_ds'length/2 to rd_data_ds'high);

end;
