
# Putty without Windows Registry

This is a fork of Putty 0.81 from [Putty Home](https://www.chiark.greenend.org.uk/~sgtatham/putty/) with the changes to the storage from [Jakub Kotrla and others](http://jakub.kotrla.net/putty/)

The goal is to stay as close to the orignal source code as possible but save the session configuration to a text file.

Putty stores all configuration information in the Windows registry ([HKEY_CURRENT_USER\Software\SimonTatham\PuTTY]) - it cannot be saved or restored without additional software. For people who don't bother working with batch files manipulating the Windows registry there is a [workaround with bat/reg files](http://the.earth.li/~sgtatham/putty/0.58/htmldoc/Chapter4.html#config-file).  PuTTY (storage.c - functions which handle storing/loading configuration). To be able to load and store the configuration to simple text files a 'storage.c' has been rewritten.

## Migration

For backward compatibilty the session configuration is read from the registry. The string '[registry]' is appended to the session names read from the registry.

Sessions are saved to a 'sessions' folder in text format.

Below is a screenshot that shows two migrated sessions.

![image](./screenshots/migrate_session.png)


This PuTTY stores its configuration (sessions, ssh host keys, random seed file path) to text files. Every session and ssh host key is stored in a separate file. Default paths are (where . represents the directory with the Putty binaries):

    ./sessions/packedSessionName
    ./sshhostkeys/packedHostName
    ./putty.rnd

## putty.conf

Path for saving configuration can be set via file putty.conf. Current working directory is searched first, if putty.conf is not found there, executable directory (same directory as putty/pscp/psftp/plink/pageant.exe) is searched. putty.conf should look like this (if it's not found defaults are used):

		;comment line
		sessions=%SYSTEMROOT%\ses
		sshhostkeys=\ssh\hostkeys
		seedfile=C:\putty.rnd
		sessionsuffix=.session
		keysuffix=.hostkey
		jumplist=jumplist.txt
	

You can use enviroment variables in config (like %SYSTEMROOT%) - string will be expanded via ExpandEnviromentString WinAPI function (user-specific variables are not supported yet).

sessionsuffix and keysuffix are optional, defaults are empty. If set, every file has a suffix as defined (saved sessions via sessionsuffix and ssh host keys via keysuffix). Primary purpose is to avoid "*.com" files from names like ssh.domain.com. Both are limited to 15 characters.
Warning: if you already have saved some sessions or ssh host keys and you change these suffixes, you have to manually rename (append them to) all files.

Jumplist is new feature in Windows 7 supported by PuTTY 0.61. Because this PuTTY should be lightweight, if you do not set a path to a jumplist, none will be created.

When PuTTY is checking ssh host key and it's not found in file but in registry, you can move/copy key to file (or of course do nothing).

Pageant loads list of saved sessions from path set in putty.conf, defaults is ./sessions/packedSessionName - it works the same way as PuTTY (including keysuffix setting). 

## Changed Files

The replaced files and a backup of the original files can be found in the folder 'patches'.
