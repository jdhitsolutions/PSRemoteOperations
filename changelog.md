# Change Log for PSRemoteOperations

## v3.3.1

+ Updated online help links.
+ Published this version to the PowerShell Gallery.

## v3.3.0

+ Added commands `Register-PSRemoteOpPath` and `Import-PSRemoteOpPath` to store path variables with the module. (Issue #13)
+ Added better error handling to `Get-PSRemoteOperation` and `Get-PSRemoteOperationResult` when unprotecting a CMS message. (Issue #14)
+ Updated about help.
+ Updated `README.md`.
+ Updated Pester tests.

## v3.2.1

+ Replaced online help links to markdown documents with bitly links.

## v3.2.0

+ Modified `Get-PSRemoteOperationResult` to include an option to display the raw contents of the result file
+ Added `New-PSRemoteOperationForm` with an alias of `nrof` for Windows platforms to display a GUI.
+ Added argument completer for `-Computername` in `Wait-PSRemoteOperation` to use names in `$PSRemoteOpPath`.
+ Added the `wro` alias for `Wait-PSRemoteOperation`.
+ Added the `sb` alias to the `-Scriptblock` parameter on `New-PSRemoteOperation`.
+ Added the `sp` alias to the `-Scriptpath` parameter on `New-PSRemoteOperation`.
+ Added `Get-PSRemoteOperation` with an alias of `grop` to get pending operations.
+ Updated auto-completers.
+ Updated documentation.
+ Updated `README.md`.
+ Updated Windows Pester tests.
+ Minor module reorganization.

## v3.1.0

+ Fixed bug using CMS messages with a dynamic parameter.
+ Fixed Pester tests to accommodate sub-modules.
+ Modified code to use `[void]` in place of `Out-Null`.
+ All `-Computername` parameters now support an alias of `-cn`.
+ Added `Wait-PSRemoteOperation`. (Issue #10)
+ Updated help documentation. Online links now point to markdown files in the GitHub repository.
+ Updated `README.md`.

## v3.0.0

+ Restructured module to support Core and Windows through nested modules. (Issue #9)

## v2.0.0

+ Added SupportsShouldProcess to `New-PSRemoteOperation`
+ Modified metadata construction in `New-PSRemoteOperation` to accommodate Linux. (Issue #7)
+ Modified Pester test file to suppress PSScriptAnalyzer rules
+ Modified `Invoke-PSRemoteOperation` to use a PowerShell runspace and not `Invoke-Command` to make it more cross-platform friendly
+ Modified `New-PSRemoteOperation` to pass an argument as a scriptblock.
+ Fixed mistake in default property names for RemoteOpResult.
+ Moved functions to separate files.
+ Updated help.
+ Major version number change due to the number of potentially breaking changes.

## v1.0.0

+ Made `Computername` positional in first position for `Get-PSRemoteOperationResult`.
+ Added Autocompleter for `Computername` in `Get-PSRemoteOperationResult`.
+ Added Autocompleter for `Computername` in `New-PSRemoteOperation`.
+ Added Autocompleter for `To` in `New-PSRemoteOperation`.
+ Added an alias of `Last` for `Newest` in `Get-PSRemoteOperationResult`.
+ Minor help updates.
+ Published to the PowerShell Gallery as production-ready.

## v0.6.1

+ Fixed a bug with error messages when they include a variable name with the `$` symbol.

## v0.6.0

+ Added support for CMS protected files. (Issue #3)

## v0.5.0

+ Modified `-Computername` parameter on `New-PSRemoteOperation` to accept an array of names. (Issue #1)
+ Set file encoding of psd1 files to ASCII. (Issue #4)
+ Fixed bug with arguments when one of them is an array. (Issue #5)

## v0.4.0

+ Added initialization script option to RemoteJob definition and execution.
+ Added `New-PSRemoteProfileScript` function.
+ Added `PSScheduledJob` as a required module.
+ Set default name for `-Credential` parameter of `Register-PSRemoteOperationWatcher` to `$env:username`.
+ Added help documentation.
+ Created Pester tests for the module.

## v0.3.0

+ Renamed function nouns to include a PSPrefix.
+ Fixed ScheduledJobOption type on `Register-PSRemoteOperationWatcher`.
+ Added `iro` alias for `Invoke-PSRemoteOperation`.
+ Added `gro` alias for `Get-PSRemoteOperationResult`.
+ Added `row` alias for `Register-RemoteOperationWatcher`.
+ Added `OutputType` to functions.
+ Added parameter to specify the number of minutes for watcher job.
+ Initial git commit.

## v0.2.0

+ Added global variables for remote operations paths.
+ Made parameters consistent where possible.
+ Added `nro` alias for `New-RemoteOperation`.

## v0.1.0

+ Initial file and module layout.
