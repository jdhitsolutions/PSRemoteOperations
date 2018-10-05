# Change Log for PSRemoteOperations

## v0.6.1

+ Fixed a bug with error messages when they include a variable name with the $ symbol.

## v0.6.0

+ Added support for CMS protected files. (Issue #3)

## v0.5.0

+ Modified `-Computername` parameter on `New-PSRemoteOperation` to accept an array of names. (Issue #1)
+ Set file encoding of psd1 files to ASCII (Issue #4)
+ Fixed bug with arguments when one of them is an array. (Issue #5)

## v0.4.0

+ Added initialization script option to RemoteJob definition and execution
+ Added `New-PSRemoteProfileScript` function
+ Added `PSScheduledJob` as a required module
+ Set default name for `-Credential` parameter of `Register-PSRemoteOperationWatcher` to `$env:username`
+ Added help documentation
+ Created Pester tests for the module

## v0.3.0

+ Renamed function nouns to include a PSPrefix
+ Fixed ScheduledJobOption type on `Register-PSRemoteOperationWatcher`
+ Added `iro` alias for `Invoke-PSRemoteOperation`
+ Added `gro` alias for `Get-PSRemoteOperationResult`
+ Added `row` alias for `Register-RemoteOperationWatcher`
+ Added OutputType to functions
+ Added parameter to specify number of minutes for watcher job
+ initial git commit

## v0.2.0

+ Added global variables for remote operations paths
+ Made parameters consistent where possible
+ Added `nro` alias for `New-RemoteOperation`

## v0.1.0

+ initial file and module layout