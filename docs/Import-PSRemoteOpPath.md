---
external help file: PSRemoteOperations-help.xml
Module Name: PSRemoteOperations
online version: http://bit.ly/31P39XJ
schema: 2.0.0
---

# Import-PSRemoteOpPath

## SYNOPSIS

Import path settings for the PSRemoteOperations module

## SYNTAX

```yaml
Import-PSRemoteOpPath [[-Path] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

This command will import the PSRemoteOPPath.json file in the module directory, and define the $PSRemoteOpPath and $PSRemoteOpArchive global variables. This settings file should be created with Register-PSRemoteOpPath. Normally, you should not need to run this command as settings are imported and defined when the module is imported.

## EXAMPLES

### Example 1

```powershell
PS C:\> Register-PSRemoteOpPath
```

Manually import the settings.

## PARAMETERS

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

Enter the path to the remote op path json file. You should normally use the default but you can specify an alternate path for testing purposes.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: $PSScriptRoot\psremoteoppath.json
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf

Shows what would happen if the cmdlet runs.
The cmdlet is not run.

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

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

Learn more about PowerShell:
http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[Register-PSRemoteOpPath](./Register-PSRemoteOpPath.md)
