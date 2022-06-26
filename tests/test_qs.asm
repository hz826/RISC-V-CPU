
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

        addi x5 x0 -357
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -730
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 306
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 768
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 384
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -707
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -543
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -215
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -347
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -266
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -567
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -689
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 465
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 794
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -277
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -229
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -983
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -434
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -751
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -360
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 551
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -185
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -834
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 526
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 549
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -769
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -560
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -144
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 868
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -87
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -184
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 863
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -233
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 614
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 459
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -35
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -253
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -919
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 210
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -879
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 992
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -457
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -593
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 945
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 147
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 349
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -771
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 786
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 740
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -135
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -690
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 215
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 771
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 520
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -470
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 414
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 1023
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 969
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -896
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 271
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 997
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 788
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 583
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 52
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 579
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -108
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -899
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -414
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 147
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -1005
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 654
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -314
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 989
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 459
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -529
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -178
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -848
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 938
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -304
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -120
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 903
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 469
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -721
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -1021
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -726
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -589
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 171
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 961
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 763
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 167
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 88
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 942
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -773
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -902
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -448
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -459
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -326
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -745
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 -980
        addi x11 x11 4
        sw x5 0(x11)
    
        addi x5 x0 662
        addi x11 x11 4
        sw x5 0(x11)

addi x2 x11 4
jal x1 qsort