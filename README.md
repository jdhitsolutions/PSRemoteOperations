# PSRemoteOperations

This PowerShell module is designed to run commands on remote computers but without using PowerShell remoting. It takes advantage of cloud services like DropBox and OneDrive. The idea is that you create a file with instructions on a command to run. The file includes the target computer name. The remote computer is monitoring the folder and when a matching file is detected the operation is invoked.

You can install the latest version from the PowerShell Gallery:

```powershell
Install-Module PSRemoteOperations
```

See [About_PSRemoteOperations](docs/about_PSRemoteOperations.md) for more detail.

Or check out the individual commands:

+ [Get-PSRemoteOperationResult](docs/Get-PSRemoteOperationResult.md)
+ [Invoke-PSRemoteOperation](docs/Invoke-PSRemoteOperation.md)
+ [New-PSRemoteOperation](docs/New-PSRemoteOperation.md)
+ [Register-PSRemoteOperationWatcher](docs/Register-PSRemoteOperationWatcher.md)

## Cross-Platform and PowerShell Core

The long-term goal is to ensure that this module will work cross-platform and in PowerShell Core. Basic functionality should exist running this module on PowerShell Core, both in Windows and non-Windows environments. Support for CMS messages is limited to Windows platforms through the use of dynamic parameters. `Register-PSRemoteOperationWatcher` requires a Windows platform but should work under PowerShell Core. For non-Windows systems, you will have to come up with your own tooling for monitoring and execution using `Invoke-PSRemoteOperation`.

 *last updated 22 October 2018*
