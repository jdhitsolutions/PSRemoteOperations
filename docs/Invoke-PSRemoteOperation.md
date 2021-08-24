---
external help file: PSRemoteOperations-help.xml
Module Name: PSRemoteOperations
online version: http://bit.ly/2Kt97HP
schema: 2.0.0
---

# Invoke-PSRemoteOperation

## SYNOPSIS

Execute the commands in a PSRemoteOperation file.

## SYNTAX

```yaml
Invoke-PSRemoteOperation [-Path] <String> [-ArchivePath <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

This command will parse a PSRemoteOperation file created with New-PSRemoteOperation and execute the script block or script file. When complete, the original file is deleted and an archived version created in the ArchivePath. The ArchivePath will default to the global variable PSRemoteOpArchive. The archive folder must already exist.

Normally, this command will be called by a remote operation watcher job, or equivalent command.

## EXAMPLES

### Example 1

```powershell
PS C:\> $file = Get-ChildItem $PSRemoteOpPath\*.psd1 | Where-Object {$_.name -match "^$($env:Computername)"}
PS C:\> Invoke-PSRemoteOperation $file
```

Assuming there is only a single file that starts with the local computer name, get the file and then call Invoke-PSRemoteOperation to invoke the scriptblock. Upon completion, the file will be deleted and an archive copy added to the $PSRemoteOpArchive path.

## PARAMETERS

### -ArchivePath

Enter the path for the archived .psd1 file The default is the global variable PSRemoteOpArchive if it has been defined.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: $PSRemoteOpArchive
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

### -Path

Enter the path of a remote operation .psd1 file

```yaml
Type: String
Parameter Sets: (All)
Aliases: pspath

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
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

### System.String

## OUTPUTS

### None

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[about_PSRemoteOperations](about_PSRemoteOperations)

[New-PSRemoteOperation](New-PSRemoteOperation)

[Get-PSRemoteOperationResult](Get-PSRemoteOperationResult])
