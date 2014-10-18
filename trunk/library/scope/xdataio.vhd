library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity dataio is
	generic (
		PAGE_SIZE    : natural :=  9;
		DDR_BANKSIZE : natural :=  2;
		DDR_ADDRSIZE : natural := 13;
		DDR_CLNMSIZE : natural :=  6;
		DDR_LINESIZE : natural := 16);
	port (
		sys_rst   : in std_logic;

		input_clk : in std_logic;
		input_req : in std_logic;
		input_rdy : out std_logic;
		input_dat : in std_logic_vector;

		video_clk : in  std_logic;
		video_ena : in  std_logic;
		video_row : in  std_logic_vector;
		video_col : in  std_logic_vector;
		video_do  : out std_logic_vector;

		ddrs_clk : in  std_logic;
		ddrs_rreq : in std_logic;
		ddrs_creq : out std_logic;
		ddrs_crdy : in std_logic;

		ddrs_bnka : out std_logic_vector(DDR_BANKSIZE-1 downto 0);
		ddrs_rowa : out std_logic_vector(DDR_ADDRSIZE-1 downto 0);
		ddrs_cola : out std_logic_vector(DDR_ADDRSIZE-1 downto 0);

		ddrs_act : in std_logic;
		ddrs_cas : in std_logic;
		ddrs_pre : in std_logic;
		ddrs_rw  : out std_logic;

		ddrs_di_rdy : in std_logic;
		ddrs_di  : out  std_logic_vector;
		ddrs_do_rdy : in std_logic;
		ddrs_do  : in std_logic_vector;
		
		mii_txc : in std_logic;
		miitx_req  : out std_logic;
		miitx_rdy  : in std_logic;
		mii_a0   : out std_logic;
		miitx_addr : in  std_logic_vector;
		miitx_data : out std_logic_vector(DDR_LINESIZE-1 downto 0));
		
	constant page_num  : natural := 6;
end;


architecture def of dataio is
	subtype aword is std_logic_vector(DDR_BANKSIZE+1+DDR_ADDRSIZE+1+DDR_CLNMSIZE+1-1 downto 0);

	signal capture_rdy : std_logic;
	signal ddrios_addr : aword;

	signal datai_brst_req : std_logic;
	signal datao_brst_req : std_logic;
	signal ddr2video_brst_req : std_logic;
	signal ddr2miitx_brst_req : std_logic;

	signal datai_req : std_logic;

	signal ddrios_brst_req : std_logic;

	signal vsync_erq : std_logic;
	signal hsync_erq : std_logic;

	signal buff_ini  : std_logic;

	signal video_page : std_logic_vector(0 to 3-1);
	signal video_off  : std_logic_vector(0 to page_num*page_size-1);
	signal video_di   : std_logic_vector(0 to page_num*2*DDR_LINESIZE-1);

	signal miitx_a0 : std_logic;

begin

	mii_a0 <= miitx_a0;
	datai_e : entity hdl4fpga.datai
	port map (
		input_clk => input_clk,
		input_dat => input_dat,
		input_req => datai_req, 

		output_clk => ddrs_clk,
		output_rdy => datai_brst_req,
		output_req => ddrs_di_rdy,
		output_dat => ddrs_di);

	input_rdy <= capture_rdy;
	ddrs_rw   <= capture_rdy;
	datai_req <= not sys_rst and not capture_rdy;

	ddrio_b: block
		signal ddrs_breq : std_logic;
		signal ddrs_addr : std_logic_vector(DDR_BANKSIZE+1+DDR_ADDRSIZE+1+DDR_CLNMSIZE downto 0);

		signal qo : std_logic_vector(DDR_BANKSIZE+1+DDR_ADDRSIZE+1+DDR_CLNMSIZE downto 0);
		signal co : std_logic_vector(0 to 3-1);

		function pencoder (
			constant arg : std_logic_vector)
			return natural is
		begin
			for i in arg'range loop
				if arg(i)='1' then
					return i;
				end if;
			end loop;
			return arg'right;
		end;
	begin

		process (ddrs_clk)
		begin
			if rising_edge(ddrs_clk) then
				if sys_rst='1' then
					capture_rdy <= '0';
				elsif input_req='0' then
					capture_rdy <= '0';
				elsif capture_rdy='0' then
					capture_rdy <= co(0);
				else
					capture_rdy <= '1';
				end if;
			end if;
		end process;

--		ddrios_cid <= to_integer(pencoder(ddrios_reg), unsigned_num_bits(ddrios_reg'length));
--		ddrios_c <= mux (
--			i => 
--				to_signed(4-1, DDR_BANKSIZE+1) & to_signed(2**DDR_ADDRSIZE-1, DDR_ADDRSIZE+1) & to_signed(2**DDR_CLNMSIZE-1, DDR_CLNMSIZE+1) &
--				to_signed(4-1, DDR_BANKSIZE+1) & to_signed(2**DDR_ADDRSIZE-1, DDR_ADDRSIZE+1) & to_signed(2**DDR_CLNMSIZE-1, DDR_CLNMSIZE+1),
--			s => ddrios_id);
		ddrs_breq <= datai_brst_req;

		ddrs_addr <= std_logic_vector(to_signed(4-1, DDR_BANKSIZE+1) & to_signed(2**DDR_ADDRSIZE-1, DDR_ADDRSIZE+1) & to_signed(2**DDR_CLNMSIZE-1, DDR_CLNMSIZE+1));
		process (ddrs_clk)
		begin
			if rising_edge(ddrs_clk) then
				if sys_rst='1'then
					ddrs_creq <= '0';
				elsif ddrs_breq='1' then
					ddrs_creq <= (ddrs_crdy or not ddrs_rreq) and not qo(DDR_CLNMSIZE);
				else
					ddrs_creq <= '0';
				end if;
			end if;
		end process;

		ddrs_bnka <= std_logic_vector(resize(shift_right(unsigned(qo),1+DDR_ADDRSIZE+1+DDR_CLNMSIZE), DDR_BANKSIZE)); 
		ddrs_rowa <= std_logic_vector(resize(shift_right(unsigned(qo),1+DDR_CLNMSIZE), DDR_ADDRSIZE)); 
		ddrs_cola <= std_logic_vector(resize(shift_left (unsigned(qo),  DDR_ADDRSIZE-DDR_CLNMSIZE), DDR_ADDRSIZE)); 

		dcounter_e : entity hdl4fpga.counter
		generic map (
			stage_size => (
				2 => DDR_BANKSIZE+1+DDR_ADDRSIZE+1+DDR_CLNMSIZE+1,
				1 => DDR_ADDRSIZE+1+DDR_CLNMSIZE+1,
				0 => DDR_CLNMSIZE+1))
		port map (
			clk  => ddrs_clk,
			load => sys_rst,
			ena  => ddrs_cas,
			data => ddrs_addr,
			qo   => qo,
			co   => co);
						 
	end block;

	ddr2miitx_e : entity hdl4fpga.ddr2miitx
	port map (
		ddrios_clk => ddrs_clk,
		ddrios_gnt => capture_rdy,
		ddrios_a0  => miitx_a0,
		ddrios_brst_req => ddr2miitx_brst_req,

		miitx_rdy  => miitx_rdy,
		miitx_req  => miitx_req);

--	miitxmem_e : entity hdl4fpga.miitxmem
--	generic map (
--		bram_size => page_size,
--		data_size => DDR_LINESIZE)
--	port map (
--		ddrs_clk => ddrs_clk,
--		ddrs_gnt => capture_rdy,
--		ddrs_di_rdy => ddrs_do_rdy,
--		ddrs_di => ddrs_do,
--
--		output_clk  => mii_txc,
--		output_a0   => miitx_a0,
--		output_addr => miitx_addr,
--		output_data => miitx_data);
end;
