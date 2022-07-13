使用 iverilog 的仿真和对拍

项目结构：

| 文件/文件夹 | 内容 |
| --- | --- |
| single_cycle_processor/ | RISC-V 单周期处理器 |
| pipelined_processor/ | RISC-V 5级流水线处理器 |
| compare.py | 对拍程序（对比两份 verilog 代码运行指定测试数据的输出） |
| inst_generate/ | 随机生成测试数据 |
| tests/ | 测试数据 |
| tb/ | 对拍代码时需要统一的文件 |
