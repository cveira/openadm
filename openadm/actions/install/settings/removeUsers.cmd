for /f "usebackq" %i in (`wmic useraccount where "Name like '¡%'" get Name`) do @net user %i /delete
for /f "usebackq" %i in (`wmic useraccount where "Name like 'job%'" get Name`) do @net user %i /delete
for /f "usebackq" %i in (`wmic useraccount where "Name = 'admin'" get Name`) do @net user %i /delete
for /f "usebackq" %i in (`wmic useraccount where "Name = 'root'" get Name`) do @net user %i /delete
for /f "usebackq" %i in (`wmic useraccount where "Name = 'sysadmin'" get Name`) do @net user %i /delete
for /f "usebackq" %i in (`wmic useraccount where "Name = 'backup'" get Name`) do @net user %i /delete