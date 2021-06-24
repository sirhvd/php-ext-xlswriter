@ECHO OFF

REM setting info box
@ECHO ############################################################################
@ECHO ##                                                                        ##
@ECHO ## Please install MS Visual C++ 2019 Build Tools                          ##
@ECHO ##                                                                        ##
@ECHO ############################################################################

@ECHO.

REM setting PHP version, Git
SET GIT="git@github.com:sirhvd/php-ext-xlswriter-s.git"
SET PHPVERSION=7.1.3
SET PHPSDK=2.2.0
SET VC=VC14
SET ARCH=64

REM setting full path of current directory to %DIR&
SET DIR=%~dp0
SET DIR=%Dir:~0,-1%

REM check for .\downloads directory
IF NOT EXIST "%DIR%\downloads" (
    @ECHO.
    @ECHO creating .\downloads directory
    MD %DIR%\downloads
)

REM adding current directory and ./downloads to path
SET PATH=%PATH%;%DIR%\downloads;%DIR%\downloads\php-%PHPVERSION%-devel-%VC%-x%ARCH%;%DIR%\downloads\php-sdk-binary-tools-php-sdk-%PHPSDK%

REM -----------------------------------------------------------
REM --- TOOLS CHECK
REM -----------------------------------------------------------

REM check for wget availability
wget >nul 2>&1
IF %ERRORLEVEL%==9009 (
    REM since wget is not available look if PHP is available and try to download wget from web with PHP
    php -v >nul 2>&1
    IF NOT %ERRORLEVEL%==9009 (
        REM download wget with php
        @ECHO.
        @ECHO loading wget...
        php -r "file_put_contents('%DIR%\downloads\wget.exe',file_get_contents('https://eternallybored.org/misc/wget/current/wget.exe'));"
    )

    REM if wget download with PHP failed try to download with bitsadmin.exe
    IF NOT EXIST "%DIR%\downloads\wget.exe" (
        REM checking for bitsadmin.exe to download wget.exe from web source
        IF NOT EXIST "%SYSTEMROOT%\System32\bitsadmin.exe" (
            @ECHO.
            @ECHO wget.exe not available
            @ECHO failed to download wget.exe automatically
            @ECHO please download wget from https://eternallybored.org/misc/wget/current/wget.exe
            @ECHO manually and put the wget.exe file in .\downloads folder
            @ECHO it is also available from the php-sdk-binary-tools zip archive
            PAUSE
            EXIT
        )

        REM bitsadmin.exe is available but wget.exe is not - so download it from web
        @ECHO.
        @ECHO loading wget for Windows from...
        @ECHO https://eternallybored.org/misc/wget/current/wget.exe
        bitsadmin.exe /transfer "WgetDownload" "https://eternallybored.org/misc/wget/current/wget.exe" "%DIR%\downloads\wget.exe"
    )

    REM if download of wget failed stop script
    IF NOT EXIST "%DIR%\downloads\wget.exe" (
        @ECHO.
        @ECHO loading wget failed. Please re-run script or
        @ECHO install .\downloads\wget.exe manually
        PAUSE
        EXIT
    )
)

REM check for 7-zip cli tool
7za >nul 2>&1
IF %ERRORLEVEL%==9009 (
    @ECHO.
    @ECHO loading 7-zip cli tool from web...
    wget http://downloads.sourceforge.net/sevenzip/7za920.zip -O %DIR%\downloads\7za920.zip -N

    REM if wget download of 7za failed stop script
    IF NOT EXIST "%DIR%\downloads\7za920.zip" (
        @ECHO.
        @ECHO failed to download 7za920.zip - please re-run this script
        PAUSE
        EXIT
    )

    REM if php is available try unpacking 7za with php
    php -v >nul 2>&1
    IF NOT %ERRORLEVEL%==9009 (
        @ECHO.
        @ECHO unpacking 7za.exe...
        php -r "file_put_contents('%DIR%\downloads\7za.exe',file_get_contents('zip://%DIR%/downloads/7za920.zip#7za.exe'));"
    )

    REM if unpacking 7za with PHP failed try to unpacking with unzip
    IF NOT EXIST "%DIR%\downloads\7za.exe" (
        REM check if unzip.exe is available to unpack 7-zip
        unzip >nul 2>&1
        IF %ERRORLEVEL%==9009 (
            REM check for unzip tool in Git\bin
            IF EXIST "%PROGRAMFILES(X86)%\Git\bin\unzip.exe" (
                @ECHO.
                @ECHO copying unzip.exe from Git...
                COPY "%PROGRAMFILES(X86)%\Git\bin\unzip.exe" "%DIR%\downloads\"
            )
        )

        REM unpacking 7za920.zip
        @ECHO.
        @ECHO unpacking 7-zip cli tool...
        CD %DIR%\downloads
        unzip -C 7za920.zip 7za.exe
        CD %DIR%
    )

	REM if unpacking 7za with unzip failed try to unpacking with vbs
    IF NOT EXIST "%DIR%\downloads\7za.exe" (
    	Call :UnZipFile "%DIR%\downloads" "%DIR%\downloads\7za920.zip"
    )
)

7za >nul 2>&1
IF %ERRORLEVEL%==9009 (
    @ECHO.
    @ECHO 7za.exe not found - please re-run this script
    PAUSE
    EXIT
)

REM -----------------------------------------------------------
REM --- PHP DEVEL SOURCE PREPARATION
REM -----------------------------------------------------------

IF NOT EXIST "%DIR%\downloads\php-devel-pack-%PHPVERSION%-Win32-%VC%-x%ARCH%.zip" (
    @ECHO.
    @ECHO loading php devel source code...
    wget https://windows.php.net/downloads/releases/archives/php-devel-pack-%PHPVERSION%-Win32-%VC%-x%ARCH%.zip -O %DIR%\downloads\php-devel-pack-%PHPVERSION%-Win32-%VC%-x%ARCH%.zip -N
)

IF NOT EXIST "%DIR%\downloads\php-devel-pack-%PHPVERSION%-Win32-%VC%-x%ARCH%.zip" (
    @ECHO.
    @ECHO php devel source code not found in .\downloads please re-run this script
    PAUSE
    EXIT
)

@ECHO.
@ECHO unpacking php-sdk-binary tools...
7za x %DIR%\downloads\php-devel-pack-%PHPVERSION%-Win32-%VC%-x%ARCH%.zip -o%DIR%/downloads -y

REM check for .\php-devel-pack-%PHPVERSION%-Win32-%VC%-x%ARCH% directory
IF NOT EXIST "%DIR%\downloads\php-%PHPVERSION%-devel-%VC%-x%ARCH%" (
    @ECHO.
    @ECHO php devel source code not found in .\downloads please re-run this script
    PAUSE
    EXIT
)

REM -----------------------------------------------------------
REM --- PHP SDK PREPARATION
REM -----------------------------------------------------------

IF NOT EXIST "%DIR%\downloads\php-sdk-binary-tools-php-sdk-%PHPSDK%.zip" (
    @ECHO.
    @ECHO loading php-sdk-binary tools...
    wget https://github.com/Microsoft/php-sdk-binary-tools/archive/php-sdk-%PHPSDK%.zip -O %DIR%\downloads\php-sdk-binary-tools-php-sdk-%PHPSDK%.zip -N
)

IF NOT EXIST "%DIR%\downloads\php-sdk-binary-tools-php-sdk-%PHPSDK%.zip" (
    @ECHO.
    @ECHO php-sdk-binary tools zip file not found in .\downloads please re-run this script
    PAUSE
    EXIT
)

@ECHO.
@ECHO unpacking php-sdk-binary tools...
7za x %DIR%\downloads\php-sdk-binary-tools-php-sdk-%PHPSDK%.zip -o%DIR%/downloads -y

REM check for .\php-sdk-binary-tools-php-sdk-%PHPSDK% directory
IF NOT EXIST "%DIR%\downloads\php-sdk-binary-tools-php-sdk-%PHPSDK%" (
    @ECHO.
    @ECHO php-sdk-binary tools zip file not found in .\downloads please re-run this script
    PAUSE
    EXIT
)

REM -----------------------------------------------------------
REM --- EXTENSION DEPENDENCIES PREPARATION
REM -----------------------------------------------------------

IF NOT EXIST "%DIR%\downloads\zlib-1.2.11.tar.gz" (
    @ECHO.
    @ECHO loading zlib library...
    wget http://zlib.net/zlib-1.2.11.tar.gz -O %DIR%\downloads\zlib-1.2.11.tar.gz -N
)

IF NOT EXIST "%DIR%\downloads\zlib-1.2.11.tar.gz" (
    @ECHO.
    @ECHO zlib library not found in .\downloads please re-run this script
    PAUSE
    EXIT
)

@ECHO.
@ECHO unpacking zlib library...
7za x %DIR%\downloads\zlib-1.2.11.tar.gz -so | 7za x -si -ttar -o%DIR%\downloads\
cd %DIR%\downloads\zlib-1.2.11
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvars%ARCH%.bat"
cmake -G "Visual Studio 14 2015" -DCMAKE_BUILD_TYPE="Release" -DCMAKE_C_FLAGS_RELEASE="/MT"
cmake --build . --config "Release"

REM -----------------------------------------------------------
REM --- CLONE & COMPLING EXTENSION SRC
REM -----------------------------------------------------------

cd %DIR%\downloads\
git clone %GIT%
cd %DIR%\downloads\php-ext-excel-export
git submodule update --init
(
    ECHO phpize
    PING 127.0.0.1 -n 2 > nul
    ECHO var PHP_SECURITY_FLAGS = 'yes';>> %DIR%\downloads\php-ext-excel-export\configure.js
    ECHO configure.bat --with-xlswriter --with-extra-libs=%DIR%\downloads\zlib-1.2.11\Release --with-extra-includes=%DIR%\downloads\zlib-1.2.11
    ECHO nmake
) | "%DIR%\downloads\php-sdk-binary-tools-php-sdk-%PHPSDK%\phpsdk-%VC%-x%ARCH%.bat"

SET /P SHOULD_CLEAN=Do you want to clean downloads folder? [y/n]
IF /I %SHOULD_CLEAN%==Y (
    IF EXIST %DIR%\downloads RD /s /q %DIR%\downloads
)

PAUSE
EXIT

:UnZipFile <ExtractTo> <newzipfile>
SET vbs="%temp%\_.vbs"
IF EXIST %vbs% DEL /f /q %vbs%
>%vbs%  ECHO Set fso = CreateObject("Scripting.FileSystemObject")
>>%vbs% ECHO If NOT fso.FolderExists(%1) Then
>>%vbs% ECHO fso.CreateFolder(%1)
>>%vbs% ECHO End If
>>%vbs% ECHO set objShell = CreateObject("Shell.Application")
>>%vbs% ECHO set FilesInZip=objShell.NameSpace(%2).items
>>%vbs% ECHO call objShell.NameSpace(%1).CopyHere(FilesInZip, 16)
>>%vbs% ECHO Set fso = Nothing
>>%vbs% ECHO Set objShell = Nothing
CSCRIPT //nologo %vbs%
IF EXIST %vbs% DEL /f /q %vbs%
