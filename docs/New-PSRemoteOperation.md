---
external help file: PSRemoteOperations-help.xml
Module Name: PSRemoteOperations
online version:
schema: 2.0.0
---

# New-PSRemoteOperation

## SYNOPSIS

Create a new remote operation file.

## SYNTAX

### scriptblock (Default)

```yaml
New-PSRemoteOperation [-Computername] <String[]> -Scriptblock <ScriptBlock> [-ArgumentList <Hashtable>]
 [-Initialization <ScriptBlock>] [-Path <String>] [-Passthru] [-WhatIf] [-Confirm]
 [-To <CmsMessageRecipient[]>] [<CommonParameters>]
```

### filepath

```yaml
New-PSRemoteOperation [-Computername] <String[]> -ScriptPath <String> [-ArgumentList <Hashtable>]
 [-Initialization <ScriptBlock>] [-Path <String>] [-Passthru] [-WhatIf] [-Confirm]
 [-To <CmsMessageRecipient[]>] [<CommonParameters>]
```

## DESCRIPTION

Use this command to create a new remote operation file. You should specify a path that the remote computer will monitor. It is recommended that you set a global variable called PSRemoteOpPath with this value. If you don't define this variable and don't specify a Path value, the command will fail.

For additional security you can protect the remote operation file as a CMS message on Windows platforms. Specify the CmsMessageRecipient. If the file is protected, the archive version will also be protected using the same recipient. You have to insure that the appropriate certificate is installed on the remote computer. The -To parameter is dynamic so even though it shows in the help syntax, if your system doesn't support it won't be available.

## EXAMPLES

### Example 1

```powershell
PS C:\> New-PSRemoteOperation -computername Foo -scriptblock {Restart-Service spooler -force}
```

This will create a remote operating psd1 file using the value of $PSRemoteOpPath for computer Foo

### Example 2

```powershell
PS C:\> New-PSRemoteOperation -computername Foo -scriptblock {Restart-Service spooler -force} -path \\DSFile\Watch -passthru


    Directory: \\DSFile\Watch


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----        10/2/2018   3:46 PM            342 foo_ed5ea30c-974a-4790-94fb-da91b6f85ef6.psd1
```

Repeat the previous example but create the file in a UNC path and pass the file object to the pipeline.

### Example 3

```powershell
PS C:\> $computers = Get-Content computers.txt
PS C:\> New-PSRemoteOperation -Computername $computers -Scriptblock {
    if (-Not (Test-Path C:\Work)) {
        mkdir c:\work
    }
    Copy-Item C:\Data\foo.dat -destination C:\work
}
```

In this example, an array of computer names is taken from the text file. A PSRemoteOperation file will be created for each computer using the same scriptblock.

### Example 4

```powershell
PS C:\> $sb = {param([string[]]$Names,[string]$Path,[boolean]$append) restart-service $names -force -PassThru | out-file $path -append:$append -encoding ascii
}
PS C:\> New-PSRemoteOperation -Computername SRV4 -Scriptblock $sb -ArgumentList @{names="spooler","bits";Path="c:\work\svc.txt";Append=$True} -To "CN=Admin@company.com"
```

This will create a new remote operations file with the given scriptblock and arguments. But it will also be protected as a CMS Message. Enter the arguments as a hashtable with each key corresponding to a parameter name.

### Example 5

```powershell
PS C:\>  New-PSRemoteOperation -Computername SRV5 -ScriptPath "c:\scripts\update.ps1"
```

Create a remote operation file for SRV5 using default locations. This operation will run the script C:\Scripts\update.ps1 which is relative to the remote computer.

## PARAMETERS

### -ArgumentList

A scriptblock with each key matching a parameter in your scriptblock or file. The hashtable is built as if you were going to use splatting.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Computername

Enter the name or names of the computer where this command will execute.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: CN

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Initialization

A script block of commands to run prior to executing your script or scriptblock. You might need this to import a module that is in a non-standard location or initialize a variable.

```yaml
Type: ScriptBlock
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Passthru

Write the operation object to the pipeline.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path

The folder where the remote operation file will be created. The command will default to the value in the global variable PSRemoteOpPath.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: $PSRemoteOpPath
Accept pipeline input: False
Accept wildcard characters: False
```

### -ScriptPath

Enter the path to the PowerShell script to execute. This is relative to the remote computer.

```yaml
Type: String
Parameter Sets: filepath
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Scriptblock

Enter a scriptblock to execute.

```yaml
Type: ScriptBlock
Parameter Sets: scriptblock
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -To

Specify one or more CMS message recipients. This is only valid on Windows platforms. The parameter is dynamic so even though it shows in the help syntax, if your system doesn't support it won't be available.

```yaml
Type: CmsMessageRecipient[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf

Shows what would happen if the cmdlet runs. The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### None

### System.IO.FileInfo

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[about_PSRemoteOperations](./about_PSRemoteOperations)

[Register-PSRemoteOperationWatcher](./Register-PSRemoteOperationWatcher)

[Protect-CmsMessage](http://go.microsoft.com/fwlink/?LinkId=821716)