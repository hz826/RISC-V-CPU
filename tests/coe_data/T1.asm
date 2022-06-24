jal	x1, 32
add	x0, x0, x0
add	x0, x0, x0
add	x0, x0, x0
add	x0, x0, x0
add	x0, x0, x0
add	x0, x0, x0
add	x0, x0, x0
lui	x4, 1048575
srai	x4, x4, 12
add	x5, x4, x4
add	x5, x5, x5
add	x5, x5, x5
add	x5, x5, x5
add	x5, x5, x5
add	x5, x5, x5
ori	x20, x0, 63
add	x5, x5, x5
add	x5, x5, x5
add	x5, x5, x5
add	x5, x5, x5
add	x5, x5, x5
add	x5, x5, x5
add	x5, x5, x5
add	x5, x5, x5
add	x5, x5, x5
add	x5, x5, x5
add	x5, x5, x5
add	x5, x5, x5
add	x5, x5, x5
add	x5, x5, x5
add	x5, x5, x5
add	x5, x5, x5
add	x5, x5, x5
add	x5, x5, x5
add	x5, x5, x5
add	x5, x5, x5
add	x6, x5, x5
add	x5, x6, x6
add	x7, x5, x5
add	x13, x7, x7
add	x8, x13, x13
sltu	x9, x0, x4
add	x14, x9, x9
add	x14, x14, x14
add	x10, x4, x4
sw	x6, 4(x5)
lw	x25, 0(x5)
add	x25, x25, x25
add	x25, x25, x25
sw	x25, 0(x5)
add	x19, x19, x9
sw	x19, 0(x7)
lw	x13, 20(x0)
lw	x25, 0(x5)
add	x25, x25, x25
add	x25, x25, x25
sw	x25, 0(x5)
lw	x25, 0(x5)
and	x11, x25, x8
add	x13, x13, x9
beq	x13, x0, 96
lw	x25, 0(x5)
add	x18, x14, x14
add	x22, x18, x18
add	x18, x18, x22
and	x11, x25, x18
beq	x11, x0, 24
beq	x11, x18, 44
add	x18, x14, x14
beq	x11, x18, 48
sw	x19, 0(x7)
jal	x1, -72
beq	x10, x4, 8
jal	x1, 12
or	x10, x4, x0
add	x10, x10, x10
sw	x10, 0(x7)
jal	x1, -96
lw	x19, 96(x17)
sw	x19, 0(x7)
jal	x1, -108
lw	x19, 32(x17)
sw	x19, 0(x7)
jal	x1, -120
lw	x13, 20(x0)
add	x10, x10, x10
or	x10, x10, x9
add	x17, x17, x14
and	x17, x17, x20
add	x19, x19, x9
beq	x19, x4, 8
jal	x1, 12
add	x19, x0, x14
add	x19, x19, x9
lw	x25, 0(x5)
add	x11, x25, x25
add	x11, x11, x11
sw	x11, 0(x5)
sw	x6, 4(x5)
lw	x25, 0(x5)
and	x11, x25, x8
jal	x1, -160
