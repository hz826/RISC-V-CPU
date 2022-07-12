ori	x5, x0, 564
lui	x6, 1
or	x5, x5, x6
lui	x6, 624485
addi	x7, x5, 837
addi	x8, x6, -1024
xori	x9, x5, 1980
sltiu	x3, x7, 52
sltiu	x4, x5, -1
andi	x18, x9, 1893
slti	x20, x6, 291
sub	x19, x6, x5
xor	x21, x20, x6
add	x22, x21, x20
add	x22, x22, x5
sub	x23, x22, x6
or	x25, x23, x22
and	x26, x23, x22
slt	x27, x25, x26
sltu	x28, x25, x26
addi	x3, x3, 4
sll	x27, x26, x3
srl	x28, x25, x3
sra	x29, x25, x3
slli	x27, x19, 16
srli	x28, x19, 4
srai	x29, x19, 4
addi	x3, x0, 768
addi	x5, x0, 255
sw	x19, 0(x3)
sw	x21, 4(x3)
sw	x23, 8(x3)
sh	x26, 4(x3)
sh	x19, 10(x3)
sb	x5, 7(x3)
sb	x5, 9(x3)
sb	x5, 8(x3)
lw	x5, 0(x3)
sw	x5, 12(x3)
lh	x7, 2(x3)
sw	x7, 16(x3)
lhu	x7, 2(x3)
sw	x7, 20(x3)
lb	x8, 3(x3)
sw	x8, 24(x3)
lbu	x8, 3(x3)
sw	x8, 28(x3)
lbu	x8, 1(x3)
sw	x8, 32(x3)
sw	x0, 0(x3)
and	x9, x0, x9
bne	x5, x7, 8
addi	x9, x9, 1
bge	x5, x7, 8
addi	x9, x9, 4
bgeu	x5, x7, 8
addi	x9, x9, 2
blt	x5, x7, 8
addi	x9, x9, 7
bltu	x5, x7, 0
addi	x9, x9, 8
beq	x7, x8, 8
addi	x9, x9, 10
sw	x9, 0(x3)
ori	x30, x0, 1397
lw	x10, 0(x3)
jal	x1, 16
addi	x10, x10, 5
sw	x10, 0(x3)
beq	x10, x30, 48
ori	x10, x10, 1360
sw	x10, 0(x3)
jalr	x0, x1, 0
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
beq	x0, x0, 0
