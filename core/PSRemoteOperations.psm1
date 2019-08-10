#region main code

. $PSScriptRoot\..\functions.ps1
. $PSScriptRoot\..\private.ps1

#endregion

#add default properties for the custom result object
Update-Typedata -TypeName RemoteOpResult -DefaultDisplayPropertySet "Computername", "Date", "Scriptblock", "Filepath", "ArgumentList", "Completed", "Error" -force

#add AutoCompleters
. $PSScriptRoot\..\autocompleters.ps1