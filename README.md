
# Putty without Windows Registry

This is a fork of Putty 0.81 from [Putty Home](https://www.chiark.greenend.org.uk/~sgtatham/putty/)

The goal is to stay as close to the orignal source code as possible but save the session configuration to a text file.

## Migration

For backward compatibilty the session configuration is read from the registry. The string '[registry]' is appended to the session names read from the registry.

Sessions are saved to a 'sessions' folder in text format.

Below is a screenshot that shows two migrated sessions.

![image](./screenshots/migrate_session.png)

## putty.conf

Todo

## Changes files

The replaced files can be found in the folder 'storage_patches'.