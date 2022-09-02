set width 0
set height 0
target extended-remote localhost:1234
add-inferior
inferior 2
attach 2
set schedule-multiple
info threads
symbol-file work/linux/vmlinux

break devm_clk_hw_register 
commands 1
backtrace

break mpfs_clk_probe
commands 1
backtrace
