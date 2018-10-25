f:
cd F:\147
layaair-cmd resourceVersion -i appRes -o . -n %date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%

rem 压缩
"C:\Program Files\WinRAR\WinRAR.exe" a manifest.zip manifest.json
rem 重命名
ren manifest.zip manifest.jpg
