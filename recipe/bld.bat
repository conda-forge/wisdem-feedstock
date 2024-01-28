@echo on
setlocal enabledelayedexpansion

REM check if clang-cl is on path as required
clang-cl.exe --version
if %ERRORLEVEL% neq 0 exit 1

REM set compilers to clang-cl
set "CC=clang-cl"
set "CXX=clang-cl"

REM flang 17 still uses "temporary" name
set "FC=flang-new"

REM need to read clang version for path to compiler-rt
FOR /F "tokens=* USEBACKQ" %%F IN (`clang.exe -dumpversion`) DO (
    SET "CLANG_VER=%%F"
)

REM attempt to match flags for flang as we set them for clang-on-win, see
REM https://github.com/conda-forge/clang-win-activation-feedstock/blob/main/recipe/activate-clang_win-64.sh
REM however, -Xflang --dependent-lib=msvcrt currently fails as an unrecognized option, see also
REM https://github.com/llvm/llvm-project/issues/63741
set "FFLAGS=-D_CRT_SECURE_NO_WARNINGS -D_MT -D_DLL --target=x86_64-pc-windows-msvc -nostdlib"
REM set "LDFLAGS=--target=x86_64-pc-windows-msvc -nostdlib -Xclang --dependent-lib=msvcrt -fuse-ld=lld"
REM set "LDFLAGS=%LDFLAGS% -Wl,-defaultlib:%BUILD_PREFIX%/Library/lib/clang/!CLANG_VER:~0,2!/lib/windows/clang_rt.builtins-x86_64.lib"

cd %SRC_DIR%
set NP_INC=%SP_DIR%\numpy\core\include
REM set CC=cl
REM set FC=flang
REM set CC_LD=link

REM See the unix build.sh for more details on the build process below.
set MESON_ARGS=-Dincdir_numpy=%NP_INC% -Dpython_target=%PYTHON% %EXTRA_FLAGS%

%PYTHON% -m build -n -x -w .
REM %PYTHON% -m pip install --prefix "%PREFIX%" --no-deps dist/wisdem-3.9-py3-none-any.whl
REM %PYTHON% setup.py install --single-version-externally-managed --record=record.txt
REM pip install --prefix "%PREFIX%" --no-deps --no-index --find-links dist pyoptsparse
REM `pip install dist\numpy*.whl` does not work on windows,
REM so use a loop; there's only one wheel in dist/ anyway
for /f %%f in ('dir /b /S .\dist') do (
    REM need to use force to reinstall the tests the second time
    REM (otherwise pip thinks the package is installed already)
    %PYTHON% -m pip install --prefix "%PREFIX%" --no-deps %%f
    if %ERRORLEVEL% neq 0 exit 1
)
REM rmdir /s /q %SP_DIR%\meson_build
