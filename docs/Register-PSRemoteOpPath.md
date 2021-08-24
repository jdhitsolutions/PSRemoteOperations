---
external help file: PSRemoteOperations-help.xml
Module Name: PSRemoteOperations
online version: http://bit.ly/31PT8cL
schema: 2.0.0
---

# Register-PSRemoteOpPath

## SYNOPSIS

Register remote operations path.

## SYNTAX

```yaml
Register-PSRemoteOpPath [-PSRemoteOpPath] <String> [-PSRemoteOpArchive] <String> [-WhatIf] [-Confirm]  [<CommonParameters>]
```

## DESCRIPTION

Many of the commands in this module rely on global variables to know where to store the pending remote operations file, $PSRemoteOpPath, and the archive folder, $PSRemoteOpArchive. Module commands that have a Path parameter default to these variables. In earlier versions of this module, you could define these variables in PowerShell profile to avoid constantly having to enter them.

This command will store your settings in a json file located in the module directory. When importing the module, the settings will also be imported and the global variables defined. If you don't have the settings file, you will see a warning message upon import.

It is assumed the locations are shared or synchronized by some method or external application like Dropbox or OneDrive.

## EXAMPLES

### Example 1

```powershell
PS C:\> Register-PSRemoteOpPath -PSRemoteOpPath $env:userprofile\dropbox\psremoteop -PSRemoteOpArchive $env:userprofile\dropbox\psremoteop\archive
```

Register the locations. Be aware that the paths will be converted to complete filesystem paths. Registration will also import the values.

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

### -PSRemoteOpArchive

Enter a filesystem path for the Remote Operations Archive path. It must already exist. This will be used to define $PSRemoteOpArchive.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PSRemoteOpPath

Enter a filesystem path for the Remote Operations path. It must already exist and should be a shared folder that is managed by some other process or application such as Dropbox or OneDrive. This will be used to define $PSRemoteOpPath.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
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

### None

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[Import-PSRemoteOpPath](Import-PSRemoteOpPath.md)
