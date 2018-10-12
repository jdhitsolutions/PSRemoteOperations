---
external help file: PSRemoteOperations-help.xml
Module Name: PSRemoteOperations
online version:
schema: 2.0.0
---

# Get-PSRemoteOperationResult

## SYNOPSIS

Parse the contents of a PSRemoteOperation archive file.

## SYNTAX

```yaml
Get-PSRemoteOperationResult [-Computername <String>] [[-ArchivePath] <String>] [-Newest <Int32>]
 [<CommonParameters>]
```

## DESCRIPTION

This command will parse the archived PSRemoteOperation file. It will default to the archive path specified by $PSRemoteOpArchive if it has been defined. The default behavior is to process all files but you can limit the search by computer name.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-PSOperationResult -computername Think51

Computername  : think51
Date          : 09/18/2018 17:19:35 UTC
Scriptblock   :
Filepath      : C:\scripts\SystemReport.ps1
ArgumentList  :
Completed     : True
Error         :
```

Get the result for computer THINK51 using the user-defined $PSRemoteOpArchive variable as the path.

## PARAMETERS

### -ArchivePath

Enter the path to the archive folder. This will default to the global variable PSRemoteOPArchive if it has been defined.

```yaml
Type: String
Parameter Sets: (All)
Aliases: path

Required: False
Position: 0
Default value: $PSRemoteOpArchive
Accept pipeline input: False
Accept wildcard characters: False
```

### -Computername

Enter a computername to filter on.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Newest

Select the newest X number of results.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: Last

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

### RemoteOpResult

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[about_PSRemoteOperations](./about_PSRemoteOperations)

[Invoke-PSRemoteOperation](./Invoke-PSRemoteOperation)

[New-PSRemoteOperation](./New-PSRemoteOperation)