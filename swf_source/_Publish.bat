@echo off
:: setlocal enabledelayedexpansion

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: 设置控制台标题
title 死神vs火影 绊 - 发布

:: 寻找当前目录的父目录
for %%a in ("..") do (
	set parent=%%~fa
)

set PATH=%PATH%;%CD%\_Tool

set name=FighterTester
set name_output=swf_output
set name_release_temp=bin-release-temp
set dir_output=%parent%\%name_output%
set dir_project=%CD%\#%name%
set dir_project_rct=%dir_project%\%name_release_temp%
set dir_project_src=%dir_project%\src

set file_swf=%name%.swf
set file_xml=%name%-app.xml
set tmp_xml=%dir_output%\%file_xml%
set out_swf=%dir_output%\%file_swf%
set out_xml=%dir_output%\META-INF\AIR\application.xml
set src_swf=%dir_project_rct%\%file_swf%
set src_xml=%dir_project_src%\%file_xml%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: 检测源 file_swf
if not exist "%src_swf%" (
	echo 源文件不存在：%src_swf%
	goto :ERROR
)

if exist "%tmp_xml%" (
	echo 正在删除文件：%tmp_xml%
	
	del "%tmp_xml%" /q
	call :CHECK %ERRORLEVEL%
)
if exist "%out_swf%" (
	echo 正在删除文件：%out_swf%
	
	del "%out_swf%" /q
	call :CHECK %ERRORLEVEL%
)
if exist "%out_xml%" (
	echo 正在删除文件：%out_xml%
	
	del "%out_xml%" /q
	call :CHECK %ERRORLEVEL%
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: 调用工具 ABCMerge 优化 file_swf.
echo 正在执行优化……
echo 输入文件：%src_swf%
echo 输出文件：%out_swf%

ABCMerge "%src_swf%" >ABCMerge.log
call :CHECK %ERRORLEVEL%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

move "%src_swf%" "%out_swf%" >nul
call :CHECK %ERRORLEVEL%

ren "%src_swf%.bak" %file_swf%
call :CHECK %ERRORLEVEL%

copy "%src_xml%" "%out_xml%" >nul
call :CHECK %ERRORLEVEL%

:: 清理工作
del /f /s /q "%dir_project_rct%\*.*" >nul
call :CHECK %ERRORLEVEL%

rd /s /q "%dir_project_rct%" >nul
call :CHECK %ERRORLEVEL%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

goto :END

:: 如果有错误信息，提示后再退出
:ERROR
pause >nul
:END
exit

:: 检查错误代码
:CHECK
if not %1 == 0 (
	echo 出错！错误代码为：%1
	goto :ERROR
)
goto :EOF

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::