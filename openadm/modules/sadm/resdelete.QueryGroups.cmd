      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      %sys.ColorNormal%
      @echo # [test-mode] removing access control group(s): [res-%VALUE_RESTYPE%-%input.LabelName%]
      @echo.

      %sys.ColorDark%

      if /i %scope.IsLocal% EQU %STATUS_ON% (
        set SecurityGroup.TypeIsRegular=%STATUS_ON%

        if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_ROLE%
          set SecurityGroup.TypeIsRegular=%STATUS_OFF%

          if /i %VALUE_RESTYPE:~0,1% EQU %VALUE_RESTYPE_SYSPRIV% (
            wmic group where "name like '!%VALUE_RESTYPE:¡=%-adm-%input.LabelName%%'" list brief
          ) else (
            wmic group where "name like '%VALUE_RESTYPE%-adm-%input.LabelName%%'" list brief
          )
        )

        if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_SVC%
          set SecurityGroup.TypeIsRegular=%STATUS_OFF%

          if /i %VALUE_RESTYPE:~0,1% EQU %VALUE_RESTYPE_SYSPRIV% (
            wmic group where "name like '¡role-%VALUE_RESTYPE:¡=%-%input.LabelName%%'" list brief
          ) else (
            wmic group where "name like 'role-%VALUE_RESTYPE%-%input.LabelName%%'" list brief
          )
        )

        if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_JOB%
          set SecurityGroup.TypeIsRegular=%STATUS_OFF%

          if /i %VALUE_RESTYPE:~0,1% EQU %VALUE_RESTYPE_SYSPRIV% (
            wmic group where "name like '¡role-%VALUE_RESTYPE:¡=%-%input.LabelName%%'" list brief
          ) else (
            wmic group where "name like 'role-%VALUE_RESTYPE%-%input.LabelName%%'" list brief
          )
        )

        if /i %SecurityGroup.TypeIsRegular% EQU %STATUS_ON% (
          wmic group where "name like 'res-%VALUE_RESTYPE%-%input.LabelName%%'" list brief
        )
      ) else (
        if /i %scope.IsAD% EQU %STATUS_ON% (
          set SecurityGroup.TypeIsRegular=%STATUS_ON%

          if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_ORG%
            set SecurityGroup.TypeIsRegular=%STATUS_OFF%
            %fs.BinDir%\dsquery group domainroot -name %VALUE_RESTYPE%-%input.LabelName%* -desc %VALUE_RESTYPE%-%input.LabelName%* -s %ds.server% -u %ds.user% -p %ds.passwd%
          )

          if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_ROLE%
            set SecurityGroup.TypeIsRegular=%STATUS_OFF%

            if /i %VALUE_RESTYPE:~0,1% EQU %VALUE_RESTYPE_SYSPRIV% (
              %fs.BinDir%\dsquery group domainroot -name ¡%VALUE_RESTYPE:¡=%-adm-%input.LabelName%* -desc !%VALUE_RESTYPE:¡=%-adm-%input.LabelName%* -s %ds.server% -u %ds.user% -p %ds.passwd%
            ) else (
              %fs.BinDir%\dsquery group domainroot -name %VALUE_RESTYPE%-adm-%input.LabelName%* -desc %VALUE_RESTYPE%-adm-%input.LabelName%* -s %ds.server% -u %ds.user% -p %ds.passwd%
            )
          )

          if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_SVC%
            set SecurityGroup.TypeIsRegular=%STATUS_OFF%

            if /i %VALUE_RESTYPE:~0,1% EQU %VALUE_RESTYPE_SYSPRIV% (
              %fs.BinDir%\dsquery group domainroot -name ¡sys-%VALUE_RESTYPE:¡=%-%input.LabelName%* -desc ¡sys-%VALUE_RESTYPE:¡=%-%input.LabelName%* -s %ds.server% -u %ds.user% -p %ds.passwd%
            ) else (
              %fs.BinDir%\dsquery group domainroot -name sys-%VALUE_RESTYPE%-%input.LabelName%* -desc sys-%VALUE_RESTYPE%-%input.LabelName%* -s %ds.server% -u %ds.user% -p %ds.passwd%
            )
          )

          if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_JOB%
            set SecurityGroup.TypeIsRegular=%STATUS_OFF%

            if /i %VALUE_RESTYPE:~0,1% EQU %VALUE_RESTYPE_SYSPRIV% (
              %fs.BinDir%\dsquery group domainroot -name ¡sys-%VALUE_RESTYPE:¡=%-%input.LabelName%* -desc ¡sys-%VALUE_RESTYPE:¡=%-%input.LabelName%* -s %ds.server% -u %ds.user% -p %ds.passwd%
            ) else (
              %fs.BinDir%\dsquery group domainroot -name sys-%VALUE_RESTYPE%-%input.LabelName%* -desc sys-%VALUE_RESTYPE%-%input.LabelName%* -s %ds.server% -u %ds.user% -p %ds.passwd%
            )
          )

          if /i %SecurityGroup.TypeIsRegular% EQU %STATUS_ON% (
            %fs.BinDir%\dsquery group domainroot -name res-%VALUE_RESTYPE%-%input.LabelName%* -desc res-%VALUE_RESTYPE%-%input.LabelName%* -s %ds.server% -u %ds.user% -p %ds.passwd%
          )
        ) else (
          set SecurityGroup.TypeIsRegular=%STATUS_ON%

          if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_ORG%
            set SecurityGroup.TypeIsRegular=%STATUS_OFF%
            if /i "%COMPUTERNAME%" EQU "%ds.server%" (
              wmic group where "name like '%VALUE_RESTYPE%-%input.LabelName%%'" list brief
            ) else (
              wmic /node:"%ds.server%" /user:"%ds.user%" /password:"%ds.passwd%" /implevel:impersonate group where "name like '%VALUE_RESTYPE%-%input.LabelName%%'" list brief
            )
          )

          if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_ROLE%
            set SecurityGroup.TypeIsRegular=%STATUS_OFF%

            if /i %VALUE_RESTYPE:~0,1% EQU %VALUE_RESTYPE_SYSPRIV% (
              if /i "%COMPUTERNAME%" EQU "%ds.server%" (
                wmic group where "name like '!%VALUE_RESTYPE:¡=%-adm-%input.LabelName%%'" list brief
              ) else (
                wmic /node:"%ds.server%" /user:"%ds.user%" /password:"%ds.passwd%" /implevel:impersonate group where "name like '!%VALUE_RESTYPE:¡=%-adm-%input.LabelName%%'" list brief
              )
            ) else (
              if /i "%COMPUTERNAME%" EQU "%ds.server%" (
                wmic group where "name like '%VALUE_RESTYPE%-adm-%input.LabelName%%'" list brief
              ) else (
                wmic /node:"%ds.server%" /user:"%ds.user%" /password:"%ds.passwd%" /implevel:impersonate group where "name like '%VALUE_RESTYPE%-adm-%input.LabelName%%'" list brief
              )
            )
          )

          if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_SVC%
            set SecurityGroup.TypeIsRegular=%STATUS_OFF%

            if /i %VALUE_RESTYPE:~0,1% EQU %VALUE_RESTYPE_SYSPRIV% (
              if /i "%COMPUTERNAME%" EQU "%ds.server%" (
                wmic group where "name like '¡sys-%VALUE_RESTYPE:¡=%-%input.LabelName%%'" list brief
              ) else (
                wmic /node:"%ds.server%" /user:"%ds.user%" /password:"%ds.passwd%" /implevel:impersonate group where "name like '¡sys-%VALUE_RESTYPE:¡=%-%input.LabelName%%'" list brief
              )
            ) else (
              if /i "%COMPUTERNAME%" EQU "%ds.server%" (
                wmic group where "name like 'sys-%VALUE_RESTYPE%-%input.LabelName%%'" list brief
              ) else (
                wmic /node:"%ds.server%" /user:"%ds.user%" /password:"%ds.passwd%" /implevel:impersonate group where "name like 'sys-%VALUE_RESTYPE%-%input.LabelName%%'" list brief
              )
            )
          )

          if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_JOB%
            set SecurityGroup.TypeIsRegular=%STATUS_OFF%

            if /i %VALUE_RESTYPE:~0,1% EQU %VALUE_RESTYPE_SYSPRIV% (
              if /i "%COMPUTERNAME%" EQU "%ds.server%" (
                wmic group where "name like '¡sys-%VALUE_RESTYPE:¡=%-%input.LabelName%%'" list brief
              ) else (
                wmic /node:"%ds.server%" /user:"%ds.user%" /password:"%ds.passwd%" /implevel:impersonate group where "name like '¡sys-%VALUE_RESTYPE:¡=%-%input.LabelName%%'" list brief
              )
            ) else (
              if /i "%COMPUTERNAME%" EQU "%ds.server%" (
                wmic group where "name like 'sys-%VALUE_RESTYPE%-%input.LabelName%%'" list brief
              ) else (
                wmic /node:"%ds.server%" /user:"%ds.user%" /password:"%ds.passwd%" /implevel:impersonate group where "name like 'sys-%VALUE_RESTYPE%-%input.LabelName%%'" list brief
              )
            )
          )

          if /i %SecurityGroup.TypeIsRegular% EQU %STATUS_ON% (
            if /i "%COMPUTERNAME%" EQU "%ds.server%" (
              wmic group where "name like 'res-%VALUE_RESTYPE%-%input.LabelName%%'" list brief
            ) else (
              wmic /node:"%ds.server%" /user:"%ds.user%" /password:"%ds.passwd%" /implevel:impersonate group where "name like 'res-%VALUE_RESTYPE%-%input.LabelName%%'" list brief
            )
          )
        )
      )

      %sys.ColorNormal%