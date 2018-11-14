library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dtof is
	generic (
		n  : natural := 0);
	port (
		clk     : in  std_logic := '0';
		point   : in  std_logic_vector;
		bcd_ena : in  std_logic := '1';
		bcd_dv  : in  std_logic := '1';
		bcd_di  : in  std_logic_vector;
		bcd_do  : out std_logic_vector;
		bcd_cy  : out std_logic);
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture def of dtof is

	procedure dbdbb(
		variable shtio : inout std_logic;
		variable digit : inout unsigned) is
		variable save  : std_logic;
	begin
		save     := digit(0);
		digit(0) := shtio;
		shtio    := save;
		digit    := digit ror 1;
		if digit >= "0101" then
			digit := digit - "0011";
		end if;
	end;

	constant size  : natural := setif(n=0, 2**point'length, n);
	signal shtio_d : unsigned(size-1 downto 0);
	signal shtio_q : unsigned(size-1 downto 0);

begin

	reg_p : process (clk)
	begin
		if rising_edge(clk) then
			if bcd_ena='1' then
				shtio_q <= shtio_d;
			end if;
		end if;
	end process;

	process (bcd_di, bcd_dv, shtio_q)
		variable tmp_value : unsigned(bcd_di'length-1 downto 0);
		variable tmp_shtio : unsigned(size-1 downto 0);
		variable carry     : std_logic;
	begin
		tmp_value := unsigned(bcd_di);
		if bcd_dv='1' then
			tmp_shtio := (others => '0');
		else
			tmp_shtio := shtio_q;
		end if;

		carry := '0';
		for k in 0 to size-1 loop
			if k <= to_integer(unsigned(not point)) then
				for i in 0 to tmp_value'length/4-1 loop
					tmp_value := tmp_value rol 4;
					dbdbb (tmp_shtio(0), tmp_value(4-1 downto 0));
				end loop;
				carry := carry or tmp_shtio(0);
			end if;
			tmp_shtio := tmp_shtio rol 1;
		end loop;

		shtio_d <= tmp_shtio;
		bcd_do  <= std_logic_vector(tmp_value);
		bcd_cy <= carry;
	end process;

end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity btod is
	port (
		clk     : in  std_logic := '0';

		bin_dv  : in  std_logic;
		bin_di  : in  std_logic_vector;
		bin_ena : in  std_logic := '1';

		bcd_di  : in  std_logic_vector;
		bcd_do  : out std_logic_vector;
		bcd_cy  : out std_logic);
end;

architecture def of btod is

	procedure dbdbb(
		variable shtio : inout std_logic;
		variable digit : inout unsigned) is
		variable save  : std_logic;
	begin
		if digit >= "0101" then
			digit := digit + "0011";
		end if;
		digit    := digit rol 1;
		save     := digit(0);
		digit(0) := shtio;
		shtio    := save;
	end;

	signal shtio_d : unsigned(bin_di'length-1 downto 0);
	signal shtio_q : unsigned(bin_di'length-1 downto 0);

begin

	reg_p : process (clk)
	begin
		if rising_edge(clk) then
			if bin_ena='1' then
				shtio_q <= shtio_d;
			end if;
		end if;
	end process;

	comb_p : process (bin_dv, bin_di, bcd_di, shtio_q)
		variable tmp_value : unsigned(bcd_di'length-1 downto 0);
		variable tmp_shtio : unsigned(bin_di'length-1 downto 0);
	begin
		tmp_value := unsigned(bcd_di);

		if bin_dv='1' then
			tmp_shtio := unsigned(bin_di);
		else
			tmp_shtio := shtio_q;
		end if;

		for k in tmp_shtio'range loop
			tmp_shtio := tmp_shtio rol 1;
			for i in 0 to tmp_value'length/4-1 loop
				dbdbb(tmp_shtio(0), tmp_value(4-1 downto 0));
				tmp_value := tmp_value ror 4;
			end loop;
		end loop;

		bcd_do  <= std_logic_vector(tmp_value);
		shtio_d <= tmp_shtio;
	end process;
	bcd_cy <= setif(shtio_d /= (shtio_d'range => '0'));

end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

-- entity ftod is
-- 	generic (
-- 		n       : natural := 4);
-- 	port (
-- 		clk     : in  std_logic;
-- 		bin_ena : in  std_logic;
-- 		bin_fix : in  std_logic := '0';
-- 		bin_di  : in  std_logic_vector;
-- 
-- 		bcd_lst : out std_logic;
-- 		bcd_lft : out std_logic_vector(n-1 downto 0);
-- 		bcd_rgt : out std_logic_vector(n-1 downto 0);
-- 		bcd_do  : out std_logic_vector);
-- end;
-- 
-- architecture def of ftod is
-- 
-- 	signal cntr_ple : std_logic;
-- 	signal cntr_rst : std_logic;
-- 	signal cntr     : unsigned(0 to n);
-- 	signal left     : unsigned(1 to cntr'right);
-- 	signal right    : unsigned(1 to cntr'right);
-- 
-- 	signal mem_ptr  : unsigned(1 to cntr'right);
-- 	signal mem_full : std_logic;
-- 	signal rd_data  : std_logic_vector(bcd_do'range);
-- 	signal wr_data  : std_logic_vector(bcd_do'range);
-- 
-- 	signal bcd_dv   : std_logic;
-- 	signal bcd_di   : std_logic_vector(bcd_do'range);
-- 	signal btod_do  : std_logic_vector(bcd_do'range);
-- 	signal btod_dv  : std_logic;
-- 
-- 	signal dtof_ena : std_logic;
-- 	signal dtof_do  : std_logic_vector(bcd_do'range);
-- 
-- 	signal btod_cy  : std_logic;
-- 	signal dtof_cy  : std_logic;
-- 	signal carry    : std_logic;
-- 
-- 	signal fix      : std_logic;
-- begin
-- 
-- 	mem_full <= setif(left+right=(left'range =>'1'));
-- 	carry    <= btod_cy when bin_fix='0' else dtof_cy;
-- 	cntr_rst <= not bin_ena;
-- 	cntr_ple <= '1' when mem_full='1' else not carry;
-- 		
-- 	cntr_p : process (clk)
-- 	begin
-- 		if rising_edge(clk) then
-- 			if cntr_rst='1' then
-- 				cntr <= (others => '1');
-- 			elsif cntr(0)='1'then
-- 				if cntr_ple='1' then
-- 					cntr <= resize(left+right, cntr'length)-1;
-- 				end if;
-- 			else
-- 				cntr <= cntr - 1;
-- 			end if;
-- 		end if;
-- 	end process;
-- 
-- 	left_p : process(clk)
-- 		variable zero : boolean;
-- 	begin
-- 		if rising_edge(clk) then
-- 			if bin_ena='0' then
-- 				zero := TRUE;
-- 				left <= (others => '0');
-- 			elsif bin_fix='0' then
-- 				zero := TRUE;
-- 				if cntr(0)='1' then
-- 					if btod_cy='1' then
-- 						left <= left + 1;
-- 					end if;
-- 				end if;
-- 			else
-- 				if cntr(0)='1' then
-- 					zero  := TRUE;
-- 				elsif wr_data/=(wr_data'range => '0') then
-- 					zero  := FALSE;
-- 				elsif zero then
-- 					left <= left - 1;
-- 				end if;
-- 			end if;
-- 		end if;
-- 	end process;
-- 	bcd_lft <= std_logic_vector(left);
-- 
-- 	right_p : process(clk)
-- 	begin
-- 		if rising_edge(clk) then
-- 			if bin_ena='0' then
-- 				right  <= (others => '0');
-- 			elsif bin_fix='1' then
-- 				if cntr(0)='1' then
-- 					if dtof_cy='1' then
-- 						if mem_full='0' then
-- 							right <= right  + 1 ;
-- 						end if;
-- 					end if;
-- 				end if;
-- 			end if;
-- 		end if;
-- 	end process;
-- 	bcd_rgt <= std_logic_vector(right);
-- 
-- 	process (clk)
-- 	begin
-- 		if rising_edge(clk) then
-- 			if bin_ena='0' then
-- 				bcd_dv    <= '1';
-- 				btod_dv   <= '1';
-- 			elsif cntr(0)='1' then
-- 				if mem_full='0' and carry='1' then
-- 					btod_dv <= '0';
-- 					bcd_dv  <= '1';
-- 				else
-- 					btod_dv  <= '1';
-- 					bcd_dv   <= '0';
-- 				end if;
-- 			else
-- 				bcd_dv  <= '0';
-- 				btod_dv <= '0';
-- 			end if;
-- 			fix <= bin_fix;
-- 		end if;
-- 	end process;
-- 
-- 	bcd_lst <= cntr(0) and not (carry and not mem_full);
-- 	bcd_di  <= (bcd_di'range => '0') when bcd_dv='1' else rd_data;
-- 
-- 	btod_e : entity hdl4fpga.btod
-- 	port map (
-- 		clk    => clk,
-- 		bin_dv => btod_dv,
-- 		bin_di => bin_di,
-- 
-- 		bcd_di => bcd_di,
-- 		bcd_do => btod_do,
-- 		bcd_cy => btod_cy);
-- 
-- 	process (clk, fix)
-- 		variable ena : std_logic;
-- 	begin
-- 		if rising_edge(clk) then
-- 			if mem_full='0' then
-- 				ena := cntr(0) and not dtof_cy;
-- 			else
-- 				ena := cntr(0);
-- 			end if;
-- 		end if;
-- 		dtof_ena <= fix and ena;
-- 	end process;
-- 
-- 	dtof_e : entity hdl4fpga.dtof
-- 	port map (
-- 		clk     => clk,
-- 		bcd_ena => dtof_ena,
-- 		point   => b"1",
-- 		bcd_di  => bcd_di,
-- 		bcd_do  => dtof_do,
-- 		bcd_cy  => dtof_cy);
-- 
-- 	wr_data <= btod_do when fix='0' else dtof_do;
--    		
-- 	mem_ptr <=
-- 		left + not cntr(mem_ptr'range) when fix='0' else
-- 		0-not cntr(mem_ptr'range)-right;
-- 
-- 	ram_e : entity hdl4fpga.dpram
-- 	port map (
-- 		wr_clk  => clk,
-- 		wr_ena  => '1',
-- 		wr_addr => std_logic_vector(mem_ptr),
-- 		wr_data => wr_data,
-- 		rd_addr => std_logic_vector(mem_ptr),
-- 		rd_data => rd_data);
-- 
-- 	bcd_do <= wr_data;
-- 
-- end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity align_bcd is
	generic (
		space : std_logic_vector(4-1 downto 0) := x"f");
	port (
		left   : in  std_logic := '0';
		value  : in  std_logic_vector;
		align  : out std_logic_vector);
end;
		
architecture def of align_bcd is

	function align_bcd_f (
		constant value : std_logic_vector;
		constant left  : std_logic)
		return std_logic_vector is
		variable retval : unsigned(value'length-1 downto 0);
	begin
		retval := unsigned(value);
		if left='1' then
			retval := retval rol 4;
		end if;
		for i in 0 to value'length/4-1 loop
			if std_logic_vector(retval(4-1 downto 0))=space then
				if left='1' then
					retval := retval rol 4;
				else
					retval := retval ror 4;
				end if;
			elsif left='1' then
				retval := retval ror 4;
				exit;
			else
				exit;
			end if;
		end loop;

		return std_logic_vector(retval);
	end;

begin
	align <= align_bcd_f(value, left);
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity format_bcd is
	generic (
		dot   : std_logic_vector(4-1 downto 0) := x"b";
		plus  : std_logic_vector(4-1 downto 0) := x"c";
		minus : std_logic_vector(4-1 downto 0) := x"d";
		space : std_logic_vector(4-1 downto 0) := x"f";
		check : boolean := true);
		
	port (
		value    : in  std_logic_vector;
		zero     : in  std_logic := '0';
		point    : in  std_logic_vector;
		format   : out std_logic_vector);
end;
		
architecture def of format_bcd is

	impure function format_bcd_f (
		constant value : std_logic_vector;
		constant point : std_logic_vector;
		constant zero  : std_logic)
		return std_logic_vector is
		variable temp  : std_logic_vector(value'length-1 downto 0);
		variable digit : std_logic_vector(4-1 downto 0);
		variable aux   : std_logic_vector(4-1 downto 0);

	begin

		temp  := value;
		digit := dot;

		if point(point'left)='1' then

			for i in 0 to value'length/digit'length-1 loop
				if to_integer(signed(point))+i < 0 then
					temp := std_logic_vector(unsigned(temp) ror digit'length);
					if temp(digit'range)=space then
						temp(digit'range) := x"0";
					end if;
				end if;
			end loop;

			temp := std_logic_vector(unsigned(temp) rol digit'length);
			swap(digit, temp(digit'range));

			for i in 0 to value'length/digit'length-1 loop
				if to_integer(signed(point))+i < 0 then
					temp := std_logic_vector(unsigned(temp) rol digit'length);
					swap(digit, temp(digit'range));
				end if;
			end loop;

		else
			if check then
				if temp(digit'range)=x"0" then
					temp  := std_logic_vector(unsigned(temp) ror digit'length);
					digit := temp(digit'range);
					temp  := std_logic_vector(unsigned(temp) rol digit'length);
					if digit=space then
						return temp;
					end if;
				end if;
			end if;

			if zero /= '1' then
				for i in 0 to value'length/digit'length-1 loop
					if i < to_integer(signed(point)) then
						temp := std_logic_vector(unsigned(temp) rol digit'length);
						if temp(digit'range)=space then
							temp(digit'range) := x"0";
						end if;
					end if;
				end loop;
			end if;

		end if;

		return temp;
	end;

begin

	format <= format_bcd_f(value, point, zero);
		
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sign_bcd is
	generic (
		plus  : std_logic_vector(4-1 downto 0) := x"c";
		minus : std_logic_vector(4-1 downto 0) := x"d";
		space : std_logic_vector(4-1 downto 0) := x"f");
	port (
		value    : in  std_logic_vector;
		negative : in  std_logic := '0';
		sign     : in  std_logic;
		format   : out std_logic_vector);
end;
		
architecture def of sign_bcd is

	function sign_bcd_f (
		constant value : std_logic_vector;
		constant code  : std_logic_vector)
		return std_logic_vector is
		variable retval : unsigned(value'length-1 downto 0);
	begin
		retval := unsigned(value);
		for i in 0 to value'length/4-1 loop
			retval := retval rol 4;
			if std_logic_vector(retval(4-1 downto 0))/=space then
				retval := retval ror 4;
				retval(4-1 downto 0) := unsigned(code);
				if i=0 then
					retval := retval ror 4;
				else
					retval := retval ror (4*i);
				end if;
				exit;
			end if;
		end loop;

		return std_logic_vector(retval);
	end;

begin

	format <= 
		sign_bcd_f(value, minus) when negative='1' else 
		sign_bcd_f(value, plus)  when sign='1'     else
		value;

end;

