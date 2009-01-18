        if /i %VALUE_RESTYPE:~0,1% NEQ %VALUE_RESTYPE_SYSPRIV% (
          setlocal enabledelayedexpansion
            @echo # creating access control security groups [%VALUE_RESTYPE%-%input.LabelName%]
            @echo.

            set SecurityGroup.TypeIsNotRes=%STATUS_OFF%

            if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_ORG% (
              @echo   + %VALUE_RESTYPE%-%input.LabelName%
              @echo.

              %sys.ColorDark%

              set SecurityGroup.TypeIsNotRes=%STATUS_ON%

              if /i %scope.IsLocal% EQU %STATUS_ON% (
                net localgroup %VALUE_RESTYPE%-%input.LabelName% /add /comment:"%VALUE_RESTYPE%-%input.LabelName%"

                if %errorlevel% EQU %EL_NET_OK% (
                  @echo     + group creation status: OK
                ) else (
                  @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                  @echo     + group creation status: FAIL
                )
              ) else (
                if /i %scope.IsAD% EQU %STATUS_ON% (
                  %fs.BinDir%\dsadd group "CN=%VALUE_RESTYPE%-%input.LabelName%,%ds.OrgObjectsPath%" -samid "%VALUE_RESTYPE%-%input.LabelName%" -desc "%VALUE_RESTYPE%-%input.LabelName%" -secgrp yes -scope l -s %ds.server% -u %ds.user% -p %ds.passwd%

                  if %errorlevel% EQU %EL_DSADD_OK% (
                    @echo     + group creation status: OK
                  ) else (
                    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                    @echo     + group creation status: FAIL
                  )
                ) else (
                  net group %VALUE_RESTYPE%-%input.LabelName% /add /comment:"%VALUE_RESTYPE%-%input.LabelName%" /domain

                  if %errorlevel% EQU %EL_NET_OK% (
                    @echo     + group creation status: OK
                  ) else (
                    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                    @echo     + group creation status: FAIL
                  )
                )
              )

              @echo.
              %sys.ColorNormal%
            )


            if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_ROLE% (
              @echo   + %VALUE_RESTYPE%-adm-%input.LabelName%
              @echo.

              %sys.ColorDark%

              set SecurityGroup.TypeIsNotRes=%STATUS_ON%

              if /i %scope.IsLocal% EQU %STATUS_ON% (
                net localgroup %VALUE_RESTYPE%-adm-%input.LabelName% /add /comment:"%VALUE_RESTYPE%-adm-%input.LabelName%"

                if %errorlevel% EQU %EL_NET_OK% (
                  @echo     + group creation status: OK
                ) else (
                  @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                  @echo     + group creation status: FAIL
                )
              ) else (
                if /i %scope.IsAD% EQU %STATUS_ON% (
                  %fs.BinDir%\dsadd group "CN=%VALUE_RESTYPE%-adm-%input.LabelName%,%ds.AdmObjectsPath%" -samid "%VALUE_RESTYPE%-adm-%input.LabelName%" -desc "%VALUE_RESTYPE%-adm-%input.LabelName%" -secgrp yes -scope l -s %ds.server% -u %ds.user% -p %ds.passwd%

                  if %errorlevel% EQU %EL_DSADD_OK% (
                    @echo     + group creation status: OK
                  ) else (
                    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                    @echo     + group creation status: FAIL
                  )
                ) else (
                  net group %VALUE_RESTYPE%-adm-%input.LabelName% /add /comment:"%VALUE_RESTYPE%-adm-%input.LabelName%" /domain

                  if %errorlevel% EQU %EL_NET_OK% (
                    @echo     + group creation status: OK
                  ) else (
                    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                    @echo     + group creation status: FAIL
                  )
                )
              )

              @echo.
              %sys.ColorNormal%
            )


            if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_SVC% (
              set SecurityGroup.TypeIsNotRes=%STATUS_ON%

              if /i %scope.IsLocal% EQU %STATUS_ON% (
                @echo   + role-%VALUE_RESTYPE%-%input.LabelName%
                @echo.

                %sys.ColorDark%

                net localgroup role-%VALUE_RESTYPE%-%input.LabelName% /add /comment:"role-%VALUE_RESTYPE%-%input.LabelName%"

                if %errorlevel% EQU %EL_NET_OK% (
                  @echo     + group creation status: OK
                ) else (
                  @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                  @echo     + group creation status: FAIL
                )
              ) else (
                @echo   + sys-%VALUE_RESTYPE%-%input.LabelName%
                @echo.

                %sys.ColorDark%

                if /i %scope.IsAD% EQU %STATUS_ON% (
                  %fs.BinDir%\dsadd group "CN=sys-%VALUE_RESTYPE%-%input.LabelName%,%ds.ServiceObjectsPath%" -samid "sys-%VALUE_RESTYPE%-%input.LabelName%" -desc "sys-%VALUE_RESTYPE%-%input.LabelName%" -secgrp yes -scope l -s %ds.server% -u %ds.user% -p %ds.passwd%

                  if %errorlevel% EQU %EL_DSADD_OK% (
                    @echo     + group creation status: OK
                  ) else (
                    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                    @echo     + group creation status: FAIL
                  )
                ) else (
                  net group sys-%VALUE_RESTYPE%-%input.LabelName% /add /comment:"sys-%VALUE_RESTYPE%-%input.LabelName%" /domain

                  if %errorlevel% EQU %EL_NET_OK% (
                    @echo     + group creation status: OK
                  ) else (
                    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                    @echo     + group creation status: FAIL
                  )
                )
              )

              @echo.
              %sys.ColorNormal%
            )


            if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_JOB% (
              set SecurityGroup.TypeIsNotRes=%STATUS_ON%

              if /i %scope.IsLocal% EQU %STATUS_ON% (
                @echo   + role-%VALUE_RESTYPE%-%input.LabelName%
                @echo.

                %sys.ColorDark%

                net localgroup role-%VALUE_RESTYPE%-%input.LabelName% /add /comment:"role-%VALUE_RESTYPE%-%input.LabelName%"

                if %errorlevel% EQU %EL_NET_OK% (
                  @echo     + group creation status: OK
                ) else (
                  @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                  @echo     + group creation status: FAIL
                )
              ) else (
                @echo   + sys-%VALUE_RESTYPE%-%input.LabelName%
                @echo.

                %sys.ColorDark%

                if /i %scope.IsAD% EQU %STATUS_ON% (
                  %fs.BinDir%\dsadd group "CN=sys-%VALUE_RESTYPE%-%input.LabelName%,%ds.JobObjectsPath%" -samid "sys-%VALUE_RESTYPE%-%input.LabelName%" -desc "sys-%VALUE_RESTYPE%-%input.LabelName%" -secgrp yes -scope l -s %ds.server% -u %ds.user% -p %ds.passwd%

                  if %errorlevel% EQU %EL_DSADD_OK% (
                    @echo     + group creation status: OK
                  ) else (
                    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                    @echo     + group creation status: FAIL
                  )
                ) else (
                  net group sys-%VALUE_RESTYPE%-%input.LabelName% /add /comment:"sys-%VALUE_RESTYPE%-%input.LabelName%" /domain

                  if %errorlevel% EQU %EL_NET_OK% (
                    @echo     + group creation status: OK
                  ) else (
                    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                    @echo     + group creation status: FAIL
                  )
                )
              )

              @echo.
              %sys.ColorNormal%
            )


            if /i !SecurityGroup.TypeIsNotRes! EQU %STATUS_OFF% (
              if /i %VALUE_ACLPROFILE% EQU %VALUE_ACLPROFILE_SINGLE% (
                @echo   + res-%VALUE_RESTYPE%-%input.LabelName%
                @echo.

                %sys.ColorDark%

                if /i %scope.IsLocal% EQU %STATUS_ON% (
                  net localgroup res-%VALUE_RESTYPE%-%input.LabelName% /add /comment:"res-%VALUE_RESTYPE%-%input.LabelName%"

                  if %errorlevel% EQU %EL_NET_OK% (
                    @echo     + group creation status: OK
                  ) else (
                    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                    @echo     + group creation status: FAIL
                  )
                ) else (
                  if /i %scope.IsAD% EQU %STATUS_ON% (
                    %fs.BinDir%\dsadd group "CN=res-%VALUE_RESTYPE%-%input.LabelName%,%ds.ResourceObjectsPath%" -samid "res-%VALUE_RESTYPE%-%input.LabelName%" -desc "res-%VALUE_RESTYPE%-%input.LabelName%" -secgrp yes -scope l -s %ds.server% -u %ds.user% -p %ds.passwd%

                    if %errorlevel% EQU %EL_DSADD_OK% (
                      @echo     + group creation status: OK
                    ) else (
                      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                      @echo     + group creation status: FAIL
                    )
                  ) else (
                    net group res-%VALUE_RESTYPE%-%input.LabelName% /add /comment:"res-%VALUE_RESTYPE%-%input.LabelName%" /domain

                    if %errorlevel% EQU %EL_NET_OK% (
                      @echo     + group creation status: OK
                    ) else (
                      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                      @echo     + group creation status: FAIL
                    )
                  )
                )

                @echo.
                %sys.ColorNormal%
              )




              if /i %VALUE_ACLPROFILE% EQU %VALUE_ACLPROFILE_BIT% (
                @echo   + res-%VALUE_RESTYPE%-%input.LabelName%
                @echo.

                %sys.ColorDark%

                if /i %scope.IsLocal% EQU %STATUS_ON% (
                  net localgroup res-%VALUE_RESTYPE%-%input.LabelName% /add /comment:"res-%VALUE_RESTYPE%-%input.LabelName%"

                  if %errorlevel% EQU %EL_NET_OK% (
                    @echo     + group creation status: OK
                  ) else (
                    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                    @echo     + group creation status: FAIL
                  )
                ) else (
                  if /i %scope.IsAD% EQU %STATUS_ON% (
                    %fs.BinDir%\dsadd group "CN=res-%VALUE_RESTYPE%-%input.LabelName%,%ds.ResourceObjectsPath%" -samid "res-%VALUE_RESTYPE%-%input.LabelName%" -desc "res-%VALUE_RESTYPE%-%input.LabelName%" -secgrp yes -scope l -s %ds.server% -u %ds.user% -p %ds.passwd%

                    if %errorlevel% EQU %EL_DSADD_OK% (
                      @echo     + group creation status: OK
                    ) else (
                      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                      @echo     + group creation status: FAIL
                    )
                  ) else (
                    net group res-%VALUE_RESTYPE%-%input.LabelName% /add /comment:"res-%VALUE_RESTYPE%-%input.LabelName%" /domain

                    if %errorlevel% EQU %EL_NET_OK% (
                      @echo     + group creation status: OK
                    ) else (
                      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                      @echo     + group creation status: FAIL
                    )
                  )
                )

                @echo.
                %sys.ColorNormal%


                @echo   + res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_DA%
                @echo.

                %sys.ColorDark%

                if /i %scope.IsLocal% EQU %STATUS_ON% (
                  net localgroup res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_DA% /add /comment:"res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_DA%"

                  if %errorlevel% EQU %EL_NET_OK% (
                    @echo     + group creation status: OK
                  ) else (
                    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                    @echo     + group creation status: FAIL
                  )
                ) else (
                  if /i %scope.IsAD% EQU %STATUS_ON% (
                    %fs.BinDir%\dsadd group "CN=res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_DA%,%ds.ResourceObjectsPath%" -samid "res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_DA%" -desc "res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_DA%" -secgrp yes -scope l -s %ds.server% -u %ds.user% -p %ds.passwd%

                    if %errorlevel% EQU %EL_DSADD_OK% (
                      @echo     + group creation status: OK
                    ) else (
                      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                      @echo     + group creation status: FAIL
                    )
                  ) else (
                    net group res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_DA% /add /comment:"res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_DA%" /domain

                    if %errorlevel% EQU %EL_NET_OK% (
                      @echo     + group creation status: OK
                    ) else (
                      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                      @echo     + group creation status: FAIL
                    )
                  )
                )

                @echo.
                %sys.ColorNormal%
              )


              set SecurityGroup.ProfileIsDefault=%STATUS_OFF%
              if /i %VALUE_ACLPROFILE% EQU %VALUE_ACLPROFILE_DEFAULT%        set SecurityGroup.ProfileIsDefault=%STATUS_ON%
              if /i %VALUE_ACLPROFILE% EQU %VALUE_ACLPROFILE_DEFAULTINHERIT% set SecurityGroup.ProfileIsDefault=%STATUS_ON%


              if /i !SecurityGroup.ProfileIsDefault! EQU %STATUS_ON% (
                @echo   + res-%VALUE_RESTYPE%-%input.LabelName%
                @echo.

                %sys.ColorDark%

                if /i %scope.IsLocal% EQU %STATUS_ON% (
                  net localgroup res-%VALUE_RESTYPE%-%input.LabelName% /add /comment:"res-%VALUE_RESTYPE%-%input.LabelName%"

                  if %errorlevel% EQU %EL_NET_OK% (
                    @echo     + group creation status: OK
                  ) else (
                    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                    @echo     + group creation status: FAIL
                  )
                ) else (
                  if /i %scope.IsAD% EQU %STATUS_ON% (
                    %fs.BinDir%\dsadd group "CN=res-%VALUE_RESTYPE%-%input.LabelName%,%ds.ResourceObjectsPath%" -samid "res-%VALUE_RESTYPE%-%input.LabelName%" -desc "res-%VALUE_RESTYPE%-%input.LabelName%" -secgrp yes -scope l -s %ds.server% -u %ds.user% -p %ds.passwd%

                    if %errorlevel% EQU %EL_DSADD_OK% (
                      @echo     + group creation status: OK
                    ) else (
                      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                      @echo     + group creation status: FAIL
                    )
                  ) else (
                    net group res-%VALUE_RESTYPE%-%input.LabelName% /add /comment:"res-%VALUE_RESTYPE%-%input.LabelName%" /domain

                    if %errorlevel% EQU %EL_NET_OK% (
                      @echo     + group creation status: OK
                    ) else (
                      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                      @echo     + group creation status: FAIL
                    )
                  )
                )

                @echo.
                %sys.ColorNormal%


                @echo   + res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_DA%
                @echo.

                %sys.ColorDark%

                if /i %scope.IsLocal% EQU %STATUS_ON% (
                  net localgroup res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_DA% /add /comment:"res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_DA%"

                  if %errorlevel% EQU %EL_NET_OK% (
                    @echo     + group creation status: OK
                  ) else (
                    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                    @echo     + group creation status: FAIL
                  )
                ) else (
                  if /i %scope.IsAD% EQU %STATUS_ON% (
                    %fs.BinDir%\dsadd group "CN=res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_DA%,%ds.ResourceObjectsPath%" -samid "res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_DA%" -desc "res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_DA%" -secgrp yes -scope l -s %ds.server% -u %ds.user% -p %ds.passwd%

                    if %errorlevel% EQU %EL_DSADD_OK% (
                      @echo     + group creation status: OK
                    ) else (
                      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                      @echo     + group creation status: FAIL
                    )
                  ) else (
                    net group res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_DA% /add /comment:"res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_DA%" /domain

                    if %errorlevel% EQU %EL_NET_OK% (
                      @echo     + group creation status: OK
                    ) else (
                      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                      @echo     + group creation status: FAIL
                    )
                  )
                )

                @echo.
                %sys.ColorNormal%


                @echo   + res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RX%
                @echo.

                %sys.ColorDark%

                if /i %scope.IsLocal% EQU %STATUS_ON% (
                  net localgroup res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RX% /add /comment:"res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RX%"

                  if %errorlevel% EQU %EL_NET_OK% (
                    @echo     + group creation status: OK
                  ) else (
                    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                    @echo     + group creation status: FAIL
                  )
                ) else (
                  if /i %scope.IsAD% EQU %STATUS_ON% (
                    %fs.BinDir%\dsadd group "CN=res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RX%,%ds.ResourceObjectsPath%" -samid "res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RX%" -desc "res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RX%" -secgrp yes -scope l -s %ds.server% -u %ds.user% -p %ds.passwd%

                    if %errorlevel% EQU %EL_DSADD_OK% (
                      @echo     + group creation status: OK
                    ) else (
                      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                      @echo     + group creation status: FAIL
                    )
                  ) else (
                    net group res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RX% /add /comment:"res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RX%" /domain

                    if %errorlevel% EQU %EL_NET_OK% (
                      @echo     + group creation status: OK
                    ) else (
                      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                      @echo     + group creation status: FAIL
                    )
                  )
                )

                @echo.
                %sys.ColorNormal%
              )


              set SecurityGroup.ProfileIsFull=%STATUS_OFF%
              if /i %VALUE_ACLPROFILE% EQU %VALUE_ACLPROFILE_FULL%        set SecurityGroup.ProfileIsFull=%STATUS_ON%
              if /i %VALUE_ACLPROFILE% EQU %VALUE_ACLPROFILE_FULLINHERIT% set SecurityGroup.ProfileIsFull=%STATUS_ON%


              if /i !SecurityGroup.ProfileIsFull! EQU %STATUS_ON% (
                @echo   + res-%VALUE_RESTYPE%-%input.LabelName%
                @echo.

                %sys.ColorDark%

                if /i %scope.IsLocal% EQU %STATUS_ON% (
                  net localgroup res-%VALUE_RESTYPE%-%input.LabelName% /add /comment:"res-%VALUE_RESTYPE%-%input.LabelName%"

                  if %errorlevel% EQU %EL_NET_OK% (
                    @echo     + group creation status: OK
                  ) else (
                    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                    @echo     + group creation status: FAIL
                  )
                ) else (
                  if /i %scope.IsAD% EQU %STATUS_ON% (
                    %fs.BinDir%\dsadd group "CN=res-%VALUE_RESTYPE%-%input.LabelName%,%ds.ResourceObjectsPath%" -samid "res-%VALUE_RESTYPE%-%input.LabelName%" -desc "res-%VALUE_RESTYPE%-%input.LabelName%" -secgrp yes -scope l -s %ds.server% -u %ds.user% -p %ds.passwd%

                    if %errorlevel% EQU %EL_DSADD_OK% (
                      @echo     + group creation status: OK
                    ) else (
                      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                      @echo     + group creation status: FAIL
                    )
                  ) else (
                    net group res-%VALUE_RESTYPE%-%input.LabelName% /add /comment:"res-%VALUE_RESTYPE%-%input.LabelName%" /domain

                    if %errorlevel% EQU %EL_NET_OK% (
                      @echo     + group creation status: OK
                    ) else (
                      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                      @echo     + group creation status: FAIL
                    )
                  )
                )

                @echo.
                %sys.ColorNormal%


                @echo   + res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_DA%
                @echo.

                %sys.ColorDark%

                if /i %scope.IsLocal% EQU %STATUS_ON% (
                  net localgroup res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_DA% /add /comment:"res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_DA%"

                  if %errorlevel% EQU %EL_NET_OK% (
                    @echo     + group creation status: OK
                  ) else (
                    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                    @echo     + group creation status: FAIL
                  )
                ) else (
                  if /i %scope.IsAD% EQU %STATUS_ON% (
                    %fs.BinDir%\dsadd group "CN=res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_DA%,%ds.ResourceObjectsPath%" -samid "res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_DA%" -desc "res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_DA%" -secgrp yes -scope l -s %ds.server% -u %ds.user% -p %ds.passwd%

                    if %errorlevel% EQU %EL_DSADD_OK% (
                      @echo     + group creation status: OK
                    ) else (
                      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                      @echo     + group creation status: FAIL
                    )
                  ) else (
                    net group res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_DA% /add /comment:"res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_DA%" /domain

                    if %errorlevel% EQU %EL_NET_OK% (
                      @echo     + group creation status: OK
                    ) else (
                      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                      @echo     + group creation status: FAIL
                    )
                  )
                )

                @echo.
                %sys.ColorNormal%


                @echo   + res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RX%
                @echo.

                %sys.ColorDark%

                if /i %scope.IsLocal% EQU %STATUS_ON% (
                  net localgroup res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RX% /add /comment:"res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RX%"

                  if %errorlevel% EQU %EL_NET_OK% (
                    @echo     + group creation status: OK
                  ) else (
                    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                    @echo     + group creation status: FAIL
                  )
                ) else (
                  if /i %scope.IsAD% EQU %STATUS_ON% (
                    %fs.BinDir%\dsadd group "CN=res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RX%,%ds.ResourceObjectsPath%" -samid "res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RX%" -desc "res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RX%" -secgrp yes -scope l -s %ds.server% -u %ds.user% -p %ds.passwd%

                    if %errorlevel% EQU %EL_DSADD_OK% (
                      @echo     + group creation status: OK
                    ) else (
                      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                      @echo     + group creation status: FAIL
                    )
                  ) else (
                    net group res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RX% /add /comment:"res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RX%" /domain

                    if %errorlevel% EQU %EL_NET_OK% (
                      @echo     + group creation status: OK
                    ) else (
                      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                      @echo     + group creation status: FAIL
                    )
                  )
                )

                @echo.
                %sys.ColorNormal%


                @echo   + res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RO%
                @echo.

                %sys.ColorDark%

                if /i %scope.IsLocal% EQU %STATUS_ON% (
                  net localgroup res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RO% /add /comment:"res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RO%"

                  if %errorlevel% EQU %EL_NET_OK% (
                    @echo     + group creation status: OK
                  ) else (
                    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                    @echo     + group creation status: FAIL
                  )

                ) else (
                  if /i %scope.IsAD% EQU %STATUS_ON% (
                    %fs.BinDir%\dsadd group "CN=res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RO%,%ds.ResourceObjectsPath%" -samid "res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RO%" -desc "res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RO%" -secgrp yes -scope l -s %ds.server% -u %ds.user% -p %ds.passwd%

                    if %errorlevel% EQU %EL_DSADD_OK% (
                      @echo     + group creation status: OK
                    ) else (
                      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                      @echo     + group creation status: FAIL
                    )
                  ) else (
                    net group res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RO% /add /comment:"res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RO%" /domain

                    if %errorlevel% EQU %EL_NET_OK% (
                      @echo     + group creation status: OK
                    ) else (
                      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                      @echo     + group creation status: FAIL
                    )
                  )
                )

                @echo.
                %sys.ColorNormal%


                @echo   + res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RW%
                @echo.

                %sys.ColorDark%

                if /i %scope.IsLocal% EQU %STATUS_ON% (
                  net localgroup res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RW% /add /comment:"res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RW%"

                  if %errorlevel% EQU %EL_NET_OK% (
                    @echo     + group creation status: OK
                  ) else (
                    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                    @echo     + group creation status: FAIL
                  )
                ) else (
                  if /i %scope.IsAD% EQU %STATUS_ON% (
                    %fs.BinDir%\dsadd group "CN=res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RW%,%ds.ResourceObjectsPath%" -samid "res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RW%" -desc "res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RW%" -secgrp yes -scope l -s %ds.server% -u %ds.user% -p %ds.passwd%

                    if %errorlevel% EQU %EL_DSADD_OK% (
                      @echo     + group creation status: OK
                    ) else (
                      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                      @echo     + group creation status: FAIL
                    )
                  ) else (
                    net group res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RW% /add /comment:"res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RW%" /domain

                    if %errorlevel% EQU %EL_NET_OK% (
                      @echo     + group creation status: OK
                    ) else (
                      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                      @echo     + group creation status: FAIL
                    )
                  )
                )

                @echo.
                %sys.ColorNormal%


                @echo   + res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RWX%
                @echo.

                %sys.ColorDark%

                if /i %scope.IsLocal% EQU %STATUS_ON% (
                  net localgroup res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RWX% /add /comment:"res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RWX%"

                  if %errorlevel% EQU %EL_NET_OK% (
                    @echo     + group creation status: OK
                  ) else (
                    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                    @echo     + group creation status: FAIL
                  )
                ) else (
                  if /i %scope.IsAD% EQU %STATUS_ON% (
                    %fs.BinDir%\dsadd group "CN=res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RWX%,%ds.ResourceObjectsPath%" -samid "res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RWX%" -desc "res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RWX%" -secgrp yes -scope l -s %ds.server% -u %ds.user% -p %ds.passwd%

                    if %errorlevel% EQU %EL_DSADD_OK% (
                      @echo     + group creation status: OK
                    ) else (
                      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                      @echo     + group creation status: FAIL
                    )
                  ) else (
                    net group res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RWX% /add /comment:"res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_RWX%" /domain

                    if %errorlevel% EQU %EL_NET_OK% (
                      @echo     + group creation status: OK
                    ) else (
                      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                      @echo     + group creation status: FAIL
                    )
                  )
                )

                @echo.
                %sys.ColorNormal%


                @echo   + res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_WO%
                @echo.

                %sys.ColorDark%

                if /i %scope.IsLocal% EQU %STATUS_ON% (
                  net localgroup res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_WO% /add /comment:"res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_WO%"

                  if %errorlevel% EQU %EL_NET_OK% (
                    @echo     + group creation status: OK
                  ) else (
                    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                    @echo     + group creation status: FAIL
                  )
                ) else (
                  if /i %scope.IsAD% EQU %STATUS_ON% (
                    %fs.BinDir%\dsadd group "CN=res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_WO%,%ds.ResourceObjectsPath%" -samid "res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_WO%" -desc "res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_WO%" -secgrp yes -scope l -s %ds.server% -u %ds.user% -p %ds.passwd%

                    if %errorlevel% EQU %EL_DSADD_OK% (
                      @echo     + group creation status: OK
                    ) else (
                      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                      @echo     + group creation status: FAIL
                    )
                  ) else (
                    net group res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_WO% /add /comment:"res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_WO%" /domain

                    if %errorlevel% EQU %EL_NET_OK% (
                      @echo     + group creation status: OK
                    ) else (
                      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                      @echo     + group creation status: FAIL
                    )
                  )
                )

                @echo.
                %sys.ColorNormal%


                @echo   + res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_LO%
                @echo.

                %sys.ColorDark%

                if /i %scope.IsLocal% EQU %STATUS_ON% (
                  net localgroup res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_LO% /add /comment:"res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_LO%"

                  if %errorlevel% EQU %EL_NET_OK% (
                    @echo     + group creation status: OK
                  ) else (
                    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                    @echo     + group creation status: FAIL
                  )
                ) else (
                  if /i %scope.IsAD% EQU %STATUS_ON% (
                    %fs.BinDir%\dsadd group "CN=res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_LO%,%ds.ResourceObjectsPath%" -samid "res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_LO%" -desc "res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_LO%" -secgrp yes -scope l -s %ds.server% -u %ds.user% -p %ds.passwd%

                    if %errorlevel% EQU %EL_DSADD_OK% (
                      @echo     + group creation status: OK
                    ) else (
                      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                      @echo     + group creation status: FAIL
                    )
                  ) else (
                    net group res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_LO% /add /comment:"res-%VALUE_RESTYPE%-%input.LabelName%-%VALUE_ACCESSROLE_LO%" /domain

                    if %errorlevel% EQU %EL_NET_OK% (
                      @echo     + group creation status: OK
                    ) else (
                      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                      @echo     + group creation status: FAIL
                    )
                  )
                )

                @echo.
                %sys.ColorNormal%
              )
            )
          endlocal
        ) else (
          if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_ROLE% (
            @echo # creating access control security group [¡%VALUE_RESTYPE:¡=%-adm-%input.LabelName%]
            @echo.

            @echo   + ¡%VALUE_RESTYPE:¡=%-adm-%input.LabelName%
            @echo.

            %sys.ColorDark%

            if /i %scope.IsLocal% EQU %STATUS_ON% (
              net localgroup ¡%VALUE_RESTYPE:¡=%-adm-%input.LabelName% /add /comment:"¡%VALUE_RESTYPE:¡=%-adm-%input.LabelName%"

              if %errorlevel% EQU %EL_NET_OK% (
                @echo     + group creation status: OK
              ) else (
                @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                @echo     + group creation status: FAIL
              )
            ) else (
              if /i %scope.IsAD% EQU %STATUS_ON% (
                %fs.BinDir%\dsadd group "CN=¡%VALUE_RESTYPE:¡=%-adm-%input.LabelName%,%ds.AdmObjectsPath%" -samid "¡%VALUE_RESTYPE:¡=%-adm-%input.LabelName%" -desc "¡%VALUE_RESTYPE:¡=%-adm-%input.LabelName%" -secgrp yes -scope l -s %ds.server% -u %ds.user% -p %ds.passwd%

                if %errorlevel% EQU %EL_DSADD_OK% (
                  @echo     + group creation status: OK
                ) else (
                  @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                  @echo     + group creation status: FAIL
                )
              ) else (
                net group ¡%VALUE_RESTYPE:¡=%-adm-%input.LabelName% /add /comment:"¡%VALUE_RESTYPE:¡=%-adm-%input.LabelName%" /domain

                if %errorlevel% EQU %EL_NET_OK% (
                  @echo     + group creation status: OK
                ) else (
                  @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                  @echo     + group creation status: FAIL
                )
              )
            )

            @echo.
            %sys.ColorNormal%
          )


          if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_SVC% (
            if /i %scope.IsLocal% EQU %STATUS_ON% (
              @echo # creating access control security group [¡role-%VALUE_RESTYPE%-%input.LabelName%]
              @echo.

              @echo   + ¡role-%VALUE_RESTYPE:¡=%-%input.LabelName%
              @echo.

              %sys.ColorDark%

              net localgroup ¡role-%VALUE_RESTYPE:¡=%-%input.LabelName% /add /comment:"¡role-%VALUE_RESTYPE:¡=%-%input.LabelName%"

              if %errorlevel% EQU %EL_NET_OK% (
                @echo     + group creation status: OK
              ) else (
                @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                @echo     + group creation status: FAIL
              )

              @echo.
              %sys.ColorNormal%
            ) else (
              @echo # creating access control security group [¡sys-%VALUE_RESTYPE%-%input.LabelName%]
              @echo.

              @echo   + ¡sys-%VALUE_RESTYPE%-%input.LabelName%
              @echo.

              %sys.ColorDark%

              if /i %scope.IsAD% EQU %STATUS_ON% (
                %fs.BinDir%\dsadd group "CN=¡sys-%VALUE_RESTYPE:¡=%-%input.LabelName%,%ds.ServiceObjectsPath%" -samid "¡sys-%VALUE_RESTYPE:¡=%-%input.LabelName%" -desc "¡sys-%VALUE_RESTYPE:¡=%-%input.LabelName%" -secgrp yes -scope l -s %ds.server% -u %ds.user% -p %ds.passwd%

                if %errorlevel% EQU %EL_DSADD_OK% (
                  @echo     + group creation status: OK
                ) else (
                  @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                  @echo     + group creation status: FAIL
                )
              ) else (
                net group ¡sys-%VALUE_RESTYPE:¡=%-%input.LabelName% /add /comment:"¡sys-%VALUE_RESTYPE:¡=%-%input.LabelName%" /domain

                if %errorlevel% EQU %EL_NET_OK% (
                  @echo     + group creation status: OK
                ) else (
                  @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                  @echo     + group creation status: FAIL
                )
              )

              @echo.
              %sys.ColorNormal%
            )
          )


          if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_JOB% (
            if /i %scope.IsLocal% EQU %STATUS_ON% (
              @echo # creating access control security group [¡role-%VALUE_RESTYPE%-%input.LabelName%]
              @echo.

              @echo   + ¡role-%VALUE_RESTYPE:¡=%-%input.LabelName%
              @echo.

              %sys.ColorDark%

              net localgroup ¡role-%VALUE_RESTYPE:¡=%-%input.LabelName% /add /comment:"¡role-%VALUE_RESTYPE:¡=%-%input.LabelName%"

              if %errorlevel% EQU %EL_NET_OK% (
                @echo     + group creation status: OK
              ) else (
                @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                @echo     + group creation status: FAIL
              )

              @echo.
              %sys.ColorNormal%
            ) else (
              @echo # creating access control security group [¡sys-%VALUE_RESTYPE%-%input.LabelName%]
              @echo.

              @echo   + ¡sys-%VALUE_RESTYPE:¡=%-%input.LabelName%
              @echo.

              %sys.ColorDark%

              if /i %scope.IsAD% EQU %STATUS_ON% (
                %fs.BinDir%\dsadd group "CN=¡sys-%VALUE_RESTYPE:¡=%-%input.LabelName%,%ds.JobObjectsPath%" -samid "¡sys-%VALUE_RESTYPE:¡=%-%input.LabelName%" -desc "¡sys-%VALUE_RESTYPE:¡=%-%input.LabelName%" -secgrp yes -scope l -s %ds.server% -u %ds.user% -p %ds.passwd%

                if %errorlevel% EQU %EL_DSADD_OK% (
                  @echo     + group creation status: OK
                ) else (
                  @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                  @echo     + group creation status: FAIL
                )
              ) else (
                net group ¡sys-%VALUE_RESTYPE:¡=%-%input.LabelName% /add /comment:"¡sys-%VALUE_RESTYPE:¡=%-%input.LabelName%" /domain

                if %errorlevel% EQU %EL_NET_OK% (
                  @echo     + group creation status: OK
                ) else (
                  @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                  @echo     + group creation status: FAIL
                )
              )

              @echo.
              %sys.ColorNormal%
            )
          )
        )