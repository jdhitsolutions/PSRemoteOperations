
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

Register-ArgumentCompleter -CommandName New-PSRemoteOperation -ParameterName To -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    (Get-ChildItem -Path Cert:\CurrentUser\my -DocumentEncryptionCert).Subject |
    ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}