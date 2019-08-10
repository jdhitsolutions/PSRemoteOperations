---
external help file: PSRemoteOperations-help.xml
Module Name: PSRemoteOperations
online version: https://github.com/jdhitsolutions/PSRemoteOperations/blob/master/docs/New-PSRemoteOperationForm.md
schema: 2.0.0
---

# New-PSRemoteOperationForm

## SYNOPSIS

Use a WPF form to create a remote operation.

## SYNTAX

```yaml
New-PSRemoteOperationForm [[-Path] <String>] [<CommonParameters>]
```

## DESCRIPTION

You can use this command in place of New-PSRemoteOperation to define a remote operation using a WPF form. This command only works on Windows platforms.

The only parameter you might specify is the Path. The default is $PSRemoteOpPath which you should have already defined. The rest of the form should be self-evident. But there are a few things to be aware of.

The dropdown boxes for Computername and To will be auto populated, but you can type in new values. Make sure they are complete. It is recommended that you keep scriptblocks simple because they have to be coded into a psd1 file. When entering a scriptblock or value for Initialization, only enter the commands. You do not need to include the { }. When defining Arguments, enter each on a separate line using an = sign.

log = system
newest = 20
verbose = $True

You should not quote any values.

## EXAMPLES

### Example 1

```powershell
PS C:\> New-PSRemoteOperationForm
```

Launch the form using the user-defined value for $PSRemoteOpPath

## PARAMETERS

### -Path

The folder where the remote operation file will be created.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: $PSRemoteOpPath
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### None

### System.IO.FileInfo

## NOTES

Learn more about PowerShell:
http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[New-PSRemoteOperation](./New-PSRemoteOperation)
