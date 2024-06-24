
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.hdo.all;

entity scopeio_axisreading is
	generic (
		inputs    : natural;
		vt_labels : string;
		hz_label  : string := "hztl";
		binary_length : natural;
		grid_unit : natural);
	port (
		rgtr_clk  : in  std_logic;
		txt_req   : in  std_logic;
		txt_rdy   : buffer std_logic;
		wdt_id : in std_logic_vector;
		botd_sht  : in std_logic_vector;
		botd_dec  : in std_logic_vector;
		offset    : in  std_logic_vector;
		scale     : in  std_logic_vector;
		code_frm  : out std_logic := '0';
		code_irdy : out std_logic := '0';
		code_data : out ascii);
end;

architecture def of scopeio_axisreading is

	signal str_req   : std_logic;
	signal str_rdy   : std_logic;
	signal btod_frm  : std_logic;
	signal btod_code : ascii;

	signal btod_req : std_logic;
	signal btod_rdy : std_logic;
	signal mul_req   : std_logic := '0';
	signal mul_rdy   : std_logic := '0';
	signal a         : std_logic_vector(0 to offset'length-1);
	signal b         : signed(0 to offset'length-1);

	signal binary    : std_logic_vector(0 to binary_length-1);
	signal botd_frm  : std_logic;
	signal botd_code : ascii;
	signal str_frm   : std_logic;
	signal str_code  : ascii;
begin

	process (rgtr_clk)
    	function textrom_init (
    		constant width : natural)
    		return string is
    		variable data  : string(1 to (inputs+2)*width);
    	begin
    		for i in 0 to inputs-1 loop
    			data(i*width+1 to (i+1)*width) := textalign(escaped(hdo(vt_labels)**("["&natural'image(i)&"].text")), width);
    		end loop;
    		data(width*inputs+1 to width*inputs+hz_label'length) := hz_label;
    		return data;
    	end;

		constant width : natural := 4;
		constant textrom : string := textrom_init (width);
		variable i : natural range 0 to width-1;
		variable cptr : natural range 0 to (1+inputs)*width;

	begin
		if rising_edge(rgtr_clk) then
			str_frm  <= str_req xor str_rdy;
			str_code <= to_ascii(textrom(cptr));
			if (str_rdy xor str_req)='1' then
				if i >= width-1 then
					str_rdy <= str_req;
				end if;
				i    := i + 1;
				cptr := cptr + 1;
			else
				i    := 0;
				cptr := width*to_integer(unsigned(wdt_id))+1;
			end if;
		end if;
	end process;

	process (rgtr_clk)
		type states is (s_label, s_offset, s_unit, s_scale);
		variable state : states;
	begin
		if rising_edge(rgtr_clk) then
			case state is
			when s_label =>
				a <= scale;
				if signed(offset) >= 0 then
					b <=  signed(offset);
				else 
					b <= -signed(offset);
				end if;
				if (to_bit(txt_rdy) xor to_bit(txt_req))='1' then
					mul_req  <= not to_stdulogic(to_bit(mul_rdy));
					str_req  <= not str_rdy;
					btod_req <= to_stdulogic(to_bit(btod_rdy));
					state    := s_offset;
				end if;
			when s_offset =>
				if (to_bit(mul_req) xor to_bit(mul_rdy))='0' then
					a <= scale;
					b <= to_signed(grid_unit, b'length);
					btod_req <= not to_stdulogic(to_bit(btod_rdy));
					state   := s_unit;
				end if;
			when s_unit =>
				if (to_bit(btod_req) xor to_bit(btod_rdy))='0' then
					mul_req  <= not mul_rdy;
					str_req  <= str_rdy;
					btod_req <= to_stdulogic(to_bit(btod_rdy));
					state   := s_scale;
				end if;
			when s_scale =>
				if (str_req xor str_rdy)='0' then
					if (mul_req xor mul_rdy)='0' then
						btod_req <= not btod_rdy;
						txt_rdy  <= txt_req;
						state   := s_label;
					end if;
				end if;
			end case;
		end if;
	end process;

	mul_ser_e : entity hdl4fpga.mul_ser
	generic map (
		lsb => true)
	port map (
		clk => rgtr_clk,
		req => mul_req,
		rdy => mul_rdy,
		a   => a,
		b   => std_logic_vector(b(1 to b'right)),
		s   => binary);

	botd_e : entity hdl4fpga.btof
	port map (
		clk      => rgtr_clk,
		btof_req => btod_req,
		btof_rdy => btod_rdy,
		sht      => botd_sht,
		dec      => botd_dec,
		left     => '0',
		width    => x"7",
		exp      => b"101",
		neg      => '0', --sign,
		bin      => binary,
		code_frm => botd_frm,
		code     => botd_code);

	code_frm  <= (txt_req xor txt_rdy) or (btod_req xor btod_rdy) or (str_req xor str_rdy);
	code_irdy <= botd_frm or str_frm;
	code_data <= multiplex(botd_code & str_code, not botd_frm);

end;
