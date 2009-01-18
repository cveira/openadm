      setlocal enabledelayedexpansion
        if /i %VALUE_RESTYPE:~0,1% NEQ %VALUE_RESTYPE_SYSPRIV% (
          set SecurityGroup.TypeIsNotRes=%STATUS_OFF%

          if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_ORG% (
            @echo # [test-mode] creating access control security groups [%VALUE_RESTYPE%-%input.LabelName%]
            @echo.

            set SecurityGroup.TypeIsNotRes=%STATUS_ON%

            %sys.ColorDark%

            @echo   + %VALUE_RESTYPE%-%input.LabelName%

            %sys.ColorNormal%
          )

          if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_ROLE% (
            @echo # [test-mode] creating access control security groups [%VALUE_RESTYPE%-adm-%input.LabelName%]
            @echo.

            set SecurityGroup.TypeIsNotRes=%STATUS_ON%

            %sys.ColorDark%

            @echo   + %VALUE_RESTYPE%-adm-%input.LabelName%

            %sys.ColorNormal%

          )

          if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_SVC% (
            set SecurityGroup.TypeIsNotRes=%STATUS_ON%

            if /i %scope.IsLocal% EQU %STATUS_ON% (
              @echo # [test-mode] creating access control security groups [res-%VALUE_RESTYPE%-%input.LabelName%]
              @echo.

              %sys.ColorDark%

              @echo   + role-%VALUE_RESTYPE%-%input.LabelName%

              %sys.ColorNormal%
            ) else (
              @echo # [test-mode] creating access control security groups [sys-%VALUE_RESTYPE%-%input.LabelName%]
              @echo.

              %sys.ColorDark%

              @echo   + sys-%VALUE_RESTYPE%-%input.LabelName%

              %sys.ColorNormal%
            )
          )

          if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_JOB% (
            set SecurityGroup.TypeIsNotRes=%STATUS_ON%

            if /i %scope.IsLocal% EQU %STATUS_ON% (
              @echo # [test-mode] creating access control security groups [res-%VALUE_RESTYPE%-%input.LabelName%]
              @echo.

              %sys.ColorDark%

              @echo   + role-%VALUE_RESTYPE%-%input.LabelName%

              %sys.ColorNormal%
            ) else (
              @echo # [test-mode] creating access control security groups [sys-%VALUE_RESTYPE%-%input.LabelName%]
              @echo.

              %sys.ColorDark%

              @echo   + sys-%VALUE_RESTYPE%-%input.LabelName%

              %sys.ColorNormal%
            )
          )

          if /i !SecurityGroup.TypeIsNotRes! EQU %STATUS_OFF% (
            @echo # [test-mode] creating access control security groups [%VALUE_RESTYPE%-%input.LabelName%]
            @echo.

            %sys.ColorDark%

            if /i %VALUE_ACLPROFILE% EQU %VALUE_ACLPROFILE_SINGLE% (
              @echo   + res-%VALUE_RESTYPE%-%input.LabelName%
            )

            if /i %VALUE_ACLPROFILE% EQU %VALUE_ACLPROFILE_BIT% (
              @echo   + res-%VALUE_RESTYPE%-%input.LabelName%
              @echo   + res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_DA%
            )

            set SecurityGroup.ProfileIsDefault=%STATUS_OFF%
            if /i %VALUE_ACLPROFILE% EQU %VALUE_ACLPROFILE_DEFAULT%        set SecurityGroup.ProfileIsDefault=%STATUS_ON%
            if /i %VALUE_ACLPROFILE% EQU %VALUE_ACLPROFILE_DEFAULTINHERIT% set SecurityGroup.ProfileIsDefault=%STATUS_ON%

            if /i !SecurityGroup.ProfileIsDefault! EQU %STATUS_ON% (
              @echo   + res-%VALUE_RESTYPE%-%input.LabelName%
              @echo   + res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_DA%
              @echo   + res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RX%
            )

            set SecurityGroup.ProfileIsFull=%STATUS_OFF%
            if /i %VALUE_ACLPROFILE% EQU %VALUE_ACLPROFILE_FULL%        set SecurityGroup.ProfileIsFull=%STATUS_ON%
            if /i %VALUE_ACLPROFILE% EQU %VALUE_ACLPROFILE_FULLINHERIT% set SecurityGroup.ProfileIsFull=%STATUS_ON%

            if /i !SecurityGroup.ProfileIsFull! EQU %STATUS_ON% (
              @echo   + res-%VALUE_RESTYPE%-%input.LabelName%
              @echo   + res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_DA%
              @echo   + res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RX%
              @echo   + res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RO%
              @echo   + res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RW%
              @echo   + res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RWX%
              @echo   + res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_WO%
              @echo   + res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_LO%
            )

            %sys.ColorNormal%
          )
        ) else (
          if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_ROLE% (
            @echo # [test-mode] creating access control security group [¡%VALUE_RESTYPE%-adm-%input.LabelName%]
            @echo.

            %sys.ColorDark%

            @echo   + !%VALUE_RESTYPE:¡=%-adm-%input.LabelName%

            %sys.ColorNormal%
          )

          if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_SVC% (
            if /i %scope.IsLocal% EQU %STATUS_ON% (
              @echo # [test-mode] creating access control security group [¡role-%VALUE_RESTYPE%-%input.LabelName%]
              @echo.

              %sys.ColorDark%

              @echo   + ¡role-%VALUE_RESTYPE:¡=%-%input.LabelName%

              %sys.ColorNormal%
            ) else (
              @echo # [test-mode] creating access control security group [¡sys-%VALUE_RESTYPE%-%input.LabelName%]
              @echo.

              %sys.ColorDark%

              @echo   + ¡sys-%VALUE_RESTYPE:¡=%-%input.LabelName%

              %sys.ColorNormal%
            )
          )

          if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_JOB% (
            if /i %scope.IsLocal% EQU %STATUS_ON% (
              @echo # [test-mode] creating access control security group [¡role-%VALUE_RESTYPE%-%input.LabelName%]
              @echo.

              %sys.ColorDark%

              @echo   + ¡role-%VALUE_RESTYPE:¡=%-%input.LabelName%

              %sys.ColorNormal%
            ) else (
              @echo # [test-mode] creating access control security group [¡sys-%VALUE_RESTYPE%-%input.LabelName%]
              @echo.

              %sys.ColorDark%

              @echo   + ¡sys-%VALUE_RESTYPE:¡=%-%input.LabelName%

              %sys.ColorNormal%
            )
          )
        )


        if /i %VALUE_RESTYPE:~0,1% EQU %VALUE_RESTYPE_SYSPRIV% (
          if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_ROLE%   set SecurityGroup.RootName=¡%VALUE_RESTYPE:¡=%-adm-%input.LabelName%

          if %scope.IsLocal% EQU %STATUS_OFF% (
            if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_SVC%  set SecurityGroup.RootName=¡sys-%VALUE_RESTYPE:¡=%-%input.LabelName%
            if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_JOB%  set SecurityGroup.RootName=¡sys-%VALUE_RESTYPE:¡=%-%input.LabelName%
          ) else (
            if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_SVC%  set SecurityGroup.RootName=¡role-%VALUE_RESTYPE:¡=%-%input.LabelName%
            if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_JOB%  set SecurityGroup.RootName=¡role-%VALUE_RESTYPE:¡=%-%input.LabelName%
          )
        ) else (
          set SecurityGroup.RootName=res-%input.LabelName%

          if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_ORG%    set SecurityGroup.RootName=org-%input.LabelName%
          if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_ROLE%   set SecurityGroup.RootName=role-adm-%input.LabelName%

          if %scope.IsLocal% EQU %STATUS_OFF% (
            if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_SVC%  set SecurityGroup.RootName=sys-%VALUE_RESTYPE%-%input.LabelName%
            if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_JOB%  set SecurityGroup.RootName=sys-%VALUE_RESTYPE%-%input.LabelName%
          ) else (
            if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_SVC%  set SecurityGroup.RootName=role-%VALUE_RESTYPE%-%input.LabelName%
            if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_JOB%  set SecurityGroup.RootName=role-%VALUE_RESTYPE%-%input.LabelName%
          )
        )

        @echo.
        @echo # [test-mode] querying target resource objects: !SecurityGroup.RootName!
        @echo.

        %sys.ColorDark%

        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LOCAL%     wmic group where "name like '!SecurityGroup.RootName!%'" list brief

        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_NTDOMAIN (
          if /i "%COMPUTERNAME%" EQU "%ds.server%" (
            wmic group where "name like '!SecurityGroup.RootName!%'" list brief
          ) else (
            wmic /node:"%ds.server%" /user:"%ds.user%" /password:"%ds.passwd%" /implevel:impersonate group where "name like '!SecurityGroup.RootName!%'" list brief
          )
        )

        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_ADDOMAIN%  %fs.BinDir%\dsquery group domainroot -name !SecurityGroup.RootName!* -desc !SecurityGroup.RootName!* -s %ds.server% -u %ds.user% -p %ds.passwd%

        %sys.ColorNormal%
      endlocal