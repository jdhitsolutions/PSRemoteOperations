---
external help file: PSRemoteOperations-help.xml
Module Name: PSRemoteOperations
online version:
schema: 2.0.0
---

# Register-PSRemoteOperationWatcher

## SYNOPSIS

Create the default PSRemoteOperation watcher.

## SYNTAX

```yaml
Register-PSRemoteOperationWatcher [[-Name] <String>] [-Minutes <Int32>] [-Path <String>]
 [-ArchivePath <String>] [-Credential <PSCredential>] [-ScheduledJobOption <ScheduledJobOptions>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

The premise of PSRemoteOperations is that the computer is monitoring a folder looking for a file that begins with its computername. Once a file has been identified, it can be passed to Invoke-PSRemoteOperation to execute. You may use whatever mechanism or techniques you'd like to monitor the PSRemoteOperation path. Or you can use this command to setup a PowerShell scheduled job to monitor the folder and invoke files as they are detected. The default behavior is to create a watcher that checks every 5 minutes for matching files. The scheduled job repeats indefinitely and will survive reboots. Use the scheduled job cmdlets to manage or remove.

You will need to re-enter your credentials.

## EXAMPLES

### Example 1

```powershell
PS C:\> Register-PSRemoteOperationWatcher -name Watch

Id         Name            JobTriggers     Command                                  Enabled
--         ----            -----------     -------                                  -------
11         Watch           1               ...                                      True
```

Create a scheduled job called Watch. This job is using the user defined defaults for $PSRemoteOpPath and $PSRemoteOpArchive. It is also using the default time interval of 5 minutes.

### Example 2

```powershell
PS C:\> Unregister-Scheduledjob watch
```

Use the scheduledjob cmdlets to remove the watcher job.

## PARAMETERS

### -ArchivePath

Enter the path of the folder to use for archive.

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

### -Credential

Enter your username and credentials.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Minutes

The number of minutes to pause between checking for new files. Enter a value between 5 and 1440.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 5
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name

The name of your scheduled job.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: RemoteOpWatcher
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path

Enter the path of the folder to watch.

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

### -ScheduledJobOption

A job option object created with New-ScheduledJobOption.

```yaml
Type: ScheduledJobOptions
Parameter Sets: (All)
Aliases: Option

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

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### Microsoft.PowerShell.ScheduledJob.ScheduledJobDefinition

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[about_PSRemoteOperations]()

[Invoke-PSRemoteOperation]()

[New-PSRemoteOperation]()