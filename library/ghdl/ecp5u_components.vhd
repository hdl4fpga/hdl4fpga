library ieee; 
use ieee.std_logic_1164.all; 

package components is 
	component fd1p3ax
			generic (gsr : string := "enabled");
		port ( 
		d : in std_logic := 'X';
		sp: in std_logic := 'X';
		ck: in std_logic := 'X';
		q : out std_logic := 'X'
	  );
	end component;
	 
	component fd1p3ay
			generic (gsr : string := "enabled");
		port ( 
		d : in std_logic := 'X';
		sp: in std_logic := 'X';
		ck: in std_logic := 'X';
		q : out std_logic := 'X'
	  );
	end component;
	 
	component fd1p3bx
			generic (gsr : string := "enabled");
		port ( 
		d : in std_logic := 'X';
		sp: in std_logic := 'X';
		ck: in std_logic := 'X';
		pd: in std_logic := 'X';
		q : out std_logic := 'X'
	  );
	end component;
	 
	component fd1p3dx
			generic (gsr : string := "enabled");
		port ( 
		d : in std_logic := 'X';
		sp: in std_logic := 'X';
		ck: in std_logic := 'X';
		cd: in std_logic := 'X';
		q : out std_logic := 'X'
	  );
	end component;
	 
	component fd1p3ix
			generic (gsr : string := "enabled");
		port ( 
		d : in std_logic := 'X';
		sp: in std_logic := 'X';
		ck: in std_logic := 'X';
		cd: in std_logic := 'X';
		q : out std_logic := 'X'
	  );
	end component;
	 
	component fd1p3jx
			generic (gsr : string := "enabled");
		port ( 
		d : in std_logic := 'X';
		sp: in std_logic := 'X';
		ck: in std_logic := 'X';
		pd: in std_logic := 'X';
		q : out std_logic := 'X'
	  );
	end component;
	 
	component fd1s3ax
			generic (gsr : string := "enabled");
		port ( 
		d : in std_logic := 'X';
		ck: in std_logic := 'X';
		q : out std_logic := 'X'
	  );
	end component;
	 
	component fd1s3ay
			generic (gsr : string := "enabled");
		port ( 
		d : in std_logic := 'X';
		ck: in std_logic := 'X';
		q : out std_logic := 'X'
	  );
	end component;
	 
	component fd1s3bx
			generic (gsr : string := "enabled");
		port ( 
		d : in std_logic := 'X';
		ck: in std_logic := 'X';
		pd: in std_logic := 'X';
		q : out std_logic := 'X'
	  );
	end component;
	 
	component fd1s3dx
			generic (gsr : string := "enabled");
		port ( 
		d: in std_logic := 'X';
		ck: in std_logic := 'X';
		cd: in std_logic := 'X';
		q : out std_logic := 'X'
	  );
	end component;
	 
	component fd1s3ix
			generic (gsr : string := "enabled");
		port ( 
		d : in std_logic := 'X';
		ck: in std_logic := 'X';
		cd: in std_logic := 'X';
		q : out std_logic := 'X'
	  );
	end component;
	 
	component fd1s3jx
			generic (gsr : string := "enabled");
		port ( 
		d : in std_logic := 'X';
		ck: in std_logic := 'X';
		pd: in std_logic := 'X';
		q : out std_logic := 'X'
	  );
	end component;

	component fl1p3az
			generic (gsr : string := "enabled");
		port ( 
		d0: in std_logic := 'X';
		d1: in std_logic := 'X';
		sp: in std_logic := 'X';
		ck: in std_logic := 'X';
		sd: in std_logic := 'X';
		q : out std_logic := 'X'
	  );
	end component;
	 
	component fl1p3ay
			generic (gsr : string := "enabled");
		port ( 
		d0: in std_logic := 'X';
		d1: in std_logic := 'X';
		sp: in std_logic := 'X';
		ck: in std_logic := 'X';
		sd: in std_logic := 'X';
		q : out std_logic := 'X'
	  );
	end component;
	 
	component fl1p3bx
			generic (gsr : string := "enabled");
		port ( 
		d0: in std_logic := 'X';
		d1: in std_logic := 'X';
		sp: in std_logic := 'X';
		ck: in std_logic := 'X';
		sd: in std_logic := 'X';
		pd: in std_logic := 'X';
		q : out std_logic := 'X'
	  );
	end component;
	 
	component fl1p3dx
			generic (gsr : string := "enabled");
		port ( 
		d0: in std_logic := 'X';
		d1: in std_logic := 'X';
		sp: in std_logic := 'X';
		ck: in std_logic := 'X';
		sd: in std_logic := 'X';
		cd: in std_logic := 'X';
		q : out std_logic := 'X'
	  );
	end component;
	 
	component fl1p3iy
			generic (gsr : string := "enabled");
		port ( 
		d0: in std_logic := 'X';
		d1: in std_logic := 'X';
		sp: in std_logic := 'X';
		ck: in std_logic := 'X';
		sd: in std_logic := 'X';
		cd: in std_logic := 'X';
		q : out std_logic := 'X'
	  );
	end component;
	 
	component fl1p3jy
			generic (gsr : string := "enabled");
		port ( 
		d0: in std_logic := 'X';
		d1: in std_logic := 'X';
		sp: in std_logic := 'X';
		ck: in std_logic := 'X';
		sd: in std_logic := 'X';
		pd: in std_logic := 'X';
		q : out std_logic := 'X'
	  );
	end component;
	 
	component fl1s3ax
			generic (gsr : string := "enabled");
		port ( 
		d0: in std_logic := 'X';
		d1: in std_logic := 'X';
		ck: in std_logic := 'X';
		sd: in std_logic := 'X';
		q : out std_logic := 'X'
	  );
	end component;
	 
	component fl1s3ay
			generic (gsr : string := "enabled");
		port ( 
		d0: in std_logic := 'X';
		d1: in std_logic := 'X';
		ck: in std_logic := 'X';
		sd: in std_logic := 'X';
		q : out std_logic := 'X'
	  );
	end component;
	 
	component gsr
		port ( 
		  gsr: in std_logic := 'X'
	  );
	end component;

	component sgsr
		port (
		  gsr: in std_logic := 'X';
		  clk : in std_logic := 'X'
	  );
	end component;

	component ifs1p3bx
			generic (gsr : string := "enabled");
		port ( 
		d   : in std_logic := 'X';
		sp  : in std_logic := 'X';
		sclk: in std_logic := 'X';
		pd  : in std_logic := 'X';
		q   : out std_logic := 'X'
	  );
	end component;
	 
	component ifs1p3dx
			generic (gsr : string := "enabled");
		port ( 
		d   : in std_logic := 'X';
		sp  : in std_logic := 'X';
		sclk: in std_logic := 'X';
		cd  : in std_logic := 'X';
		q   : out std_logic := 'X'
	  );
	end component;
	 
	component ifs1p3ix
			generic (gsr : string := "enabled");
		port ( 
		d   : in std_logic := 'X';
		sp  : in std_logic := 'X';
		sclk: in std_logic := 'X';
		cd  : in std_logic := 'X';
		q   : out std_logic := 'X'
	  );
	end component;
	 
	component ifs1p3jx
			generic (gsr : string := "enabled");
		port ( 
		d   : in std_logic := 'X';
		sp  : in std_logic := 'X';
		sclk: in std_logic := 'X';
		pd  : in std_logic := 'X';
		q   : out std_logic := 'X'
	  );
	end component;
	 
	component ifs1s1b
			generic (gsr : string := "enabled");
		port ( 
		d   : in std_logic := 'X';
		sclk: in std_logic := 'X';
		pd  : in std_logic := 'X';
		q   : out std_logic := 'X'
	  );
	end component;
	 
	component ifs1s1d
			generic (gsr : string := "enabled");
		port ( 
		d   : in std_logic := 'X';
		sclk: in std_logic := 'X';
		cd  : in std_logic := 'X';
		q   : out std_logic := 'X'
	  );
	end component;
	 
	component ifs1s1i
			generic (gsr : string := "enabled");
		port ( 
		d   : in std_logic := 'X';
		sclk: in std_logic := 'X';
		cd  : in std_logic := 'X';
		q   : out std_logic := 'X'
	  );
	end component;
	 
	component ifs1s1j
			generic (gsr : string := "enabled");
		port ( 
		d   : in std_logic := 'X';
		sclk: in std_logic := 'X';
		pd  : in std_logic := 'X';
		q   : out std_logic := 'X'
	  );
	end component;
	 
	component ofs1p3bx
			generic (gsr : string := "enabled");
		port (
			d : in std_logic := 'X';
			sp: in std_logic := 'X';
			sclk: in std_logic := 'X';
			pd: in std_logic := 'X';
			q : out std_logic := 'X'
	  );
	end component;

	component ofs1p3dx
			generic (gsr : string := "enabled");
		port (
			d : in std_logic := 'X';
			sp: in std_logic := 'X';
			sclk: in std_logic := 'X';
			cd: in std_logic := 'X';
			q : out std_logic := 'X'
	  );
	end component;

	component ofs1p3ix
			generic (gsr : string := "enabled");
		port (
			d : in std_logic := 'X';
			sp: in std_logic := 'X';
			sclk: in std_logic := 'X';
			cd: in std_logic := 'X';
			q : out std_logic := 'X'
	  );
	end component;

	component ofs1p3jx
			generic (gsr : string := "enabled");
		port (
			d : in std_logic := 'X';
			sp: in std_logic := 'X';
			sclk: in std_logic := 'X';
			pd: in std_logic := 'X';
			q : out std_logic := 'X'
	  );
	end component;

	component ilvds
		port (
			a : in std_logic := 'X';
			an: in std_logic := 'X';
			z : out std_logic
	 );
	end component;

	component olvds
		port (
			a  : in std_logic := 'X';
			z  : out std_logic ;
			zn : out std_logic
	 );
	end component;

	component bb
		port (
			b:  inout std_logic := 'X';
			i:  in std_logic := 'X';
			t:  in std_logic := 'X';
			o:  out std_logic);
	end component;

	component bbpd
		port (
			b:  inout std_logic := 'X';
			i:  in std_logic := 'X';
			t:  in std_logic := 'X';
			o:  out std_logic);
	end component;

	component bbpu
		port (
			b:  inout std_logic := 'X';
			i:  in std_logic := 'X';
			t:  in std_logic := 'X';
			o:  out std_logic);
	end component;

	component ib
		port (
			i:  in std_logic := 'X';
			o:  out std_logic);
	end component;

	component ibpd
		port (
			i:  in std_logic := 'X';
			o:  out std_logic);
	end component;

	component ibpu
		port (
			i:  in std_logic := 'X';
			o:  out std_logic);
	end component;

	component ob
		port (
			i:  in std_logic := 'X';
			o:  out std_logic);
	end component;

	component obco
		port (
			i :  in std_logic := 'X';
			ot:  out std_logic;
			oc:  out std_logic);
	end component;

	component obz
		port (
			i:  in std_logic := 'X';
			t:  in std_logic := 'X';
			o:  out std_logic);
	end component;

	component obzpu
		port (
			i:  in std_logic := 'X';
			t:  in std_logic := 'X';
			o:  out std_logic);
	end component;

	component clkdivf
		generic (
	   gsr   : string := "disabled";
	   div   : string := "2.0" );
		port (
	   clki, rst, alignwd : in std_logic := 'X';
	   cdivx  : out std_logic := 'X' );
	end component;

	component pcsclkdiv
		generic (
	   gsr   : string := "disabled" );
		port (
	   clki, rst, sel2, sel1,sel0 : in std_logic := 'X';
	   cdiv1, cdivx  : out std_logic := 'X' );
	end component;

	component dcsc
		generic (
	   dcsmode       : string := "pos" );
		port (
	   clk1, clk0, sel1, sel0, modesel : in std_logic := 'X';
	   dcsout  : out std_logic := 'X' );
	end component;

	component eclksyncb
		port (
	   eclki, stop : in std_logic := 'X';
	   eclko  : out std_logic := 'X' );
	end component;

	component eclkbridgecs
		port (
	   clk0, clk1, sel : in std_logic := 'X';
	   ecsout  : out std_logic := 'X' );
	end component;

	component dcca
		port (
	   clki, ce : in std_logic := 'X';
	   clko  : out std_logic := 'X' );
	end component;

	component oscg
		generic (
	   div   : integer := 128 );
		port (
	   osc  : out std_logic := 'X' );
	end component;

	component ehxplll
		generic (
	   clki_div      : integer := 1;
	   clkfb_div     : integer := 1;
	   clkop_div     : integer := 8;
	   clkos_div     : integer := 8;
	   clkos2_div    : integer := 8;
	   clkos3_div    : integer := 8;
	   clkop_enable  : string := "enabled";
	   clkos_enable  : string := "disabled";
	   clkos2_enable         : string := "disabled";
	   clkos3_enable         : string := "disabled";
	   clkop_cphase  : integer := 0;
	   clkos_cphase  : integer := 0;
	   clkos2_cphase         : integer := 0;
	   clkos3_cphase         : integer := 0;
	   clkop_fphase  : integer := 0;
	   clkos_fphase  : integer := 0;
	   clkos2_fphase         : integer := 0;
	   clkos3_fphase         : integer := 0;
	   feedbk_path   : string := "clkop";
	   clkop_trim_pol        : string := "rising";
	   clkop_trim_delay      : integer := 0;
	   clkos_trim_pol        : string := "rising";
	   clkos_trim_delay      : integer := 0;
	   outdivider_muxa       : string := "diva";
	   outdivider_muxb       : string := "divb";
	   outdivider_muxc       : string := "divc";
	   outdivider_muxd       : string := "divd";
	   pll_lock_mode         : integer := 0;
	   pll_lock_delay        : integer := 200;
	   stdby_enable  : string := "disabled";
	   refin_reset   : string := "disabled";
	   sync_enable   : string := "disabled";
	   int_lock_sticky       : string := "enabled";
	   dphase_source         : string := "disabled";
	   pllrst_ena    : string := "disabled";
	   intfb_wake    : string := "disabled" );
		port (
	   clki, clkfb, phasesel1, phasesel0, phasedir, phasestep,
	   phaseloadreg, stdby, pllwakesync, rst,
	   enclkop, enclkos, enclkos2, enclkos3 : in std_logic := 'X';
	   clkop, clkos, clkos2, clkos3, lock, intlock, refclk,
	   clkintfb : out std_logic := 'X' );
	end component;

	component pllrefcs
		port (
	   clk0,clk1,sel : in std_logic := 'X';
	   pllcsout  : out std_logic := 'X' );
	end component;

	component lvdsob
		port (
	   d,
	   e : in std_logic := 'X';
	   q  : out std_logic := 'X' );
	end component;

	component delayg
		generic (
	   del_mode      : string := "user_defined";
	   del_value     : integer := 0 );
		port (
	   a : in std_logic := 'X';
	   z  : out std_logic := 'X' );
	end component;

	component dqsbufm
		generic (
	   dqs_li_del_val        : integer := 4;
	   dqs_li_del_adj        : string := "factoryonly";
	   dqs_lo_del_val        : integer := 0;
	   dqs_lo_del_adj        : string := "factoryonly";
	   gsr   : string := "enabled" );
		port (
	   dqsi,read1,read0,readclksel2,readclksel1,readclksel0,ddrdel,eclk,sclk, rst,
	   dyndelay7, dyndelay6, dyndelay5, dyndelay4, dyndelay3, dyndelay2, dyndelay1, dyndelay0,
	   pause,rdloadn,rdmove,rddirection,wrloadn,wrmove,wrdirection : in std_logic := 'X';
	   dqsr90,dqsw,dqsw270,rdpntr2,rdpntr1,rdpntr0,wrpntr2,wrpntr1,wrpntr0,
	   datavalid, burstdet,rdcflag,wrcflag  : out std_logic := 'X' );
	end component;


	component ddrdlla
		generic (
	   force_max_delay	 : string := "no";
	   lock_cyc	 : integer := 200;
	   gsr	 : string := "enabled" );
		port (
	   clk, rst, uddcntln, freeze : in std_logic := 'X';
	   ddrdel, lock,
	   dcntl7,dcntl6,dcntl5,dcntl4,dcntl3,dcntl2,dcntl1,dcntl0  : out std_logic := 'X' );
	end component;

	component dlldeld
		port (
	   a, ddrdel,loadn,move,direction : in std_logic := 'X';
	   z, cflag  : out std_logic := 'X' );
	end component;

	component iddrx1f
		generic (
	   gsr	 : string := "enabled" );
		port (
	   d, sclk, rst : in std_logic := 'X';
	   q0, q1  : out std_logic := 'X' );
	end component;

	component iddrx2f
		generic (
	   gsr	 : string := "enabled" );
		port (
	   d, sclk, eclk, rst, alignwd : in std_logic := 'X';
	   q3, q2, q1, q0  : out std_logic := 'X' );
	end component;

	component iddr71b
		generic (
	   gsr	 : string := "enabled" );
		port (
	   d, sclk,eclk,rst,alignwd : in std_logic := 'X';
	   q6,q5,q4,q3,q2,q1,q0  : out std_logic := 'X' );
	end component;

	component oddrx1f
		generic (
	   gsr	 : string := "enabled" );
		port (
	   sclk, rst, d0, d1 : in std_logic := 'X';
	   q  : out std_logic := 'X' );
	end component;

	component oddrx2f
		generic (
	   gsr	 : string := "enabled" );
		port (
	   sclk,eclk,rst,d3,d2,d1,d0 : in std_logic := 'X';
	   q  : out std_logic := 'X' );
	end component;

	component oddr71b
		generic (
	   gsr	 : string := "enabled" );
		port (
	   sclk,eclk,rst,d6,d5,d4,d3,d2,d1,d0 : in std_logic := 'X';
	   q  : out std_logic := 'X' );
	end component;

	component imipi
		port (
	   a, an, hssel : in std_logic := 'X';
	   ohsols1, ols0 : out std_logic := 'X' );
	end component;

	component iddrx2dqa
		generic (
	   gsr   : string := "enabled" );
		port (
	   sclk,eclk,dqsr90,d,rst,
	   rdpntr2,rdpntr1,rdpntr0,wrpntr2,wrpntr1,wrpntr0 : in std_logic := 'X';
	   q3,q2,q1,q0,qwl  : out std_logic := 'X' );
	end component;

	component oddrx2dqa
		generic (
	   gsr   : string := "enabled");
		port (
	   d3,d2,d1,d0,dqsw270,sclk,eclk,rst : in std_logic := 'X';
	   q  : out std_logic := 'X' );
	end component;

	component oddrx2dqsb
		generic (
	   gsr   : string := "enabled");
		port (
	   d3,d2,d1,d0,sclk,eclk,dqsw,rst : in std_logic := 'X';
	   q  : out std_logic := 'X' );
	end component;

	component tshx2dqa
		generic (
	   gsr   : string := "enabled";
	   regset        : string := "set" );
		port (
	   t1,t0,sclk,eclk,dqsw270,rst : in std_logic := 'X';
	   q  : out std_logic := 'X' );
	end component;

	component tshx2dqsa
		generic (
	   gsr   : string := "enabled";
	   regset        : string := "set" );
		port (
	   t1,t0,sclk,eclk,dqsw,rst : in std_logic := 'X';
	   q  : out std_logic := 'X' );
	end component;

	component oshx2a
		generic (
	   gsr   : string := "enabled" );
		port (
	   d1,d0,sclk,eclk,rst : in std_logic := 'X';
	   q  : out std_logic := 'X' );
	end component;

end;

