addi x1 x0 1
sw x1 4(x0)
lw x2 4(x0)
add x3 x1 x2
add x4 x2 x0
sh x4 0(x0)
sh x3 2(x0)
lw x5 0(x0)