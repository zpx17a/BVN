@echo off

set COMMANDS_NAME=Commands
set FLASH_NAME=Flash CC 2015
set flashDir=%LOCALAPPDATA%\Adobe\%FLASH_NAME%
set flashCommands=%flashDir%\zh_CN\Configuration\%COMMANDS_NAME%

:: 检查目录 %flashDir% 是否存在
if not exist "%flashDir%" (
	echo 未安装软件 %FLASH_NAME%
	goto :ERROR
)

:: 检查操作系统语言
chcp | find "936" >nul || (
	echo 操作系统语言必须为简体中文！ && goto :ERROR
)

set copyDir=%~dp0%COMMANDS_NAME%
echo D|xcopy "%copyDir%" "%flashCommands%" /E /y >nul
if not %ERRORLEVEL% == 0 (
	echo 复制目录 %copyDir% 失败！
	goto :ERROR
)

goto :END

:: 如果有错误信息，提示后再退出
:ERROR
pause >nul
:END
exit