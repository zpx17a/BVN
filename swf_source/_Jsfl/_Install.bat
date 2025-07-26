@echo off

set COMMANDS_NAME=Commands
set FLASH_NAME=Flash CC 2015
set flashDir=%LOCALAPPDATA%\Adobe\%FLASH_NAME%
set flashCommands=%flashDir%\zh_CN\Configuration\%COMMANDS_NAME%

:: ���Ŀ¼ %flashDir% �Ƿ����
if not exist "%flashDir%" (
	echo δ��װ��� %FLASH_NAME%
	goto :ERROR
)

:: ������ϵͳ����
chcp | find "936" >nul || (
	echo ����ϵͳ���Ա���Ϊ�������ģ� && goto :ERROR
)

set copyDir=%~dp0%COMMANDS_NAME%
echo D|xcopy "%copyDir%" "%flashCommands%" /E /y >nul
if not %ERRORLEVEL% == 0 (
	echo ����Ŀ¼ %copyDir% ʧ�ܣ�
	goto :ERROR
)

goto :END

:: ����д�����Ϣ����ʾ�����˳�
:ERROR
pause >nul
:END
exit