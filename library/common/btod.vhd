library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dtof is
	port (
		clk     : in  std_logic := '0';
		point   : in  std_logic_vector;
		bcd_ena : in  std_logic := '1';
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

	signal shtio_d : unsigned(2**point'length-1 downto 0);
	signal shtio_q : unsigned(2**point'length-1 downto 0);

begin

	reg_p : process (clk)
	begin
		if rising_edge(clk) then
			shtio_q <= shtio_d;
		end if;
	end process;

	process (bcd_di, bcd_ena, shtio_q)
		variable tmp_value : unsigned(bcd_di'length-1 downto 0);
		variable tmp_shtio : unsigned(2**point'length-1 downto 0);
		variable carry     : std_logic;
	begin
		tmp_value := unsigned(bcd_di);
		if bcd_ena='1' then
			tmp_shtio := (others => '0');
		else
			tmp_shtio := shtio_q;
		end if;

		carry := '0';
		for k in 0 to 2**point'length-1 loop
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

entity btod is
	port (
		clk    : in  std_logic := '0';

		bin_dv : in  std_logic;
		bin_di : in  std_logic_vector;

		bcd_dv : in  std_logic := '1';
		bcd_di : in  std_logic_vector;
		bcd_do : out std_logic_vector;
		bcd_cy : out std_logic);
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
			shtio_q <= shtio_d;
		end if;
	end process;

	comb_p : process (bin_dv, bin_di, bcd_dv, bcd_di, shtio_q)
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
	bcd_cy <= '1' when shtio_d /= (shtio_d'range => '0') else '0';

end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity ftod is
	port (
		clk     : in  std_logic;
		bin_ena : in  std_logic;
		bin_dv  : out std_logic;
		bin_fix : in  std_logic := '0';
		bin_di  : in  std_logic_vector;

		bcd_lst : out std_logic;
		bcd_do  : out std_logic_vector);
end;

architecture def of ftod is

	signal cntr_ple : std_logic;
	signal cntr_rst : std_logic;
	signal cntr     : unsigned(0 to 4);
	signal right    : unsigned(1 to cntr'right);
	signal left     : unsigned(1 to cntr'right);

	signal mem_ptr  : unsigned(1 to cntr'right);
	signal mem_full : std_logic;
	signal rd_data  : std_logic_vector(bcd_do'range);
	signal wr_data  : std_logic_vector(bcd_do'range);

	signal bcd_dv   : std_logic;
	signal bcd_di   : std_logic_vector(bcd_do'range);
	signal btod_do  : std_logic_vector(bcd_do'range);
	signal btod_dv  : std_logic;

	signal dtof_ena : std_logic;
	signal dtof_do  : std_logic_vector(bcd_do'range);

	signal btod_cy  : std_logic;
	signal dtof_cy  : std_logic;
	signal carry    : std_logic;

	signal fix      : std_logic;
begin

	mem_full <= setif(right+left=(right'range =>'1'));
	carry    <= btod_cy when bin_fix='0' else dtof_cy;
	cntr_rst <= not bin_ena;
	cntr_ple <= '1' when mem_full='1' else not carry;
		
	cntr_p : process (clk)
	begin
		if rising_edge(clk) then
			if cntr_rst='1' then
				cntr <= (others => '1');
			elsif cntr(0)='1'then
				if cntr_ple='1' then
					cntr <= resize(right+left, cntr'length)-1;
				end if;
			else
				cntr <= cntr - 1;
			end if;
		end if;
	end process;

	right_p : process(clk)
		variable zero : boolean;
	begin
		if rising_edge(clk) then
			if bin_ena='0' then
				zero  := TRUE;
				right <= (others => '0');
			elsif bin_fix='0' then
				zero  := TRUE;
				if cntr(0)='1' then
					if btod_cy='1' then
						right <= right + 1;
					end if;
				end if;
			else
				if cntr(0)='1' then
					zero  := TRUE;
				elsif wr_data/=(wr_data'range => '0') then
					zero  := FALSE;
				elsif zero then
					right <= right - 1;
				end if;
			end if;
		end if;
	end process;

	left_p : process(clk)
	begin
		if rising_edge(clk) then
			if bin_ena='0' then
				left  <= (others => '0');
			elsif bin_fix='1' then
				if cntr(0)='1' then
					if dtof_cy='1' then
						if mem_full='0' then
							left <= left  + 1 ;
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;

	process (clk)
	begin
		if rising_edge(clk) then
			if bin_ena='0' then
				bcd_dv    <= '1';
				btod_dv   <= '1';
			elsif cntr(0)='1' then
				if mem_full='0' and carry='1' then
					btod_dv <= '0';
					bcd_dv  <= '1';
				else
					btod_dv  <= '1';
					bcd_dv   <= '0';
				end if;
			else
				bcd_dv  <= '0';
				btod_dv <= '0';
			end if;
			fix <= bin_fix;
		end if;
	end process;

	bin_dv  <= btod_dv;
	bcd_lst <= cntr(0) and not (carry and not mem_full);
	bcd_di  <= (bcd_di'range => '0') when bcd_dv='1' else rd_data;

	btod_e : entity hdl4fpga.btod
	port map (
		clk    => clk,
		bin_dv => btod_dv,
		bin_di => bin_di,

		bcd_dv => '1',
		bcd_di => bcd_di,
		bcd_do => btod_do,
		bcd_cy => btod_cy);

	process (clk, fix)
		variable ena : std_logic;
	begin
		if rising_edge(clk) then
			if mem_full='0' then
				ena := cntr(0) and not dtof_cy;
			else
				ena := cntr(0);
			end if;
		end if;
		dtof_ena <= fix and ena;
	end process;

	dtof_e : entity hdl4fpga.dtof
	port map (
		clk     => clk,
		bcd_ena => dtof_ena,
		point   => b"1",
		bcd_di  => bcd_di,
		bcd_do  => dtof_do,
		bcd_cy  => dtof_cy);

	wr_data <= btod_do when fix='0' else dtof_do;
   		
	mem_ptr <=
		right + not cntr(mem_ptr'range) when fix='0' else
		0-not cntr(mem_ptr'range)-left;

	ram_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => clk,
		wr_ena  => bin_ena,
		wr_addr => std_logic_vector(mem_ptr),
		wr_data => wr_data,
		rd_addr => std_logic_vector(mem_ptr),
		rd_data => rd_data);

	bcd_do <= wr_data;

end;
