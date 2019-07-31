# Change Log for PSRemoteOperations

## v3.1.0

+ Fixed bug using CMS messages with a dynamic parameter
+ Fixed pester tests to accommodate sub-modules
+ Modified code to use `[void]` in place of `Out-Null`
+ All `-Computername` parameters now support an alias of `-cn`
+ Added `Wait-PSRemoteOperation` (Issue #10)
+ Updated help documentation. Online links now point to markdown files in the Github repository.
+ Updated `README.md`

## v3.0.0

+ restructured module to support Core and Windows through nested modules. (Issue #9)

## v2.0.0

+ Added SupportsShouldProcess to `New-PSRemoteOperation`
+ Modified metadata construction in `New-PSRemoteOperation` to accommodate Linux. (Issue #7)
+ Modified Pester test file to suppress PSScriptAnalyzer rules
+ Modified `Invoke-PSRemoteOperation` to use a PowerShell runspace and not `Invoke-Command` to make it more cross-platform friendly.
+ Modified `New-PSRemoteOperation` to pass argument as a scriptblock.
+ Fixed mistake in default property names for RemoteOpResult.
+ moved functions to separate files
+ Updated help
+ Major version number change due to the number of potentially breaking changes.

## v1.0.0

+ Made `Computername` positional in first position for `Get-PSRemoteOperationResult`
+ Added Autocompleter for `Computername` in `Get-PSRemoteOperationResult`
+ Added Autocompleter for `Computername` in `New-PSRemoteOperation`
+ Added Autocompleter for `To` in `New-PSRemoteOperation`
+ Added an alias of `Last` for `Newest` in `Get-PSRemoteOperationResult`
+ Minor help updates
+ Published to the PowerShell Gallery as production ready

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