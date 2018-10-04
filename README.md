# PSRemoteOperations

This PowerShell module is designed to run commands on remote computers but without using PowerShell remoting. It takes advantage of cloud services like DropBox and OneDrive. The idea is that you create a file with instructions on a command to run. The file includes the target computername. The remote computer is monitoring the folder and when a matching file is detected the operation is invoked.

See [About_PSRemoteOperations](docs/about_PSRemoteOperations.md) for more detail.

Or check out the individual commands:

+ [Get-PSRemoteOperationResult](docs/Get-PSRemoteOperationResult.md)
+ [Invoke-PSRemoteOperation](docs/Invoke-PSRemoteOperation.md)
+ [New-PSRemoteOperation](docs/New-PSRemoteOperation.md)
+ [Register-PSRemoteOperationWatcher](docs/Register-PSRemoteOperationWatcher.md)

 *last updated 4 October 2018*
