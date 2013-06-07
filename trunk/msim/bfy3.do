onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /testbench/rst
add wave -noupdate -format Logic /testbench/clk
add wave -noupdate -format Literal -radix decimal /testbench/xi
add wave -noupdate -format Literal -radix unsigned /testbench/s
add wave -noupdate -divider {Bfy 0}
add wave -noupdate -format Logic /testbench/bu/du/bfy__0/bfy3/si
add wave -noupdate -format Literal -radix decimal /testbench/bu/du/bfy__0/bfy3/fifo_di
add wave -noupdate -format Literal -radix decimal /testbench/bu/du/bfy__0/bfy3/xi
add wave -noupdate -format Literal -radix decimal /testbench/bu/du/bfy__0/bfy3/xo
add wave -noupdate -format Literal -radix decimal /testbench/bu/du/bfy__0/bfy3/fifo_do
add wave -noupdate -format Literal -radix decimal /testbench/bu/mu__0/mu/fifo
add wave -noupdate -divider {Twd 1}
add wave -noupdate -format Logic /testbench/bu/du/twd1_j
add wave -noupdate -format Literal -radix decimal /testbench/bu/du/u_twd1/twd_xi
add wave -noupdate -format Literal -radix decimal /testbench/bu/du/u_twd1/twd_xo
add wave -noupdate -divider Bfy1
add wave -noupdate -format Logic /testbench/bu/du/bfy__1/bfy3/si
add wave -noupdate -format Logic /testbench/bu/du/bfy__1/bfy3/op
add wave -noupdate -format Literal -radix decimal /testbench/bu/du/bfy__1/bfy3/fifo_di
add wave -noupdate -format Literal -radix decimal /testbench/bu/du/bfy__1/bfy3/xi
add wave -noupdate -format Literal -radix decimal /testbench/bu/du/bfy__1/bfy3/xo
add wave -noupdate -format Literal -radix decimal /testbench/bu/du/bfy__1/bfy3/fifo_do
add wave -noupdate -format Literal -radix decimal -expand /testbench/bu/mu__1/mu/fifo
add wave -noupdate -divider {Twd 2}
add wave -noupdate -format Logic /testbench/bu/du/u_twd2/twd_j
add wave -noupdate -format Logic /testbench/bu/du/u_twd2/twd_sqrt2
add wave -noupdate -format Logic /testbench/bu/du/ri
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /testbench/bu/du/u_twd2/twd_mux_j
add wave -noupdate -format Literal /testbench/bu/du/u_twd2/twd_mux_sqrt2
add wave -noupdate -format Literal -radix decimal /testbench/bu/du/u_twd2/twd_b
add wave -noupdate -format Literal -radix decimal /testbench/bu/du/u_twd2/twd_a
add wave -noupdate -format Literal -radix decimal /testbench/bu/du/u_twd2/twd_ab
add wave -noupdate -format Literal -radix decimal /testbench/bu/du/u_twd2/twd_opb
add wave -noupdate -format Literal -radix decimal /testbench/bu/du/u_twd2/twd_xo
add wave -noupdate -divider {Bfy 2}
add wave -noupdate -format Logic /testbench/bu/du/bfy_op(2)
add wave -noupdate -format Logic /testbench/bu/du/bfy__2/bfy3/si
add wave -noupdate -format Literal -radix decimal /testbench/bu/du/bfy__2/bfy3/xi
add wave -noupdate -format Literal -radix decimal /testbench/xo
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {314 ns} 0} {{Cursor 2} {319 ns} 0}
configure wave -namecolwidth 139
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {236 ns} {376 ns}
