
. $PSScriptRoot\functions\functions.ps1
. $PSScriptRoot\functions\private.ps1
. $PSScriptRoot\functions\New-PSRemoteOperationForm.ps1
. $PSScriptRoot\functions\Register-PSRemoteOperationWatcher.ps1

#add default properties for the custom result object
$update = @{
    TypeName = "RemoteOpResult"
    DefaultDisplayPropertySet = "Computername", "Date", "Scriptblock", "Filepath", "ArgumentList", "Completed", "Error"
    Force = $True
}
Update-TypeData @update

$update.TypeName = "PSRemoteOpScriptBlock"
$Update.DefaultDisplayPropertySet = "Computername", "CreatedAt", "Scriptblock", "ArgumentList","Status","PSVersion"
$update.MemberName = "Age"
$update.MemberType = "ScriptProperty"
$update.Value = {(Get-Date) - $this.CreatedAt}
Update-Typedata @update

$update.TypeName = "PSRemoteOpFile"
$Update.DefaultDisplayPropertySet = "Computername", "CreatedAt", "FilePath", "ArgumentList", "Status","PSVersion"
$update.MemberName = "Age"
$update.MemberType = "ScriptProperty"
$update.Value = { (Get-Date) - $this.CreatedAt }
Update-TypeData @update

#add AutoCompleters
. $PSScriptRoot\autocompleters.ps1
