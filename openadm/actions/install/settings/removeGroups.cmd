for /f "usebackq" %i in (`wmic group where "Name like 'res%'" get Name`) do C:\openadm\bin\system\lg %i -removegroup
for /f "usebackq" %i in (`wmic group where "Name like '¡%'" get Name`) do @C:\openadm\bin\system\lg %i -removegroup
for /f "usebackq" %i in (`wmic group where "Name like 'role%'" get Name`) do @C:\openadm\bin\system\lg %i -removegroup