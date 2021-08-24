
Register-ArgumentCompleter -CommandName Get-PSRemoteOperationResult, New-PSRemoteOperation -ParameterName Computername -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    $names = (Get-ChildItem -Path $PSRemoteOpArchive | Split-Path -leaf).foreach( { $_.split("_")[0].toUpper() }) | Get-Unique

    if ($wordToComplete) {
        $fill = $names | Where-Object { $_ -match "$wordToComplete" }
    }
    else {
        $fill = $names
    }
    $fill | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

Register-ArgumentCompleter -CommandName Wait-PSRemoteOperation, Get-PSRemoteOperation -ParameterName Computername -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    $names = (Get-ChildItem -Path $PSRemoteOpPath -file | Split-Path -leaf).foreach( { $_.split("_")[0].toUpper() }) | Get-Unique

    if ($wordToComplete) {
        $fill = $names | Where-Object { $_ -match "$wordToComplete" }
    }
    else {
        $fill = $names
    }
    $fill | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

Register-ArgumentCompleter -CommandName New-PSRemoteOperation -ParameterName To -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    (Get-ChildItem -Path Cert:\CurrentUser\my -DocumentEncryptionCert).Subject |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}

<#
Test for the json file with remote op path settings and prompt the user to run Register-PSRemoteOpPath if not found
#>

$json = Join-Path -path $PSScriptRoot -ChildPath psremoteoppath.json

if (Test-Path $json) {
    Import-PSRemoteOpPath -path $json
}
else {
    $msg = @"
No PSRemoteOpPath settings file was found to import. The module will be easier to use
if you set global variables for `$PSRemoteOpPath and `$PSRemoteOpArchive. Run the
commmand Register-PSRemoteOpPath. If you've recently updated the module through the
PowerShell Gallery, you might need to re-register the paths.

If you prefer to set the values in your profile script you can ignore this
warning.

"@
    Write-Warning $msg
}