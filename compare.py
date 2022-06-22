import os

def run(code) :
    os.chdir(code)
    print(os.getcwd())
    os.system('iverilog -o sccomp_tb.v.out sccomp_tb.v')
    os.system('vvp -n sccomp_tb.v.out > ../output_{}.txt'.format(code))
    os.chdir('..')

def compare(code1, code2) :
    run(code1)
    run(code2)
    os.system('fc output_{}.txt output_{}.txt'.format(code1, code2))

code1 = 'pipelined_processor'
code2 = 'single_cycle_processor'

compare(code1, code2)