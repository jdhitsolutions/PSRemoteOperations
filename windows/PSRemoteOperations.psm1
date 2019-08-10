
#region main code for Windows platforms

. $PSScriptRoot\..\functions.ps1
. $PSScriptRoot\..\private.ps1
. $PSScriptRoot\New-PSRemoteOperationForm.ps1
. $PSScriptRoot\Register-PSRemoteOperationWatcher.ps1

#endregion

#add default properties for the custom result object
Update-Typedata -TypeName RemoteOpResult -DefaultDisplayPropertySet "Computername", "Date", "Scriptblock", "Filepath", "ArgumentList", "Completed", "Error" -force

#add AutoCompleters
. $PSScriptRoot\..\autocompleters.ps1
