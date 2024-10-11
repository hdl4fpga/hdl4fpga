#set terminal qt background rgb "black" font "Helvetica,12"
set terminal qt  size 1280, 360 font "Helvetica,12"
set terminal svg size 1280, 360 background rgb "black" font "verdana,12"
#set terminal png background rgb "black" font "Helvetica,12"
set size ratio 9.0/16.0/2.0

set style line 12 lc rgb 'magenta' lt 0 lw 1
set style line 13 lc rgb 'magenta' lt 0 lw 1
set grid xtics ytics mxtics mytics ls 12, ls 13

set key textcolor rgb "white"
set xlabel "us" textcolor rgb "white"
set ylabel "V" textcolor rgb "white" rotate by 0
set border 0 lt 0 lw 1 lc rgb "magenta"
#set border 0
#set yrange [-0.25:]
#set xrange [-25:]
set ticslevel 0
set xtics 0, 322.5
set tics textcolor rgb 'white'

plot \
    "data.txt" using 1:2 title "CHN1" with lines linewidth 1 linecolor rgb "cyan",\
    "data.txt" using 1:3 title "CHN2" with lines linewidth 1 linecolor rgb "white",\
    "data.txt" using 1:4 title "CHN3" with lines linewidth 1 linecolor rgb "cyan",\
    "data.txt" using 1:5 title "CHN4" with lines linewidth 1 linecolor rgb "white"
