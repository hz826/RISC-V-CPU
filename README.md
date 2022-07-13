# RISC-V-CPU

武汉大学《计算机系统综合设计》作业

使用 verilog 实现支持37条 RISC-V 指令的单周期/5级流水线处理器，并在 [SWORD](http://www.sword.org.cn/hardwares/sword4.0) 上运行汇编程序

项目结构：

| 文件/文件夹 | 内容 |
| --- | --- |
| simulation/ | 使用 iverilog 仿真和对拍 |
| simulation/single_cycle_processor/ | RISC-V 单周期处理器 |
| simulation/pipelined_processor/ | RISC-V 5级流水线处理器 |
| SWORD/ | 导入到 SWORD 的文件，包含接线、流水线处理器、汇编程序（跑马灯和快速排序） |
