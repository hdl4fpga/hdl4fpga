-------------------------------------------------------
-- USB constant requests functions package
-------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

package usb_req_gen_func_pack is
  function reverse_any_vecetor(a: std_logic_vector) return std_logic_vector;
  function usb_token_gen(input_data: std_logic_vector(10 downto 0)) return std_logic_vector;
  function usb_data_gen(input_data: std_logic_vector(71 downto 0)) return std_logic_vector;
end;

package body usb_req_gen_func_pack is
  function reverse_any_vector (a: std_logic_vector)
  return std_logic_vector is
    variable result: std_logic_vector(a'RANGE);
    alias aa: std_logic_vector(a'REVERSE_RANGE) is a;
  begin
    for i in aa'RANGE loop
      result(i) := aa(i);
    end loop;
    return result;
  end; -- function reverse_any_vector

  -- function to ease making USB 16-bit tokens
  -- reverses bit order of 11 input bits (passed as 11-bit vector)
  -- and appends 5-bit CRC
  -- user can write packet as 11-bit string like
  -- usb_token_gen("10000001000")
  -- this function will return 16-bit vector ready for transmission.
  -- test it with perl script:
  -- ./crc5.pl 10000001000 <- input nrz stream
  -- 11010 <- this is correct CRC
  -- compare same with this function (bits of input are reverse ordered)
  -- usb_token_gen("00010000001") = "11010"
  function usb_token_gen(input_data: std_logic_vector(10 downto 0))
  return std_logic_vector is
    variable nrzstream: std_logic_vector(input_data'range);
    variable crc: std_logic_vector(4 downto 0);
    constant generator_polynomial: std_logic_vector(crc'range) := "00101"; -- (x^5)+x^2+x^0
    variable result: std_logic_vector(input_data'high+crc'length downto 0);
    variable nextb, crc_msb: std_logic;
  begin
    -- reverse bit order of every byte in input data
    -- to create nrzstream ready for transmission
    nrzstream := reverse_any_vector(input_data);
    -- process each bit, accumulating the crc
    crc := "11111"; -- start with all bits 1
    for i in nrzstream'high downto 0 loop
      nextb := nrzstream(i);
      crc_msb := crc(crc'high); -- remember CRC MSB before shifting
      crc := crc(crc'high-1 downto 0) & '0'; -- shift 1 bit left, LSB=0, delete MSB
      if nextb /= crc_msb then
        crc := crc xor generator_polynomial;
      end if;
    end loop;
    crc := crc xor "11111"; -- finally invert all CRC bits
    result := nrzstream & crc;
    return result;
  end; -- function usb_token_gen
  
  -- function to ease making USB 11-byte data packets
  -- reverses bit order of 9 input bytes (passed as 72-bit vector)
  -- and appends 16-bit CRC
  -- user can write packet as 72-bit string like
  -- usb_data_gen(x"001122334455667788")
  -- this function will return 88-bit vector ready for transmission.
  -- example x"001122334455667788": 00 will be sent first, 88 last and then crc. 
  -- test crc with perl script:
  -- ./crc16.pl 1000000101100000000000000100010000000000000000001110110100000000
  -- 1111100111110101
  -- compare same with this function. Bits of input bytes are reverse ordered,
  -- because function ignores first byte in crc calculation.
  -- usb_data_gen("1111111111000000101100000000000000100010000000000000000001110110100000000") = "1111100111110101"
  function usb_data_gen(input_data: std_logic_vector(71 downto 0))
  return std_logic_vector is
    variable nrzstream: std_logic_vector(input_data'range);
    variable crc: std_logic_vector(15 downto 0);
    constant generator_polynomial: std_logic_vector(crc'range) := "1000000000000101"; -- (x^16)+x^15+x^2+x^0
    variable result: std_logic_vector(input_data'high+crc'length downto 0);
    variable nextb, crc_msb: std_logic;
  begin
    -- reverse bit order of every byte in input data
    -- to create nrzstream ready for transmission
    for i in 0 to input_data'high/8 loop
      nrzstream(8*(i+1)-1 downto 8*i) := reverse_any_vector(input_data(8*(i+1)-1 downto 8*i));
    end loop;
    -- process each bit, accumulating the crc
    crc := x"FFFF"; -- start with all bits 1
    for i in nrzstream'high-8 downto 0 loop
      nextb := nrzstream(i);
      crc_msb := crc(crc'high); -- remember CRC MSB before shifting
      crc := crc(crc'high-1 downto 0) & '0'; -- shift 1 bit left, LSB=0, delete MSB
      if nextb /= crc_msb then
        crc := crc xor generator_polynomial;
      end if;
    end loop;
    crc := crc xor x"FFFF"; -- finally invert all CRC bits
    result := nrzstream & crc;
    return result;
  end; -- function usb_data_gen
end package body;
