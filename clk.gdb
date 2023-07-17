set width 0
set height 0
target extended-remote localhost:1234
add-inferior
inferior 2
attach 2
set schedule-multiple
info threads
symbol-file work/linux/vmlinux

break /home/conor/stuff/linux/drivers/gpio/gpio-mpfs.c:284
commands 1
backtrace
# break /home/conor/stuff/linux/drivers/irqchip/irq-mpfs-mux.c:158
# break /home/conor/stuff/linux/kernel/irq/irqdomain.c:453
# break /home/conor/stuff/linux/drivers/of/irq.c:331
# break /home/conor/stuff/linux/drivers/irqchip/irq-mpfs-mux.c:174

# condition 2 fwspec->param_count


