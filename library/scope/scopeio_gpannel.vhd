library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_gpannel is
	generic (
		inputs         : natural;
		gauge_labels   : string;
		trigger_scales : std_logic_vector;
		time_scales    : std_logic_vector;
		hz_scales      : scale_vector;
		vt_scales      : scale_vector);
	port (
		pannel_clk     : in  std_logic;
		time_scale     : in  std_logic_vector;
		time_value     : in  std_logic_vector;
		trigger_scale  : in  std_logic_vector;
		trigger_value  : in  std_logic_vector;
		channel_scale  : in  std_logic_vector;
		--channel_level  : in  std_logic_vector;
		text_addr      : in  std_logic_vector;
		text_data      : out std_logic_vector);
end;

architecture beh of scopeio_gpannel is

	constant label_size : natural := gauge_labels'length/(2+2*inputs);
	signal   col_addr   : std_logic_vector(unsigned_num_bits(label_size-1)-1 downto 0);
	signal   row_addr   : std_logic_vector(unsigned_num_bits((2+2*inputs)-1)+col_addr'length-1 downto 0);
	constant row_size   : natural := 2**row_addr'length;

	impure function init_rom 
		return std_logic_vector is
		variable retval : std_logic_vector(0 to ascii'length*2**col_addr'length*(2+2*inputs)-1);
	begin 
		for i in 2+2*inputs-1 downto 0 loop
			retval(0 to retval'length/(2+2*inputs)-1) := fill(to_ascii(gauge_labels(i*label_size+1 to (i+1)*label_size)), ascii'length*2**col_addr'length);
			retval := std_logic_vector(unsigned(retval) ror (ascii'length*2**col_addr'length));
		end loop;
		return retval;
	end;

	constant label_rom : byte_vector(0 to row_size-1) := to_bytevector(init_rom);

	signal scale   : std_logic_vector(0 to channel_scale'length/inputs-1) := b"0000";
	signal value   : std_logic_vector(inputs*9-1 downto 0) := b"0_1110_0000";
	signal unit    : std_logic_vector(0 to 4*8-1);
	signal reading : std_logic_vector(20-1 downto 0);

	function init_mult (
		constant arg : scales_vector)
		return std_logic_vector is
		variable retval : unsigned(arg'length*ascii'length-1 downto 0);
		constant symbols : string := "m" & character'val(230) & "n";
	begin
		for i in arg'range loop
			retval(ascii'range) := to_ascii(string(-arg(i).mult/3));
			retval := retval rol ascii'length;
		end loop;
		return std_logic_vector(retval);
	end;

	constant hz_mults : std_logic_vector(0 to ascii'length*hz_scales'length-1) := init_unit(hz_mult);
	constant vt_mults : std_logic_vector(0 to ascii'length*vt_scales'length-1) := init_unit(vt_mult);
begin

	process (pannel_clk)
		constant rtxt_size : natural := unsigned_num_bits(2+2*inputs-1);
		variable scale_aux : unsigned(0 to 2*channel_scale'length-1);

		function dup (
			constant arg : std_logic_vector)
			return std_logic_vector is
			constant size   : natural := arg'length/inputs;
			variable aux    : unsigned(0 to arg'length-1);
			variable retval : unsigned(0 to 2*arg'length*ascii'length-1);
		begin
			retval := (others => '-');
			aux    := unsigned(arg);
			for i in 0 to inputs-1 loop
				for j in 0 to 2-1 loop
					retval(scale'range) := aux(0 to size-1);
					retval := retval rol size;
				end loop;
				aux := aux srl size;
			end loop;
			return std_logic_vector(retval);
		end;

		variable hz_mult : std_logic_vector(0 to ascii'length-1);
		variable trigger_mult : std_logic_vector(0 to ascii'length-1);
		variable vt_mult : std_logic_vector(0 to ascii'length*inputs-1);

	begin
		if rising_edge(pannel_clk) then

			hz_mult <= word2byte(hz_mults, time_scale);
			for i in 0 to inputs-1 loop
				vt_mult <= word2byte(hz_mults, channel_scale);
			end loop;

			scale <= word2byte(
				word2byte(time_scales,    time_scale)    &
				word2byte(trigger_scales, trigger_scale) &
				dup(channel_scale),
				text_addr(row_addr'left+2 downto row_addr'left),
				scale'length);

--			value <= word2byte(
--				word2byte(time_value,    time_scale)    &
--				word2byte(trigger_value, trigger_scale) &
--				channel_level,
--				text_addr,
--				scale'length);

			unit <= word2byte(
				word2byte(time_scales,    time_scale)    &
				word2byte(trigger_scales, trigger_scale) &
				dup(
					word2byte(time_scales,    time_scale)  &
					word2byte(trigger_scales, trigger_scale)),
				text_addr(row_addr'left+2 downto row_addr'left),
				scale'length);
		end if;
	end process;

	display_e : entity hdl4fpga.scopeio_gauge
	generic map (
		frac => 6,
		int  => 2,
		dec  => 2)
	port map (
		value => value(9-1 downto 0),
		scale => scale,
		fmtds => reading);	

	text_data <=
		label_rom(to_integer(unsigned(std_logic_vector'(text_addr(row_addr'left+2 downto row_addr'left) & text_addr(col_addr'range))))) 
		when to_integer(unsigned(text_addr(col_addr'length downto 0))) < label_size else
		word2byte(bcd2ascii(reading), std_logic_vector(unsigned(text_addr(3-1 downto 0))+((8-(label_size mod 8)) mod 8)), ascii'length)
		when to_integer(unsigned(text_addr(col_addr'length downto 0))) < label_size+reading'length/4 else
		word2byte(to_ascii(string'("hola")), std_logic_vector(unsigned(text_addr(2-1 downto 0))+((4-((label_size+reading'length/4) mod 4)) mod 4)), ascii'length)
		when to_integer(unsigned(text_addr(col_addr'length downto 0))) < label_size+reading'length/4+4 else
		(text_data'range => '0');
--			text_data <= word2byte(
--				glabel & bcd2ascii(reading) & unit,
--				not text_addr,
--				text_data'length);

end;
