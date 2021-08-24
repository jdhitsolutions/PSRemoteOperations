---
external help file: PSRemoteOperations-help.xml
Module Name: PSRemoteOperations
online version: http://bit.ly/2KsYc14
schema: 2.0.0
---

# Get-PSRemoteOperation

## SYNOPSIS

Get pending PS Remote Operations

## SYNTAX

```yaml
Get-PSRemoteOperation [[-Computername] <String>] [[-Path] <String>] [<CommonParameters>]
```

## DESCRIPTION

When you create a PS Remote operation, a psd1 file is created in the $PSRemoteOpPath. Instead of doing a simple directory listing of files waiting to be processed, this command will analyze the directory and create an object that reflects each pending operation. The default is to process every file but you can filter by computername.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-PSRemoteOperation

CreatedBy    : DESK01\jeff
Path         : C:\Users\Jeff Hicks\dropbox\remoteop\REMOTE320_23b9ed7c-9b2c-463d-9ea8-e121cf6d8da4.psd1
CreatedAt    : 08/10/2020 16:40:14 UTC
Computername : REMOTE320
Scriptblock  : get-scheduledtask | where state -eq running | out-file $env:userprofile\dropbox\work\running.txt
CreatedOn    : DESK01

CreatedBy    : DESK01\jeff
Path         : C:\Users\Jeff Hicks\dropbox\remoteop\REMOTE320_eae4d5b3-2700-4c98-9253-3d361df16863.psd1
CreatedAt    : 08/10/2020 15:40:01 UTC
Computername : REMOTE320
Scriptblock  :  restart-computer -force
CreatedOn    : DESK01
```

## PARAMETERS

### -Computername

Enter a computer name to filter on.

```yaml
Type: String
Parameter Sets: (All)
Aliases: cn

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path

Enter the path to the operations folder.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $PSRemoteOpPath
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### RemoteOp

## NOTES

Learn more about PowerShell:
http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[New-PSRemoteOperation](New-PSRemoteOperation.md)

[Get-PSRemoteOperationResult](Get-PSRemoteOperationResult.md)
