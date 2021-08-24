---
external help file: PSRemoteOperations-help.xml
Module Name: PSRemoteOperations
online version: http://bit.ly/2KscTkO
schema: 2.0.0
---

# Wait-PSRemoteOperation

## SYNOPSIS

Wait for a PSRemoteOperation to complete.

## SYNTAX

### folder (Default)

```yaml
Wait-PSRemoteOperation [-Path <String>] [-Computername <String>]
[-Timeout <Int32>] [<CommonParameters>]
```

### file

```yaml
Wait-PSRemoteOperation [[-FilePath] <String>] [-Timeout <Int32>] [<CommonParameters>]
```

## DESCRIPTION

Most of the time remote operations are intended to be run asynchronously in much the same way that you use Start-Job. But there may be situations where you want to wait for a remote operation to complete. This command will pause your PowerShell prompt until the job completes or a timeout value has been exceeded.

This command does not write any results to the pipeline.

## EXAMPLES

### Example 1

```powershell
PS C:\> New-PSRemoteOperation -scriptblock { get-process | export-clixml c:\shared\proc.xml} -computername SRV1 -passthru | Wait-PSRemoteOperation
```

This example will create a new PSRemote operation which passes the resulting .psd1 file to Wait-PSRemoteOperation.

### Example 2

```powershell
PS C:\> Wait-PSRemoteOperation -computername SRV2 -timeout 30
```

Watch the $PSRemoteOpPath folder for a job targeted to SRV2 but timeout waiting after 30 seconds.

## PARAMETERS

### -Computername

Wait for results from a specific computer

```yaml
Type: String
Parameter Sets: folder
Aliases: cn

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilePath

Specify the path to a PSRemoteOperation file.

```yaml
Type: String
Parameter Sets: file
Aliases: fullname

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Path

This should be the value of $PSRemoteOpPath

```yaml
Type: String
Parameter Sets: folder
Aliases:

Required: False
Position: Named
Default value: $PSRemoteOpPath
Accept pipeline input: False
Accept wildcard characters: False
```

### -Timeout

Specify a timeout value in seconds between 5 and 300.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### None

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[New-PSRemoteOperation](New-PSRemoteOperation.md)
