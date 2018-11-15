library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity ftod is
	generic (
		size    : natural := 4);
	port (
		clk      : in  std_logic;
		bin_frm  : in  std_logic;
		bin_irdy : in  std_logic := '1';
		bin_trdy : out std_logic;
		bin_flt  : in  std_logic := '0';
		bin_exp  : in  std_logic_vector;
		bin_di   : in  std_logic_vector;

		bcd_do   : out std_logic_vector);
end;

architecture def of ftod is

	constant up : std_logic := '0';
	constant dn : std_logic := '1';

	signal vector_rst   : std_logic;
	signal vector_full  : std_logic;
	signal vector_left  : std_logic_vector(size-1 downto 0);
	signal vector_right : std_logic_vector(size-1 downto 0);
	signal vector_addr  : std_logic_vector(size-1 downto 0);
	signal vector_do    : std_logic_vector(bcd_do'range);
	signal vector_di    : std_logic_vector(vector_do'range);
	signal left_updn    : std_logic;
	signal left_ena     : std_logic;
	signal right_updn   : std_logic;
	signal right_ena    : std_logic;

	signal btod_ena     : std_logic;
	signal btod_cnv     : std_logic;
	signal btod_ini     : std_logic;
	signal btod_dcy     : std_logic;
	signal btod_bdv     : std_logic;
	signal btod_ddi     : std_logic_vector(bcd_do'range);
	signal btod_ddo     : std_logic_vector(bcd_do'range);
	signal btod_trdy    : std_logic;

	signal dtof_ena     : std_logic;
	signal dtof_dcy     : std_logic;
	signal dtof_do      : std_logic_vector(bcd_do'range);
	signal unit_sel     : std_logic;
begin

	unitsel_p : process (clk)
	begin
		if rising_edge(clk) then
			if bin_irdy='1' then
				if btod_cnv='0' then
					unit_sel <= bin_flt;
				elsif btod_dcy='0' then
					unit_sel <= bin_flt;
				end if;
			end if;
		end if;
	end process;

	btod_ddi_p : process(clk)
	begin
		if rising_edge(clk) then
			if bin_frm='0' then
				btod_ini <= '1';
			elsif btod_ena='1' then
				if vector_addr=vector_left(vector_addr'range) then
					if btod_dcy='1' then
						btod_ini <= '1';
					else
						btod_ini <= '0';
					end if;
				end if;
			end if;
		end if;
	end process;

	btodcnv_p : process(clk)
	begin
		if rising_edge(clk) then
			if bin_frm='0' then
				btod_cnv <= '0';
			elsif btod_cnv='0' then
				if btod_dcy='1' then
					btod_cnv <= bin_irdy;
				end if;
			else
				btod_cnv <= btod_dcy;
			end if;
		end if;
	end process;

	btod_ena  <= bin_irdy or      btod_cnv;
	btod_bdv  <= bin_irdy and not btod_cnv;
	btod_trdy <= (not btod_dcy and btod_ena) and bin_frm;
	btod_ddi  <= (btod_ddi'range => '0') when btod_ini='1' else vector_do;

	btod_e : entity hdl4fpga.btod
	port map (
		clk     => clk,
		bin_dv  => btod_bdv,
		bin_ena => btod_ena,
		bin_di  => bin_di,

		bcd_di  => btod_ddi,
		bcd_do  => btod_ddo,
		bcd_cy  => btod_dcy);

	addr_p : process(clk)
	begin
		if rising_edge(clk) then
			if bin_frm='0' then
				vector_addr <= (others => '0');
			else
				if unit_sel='0' then
					if btod_ena='1' then
						if vector_addr = vector_left(vector_addr'range) then
							if btod_dcy='1' then
								vector_addr <= std_logic_vector(unsigned(vector_addr) + 1);
							else
								vector_addr <= vector_right(vector_addr'range);
							end if;
						else
							vector_addr <= std_logic_vector(unsigned(vector_addr) + 1);
						end if;
					end if;
				else
					if dtof_ena='1' then
						if vector_addr = vector_right(vector_addr'range) then
							if dtof_dcy='1' then
	--							vector_addr <= std_logic_vector(unsigned(vector_addr) - 1);
								vector_addr <= vector_left(vector_addr'range);
							else
								vector_addr <= vector_left(vector_addr'range);
							end if;
						else
							vector_addr <= std_logic_vector(unsigned(vector_addr) - 1);
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;

	left_p : process(
		vector_addr, 
		vector_left,
		vector_di,
	   	unit_sel, 
		btod_dcy,
		dtof_dcy)
	begin
		left_updn <= '-';
		left_ena  <= '0';
		if unit_sel='0' then
			if vector_addr=vector_left(vector_addr'range) then
				if btod_dcy='1' then
					left_updn <= up;
					left_ena  <= '1';
				end if;
			end if;
		else
			if vector_addr=vector_left(vector_addr'range) then
				if vector_di=(vector_di'range => '0') then
					left_updn <= dn;
					left_ena  <= '1';
				end if;
			end if;
		end if;
	end process;

	right_p : process(
		vector_addr, 
		vector_left,
		vector_right,
	   	unit_sel, 
		btod_dcy,
		dtof_dcy)
	begin
		right_updn <= '-';
		right_ena  <= '0';
		if unit_sel='0' then
			if vector_full='1' then
				if btod_dcy='1' then
					right_updn <= up;
					right_ena  <= '1';
				end if;
			end if;
		else
			if vector_full='0' then
				if dtof_dcy='1' then
					right_updn <= dn;
					right_ena  <= '1';
				end if;
			end if;
		end if;
	end process;

	vector_rst <= not bin_frm;
	vector_di  <= btod_ddo when unit_sel='0' else dtof_do;
	vector_e : entity hdl4fpga.vector
	port map (
		vector_clk   => clk,
		vector_rst   => vector_rst,
		vector_ena   => btod_ena,
		vector_addr  => std_logic_vector(vector_addr),
		vector_full  => vector_full,
		vector_di    => vector_di,
		vector_do    => vector_do,
		left_ena     => left_ena,
		left_updn    => left_updn,
		vector_left  => vector_left,
		right_ena    => right_ena,
		right_updn   => right_updn,
		vector_right => vector_right);
	bcd_do <= btod_ddo;
	bin_trdy <= btod_trdy;
end;
