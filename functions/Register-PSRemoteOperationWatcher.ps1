
if ($PSEdition -eq 'Desktop') {
    Function Register-PSRemoteOperationWatcher {
        [cmdletbinding(SupportsShouldProcess)]
        [OutputType([Microsoft.PowerShell.ScheduledJob.ScheduledJobDefinition])]
        [alias('row')]

        Param(
            [Parameter(Position = 0)]
            [ValidateNotNullorEmpty()]
            [string]$Name = "RemoteOpWatcher",

            [ValidateRange(2, 1440)]
            [int]$Minutes = 5,

            [Parameter(HelpMessage = "Enter the path of the folder to watch.")]
            [ValidateNotNullOrEmpty()]
            [ValidateScript( {Test-Path $_})]
            [string]$Path = $PSRemoteOpPath,

            [Parameter(HelpMessage = "Enter the path of the folder to use for archive.")]
            [ValidateNotNullOrEmpty()]
            [ValidateScript( {Test-Path $_})]
            [string]$ArchivePath = $PSRemoteOpArchive,

            [Parameter(HelpMessage = "Enter your username and credentials")]
            [ValidateNotNullOrEmpty()]
            [PSCredential]$Credential = "$env:USERDOMAIN\$env:USERNAME",

            [Alias("Option")]
            [Microsoft.PowerShell.ScheduledJob.ScheduledJobOptions]$ScheduledJobOption
        )

        Write-Verbose "Starting $($myinvocation.MyCommand)"

        if ($PSVersionTable.Platform -eq 'UNIX') {
            Write-Warning "This command requires a Windows platform and the ScheduledJob module."
            #bail out
            Return
        }

        Write-Verbose "Creating watcher $Name"

        #create a watcher job to start in 2 minutes
        $t = New-JobTrigger -Once -At (Get-Date).AddMinutes(2) -RepeatIndefinitely -RepetitionInterval (New-TimeSpan -Minutes $minutes)

        $action = {
            param([string]$in, [string]$out)
            #guid regex
            $guidrx = "[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}"

            Get-Childitem $in\*.psd1 |
            Where-Object {$_.name -match "^$($env:computername)_$guidrx" } |
            Invoke-PSRemoteOperation -ArchivePath $out
        }
        
        Write-Verbose "Using data path: $path"
        Write-verbose "Using archive path: $archivePath"

        $jobParams = @{
            Name                 = $Name
            ScriptBlock          = $action
            Trigger              = $t
            MaxResultCount       = 1
            ArgumentList         = @($Path, $ArchivePath)
            Credential           = $Credential
            InitializationScript = { Import-Module PSRemoteOperations }
        }

        if ($ScheduledJobOption) {
            $jobParams.add("ScheduledJobOption", $ScheduledJobOption)
        }
        Write-Verbose "Using job parameters"
        Write-Verbose ($jobParams | Out-String)
        Register-ScheduledJob @jobParams

        Write-Verbose "Ending $($myinvocation.MyCommand)"

    } #close Register-PSRemoteOperationWatcher

}
Else {
    #depending on how functions are exported, this might never be seen
    Function Register-PSRemoteOperationWatcher {
        [cmdletbinding()]
        [alias('row')]

        Param()

        $msg = @"

The original version of this function is only supported on Windows platforms that have
the PSScheduledJobs module. It does not appear to be valid on this system. You will
need to create your own mechanism for monitoring the PSRemoteOp path for new psd1 files
that match the local computername. Your mechanism can still call Invoke-PSRemoteOperation
to process the file.
"@
        Write-Warning $msg

    } #close function
}