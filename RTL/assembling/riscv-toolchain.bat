REM This uses WSL, so make sure WSL is installed and a Linux distro is set up.
REM The compiler is Ubuntu native, thats why WSL is needed.

@echo Running RISC-V toolchain commands in WSL...
wsl bash riscv-toolchain.sh %*

@echo Dumping Instructions...
wsl riscv32-unknown-elf-objdump -d program.elf

@echo Done.