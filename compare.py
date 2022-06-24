import os
import shutil

def rm(filename) :
    try :
        os.remove(filename)
    except Exception as result :
        pass

def cp(f1, f2) :
    # print('f1 =', f1, 'f2 =', f2)
    rm(f2)
    shutil.copyfile(f1, f2)

def run(code, tb) :
    os.chdir(code)
    print(os.getcwd())
    for filename in tb :
        cp('../tb/{}'.format(filename), '{}'.format(filename))

    os.system('make run')
    cp('output.txt', '../output_{}.txt'.format(code))
    os.chdir('..')

def compare(code1, code2, test, tb) :
    cp(test[0], 'tb/test.dat')
    cp(test[1], 'tb/test.mem')
    cp(test[2], 'tb/test.asm')

    rm('output_{}.txt'.format(code1))
    rm('output_{}.txt'.format(code2))
    run(code1, tb)
    run(code2, tb)
    os.system('fc output_{}.txt output_{}.txt'.format(code1, code2))

    rm('tb/test.dat')
    rm('tb/test.mem')
    rm('tb/test.asm')



def te1(path) :
    return (path+'.dat', path+'.mem', 'tests/empty.asm')

def te2(path) :
    return (path+'.dat', 'tests/random.mem', path+'.asm')



# code1 = 'single_cycle_processor_correct'
code1 = 'pipelined_processor'
# code1 = 'fyc_sc'
code2 = 'single_cycle_processor'

tb = ['dm.v', 'im.v', 'sccomp.v', 'sccomp_tb.v', 'test.dat', 'test.mem', 'test.asm', 'makefile']

# test = te1('tests/coe_data/T2')
test = te2('tests/test')
# test = ('tests/coe_data/T2.dat', 'tests/coe_data/T2.mem', 'tests/empty.asm')

compare(code1, code2, test, tb)