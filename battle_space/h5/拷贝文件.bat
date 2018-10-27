@echo off
:: 将bin-debug下h5目录拷贝到bin下h5目录下
set root=%cd%
echo %root%
set fromDir=F:\h5\workSpace\StarWar\bin-debug\h5
set toDir=F:\147
::rd %toDir% /S /Q
::md %toDir%
::xcopy %fromDir% %toDir%  /y /EXCLUDE:%fromDir%/pcRes/
xcopy /e %fromDir%\appRes\*.* %toDir%\appRes\ /y
xcopy %fromDir%\*.html %toDir% /y
xcopy %fromDir%\*.js %toDir% /y
xcopy %fromDir%\*.css %toDir% /y
xcopy %fromDir%\*.json %toDir% /y
xcopy %fromDir%\*.jpg %toDir% /y
xcopy %fromDir%\*.record %toDir% /y
echo copy_finish
::pause