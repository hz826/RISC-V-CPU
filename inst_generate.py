import random

def rint(l, r) :
    return random.randint(l, r)

def addi(x1, x2, x3) :
    print('addi x{} x{} {}'.format(x1, x2, x3))

def add(x1, x2, x3) :
    print('add x{} x{} x{}'.format(x1, x2, x3))

def sw(x1, x2, x3) :
    print('sw x{} {}(x{})'.format(x1, x3, x2))

def lw(x1, x2, x3) :
    print('lw x{} {}(x{})'.format(x1, x3, x2))


inst_len = 500
reg_num = 4

for i in range(1,reg_num+1) :
    addi(i, 0, rint(-1024, 1023))

for i in range(inst_len) :
    type = rint(0,3)
    if   type == 0 :
        addi(rint(0,reg_num), rint(0,reg_num), rint(-1024, 1023))
    elif type == 1 :
        addi(rint(0,reg_num), rint(0,reg_num), rint(0,reg_num))
    elif type == 2 :
        sw(rint(0,reg_num), 0, rint(0,4) * 4)
    elif type == 3 :
        lw(rint(0,reg_num), 0, rint(0,4) * 4)