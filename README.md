
# Putty- Storing Configuration to Text Files.

This is a fork of Putty 0.81 from [Putty Home](https://www.chiark.greenend.org.uk/~sgtatham/putty/) with changes to the storage from [Jakub Kotrla and others](http://jakub.kotrla.net/putty/).

The goal is to stay as close to the orignal source code as possible but save the session configurations to text files.

Putty stores all configuration information in the Windows registry ([HKEY_CURRENT_USER\Software\SimonTatham\PuTTY]) - it cannot be saved or restored without additional software. For people who don't bother working with batch files manipulating the Windows registry there is a [workaround with bat/reg files](http://the.earth.li/~sgtatham/putty/0.58/htmldoc/Chapter4.html#config-file). The file responsible for storing and loading the configuration is 'storage.c'. To be able to load and store the configuration to simple text files, 'storage.c' has been rewritten.

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

The path for loading and storing the configuration files can be set via file *putty.conf*. 

The current working directory is searched first, if putty.conf is not found in the binary directory (same directory for putty/pscp/psftp/plink/pageant.exe) is searched. 

Below is an example *putty.conf'* file (if it's not found defaults are used):

    ;Settings
    sessions=%HOMEPATH%\.putty\sessions
    sshhostkeys=%HOMEPATH%\.putty\sshhostkeys
    seedfile=%HOMEPATH%\.putty\putty.rnd
    sessionsuffix=.txt
    keysuffix=.hostkey
    jumplist=%HOMEPATH%\.putty\jumplist.txt

You can use enviroment variables in config (like %SYSTEMROOT%) - string will be expanded via ExpandEnviromentString WinAPI function (user-specific variables are not supported yet).

The *putty.conf* file **must not** contain any spaces. 

*sessionsuffix* and *keysuffix* are optional, defaults are empty. If set, every file has a suffix as defined (saved sessions via sessionsuffix and ssh host keys via keysuffix). Primary purpose is to avoid "*.com" files from names like ssh.domain.com. Both are limited to 15 characters.

Warning: if you already have saved some sessions or ssh host keys and you change these suffixes, you have to manually rename all files (append the suffix to all files).

Jumplist was a new feature in Windows 7 supported by PuTTY 0.61. This PuTTY should be lightweight, if you do not set a path to a jumplist, none will be created.

When PuTTY is checking ssh host key and it's not found in file but in registry, you can move/copy key to file (or do nothing).

Pageant loads a list of saved sessions from the path set in *putty.conf*, the default is ./sessions/packedSessionName - it works the same way as PuTTY (including *keysuffix* setting). 

## Changed Files

The replaced files and a backup of the original files can be found in the folder 'patched_files'.

## Installation

This portable version of PuTTY requires on Windows the Visual Studio VC runtime dll's (Universal CRT - Platform Toolset x64 - v142). The Universal CRT is a Windows operating system component. It is a part of Windows 10 and later. For Windows versions prior to Windows 10, the Universal CRT is distributed via Windows Update.
The installer can be downloaded from Microsoft (Windows 7, 8.1, 10 and 11): 

[vc_redist](http://aka.ms/vs/17/release/vc_redist.x64.exe)

## Minisign

The binaries are signed with 'minisig' [minisign](https://jedisct1.github.io/minisign/).

The compiled binaries can be verified with the following public key:

RWQQ7GxsxIJrCmP8+GS9SY3AR8ofelEUEs+s+6opq1UoW8yTHy0sPP7N

Example: 

minisign -Vm <release.zip> -P RWQQ7GxsxIJrCmP8+GS9SY3AR8ofelEUEs+s+6opq1UoW8yTHy0sPP7N
