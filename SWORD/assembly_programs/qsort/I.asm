#######################################
# main
# x13 write 数码管
# x14 read 拨码开关
# x15 ctrl_last
# x16 ctrl_now
# x17 input
# x18 pos1
# x19 pos0
# x20 neg1
# x21 neg0
# x22 mode1
# x23 mode0

# x28 addrL = x10
# x29 addrR = x11
# x30 addr
# x31 size

init_verilog:
    addi x31 x0 0
    addi x10 x0 8
    addi x11 x10 -4
    lui	x13, 0x10000
    addi x13 x0 0
    addi x14 x13 4

init:
    addi x31 x0 0
    addi x10 x0 4
    addi x11 x10 -4
    lui	x13, 0xe0000
    lui	x14, 0xf0000

mainloop:
    lw	x16, 0(x14)

    lui x5 1
    addi x5 x5 -1
    and x17 x16 x5
    ### 读取输入

    srli x16 x16 12
    andi x15 x15 3
    andi x16 x16 3

    xor x5 x15 x16
    and x18 x16 x5
    and x20 x15 x5

    andi x19 x18 1
    srli x18 x18 1
    andi x21 x20 1
    srli x20 x20 1
    ### 得到上升沿/下降沿

    addi x15 x16 0
    andi x23 x16 1
    srli x22 x16 1

    ### 读取地址 0xf0000000 并截取 x17 = input[11:0] x18-21 = pos/neg

    bne x22 x0 label1
        ### mode == 0 读入数据

        bne x23 x0 label3
            sw	x31, 0(x13)
            jal x0 label4
        label3:
            sw	x17, 0(x13)
        label4:

        beq x21 x0 label5
            addi x31 x31 1
            addi x11 x11 4
            sw x17 0(x11)
        label5:
        
        jal x0 label2
    label1:
        ### mode == 1 显示数据
        beq x21 x0 label6
            bne x30 x29 label7
                addi x30 x28 -4
            label7:
            addi x30 x30 4
        label6:
        
        ### show *x30
        lw x6 0(x30)
        sw	x6, 0(x13)
    label2:
    
    beq x18 x0 label8
        ### 控制1上升沿，调用qsort
        ### save l,r
        addi x28 x10 0
        addi x29 x11 4
        addi x30 x29 0
        sw x31 0(x30)

        ### show = 0x66CCFF;
        lui x6 0x66D
        addi x6 x6 -0x301
        sw	x6, 0(x13)

        ### call qsort
        addi x2 x11 4
        jal x1 qsort
    label8:

    bne x20 x0 init
    jal	x0 mainloop

#######################################
# qsort(*l, *r)
# x2 stack
# x10 *l
# x11 *r
# x5 *ll
# x6 *rr
# x8, x9 tmp

qsort:
    bge x10 x11 Qlabel0
    
    add x5 x10 x0
    add x6 x11 x0
    lw x7 0(x10)
    
Qlabel1:

    jal x0 Qlabel2
Qlabel3:
    addi x5 x5 4
Qlabel2:
    lw x8 0(x5)
    blt x8 x7 Qlabel3
    
    jal x0 Qlabel4
Qlabel5:
    addi x6 x6 -4
Qlabel4:
    lw x9 0(x6)
    blt x7 x9 Qlabel5
    
    blt x6 x5 Qlabel6
    lw x8 0(x5)
    lw x9 0(x6)
    sw x8 0(x6)
    sw x9 0(x5)
    addi x5 x5 4
    addi x6 x6 -4
Qlabel6:
    bge x6 x5 Qlabel1
    
    addi x2 x2 12
    sw x1  0(x2)
    sw x5  4(x2)
    sw x11 8(x2)
    add x11 x6 x0
    
    jal x1 qsort
    lw x10 4(x2)
    lw x11 8(x2)
    jal x1 qsort
    lw x1 0(x2)
    addi x2 x2 -12

Qlabel0:
    jalr x0 x1 0

# qsort end
#######################################