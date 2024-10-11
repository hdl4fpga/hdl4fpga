set terminal x11 background rgb "black" font "Helvetica,12"
#set terminal png background rgb "black" font "Helvetica,12"

set style line 12 lc rgb '#ff404040' lt 1 lw 1
set style line 13 lc rgb '#ff404040' lt 1 lw 1
set grid xtics ytics mxtics mytics ls 12, ls 13

set key textcolor rgb "white"
set xlabel "us" textcolor rgb "white"
set ylabel "V" textcolor rgb "white" rotate by 0
set border lw 1 lc rgb "gray"
set border 0

plot \
    "data.txt" using 1:2 title "CHN1" with lines linewidth 1 linecolor rgb "#00ff0000",\
    "data.txt" using 1:3 title "CHN2" with lines linewidth 1 linecolor rgb "#0000ff00",\
    "data.txt" using 1:4 title "CHN3" with lines linewidth 1 linecolor rgb "#008080ff",\
    "data.txt" using 1:5 title "CHN4" with lines linewidth 1 linecolor rgb "#00ffff00"
