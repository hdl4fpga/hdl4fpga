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

		captured_clk           : in  std_logic;
		captured_addr          : in  std_logic_vector;
		captured_scroll        : in  std_logic_vector;
		captured_data          : out std_logic_vector
	);
end;

architecture beh of scopeio_storage is
	signal t0_addr      : unsigned(storage_addr'range);
	signal scrolled_addr: unsigned(t0_addr'range);
	signal rd_addr      : unsigned(t0_addr'range);
	signal wr_addr      : unsigned(t0_addr'range);
	signal wr_ena       : std_logic;
	signal null_data    : std_logic_vector(storage_data'range);
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

	mem_e : entity hdl4fpga.bram(inference)
	port map (
		clka  => storage_clk,
		addra => std_logic_vector(wr_addr),
		wea   => storage_write,
		dia   => storage_data,
		doa   => null_data,

		clkb  => captured_clk,
		addrb => std_logic_vector(rd_addr),
		dib   => null_data,
		dob   => captured_data);

end;
