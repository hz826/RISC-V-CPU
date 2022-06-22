sccomp_tb.v.out : *.v
	iverilog -o sccomp_tb.v.out sccomp_tb.v

comp : sccomp_tb.v.out

run : comp
	vvp -n sccomp_tb.v.out