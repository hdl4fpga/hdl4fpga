-- AUTHOR=EMARD
-- LICENSE=GPL

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_storage is
	generic (
		inputs                 : natural;
		visibility_register    : boolean := false; -- true: with latency but fmax friendly
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
		captured_visible       : out std_logic;
		captured_data          : out std_logic_vector
	);
end;

architecture beh of scopeio_storage is
	-- "_ds" suffix used to treat special case of "downsampling"
	constant sample_bits: natural := storage_data'length / inputs / 2;
	signal t0_addr      : unsigned(storage_addr'range);
	signal t0_addr_ds   : unsigned(0 to t0_addr'length);
	signal scrolled_addr: unsigned(t0_addr_ds'range);
	signal rd_addr      : unsigned(t0_addr_ds'range);
	signal wr_addr      : unsigned(t0_addr'range);
	signal wr_ena       : std_logic;
	signal null_data    : std_logic_vector(storage_data'range);
	signal rd_addr_ds   : unsigned(t0_addr'range);
	signal rd_data_ds   : std_logic_vector(captured_data'range);
	signal pr_data_ds   : std_logic_vector(captured_data'range);
	signal rd_data_0, rd_data_1: std_logic_vector(captured_data'range);
	signal visible_addr : unsigned(0 to captured_scroll'length-1);
	signal visible_addr_ds : unsigned(0 to visible_addr'length-2);
	signal visible_addr_ds_compare : unsigned(0 to visible_addr_ds'length-rd_addr_ds'length);
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

	-- special case treatment: at downsampling=0
	-- t0_addr actually holds double address
	t0_addr_ds <= '0' & t0_addr when downsampling = '1'
	         else t0_addr & '0';

	-- "captured_scroll" is horizontal scrolling offset, requested by display system
	-- Latency is allowed so we can offload arithmetic stage with a register:
	P_horizontal_scroll:
	process(storage_clk)
	begin
		if rising_edge(storage_clk) then
			scrolled_addr <= t0_addr_ds + resize(unsigned(captured_scroll),scrolled_addr'length)
			               + to_unsigned(-align_to_grid,scrolled_addr'length);
		end if; -- rising_edge
	end process;

	-- "scrolled_addr" is triggering point T=0 displaced by "storage_scroll".
	-- "captured_addr" is addr for drawing traces, requested by display system
	-- No latency is allowed for "captured_addr", therefore combinatorial logic here:
	-- Registered latency will cause display artefacts.
	rd_addr <= scrolled_addr + unsigned(captured_addr);

	-- if downsampling = 0 special case: right shift rd_addr value
	-- if downsampling = 1 just discard MSB bit
	rd_addr_ds <= rd_addr(1 to rd_addr'high) when downsampling = '1' 
	         else rd_addr(0 to rd_addr'high-1);

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
	-- it works because video read is sequential
	process(captured_clk)
	begin
		if rising_edge(captured_clk) then
			pr_data_ds <= rd_data_ds;
		end if; -- rising_edge
	end process;

--    Emard's original
--	G_split_double_samples:
--	for i in 0 to inputs-1 generate
--	  rd_data_0(i*(2*sample_bits) to (i+1)*(2*sample_bits)-1)
--	  <= pr_data_ds((2*i+1)*sample_bits to (2*i+2)*sample_bits-1)
--	   & rd_data_ds((2*i+0)*sample_bits to (2*i+1)*sample_bits-1);
--	  rd_data_1(i*(2*sample_bits) to (i+1)*(2*sample_bits)-1)
--	  <= rd_data_ds((2*i+0)*sample_bits to (2*i+1)*sample_bits-1)
--	   & rd_data_ds((2*i+1)*sample_bits to (2*i+2)*sample_bits-1);
--	end generate;
	rd_data_0 <= pr_data_ds(pr_data_ds'length/2 to pr_data_ds'length-1) & rd_data_ds(0 to rd_data_ds'length/2-1);
	rd_data_1 <= pr_data_ds(0 to pr_data_ds'length/2-1) & rd_data_ds(rd_data_ds'length/2 to rd_data_ds'length-1);

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

	-- draw traces only for buffer content (no wraparound)
	visible_addr <= resize(unsigned(captured_addr),visible_addr'length) + unsigned(captured_scroll);
	visible_addr_ds_compare <= (others => visible_addr_ds(0)); -- condition to be visible

	G_yes_visibility_register:
	if visibility_register generate
	-- generate signal for trace visibility
	-- registered to offload timing
	-- at downsampling = 0, two samples from end of the buffer
	-- will be drawn wrong at beginning of the buffer
	P_trace_visibility:
	process(storage_clk)
	begin
		if rising_edge(storage_clk) then
			if downsampling = '1' then
				visible_addr_ds <= visible_addr(1 to visible_addr'high);
			else
				visible_addr_ds <= visible_addr(0 to visible_addr'high-1);
			end if;
			if visible_addr_ds(visible_addr_ds_compare'range)
	                           = visible_addr_ds_compare
			then
	                        captured_visible <= '1';
			else
				captured_visible <= '0';
			end if;
		end if; -- rising_edge
	end process;
	end generate;

	G_not_visibility_register:
	-- fully combinatorial logic
	if not visibility_register generate
	-- at downsampling = 0, one sample from end of the buffer
	-- will be drawn wrong at beginning of the buffer
	visible_addr_ds <= visible_addr(1 to visible_addr'high) when downsampling = '1'
		      else visible_addr(0 to visible_addr'high-1);
	captured_visible <= '1' when visible_addr_ds(visible_addr_ds_compare'range)
	                           = visible_addr_ds_compare
	               else '0';
	end generate;
end;
