    @echo.
    %sys.ColorBright%
    @echo # ------------------------------------------------------------------------
    %sys.ColorNormal%
    @echo # elements recorded on resource log
    @echo.

    %sys.ColorDark%

    for /d %fs.CmdbDir% %%i in (*) do (
      for /f %%j in ('dir /b /s *.cmd') do (
        for /f "tokens=* eol=#" %%k in (%%j) do (
          @echo   + session:[%%~ni] - action:[%%~nj] - command:[%%k]
        )
      )
    )

    %sys.ColorNormal%