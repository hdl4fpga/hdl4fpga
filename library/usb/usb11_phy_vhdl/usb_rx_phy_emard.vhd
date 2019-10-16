-- (c)EMARD
-- License=GPL

-- USB clock recovery

-- differential data correctly recovered
-- currenctly it is not working as phy replacement

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity usb_rx_phy_emard is
generic
(
  C_clk_input_hz: natural := 6000000; -- Hz input to this module (6 or 48 MHz)
  C_clk_bit_hz: natural   := 1500000; -- Hz bit clock (1.5 Mbps or 12 Mbps)
  C_PA_bits: natural      := 8        -- phase accumulator bits
);
port
(
  clk, reset: in std_logic; -- input clock and reset
  usb_dif, usb_dp, usb_dn: in std_logic; -- differential D+/D- input
  linestate: out std_logic_vector(1 downto 0);
  clk_recovered, clk_recovered_edge: out std_logic;
  rawdata: out std_logic;
  rx_en: in std_logic;
  rx_active: out std_logic;
  valid: out std_logic;
  data: out std_logic_vector
);
end; -- entity

architecture Behavioral of usb_rx_phy_emard is
  constant C_PA_inc: unsigned(C_PA_bits-1 downto 0) := to_unsigned(2**(C_PA_bits-1)*C_clk_bit_hz/C_clk_input_hz,C_PA_bits); -- default PA increment
  constant C_PA_phase: unsigned(C_PA_bits-2 downto 0) :=
  (
    C_PA_bits-2 => '0', -- 1/4
    C_PA_bits-3 => '0', -- 1/8
    C_PA_bits-4 => '0', -- 1/16
    C_PA_bits-5 => '0', -- 1/32
    others      => '1'
  );
  constant C_PA_compensate: unsigned(C_PA_bits-2 downto 0) := C_PA_inc(C_PA_bits-2 downto 0)+C_PA_inc(C_PA_bits-2 downto 0);
  constant C_PA_init: unsigned(C_PA_bits-2 downto 0) := C_PA_phase + C_PA_compensate;
  constant C_valid_init: std_logic_vector(data'range) := (data'high-1 => '1', others => '0'); -- adjusted (1 bit early) to split stream at byte boundary
  constant C_idlecnt_init: std_logic_vector(6 downto 0) := (6 => '1', others => '0'); -- 6 data bits + 1 stuff bit
  signal R_PA: unsigned(C_PA_bits-1 downto 0);
  signal R_dif_shift: std_logic_vector(1 downto 0);
  signal R_clk_recovered_shift: std_logic_vector(1 downto 0);
  signal S_clk_recovered: std_logic;
  signal S_data, R_data_prev, S_bit: std_logic;
  signal R_frame: std_logic;
  signal R_data: std_logic_vector(data'range);
  signal R_valid: std_logic_vector(data'range) := C_valid_init;
  signal R_linestate, R_linestate_sync: std_logic_vector(1 downto 0);
  signal R_idlecnt: std_logic_vector(C_idlecnt_init'range) := C_idlecnt_init;
  signal R_rx_en: std_logic;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      R_dif_shift <= usb_dif & R_dif_shift(R_dif_shift'high downto 1);
      R_clk_recovered_shift <= S_clk_recovered & R_clk_recovered_shift(R_dif_shift'high downto 1);
      R_linestate <= usb_dp & usb_dn;
      R_rx_en <= rx_en;
    end if; -- clk rising edge
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if R_dif_shift(R_dif_shift'high) /= R_dif_shift(R_dif_shift'high-1) then
        R_PA(R_PA'high-1 downto 0) <= C_PA_init(R_PA'high-1 downto 0);
      else
        R_PA <= R_PA + C_PA_inc;
      end if;
    end if; -- clk rising edge
  end process;
  S_clk_recovered <= R_PA(R_PA'high);
  clk_recovered <= S_clk_recovered;
  clk_recovered_edge <= '1' when R_clk_recovered_shift(1) /= S_clk_recovered else '0';

  -- synchronous with recovered clock
  S_data <= R_dif_shift(R_dif_shift'high-1);
  S_bit <= not(S_data xor R_data_prev);
  process(clk)
  begin
    if rising_edge(clk) then
      if R_rx_en = '1' and reset = '0' then
        if R_clk_recovered_shift(1) /= S_clk_recovered then
          R_linestate_sync <= R_linestate;
          if R_data_prev = S_data then
            R_idlecnt <= R_idlecnt(0) & R_idlecnt(R_idlecnt'high downto 1); -- shift (used for stuffed bit removal)
          else
            R_idlecnt <= C_idlecnt_init; -- reset
          end if;
          if R_linestate_sync = "00" then -- SE0
            R_frame <= '0';
            R_valid <= C_valid_init;
          else
            if R_frame = '1' then
              if R_idlecnt(0) = '0' then -- skips stuffed bit
                R_data <= S_bit & R_data(R_data'high downto 1); -- only payload bits, skips stuffed bit
                R_valid <= R_valid(0) & R_valid(R_valid'high downto 1);
              end if;
            else -- R_frame = '0'
              if R_data_prev = '0' and S_data = '1' then
                R_frame <= '1';
                R_valid <= C_valid_init;
              end if;
            end if;
          end if;
          R_data_prev <= S_data;
        end if;
      else -- R_rx_en = '0'
        R_valid <= C_valid_init;
        R_frame <= '0';
      end if;
    end if; -- clk rising edge
  end process;
  data <= R_data;
  rawdata <= R_data_prev;
  linestate <= R_linestate;
  rx_active <= R_frame;

  B_valid_1clk: block
    signal R_valid_prev: std_logic;
  begin
    process(clk)
    begin
      if rising_edge(clk) then
        R_valid_prev <= R_valid(0);
      end if; -- clk rising edge
    end process;
    valid <= '1' when R_valid_prev = '0' and R_valid(0) = '1' else '0'; -- single clk cycle
--  valid <= R_valid(0); -- spans several clk cycles
  end block;

end; -- architecture
