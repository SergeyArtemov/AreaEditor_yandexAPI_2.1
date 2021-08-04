@echo 'Delete files...'
@echo off
del *.dcu>NUL
del *.bak>NUL
del *.~*>NUL
@echo on
@echo 'Pack EXE...'
D:\Projects_Common\_RESOURCE\UPX.EXE -9 *.exe
D:\Projects_Common\_RESOURCE\UPX.EXE -9 *.dll
