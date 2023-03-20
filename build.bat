@echo off
iverilog -obuild.v src/main.vl 
vvp build.v