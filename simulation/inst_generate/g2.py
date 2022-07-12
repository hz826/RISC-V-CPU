import random

def rint(l, r) :
    return random.randint(l, r)

head = \
'''
jal x0 main

qsort:
    bge x10 x11 label0
    
    add x5 x10 x0
    add x6 x11 x0
    lw x7 0(x10)
    
label1:

    jal x0 label2
label3:
    addi x5 x5 4
label2:
    lw x8 0(x5)
    blt x8 x7 label3
    
    jal x0 label4
label5:
    addi x6 x6 -4
label4:
    lw x9 0(x6)
    blt x7 x9 label5
    
    blt x6 x5 label6
    lw x8 0(x5)
    lw x9 0(x6)
    sw x8 0(x6)
    sw x9 0(x5)
    addi x5 x5 4
    addi x6 x6 -4
label6:
    bge x6 x5 label1
    
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

label0:
    jalr x0 x1 0
    
main:
    lui x10 0x10000
    addi x11 x10 -4
'''

def ins(x) :
    return \
    '''
        addi x5 x0 {}
        addi x11 x11 4
        sw x5 0(x11)
    '''.format(x)
    
tail = \
'''
addi x2 x11 4
jal x1 qsort
'''

code = head
for i in range(100) :
    code += ins(rint(-1024,1023))

code += tail

print(code)