import random

def rint(l, r) :
    return random.randint(l, r)

def addi(x1, x2, x3) :
    print('addi x{} x{} {}'.format(x1, x2, x3))

def add(x1, x2, x3) :
    print('add x{} x{} x{}'.format(x1, x2, x3))

def s(x1, x2, x3) :
    l = rint(0,2)
    x3 = (x3 // (1<<l)) * (1<<l)
    t = ['b', 'h', 'w'][l]

    print('s{} x{} {}(x{})'.format(t, x1, x3, x2))

def l(x1, x2, x3) :
    l = rint(0,2)
    x3 = (x3 // (1<<l)) * (1<<l)
    t = ['b', 'h', 'w'][l]

    if l != 2 and rint(0,1) == 0 :
        t = t + 'u'

    print('l{} x{} {}(x{})'.format(t, x1, x3, x2))


inst_len = 500
reg_num = 4

for i in range(1,reg_num+1) :
    addi(i, 0, rint(-1024, 1023))

for i in range(inst_len) :
    type = rint(0,3)
    if   type == 0 :
        addi(rint(0,reg_num), rint(0,reg_num), rint(-1024, 1023))
    elif type == 1 :
        add(rint(0,reg_num), rint(0,reg_num), rint(0,reg_num))
    elif type == 2 :
        s(rint(0,reg_num), 0, rint(0,15))
    elif type == 3 :
        l(rint(0,reg_num), 0, rint(0,15))