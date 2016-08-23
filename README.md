### Account Manager Command Line Tool
##### Provides CRUD function to help manage account

Create alias 'am'
```
sh alias.sh
```

Show help information
```
am -h
```
Add new account
```
am -a label,username,password
```
Update username
```
am -u label,new_username
```
Update password
```
am -p label,new_password
```

TODO: Create general password for showing real passwords