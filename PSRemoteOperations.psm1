#requires -version 5.1

#TODO : Update Readme

#region main code

Function New-PSRemoteOperation {
    [cmdletbinding(DefaultParameterSetName = "scriptblock")]
    [OutputType("None",[system.io.fileinfo])]
    [Alias('nro')]

    Param (
        [Parameter(Position = 0, Mandatory,
            HelpMessage = "Enter the name of the computer where this command will execute.")]
        [Alias("CN")]
        [ValidateNotNullorEmpty()]
        [string[]]$Computername,

        [Parameter(
            Mandatory,
            HelpMessage = "Enter a scriptblock to execute",
            ParameterSetName = "scriptblock"
        )]
        [ValidateNotNullorEmpty()]
        [scriptblock]$Scriptblock,

        [Parameter(
            Mandatory,
            HelpMessage = "Enter the path to the PowerShell script to execute. This is relative to the remote computer.",
            ParameterSetName = "filepath"
        )]
        [ValidateNotNullorEmpty()]
        [string]$ScriptPath,

        [Parameter(HelpMessage = "An array of objects to pass as arguments. Values are positional to your script or scriptblock.")]
        [Object[]]$ArgumentList,

        [Parameter(HelpMessage = "A script block of commands to run prior to executing your script or scriptblock.")]
        [scriptblock]$Initialization,

        [ValidateScript( {Test-Path -Path $_})]
        [Parameter(HelpMessage = "The folder where the remote operation file will be created.")]
        [string]$Path = $global:PSRemoteOpPath,

        [switch]$Passthru
    )

    Write-Verbose "Starting $($MyInvocation.MyCommand)"

    foreach ($Computer in $Computername) {
        Write-Verbose "Creating a remote operations file for $($computer.toUpper())"
    #define a here string for the psd1 content
    $out = @"
@{
CreatedOn = '$($env:computername)'
CreatedBy = '$($env:userdomain)\$($env:username)'
CreatedAt = '$((Get-Date).toUniversalTime()) UTC'
Computername = '$($Computer.ToUpper())'

"@

    if ($ArgumentList) {
        $outargs = @()
        foreach ($a in $ArgumentList ) {
            
            Switch ($a.gettype().name) {
                "Object[]" {
                    $items = "'$($a -join "','")'"
                    $thisarg = "@($items)"
                }
                "Boolean" {
                    $thisarg = "`$$($a)"
                }
                "string" {
                    $thisarg = "'$a'"
                }
                Default {
                    $thisarg = $a
                }
            }
            $outargs+=$thisarg
        }

        $opargs = $outargs -join ","
        $out += "ArgumentList = $opargs"
        $out += "`n"
    }

    if ($Scriptblock) {
        $out += "Scriptblock = '$scriptblock'"
        $out += "`n"
    }
    else {
        $out += "Filepath = '$Scriptpath'"
        $out += "`n"
    }

    if ($Initialization) {
        $out += "Initialization = '$Initialization'"
        $out += "`n"
    }
    $out += "}"

    $out | Write-Verbose

    #make the filename all lower case
    $fname = "$($Computer.ToUpper())_$(New-GUID).psd1"
    $outFile = Join-path -Path $Path -ChildPath $fname #.toLower()

    Write-Verbose "Creating datafile $outfile"

    $out | Out-File -FilePath $outFile -force -Encoding ascii
    if ($Passthru) {
        Get-Item -path $outFile
    }
    } #foreach computer

    Write-Verbose "Ending $($MyInvocation.MyCommand)"
} #close New-PSRemoteOperation

Function Invoke-PSRemoteOperation {
    #You cannot make second hops to other domain machines or systems where you must authenticate
    [cmdletbinding(SupportsShouldProcess)]
    [OutputType("None")]
    [alias('iro')]

    Param(
        [Parameter(Position = 0, Mandatory,
            HelpMessage = "Enter the path of a remote operation .psd1 file",
            ValueFromPipelineByPropertyName
        )]
        [ValidatePattern("\.psd1$")]
        [ValidateScript({Test-Path -Path $_})]
        [Alias("pspath")]
        [string]$Path,

        [Parameter(HelpMessage = "Enter the path for the archived .psd1 file")]
        [ValidateScript({Test-Path -Path $_})]
        [string]$ArchivePath = $global:PSRemoteOpArchive
    )

    Begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Write-Verbose "Using archive path $ArchivePath"
    } #begin

    Process {
        #convert paths to plain filesystem paths
        $cPath = Convert-Path $path
        Write-Verbose "Processing $cPath"

        $parent = Split-Path -Path $cPath -parent
        Write-Verbose "Comparing $parent to $ArchivePath"
        #The archive path and path for data file must be different
        if ($parent -eq $ArchivePath) {
            Write-Warning "The archive path must be different from the path to the psd1 file."
            #bail out
            Return
        }

        #import the data file to create a settings hashtable
        $in = Import-PowerShellDataFile -Path $cPath

        #remove metadata keys and computername
        #the command should run locally
        "CreatedOn", "CreatedBy", "CreatedAt", "Computername" |
            ForEach-Object { $in.Remove($_)}

        #set hashtable values to correct type
        if ($in.Scriptblock) {
            $in.Scriptblock = [scriptblock]::Create($in.Scriptblock)
        }

        if ($in.ArgumentList) {
            $in.ArgumentList = $in.ArgumentList # -split ","
        }

        #run the command
        Try {
            if ($PSCmdlet.ShouldProcess($cPath)) {
                #create a session
                Write-Verbose "Creating a temporary local session"
                $tmpSession = New-PSSession -ConnectionUri http://localhost:5985/WSman -ErrorAction stop

                if ($in.Initialization) {
                    Write-Verbose "Initializing"
                    $init = [scriptblock]::Create($in.Initialization)
                    Invoke-Command -ScriptBlock $init -session $tmpSession
                    $in.Remove("Initialization")
                }

                $in.Add("ErrorAction","Stop")
                $in.Add("Session",$tmpSession)
                #invoke the command
                Write-Verbose "Invoking Command"
                Write-Verbose ($in | Out-String)
                Invoke-Command @in

                Write-Verbose "Removing temporary session"
                $tmpSession | Remove-PSSession
            }
            $errormsg = "''"
            $Completed = $True
        }
        Catch {
            $errormsg = """$($_.exception.message)"""
            $Completed = $False
        }
        Finally {
            #create a results file
            Write-Verbose "Result Data"
            $resultdata = @"
@{

"@
            #append the result data to the data file.
            (Get-Content -Path $cPath | Select-Object -skip 1 | Select-Object -SkipLast 1 ).Foreach( {$resultData += "$_`n"})

            $resultData += "Completed = '$completed'`n"
            $resultData += "Error = $errormsg`n"
            $resultdata += "Date = '$((Get-Date).toUniversalTime()) UTC'`n"

            $resultData += "}"

            $resultdata | Out-String | Write-Verbose

            $filename = Split-Path -Path $cPath -Leaf
            $resultFile = Join-Path -Path $ArchivePath -ChildPath $filename

            Write-Verbose "Creating results file $resultFile"
            $resultdata | Out-File -FilePath $resultFile -Encoding ascii

            #delete
            Write-Verbose "Removing operation file $cPath"
            Remove-Item -Path $cPath -Force

        } #finally
    } #process

    End {
        Write-Verbose "Ending $($MyInvocation.MyCommand)"
    } #end
} #close Invoke-PSRemoteOperation

Function Get-PSRemoteOperationResult {
    [cmdletbinding()]
    [OutputType("RemoteOpResult")]
    [alias('gro')]

    Param(
        [Parameter(Position = 0, HelpMessage = "Enter the path to the archive folder.")]
        [ValidateScript( {Test-Path -path $_})]
        [Alias("path")]
        [string]$ArchivePath = $global:PSRemoteOpArchive,
        [Parameter(HelpMessage = "Enter a computername to filter on.")]
        [string]$Computername,
        [int]$Newest
    )

    Write-Verbose "Starting $($myinvocation.MyCommand)"
    Write-Verbose "Getting remote operation results from $ArchivePath"
    if ($computername) {
        Write-Verbose "Using computername $Computername"
        $filter = "$($computername)_*.psd1"
    }
    else {
        $filter = "*.psd1"
    }

    Write-verbose "Filtering for $filter"
    $data = Get-ChildItem -Path $ArchivePath -filter $filter | Sort-Object -Property LastWriteTime -Descending

    if ($Newest -gt 0) {
        Write-Verbose "Getting newest $newest results"
        $data = $data | Select-object -First $Newest
    }
    foreach ($file in $data) {
        Write-Verbose "Processing $($file.fullname)"
        $hash = Import-PowerShellDataFile -Path $file.fullname
        $hash.Add("Path", $file.fullname)
        $obj = New-Object -typename psobject -Property $hash
        $obj.psobject.typenames.insert(0, "RemoteOpResult")
        $obj
    }

    Write-Verbose "Ending $($myinvocation.MyCommand)"
} #end PSGet-RemoteOperationResult

Function Register-PSRemoteOperationWatcher {
    [cmdletbinding(SupportsShouldProcess)]
    [OutputType([Microsoft.PowerShell.ScheduledJob.ScheduledJobDefinition])]
    [alias('row')]

    Param(
        [Parameter(Position = 0)]
        [ValidateNotNullorEmpty()]
        [string]$Name = "RemoteOpWatcher",

        [ValidateRange(2,1440)]
        [int]$Minutes = 5,

        [Parameter(HelpMessage = "Enter the path of the folder to watch.")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Path $_})]
        [string]$Path = $global:PSRemoteOpPath,

        [Parameter(HelpMessage = "Enter the path of the folder to use for archive.")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Path $_})]
        [string]$ArchivePath = $global:PSRemoteOpArchive,

        [Parameter(HelpMessage = "Enter your username and credentials")]
        [ValidateNotNullOrEmpty()]
        [PSCredential]$Credential = "$env:USERDOMAIN\$env:USERNAME",

        [Alias("Option")]
        [Microsoft.PowerShell.ScheduledJob.ScheduledJobOptions]$ScheduledJobOption
    )

    Write-Verbose "Starting $($myinvocation.MyCommand)"
    Write-Verbose "Creating watcher $Name"

    #create a watcher job to start in 2 minutes
    $t = New-JobTrigger -Once -at (Get-Date).AddMinutes(2) -RepeatIndefinitely -RepetitionInterval (new-timespan -Minutes $minutes)

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
        Name =  $Name
        ScriptBlock = $action
        Trigger = $t
        MaxResultCount = 1
        ArgumentList = @($Path,$ArchivePath)
        Credential = $Credential
        InitializationScript = { Import-Module PSRemoteOperations }
    }

    if ($ScheduledJobOption) {
        $jobParams.add("ScheduledJobOption",$ScheduledJobOption)
    }

    Register-ScheduledJob @jobParams

    Write-Verbose "Ending $($myinvocation.MyCommand)"

} #close Register-PSRemoteOperationWatcher

#endregion

#add default properties for the custom result object
Update-Typedata -TypeName RemoteOpResult -DefaultDisplayPropertySet "Computername", "Date", "Scriptblock", "Filepath", "ArgumentsList", "Completed", "Error" -force


