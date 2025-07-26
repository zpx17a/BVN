@echo off
:: setlocal enabledelayedexpansion

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: ���ÿ���̨����
title ����vs��Ӱ �� - ����

:: Ѱ�ҵ�ǰĿ¼�ĸ�Ŀ¼
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

:: ���Դ file_swf
if not exist "%src_swf%" (
	echo Դ�ļ������ڣ�%src_swf%
	goto :ERROR
)

if exist "%tmp_xml%" (
	echo ����ɾ���ļ���%tmp_xml%
	
	del "%tmp_xml%" /q
	call :CHECK %ERRORLEVEL%
)
if exist "%out_swf%" (
	echo ����ɾ���ļ���%out_swf%
	
	del "%out_swf%" /q
	call :CHECK %ERRORLEVEL%
)
if exist "%out_xml%" (
	echo ����ɾ���ļ���%out_xml%
	
	del "%out_xml%" /q
	call :CHECK %ERRORLEVEL%
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: ���ù��� ABCMerge �Ż� file_swf.
echo ����ִ���Ż�����
echo �����ļ���%src_swf%
echo ����ļ���%out_swf%

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

:: ������
del /f /s /q "%dir_project_rct%\*.*" >nul
call :CHECK %ERRORLEVEL%

rd /s /q "%dir_project_rct%" >nul
call :CHECK %ERRORLEVEL%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

goto :END

:: ����д�����Ϣ����ʾ�����˳�
:ERROR
pause >nul
:END
exit

:: ���������
:CHECK
if not %1 == 0 (
	echo �����������Ϊ��%1
	goto :ERROR
)
goto :EOF

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::