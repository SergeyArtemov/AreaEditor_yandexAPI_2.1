cd D:\Projects Work\AreaEditor\HTML
del ..\Debug\Win32\AreaEditor.exe
del ..\Debug\Win32\*.dcu
del .\*.bak
del ..\HtmlPages.res
del .\*.res
brcc32.exe HtmlPages.rc -32 
copy HtmlPages.res ..\HtmlPages.res
pause