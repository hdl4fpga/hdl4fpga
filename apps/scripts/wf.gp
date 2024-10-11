#set terminal qt background rgb "black" font "Helvetica,12"
set terminal qt  size 2*720, 2*360 font "Helvetica,12"
#set terminal svg size 1280, 360 background rgb "black" font "verdana,12"
#set terminal png background rgb "black" font "Helvetica,12"
set size ratio 1/3.17

set style line 12 lc rgb 'magenta' lt 0 lw 1
set style line 13 lc rgb 'magenta' lt 0 lw 1
set grid xtics ytics mxtics mytics ls 12, ls 13

set key textcolor rgb "white"
set xlabel "us" textcolor rgb "white"
set ylabel "V" textcolor rgb "white" rotate by 0
set border 0 lt 0 lw 1 lc rgb "magenta"
#set border 0
set yrange [0:5]
#set xrange [-25:]
set ticslevel 0
unset x2tics
#set xtics 0, 322.5
#set for [i=0: 5000] xtics (0, 2*322.5*i)
set xtics 0, 2*322.5
set mxtics 2
set grid mxtics
set tics textcolor rgb 'white'

plot \
    "data.txt" using 1:2 title "CHN1" with lines linewidth 2 linecolor rgb "cyan",\
    "data.txt" using 1:3 title "CHN2" with lines linewidth 2 linecolor rgb "white",\
    "data.txt" using 1:4 title "CHN3" with lines linewidth 2 linecolor rgb "cyan",\
    "data.txt" using 1:5 title "CHN4" with lines linewidth 2 linecolor rgb "white"
