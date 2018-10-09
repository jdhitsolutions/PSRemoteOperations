# PSRemoteOperations

This PowerShell module is designed to run commands on remote computers but without using PowerShell remoting. It takes advantage of cloud services like DropBox and OneDrive. The idea is that you create a file with instructions on a command to run. The file includes the target computer name. The remote computer is monitoring the folder and when a matching file is detected the operation is invoked.

See [About_PSRemoteOperations](docs/about_PSRemoteOperations.md) for more detail.

Or check out the individual commands:

+ [Get-PSRemoteOperationResult](docs/Get-PSRemoteOperationResult.md)
+ [Invoke-PSRemoteOperation](docs/Invoke-PSRemoteOperation.md)
+ [New-PSRemoteOperation](docs/New-PSRemoteOperation.md)
+ [Register-PSRemoteOperationWatcher](docs/Register-PSRemoteOperationWatcher.md)

## Cross-Platform and PowerShell Core

The current version of this module is designed for the Desktop edition of Windows PowerShell. Although much of the module's design could work on PowerShell Core and on non-Windows platforms. Some features, like support for CMS Messages would need to be revised as dynamic parameters. This issue is being tracked and will be addressed in future releases.

 *last updated 9 October 2018*
