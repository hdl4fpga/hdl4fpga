library ieee;
use ieee.std_logic_1164.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity dataio is
	generic (
		page_size : natural := 9;
		bank_size : natural := 2;
		addr_size : natural := 13;
		col_size  : natural := 6;
		data_size : natural := 16);
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
		ddrs_ref_req : in std_logic;
		ddrs_cmd_req : out std_logic;
		ddrs_cmd_rdy : in std_logic;
		ddrs_ba  : out std_logic_vector;
		ddrs_a   : out std_logic_vector;
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
		miitx_data : out std_logic_vector(2*data_size-1 downto 0);
		tp : out nibble_vector(0 to 7-1));
		
	constant page_num  : natural := 6;
end;


architecture def of dataio is
	subtype aword is std_logic_vector(bank_size+1+addr_size+1+col_size+1-1 downto 0);

	signal capture_rdy : std_logic;
	signal ddrios_addr : aword;

	signal datai_brst_req : std_logic;
	signal datao_brst_req : std_logic;
	signal ddr2video_brst_req : std_logic;
	signal ddr2miitx_brst_req : std_logic;

	signal datai_req : std_logic;

	signal ddrios_ini : std_logic;
	signal ddrios_eoc : std_logic;
	signal ddrios_brst_req : std_logic;

	signal vsync_erq : std_logic;
	signal hsync_erq : std_logic;

	signal buff_ini  : std_logic;

	signal video_page : std_logic_vector(0 to 3-1);
	signal video_off  : std_logic_vector(0 to page_num*page_size-1);
	signal video_di   : std_logic_vector(0 to page_num*2*data_size-1);

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

	ddrios_ini <= 
		'1' when sys_rst='1' else
		'1' when input_req='0' else
		ddrios_eoc when capture_rdy='0' else
		buff_ini or ddrios_eoc when false else
		ddrios_eoc;

	process (ddrs_clk)
	begin
		if rising_edge(ddrs_clk) then
			if sys_rst='1' then
				capture_rdy <= '0';
			elsif input_req='0' then
				capture_rdy <= '0';
			elsif capture_rdy='0' then
				capture_rdy <= ddrios_eoc;
			else
				capture_rdy <= '1';
			end if;
		end if;
	end process;

	process (ddrs_clk)
		type aword_vector is array (natural range <>) of aword;
		constant addr : aword_vector(0 to 1) := (
			0 => '0' & to_unsigned(4-1, bank_size) &	-- bank address
			     '0' & to_unsigned(2**addr_size-1, addr_size) &	-- row  address
			     '0' & to_unsigned(2**col_size-1, col_size),
--  		0 => '0' & to_unsigned(0, bank_size) &	-- bank address
--  		     '0' & to_unsigned(0, addr_size) &	-- row  address
--  		     '0' & to_unsigned(2**col_size-1, col_size),
  			1 => '0' & to_unsigned(4-1, bank_size) &
  			     '0' & to_unsigned(2**addr_size-1, addr_size) &
  			     '0' & to_unsigned(2**col_size-1, col_size));
--			1 => '0' & to_unsigned(0, bank_size) &
--			     '0' & to_unsigned(0, addr_size) &
--			     '0' & to_unsigned(2**col_size-1, col_size));
	begin
		if rising_edge(ddrs_clk) then
			case input_req is
			when '0' =>
				ddrios_addr <= addr(0);
			when others =>
				ddrios_addr <= addr(1);
			end case;
		end if;
	end process;

	with capture_rdy select
	ddrios_brst_req <= 
		datai_brst_req when '0',
		datao_brst_req when others;

	with std_logic'('0') select
	datao_brst_req <=
		ddr2video_brst_req when '1',
		ddr2miitx_brst_req when others;

	ddrio_e : entity hdl4fpga.ddrio
	generic map (
		bank_size => bank_size,
		addr_size => addr_size,
		col_size  => col_size)
	port map (
		tp => tp,
		sys_clk => ddrs_clk,
		sys_ini => ddrios_ini,
		sys_eoc => ddrios_eoc,

		sys_addr => ddrios_addr,
		sys_brst_req => ddrios_brst_req,
					 
		ddrs_ref_req => ddrs_ref_req,
		ddrs_cmd_req => ddrs_cmd_req,
		ddrs_cmd_rdy => ddrs_cmd_rdy,
		ddrs_ba  => ddrs_ba,
		ddrs_a   => ddrs_a,
		ddrs_act => ddrs_act,
		ddrs_cas => ddrs_cas,
		ddrs_pre => ddrs_pre);

	process (video_clk)
	begin
		if rising_edge(video_clk) then
			vsync_erq <= video_ena;
			hsync_erq <= vsync_erq and video_row(video_row'right) and video_ena;
		end if;
	end process;

	ddr2video_e : entity hdl4fpga.ddr2video
	port map (
		ddrios_clk => ddrs_clk,
		ddrios_brst_req => ddr2video_brst_req,
		vsync_erq => vsync_erq, --video_ena,
		hsync_erq => hsync_erq, --video_row(video_row'right),

		ddrios_rd => capture_rdy,
		buff_ini  => buff_ini,

		page_addr => video_page);

	videomem_e : entity hdl4fpga.videomem
	generic map (
		bram_num  => page_num,
		bram_size => page_size,
		data_size => 2*data_size)
	port map (
		ddrs_clk => ddrs_clk,
		ddrs_di_rdy => ddrs_do_rdy,
		ddrs_di  => ddrs_do,
		buff_ini => sys_rst,  --buff_ini,
		page_addr => video_page,

		output_clk  => video_clk,
		output_addr => video_off,
		output_data => video_di);

	mem2vio_e : entity hdl4fpga.mem2vio
	generic map (
		page_num  => page_num,
		page_size => page_size,
		data_size => data_size)
	port map (
		video_clk => video_clk,
		mem_addr  => video_off,
		mem_di    => video_di,

		video_col => video_col,
		video_row => video_row,
		video_do  => video_do);

	ddr2miitx_e : entity hdl4fpga.ddr2miitx
	port map (
		ddrios_clk => ddrs_clk,
		ddrios_gnt => capture_rdy,
		ddrios_a0  => miitx_a0,
		ddrios_brst_req => ddr2miitx_brst_req,

		miitx_rdy  => miitx_rdy,
		miitx_req  => miitx_req);

	miitxmem_e : entity hdl4fpga.miitxmem
	generic map (
		bram_size => page_size,
		data_size => 2*data_size)
	port map (
		ddrs_clk => ddrs_clk,
		ddrs_gnt => capture_rdy,
		ddrs_di_rdy => ddrs_do_rdy,
		ddrs_di => ddrs_do,

		output_clk  => mii_txc,
		output_a0   => miitx_a0,
		output_addr => miitx_addr,
		output_data => miitx_data);
end;
