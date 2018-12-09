@echo off
ctran %1 -e\sibosdk\include\ -x\sibosdk\include\ -g\sibosdk\include\ -c -l -s
tsc zxemul.c /fpcat
ecobj %1