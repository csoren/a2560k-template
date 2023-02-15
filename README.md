This repository contains an example project for building an executable for Foenix A2560U or 2560K, in a mix of C and assembly.

The C compiler used is (Calypsi)[https://www.calypsi.cc/], and the assembler is (ASMotor)[https://github.com/asmotor/asmotor]

The Makefile features automatic dependency generation, source files can be specified at the very top, in the `ASM_SRCS` and `C_SRCS` variables.

Two different executables can be built - `hello.pgz` (default) which is a "release" optimized version, and `hello-debug.pgz` which is an executable suitable for debugging.
