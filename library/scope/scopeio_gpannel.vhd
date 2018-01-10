library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_gpannel is
	generic (
		inputs         : natural;
		gauge_frac     : natural;
		gauge_labels   : std_logic_vector;
		unit_symbols   : std_logic_vector);
	port (
		pannel_clk     : in  std_logic;
		time_scale     : in  std_logic_vector;
		time_deca      : in  std_logic_vector(ascii'range);
		trigger_scale  : in  std_logic_vector;
		trigger_deca   : in  std_logic_vector(ascii'range);
		trigger_edge   : in  std_logic;
		trigger_value     : in  std_logic_vector;
		channel_decas  : in  std_logic_vector;
		channel_scale  : in  std_logic_vector;
		channel_level  : in  std_logic_vector;
		video_clk      : in  std_logic;
		gpannel_row    : in  std_logic_vector;
		gpannel_col    : in  std_logic_vector;
		gpannel_on     : in  std_logic_vector;
		gauge_on       : out std_logic_vector;
		gauge_code     : out std_logic_vector);
end;

architecture beh of scopeio_gpannel is

	constant label_size : natural := gauge_labels'length/((2*inputs+2)*ascii'length);
	signal   reading    : std_logic_vector(24-1 downto 0);

	impure function init_rom (
		constant size : natural)
		return std_logic_vector is
		variable aux    : std_logic_vector(gauge_labels'length-1 downto 0);
		variable aux1   : std_logic_vector(unit_symbols'length-1 downto 0);
		variable retval : std_logic_vector(0 to ascii'length*size*(2*inputs+2)-1);
		constant ssize  : natural := aux'length/(2+2*inputs);
		constant ssize1 : natural := aux1'length/(2+2*inputs);
	begin 
		aux  := std_logic_vector(gauge_labels);
		aux1 := std_logic_vector(unit_symbols);
		for i in 0 to 2*inputs+2-1 loop
			retval := std_logic_vector(unsigned(retval) ror (ascii'length*size));
			retval(0 to retval'length/(2+2*inputs)-1) := fill(
				aux(ssize-1 downto 0)    & 
				fill("", ascii'length*reading'length/4) &
				to_ascii(string'("   "))  &
				aux1(ssize1-1 downto 0),
				ascii'length*size, value => '0');
			aux  := std_logic_vector(unsigned(aux)  srl ssize);
			aux1 := std_logic_vector(unsigned(aux1) srl ssize1);
		end loop;
		return retval;
	end;

	signal mem       : byte_vector(0 to (2*inputs+2)*2**gpannel_col'length-1) := to_bytevector(init_rom(2**gpannel_col'length));
	signal scale     : std_logic_vector(0 to channel_scale'length/inputs-1) := b"0011";
	signal value     : std_logic_vector(0 to channel_level'length/inputs-1) := b"0_0010_0000";
	signal deca      : std_logic_vector(ascii'range);
	signal reading1  : std_logic_vector(reading'range):= (others => '0');

	signal chan_dot  : std_logic_vector(0 to 2+inputs-1);
	signal meter_fld : std_logic_vector(0 to 2+inputs-1);
	signal page      : std_logic_vector(unsigned_num_bits(gpannel_on'length-1)-1 downto 0);


	impure function fmt_reading (
		constant arg1 : std_logic_vector;
		constant arg2 : natural)
		return std_logic_vector is
	begin
		return std_logic_vector(unsigned(fill(arg1, 2**gpannel_col'length*ascii'length)) ror arg2 );
	end;

	signal text_col  : std_logic_vector(gpannel_col'left downto gpannel_col'right);
	signal text_row  : std_logic_vector(page'length+gpannel_row'left downto gpannel_row'right);
	signal text_addr : std_logic_vector(text_row'length+text_col'length-1 downto 0);
	signal text_data : std_logic_vector(ascii'range);

	signal we : std_logic := '0';
begin

	page <= encoder(gpannel_on);
	process (pannel_clk)
		constant start  : natural := label_size;
		constant finish : natural := start+reading'length/4+3;
	begin
		if rising_edge(pannel_clk) then
			if unsigned(text_col) < (finish-1) then
				text_col <= std_logic_vector(unsigned(text_col) + 1);
			else
				text_col <= std_logic_vector(to_unsigned(start, text_col'length));
				we <= '1';
				if unsigned(text_row) < (2*inputs+2-1) then
					text_row <= std_logic_vector(unsigned(text_row) + 1);
				else
					text_row <= (others => '0');
				end if;
			end if;
		end if;
	end process;

	textcol_align_e : entity hdl4fpga.align
	generic map (
		n => text_col'length,
		d => (text_col'range => 2))
	port map (
		clk => pannel_clk,
		di  => text_col,
		do  => text_addr(text_col'length-1 downto 0));

	textrow_align_e : entity hdl4fpga.align
	generic map (
		n => text_row'length,
		d => (text_row'range => 0))
	port map (
		clk => pannel_clk,
		di  => text_row,
		do  => text_addr(text_row'length+text_col'length-1 downto text_col'length));


	process(pannel_clk)
		variable addr : std_logic_vector(text_addr'range);
		variable data : std_logic_vector(ascii'range);
		variable edge : std_logic_vector(ascii'range);
	begin
		if rising_edge(pannel_clk) then
			if we='1' then
				mem(to_integer(unsigned(addr))) <= data;
			end if;
			addr := text_addr;
			edge := x"20";
			if text_addr(text_row'length+text_col'length-1 downto text_col'length)=std_logic_vector(to_unsigned(2+2*inputs-1,text_row'length)) then
				edge := x"19";
				if trigger_edge='1' then
					edge := x"18";
				end if;
			end if;
			data := word2byte(fmt_reading(bcd2ascii(reading1) & edge & x"20" & deca, label_size*ascii'length), text_addr(text_col'length-1 downto 0), ascii'length);
		end if;
	end process;

	process (pannel_clk)
		variable vt_value  : std_logic_vector(0 to 2*inputs*value'length-1);
		variable vt_deca   : std_logic_vector(0 to 2*inputs*ascii'length-1);
		variable vt_scale  : std_logic_vector(0 to 2*inputs*scale'length-1);
	begin
		if rising_edge(pannel_clk) then
			scale <= word2byte(
				vt_scale    &
				time_scale  &
				trigger_scale,
				text_row, scale'length);

			value <= word2byte(
				vt_value    &
				std_logic_vector(to_unsigned(128, value'length)) &
				trigger_value,
				text_row, value'length);

			deca <= word2byte(
				vt_deca    & 
				time_deca  & 
				trigger_deca,
				text_row, ascii'length);

			for i in 0 to inputs-1 loop
				vt_value := byte2word(
					vt_value, 
					std_logic_vector(to_unsigned(32, value'length)) & word2byte(channel_level, i, value'length),
					reverse(std_logic_vector(to_unsigned(2**i, inputs))));
				vt_deca  := byte2word(
					vt_deca, 
					word2byte(channel_decas, i, ascii'length) & word2byte(channel_decas, i, ascii'length),
					reverse(std_logic_vector(to_unsigned(2**i, inputs))));
				vt_scale := byte2word(
					vt_scale, 
					word2byte(channel_scale, i, scale'length) & word2byte(channel_scale, i, scale'length),
					reverse(std_logic_vector(to_unsigned(2**i, inputs))));
			end loop;

			reading1 <= reading;
		end if;
	end process;

	display_e : entity hdl4fpga.scopeio_gauge
	generic map (
		frac => gauge_frac,
		dec  => 3)
	port map (
		value => value,
		scale => scale,
		fmtds => reading);	

	process(video_clk)
		variable address : unsigned(unsigned_num_bits(mem'length-1)-1 downto 0);
	begin
		if rising_edge(video_clk) then
			address(page'range) := unsigned(page);
			address := address sll gpannel_row'length;
			address(gpannel_row'length-1 downto 0) := unsigned(gpannel_row);
			address := address sll gpannel_col'length;
			address(gpannel_col'length-1 downto 0) := unsigned(gpannel_col);
			gauge_code <= mem(to_integer(address));
		end if;
	end process;

	process(gpannel_row, gpannel_on)
		variable row : unsigned(0 to 2**(page'length+gpannel_row'length)-1);
	begin
		row := unsigned(demux(page & gpannel_row));
		gauge_on <= (gauge_on'range => '0');
		for i in 0 to inputs+2-1 loop
			if gpannel_on/=(gpannel_on'range => '0') then
				if i < inputs then
					gauge_on(i) <= setif(row(0 to 2-1) /= (0 to 2-1 => '0'));
					row         := row sll 2;
				else
					gauge_on(i) <= row(0);
					row         := row sll 1;
				end if;
			end if;
		end loop;
	end process;

end;
