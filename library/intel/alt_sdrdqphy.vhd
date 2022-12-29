--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                         --
--    Miguel Angel Sagreras                                                   --
--                                                                            --
-- This source file may be used and distributed without restriction provided  --
-- that this copyright statement is not removed from the file and that any    --
-- derivative work contains  the original copyright notice and the associated --
-- disclaimer.                                                                --
--                                                                            --
-- This source file is free software; you can redistribute it and/or modify   --
-- it under the terms of the GNU General Public License as published by the   --
-- Free Software Foundation, either version 3 of the License, or (at your     --
-- option) any later version.                                                 --
--                                                                            --
-- This source is distributed in the hope that it will be useful, but WITHOUT --
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      --
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   --
-- more details at http://www.gnu.org/licenses/.                              --
--                                                                            --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.profiles.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

entity alt_sdrdqphy is
	generic (
		dqs_delay  : time := 1.65*1.25 ns;
		dqi_delay  : time := 1.65*1.25 ns;

		loopback   : boolean := false;
		bypass     : boolean := false;
		bufio      : boolean;
		device     : fpga_devices;
		taps       : natural;
		data_gear  : natural;
		data_edge  : boolean;
		byte_size  : natural);
	port (
		tp_sel     : in  std_logic := '-';
		tp_delay   : out std_logic_vector(1 to 8);

		rst        : in  std_logic;
		iod_clk    : in  std_logic;
		clk0       : in  std_logic := '-';
		clk90      : in  std_logic := '-';
		clk0x2     : in  std_logic := '-';
		clk90x2    : in  std_logic := '-';
		ctlr_clk   : in  std_logic := '-';

		parallelterminationcontrol : in	std_logic_vector (15 downto 0);
		seriesterminationcontrol   : in std_logic_vector (15 downto 0);
		dll_delayctrlout           : in  std_logic_vector (6 downto 0); 

		sys_wlreq  : in  std_logic := '-';
		sys_wlrdy  : out std_logic;

		sys_rlreq  : in  std_logic;
		sys_rlrdy  : buffer std_logic;
		read_rdy   : in  std_logic;
		read_req   : buffer std_logic;
		read_brst  : out std_logic;
		write_rdy  : in  std_logic;
		write_req  : buffer std_logic;

		sys_dmt    : in  std_logic_vector(data_gear-1 downto 0) := (others => '-');
		sys_sti    : in  std_logic_vector(data_gear-1 downto 0) := (others => '-');
		sys_sto    : out std_logic_vector(data_gear-1 downto 0);
		sys_dmi    : in  std_logic_vector(data_gear-1 downto 0) := (others => '-');
		sys_dqi    : in  std_logic_vector(data_gear*byte_size-1 downto 0);
		sys_dqt    : in  std_logic_vector(data_gear-1 downto 0);
		sys_dqo    : out std_logic_vector(data_gear*byte_size-1 downto 0);
		sys_dqsi   : in  std_logic_vector(data_gear-1 downto 0);
		sys_dqso   : buffer std_logic_vector(data_gear-1 downto 0);
		sys_dqst   : in  std_logic_vector(data_gear-1 downto 0);
		sto_synced : buffer std_logic;

		sdram_sti  : in  std_logic := '-';
		sdram_sto  : out std_logic;
		sdram_dm   : inout std_logic;
		sdram_dq   : inout std_logic_vector(byte_size-1 downto 0);
		sdram_dqs  : inout std_logic);

end;

architecture intel of alt_sdrdqphy is

	signal write_oe_in         : std_logic_vector(15 downto 0);
	signal lfifo_rdata_en_full : std_logic_vector( 1 downto 0);
	signal lfifo_rd_latency    : std_logic_vector( 4 downto 0);
	signal vfifo_inc_wr_ptr    : std_logic_vector( 1 downto 0);
	signal dqso                : std_logic;

	component altdq_dqs2_acv_cyclonev
		generic (
			PIN_WIDTH                       : natural :=  8;
			PIN_TYPE                        : string  := "bidir";
			USE_INPUT_PHASE_ALIGNMENT       : string  :=  "false";
			USE_OUTPUT_PHASE_ALIGNMENT      : string  :=  "false";
			USE_LDC_AS_LOW_SKEW_CLOCK       : string  :=  "false";
			USE_HALF_RATE_INPUT             : string  :=  "false";
			USE_HALF_RATE_OUTPUT            : string  :=  "true";
			DIFFERENTIAL_CAPTURE_STROBE     : string  :=  "false";
			SEPARATE_CAPTURE_STROBE         : string  :=  "false";
			INPUT_FREQ                      : real    :=  300.0;
			INPUT_FREQ_PS                   : string  :=  "3333 ps";
			DELAY_CHAIN_BUFFER_MODE         : string  :=  "high";
			DQS_PHASE_SETTING               : natural :=  0;
			DQS_PHASE_SHIFT                 : natural :=  0;
			DQS_ENABLE_PHASE_SETTING        : natural :=  0;
			USE_DYNAMIC_CONFIG              : string  :=  "false";
			INVERT_CAPTURE_STROBE           : string  :=  "true";
			SWAP_CAPTURE_STROBE_POLARITY    : string  :=  "false";
			USE_TERMINATION_CONTROL         : string  :=  "true";
			USE_DQS_ENABLE                  : string  :=  "false";
			USE_OUTPUT_STROBE               : string  :=  "true";
			USE_OUTPUT_STROBE_RESET         : string  :=  "false";
			DIFFERENTIAL_OUTPUT_STROBE      : string  :=  "false";
			USE_BIDIR_STROBE                : string  :=  "true";
			REVERSE_READ_WORDS              : string  :=  "false";
			EXTRA_OUTPUT_WIDTH              : natural :=  1;
			DYNAMIC_MODE                    : string  :=  "false";
			OCT_SERIES_TERM_CONTROL_WIDTH   : natural :=  16; 
			OCT_PARALLEL_TERM_CONTROL_WIDTH : natural :=  16; 
			DLL_WIDTH                       : natural :=  7;
			USE_DATA_OE_FOR_OCT             : string  :=  "true";
			DQS_ENABLE_WIDTH                : natural :=  2;
			USE_OCT_ENA_IN_FOR_OCT          : string  :=  "false";
			PREAMBLE_TYPE                   : string  :=  "high";
			EMIF_UNALIGNED_PREAMBLE_SUPPORT : string  :=  "false";
			EMIF_BYPASS_OCT_DDIO            : string  :=  "false";
			USE_OFFSET_CTRL                 : string  :=  "false";
			HR_DDIO_OUT_HAS_THREE_REGS      : string  :=  "false";
			DQS_ENABLE_PHASECTRL            : string  :=  "false";
			USE_2X_FF                       : string  :=  "false";
			DLL_USE_2X_CLK                  : string  :=  "false";
			USE_DQS_TRACKING                : string  :=  "false";
			USE_HARD_FIFOS                  : string  :=  "true";
			USE_DQSIN_FOR_VFIFO_READ        : string  :=  "false";
			CALIBRATION_SUPPORT             : string  :=  "false";
			NATURAL_ALIGNMENT               : string  :=  "false";
			SEPERATE_LDC_FOR_WRITE_STROBE   : string  :=  "false";
			HHP_HPS                         : string  :=  "false");
		port (

			core_clock_in          : in  std_logic := '0';
			reset_n_core_clock_in  : in  std_logic := '0';
			fr_clock_in            : in  std_logic := '0';
			hr_clock_in            : in  std_logic := '0';
			write_strobe_clock_in  : in  std_logic := '0';
			read_write_data_io     : inout std_logic_vector(PIN_WIDTH-1 downto 0) := (others => '0');
			write_oe_in            : in    std_logic_vector(2*PIN_WIDTH-1 downto 0)      := (others => '1');
			strobe_io              : inout std_logic := '0';
			output_strobe_ena      : in  std_logic_vector(2-1 downto 0) := (others => '0');
			read_data_out          : out std_logic_vector(2*2*PIN_WIDTH-1 downto 0);
			capture_strobe_ena     : in std_logic_vector(DQS_ENABLE_WIDTH-1 downto 0) := (others => '1');
			capture_strobe_out     : out std_logic;
			write_data_in          : in  std_logic_vector(2*2*PIN_WIDTH-1 downto 0);
			extra_write_data_in    : in  std_logic_vector(2*2*EXTRA_OUTPUT_WIDTH-1 downto 0) := (others => '0');
			extra_write_data_out   : out std_logic_vector(EXTRA_OUTPUT_WIDTH-1 downto 0);
			parallelterminationcontrol_in : in std_logic_vector(OCT_SERIES_TERM_CONTROL_WIDTH-1 downto 0);
			seriesterminationcontrol_in   : in std_logic_vector(OCT_SERIES_TERM_CONTROL_WIDTH-1 downto 0);
			lfifo_rdata_en         : in  std_logic_vector(2-1 downto 0) := (others => '0');
			lfifo_rdata_en_full    : in  std_logic_vector(2-1 downto 0) := (others => '0');
			lfifo_rd_latency       : in  std_logic_vector(5-1 downto 0) := (others => '0');
			lfifo_reset_n          : in  std_logic := '0';
			lfifo_rdata_valid      : out std_logic;
			vfifo_qvld             : in  std_logic_vector(2-1 downto 0);
			vfifo_inc_wr_ptr       : in  std_logic_vector(2-1 downto 0);
			vfifo_reset_n          : in  std_logic := '0';
			rfifo_reset_n          : in  std_logic := '0';
			dll_delayctrl_in       : in  std_logic_vector(DLL_WIDTH-1 downto 0));
	end component;
   
begin

	sys_wlrdy <= sys_wlreq;
	sys_rlrdy <= sys_rlreq;
	read_req  <= read_rdy;
	write_req <= write_rdy;

	lfifo_rdata_en_full <= (others => sys_sti(1));
	write_oe_in         <= (others => sys_dqt(0));
	lfifo_rd_latency    <= (others => sys_sti(1));
	vfifo_inc_wr_ptr    <= (others => sys_sti(1));

	altdq_dqs2_i : altdq_dqs2_acv_cyclonev
	generic map (
		PIN_WIDTH                       => 8,
		PIN_TYPE                        =>"bidir",
		USE_INPUT_PHASE_ALIGNMENT       => "false",
		USE_OUTPUT_PHASE_ALIGNMENT      => "false",
		USE_LDC_AS_LOW_SKEW_CLOCK       => "false",
		USE_HALF_RATE_INPUT             => "false",
		USE_HALF_RATE_OUTPUT            => "true",
		DIFFERENTIAL_CAPTURE_STROBE     => "false",
		SEPARATE_CAPTURE_STROBE         => "false",
		INPUT_FREQ                      => 300.0,
		INPUT_FREQ_PS                   => "3333 ps",
		DELAY_CHAIN_BUFFER_MODE         => "high",
		DQS_PHASE_SETTING               => 0,
		DQS_PHASE_SHIFT                 => 0,
		DQS_ENABLE_PHASE_SETTING        => 0,
		USE_DYNAMIC_CONFIG              => "false",
		INVERT_CAPTURE_STROBE           => "true",
		SWAP_CAPTURE_STROBE_POLARITY    => "false",
		USE_TERMINATION_CONTROL         => "true",
		USE_DQS_ENABLE                  => "false",
		USE_OUTPUT_STROBE               => "true",
		USE_OUTPUT_STROBE_RESET         => "false",
		DIFFERENTIAL_OUTPUT_STROBE      => "false",
		USE_BIDIR_STROBE                => "true",
		REVERSE_READ_WORDS              => "false",
		EXTRA_OUTPUT_WIDTH              => 1,
		DYNAMIC_MODE                    => "false",
		OCT_SERIES_TERM_CONTROL_WIDTH   => 16, 
		OCT_PARALLEL_TERM_CONTROL_WIDTH => 16, 
		DLL_WIDTH                       => 7,
		USE_DATA_OE_FOR_OCT             => "true",
		DQS_ENABLE_WIDTH                => 1,
		USE_OCT_ENA_IN_FOR_OCT          => "false",
		PREAMBLE_TYPE                   => "high",
		EMIF_UNALIGNED_PREAMBLE_SUPPORT => "false",
		EMIF_BYPASS_OCT_DDIO            => "false",
		USE_OFFSET_CTRL                 => "false",
		HR_DDIO_OUT_HAS_THREE_REGS      => "false",
		DQS_ENABLE_PHASECTRL            => "false",
		USE_2X_FF                       => "false",
		DLL_USE_2X_CLK                  => "false",
		USE_DQS_TRACKING                => "false",
		USE_HARD_FIFOS                  => "true",
		USE_DQSIN_FOR_VFIFO_READ        => "false",
		CALIBRATION_SUPPORT             => "false",
		NATURAL_ALIGNMENT               => "false",
		SEPERATE_LDC_FOR_WRITE_STROBE   => "false",
		HHP_HPS                         => "false")
	port map (
		strobe_io                     => sdram_dqs,
		extra_write_data_out(0)       => sdram_dm,
		read_write_data_io            => sdram_dq,
		write_strobe_clock_in         => clk0x2,
		extra_write_data_in           => sys_dmi,
		write_data_in                 => sys_dqi,
		write_oe_in                   => write_oe_in,
		output_strobe_ena             => lfifo_rdata_en_full,
		parallelterminationcontrol_in => parallelterminationcontrol,
		seriesterminationcontrol_in   => seriesterminationcontrol,
		dll_delayctrl_in              => dll_delayctrlout,
		fr_clock_in                   => clk0x2,
		hr_clock_in                   => clk0,
		read_data_out                 => sys_dqo,
		lfifo_rdata_en_full           => lfifo_rdata_en_full,
		lfifo_rd_latency              => lfifo_rd_latency,
		vfifo_qvld                    => lfifo_rdata_en_full,
		vfifo_inc_wr_ptr              => vfifo_inc_wr_ptr);
   
	sys_dqso <= (others => ctlr_clk);
	sys_sto  <= sys_sti;

end;