
Function New-PSRemoteOperation {
    [cmdletbinding(DefaultParameterSetName = "scriptblock", SupportsShouldProcess)]
    [OutputType("None", [system.io.fileinfo])]
    [Alias('nro')]

    Param (
        [Parameter(
            Position = 0,
            Mandatory,
            HelpMessage = "Enter the name of the computer where this command will execute.")]
        [Alias("cn")]
        [ValidateNotNullorEmpty()]
        [string[]]$Computername,

        [Parameter(
            Mandatory,
            HelpMessage = "Enter a scriptblock to execute",
            ParameterSetName = "scriptblock"
        )]
        [alias("sb")]
        [ValidateNotNullorEmpty()]
        [scriptblock]$Scriptblock,

        [Parameter(
            Mandatory,
            HelpMessage = "Enter the path to the PowerShell script to execute. This is relative to the remote computer.",
            ParameterSetName = "filepath"
        )]
        [ValidateNotNullorEmpty()]
        [alias("sp")]
        [string]$ScriptPath,

        [Parameter(HelpMessage = "A hashtable of parameter names and values for your scriptblock or script.")]
        [Hashtable]$ArgumentList,

        [Parameter(HelpMessage = "A script block of commands to run prior to executing your script or scriptblock.")]
        [scriptblock]$Initialization,

        [ValidateScript( { Test-Path -Path $_ })]
        [Parameter(HelpMessage = "The folder where the remote operation file will be created.")]
        [string]$Path = $PSRemoteOpPath,

        [switch]$Passthru
    )
    DynamicParam {
        if (Get-Command Protect-CmsMessage -ea silentlycontinue) {
            $attributes = New-Object System.Management.Automation.ParameterAttribute
            $attributes.HelpMessage = "Specify one or more CMS message recipients."

            $attributeCollection = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]
            $attributeCollection.Add($attributes)

            $dynParam1 = New-Object -Type System.Management.Automation.RuntimeDefinedParameter("To", [System.Management.Automation.CmsMessageRecipient[]], $attributeCollection)
            $paramDictionary = New-Object -Type System.Management.Automation.RuntimeDefinedParameterDictionary
            $paramDictionary.Add("To", $dynParam1)
            return $paramDictionary
        }
    }

    Begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
    }

    Process {
        Write-Verbose "Using these PSBoundparameters"
        $PSBoundParameters | Out-String | Write-Verbose
        foreach ($Computer in $Computername) {
            Write-Verbose "Creating a remote operations file for $($computer.toUpper())"
            #define a here string for the psd1 content
            $out = @"
@{
CreatedOn = '$(hostname)'
CreatedBy = '$(whoami)'
CreatedAt = '$((Get-Date).toUniversalTime()) UTC'
Computername = '$($Computer.ToUpper())'

"@

            if ($ArgumentList) {

                $opArgs = Convert-HashTableToCode $ArgumentList
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
            if ($PSCmdlet.ShouldProcess($outFile, "Creating PSRemote Operations File")) {

                if ($PSBoundParameters.ContainsKey("To")) {
                    Write-Verbose "Creating a CMS file"
                    Protect-CmsMessage -To $PSBoundParameters.Item("to") -Content $out -OutFile $outFile
                }
                else {
                    $out | Out-File -FilePath $outFile -force -Encoding ascii
                }
                if ($Passthru) {
                    Get-Item -path $outFile
                }
            } #if should process
        } #foreach computer
    } #process
    End {
        Write-Verbose "Ending $($MyInvocation.MyCommand)"
    }
} #close New-PSRemoteOperation

Function Invoke-PSRemoteOperation {
    #You cannot make second hops to other domain machines or systems where you must authenticate
    [cmdletbinding(SupportsShouldProcess)]
    [OutputType("None")]
    [alias('iro')]

    Param(
        [Parameter(
            Position = 0,
            Mandatory,
            HelpMessage = "Enter the path of a remote operation .psd1 file",
            ValueFromPipelineByPropertyName
        )]
        [ValidatePattern("\.psd1$")]
        [ValidateScript( { Test-Path -Path $_ })]
        [Alias("pspath")]
        [string]$Path,

        [Parameter(HelpMessage = "Enter the path for the archived .psd1 file")]
        [ValidateScript( { Test-Path -Path $_ })]
        [string]$ArchivePath = $PSRemoteOpArchive
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

        #test if the file contains a CMS message
        Try {
            Write-Verbose "Testing if a CMS Message"
            $cms = Get-CmsMessage -Path $cPath -ErrorAction stop
            $to = $cms.Recipients.issuerName
            $raw = (Unprotect-CmsMessage -path $cPath).split("`n")
            $in = $raw | Out-string | Convert-HashtableString
        }
        Catch {
            Write-Verbose "Not a CMS Message or this is a non-Windows platform. $($_.exception.message)"
            Write-Verbose "Import the data file to create a settings hashtable"
            $in = Import-PowerShellDataFile -Path $cPath
            $raw = Get-Content -Path $cpath
            Write-Verbose ($raw | Out-string)
            $To = $False
        }

        #set hashtable values to correct type
        if ($in.Scriptblock) {
            #$in.Scriptblock = [scriptblock]::Create($in.Scriptblock)
            Write-Verbose "Creating scriptblock"
            $action = [scriptblock]::Create($in.Scriptblock)
        }
        else {
            Write-Verbose "Getting script contents from $($in.FilePath)"
            $action = Get-Content -Path $in.FilePath | Out-String
        }

        if ($in.ArgumentList) {
            # $in.ArgumentList = $in.ArgumentList # -split ","
            #arguments must be entered as a hashtable
            Write-Verbose "Adding Parameters"
            $actionParams = $in.ArgumentList
            Write-Verbose ($actionParams | Out-String)
        }

        if ($PSCmdlet.ShouldProcess($cPath)) {

            #TODO - this should be turned into private functions so it can be tested with Pester
            $psrunspace = [powershell]::Create()
            if ($in.Initialization) {
                Write-Verbose "Adding initialization"
                $init = [scriptblock]::Create($in.Initialization)
                [void]$psrunspace.AddScript($init)
            }

            Write-Verbose "Adding action"
            [void]$psrunspace.Addscript($action)
            if ($actionParams) {
                [void]$psrunspace.AddParameters($actionParams)
            }

            Write-Verbose ($psrunspace.Commands.commands | Out-String)
            $psrunspace.invoke()
            if ($psrunspace.HadErrors) {
                $completed = $False
            }
            else {
                $completed = $True
            }

            $errormsg = """$($psrunspace.Streams.Error.exception.Message)"""
            $psrunspace.dispose()

            #create a results file
            Write-Verbose "Result Data"
            $resultdata = @"
@{

"@
            #append the result data to the data file.
            ($Raw | Select-Object -skip 1 | Select-Object -SkipLast 1 ).Foreach( { $resultData += "$_`n" })

            $resultData += "Completed = '$completed'`n"
            #replace any variables in the errormessage with escaped literals
            $errormsg = $errormsg.Replace('$', '`$')
            $resultData += "Error = $errormsg`n"
            $resultdata += "Date = '$((Get-Date).toUniversalTime()) UTC'`n"

            $resultData += "}"

            $resultdata | Out-String | Write-Verbose

            $filename = Split-Path -Path $cPath -Leaf
            $resultFile = Join-Path -Path $ArchivePath -ChildPath $filename

            Write-Verbose "Creating results file $resultFile"
            if ($to) {
                Write-Verbose "Create a CMS archive file to $To"
                Protect-CmsMessage -Content $resultdata -To $to -OutFile $resultFile
            }
            else {
                $resultdata | Out-File -FilePath $resultFile -Encoding ascii
            }
            #delete
            Write-Verbose "Removing operation file $cPath"
            Remove-Item -Path $cPath -Force

            # } #finally
        } #should process
    }#process

    End {
        Write-Verbose "Ending $($MyInvocation.MyCommand)"
    } #end
} #close Invoke-PSRemoteOperation

Function Get-PSRemoteOperationResult {
    [cmdletbinding(DefaultParameterSetName = "result")]
    [OutputType("RemoteOpResult", ParameterSetName = "result")]
    [OutputType([String[]], ParameterSetName = "raw")]
    [alias('gro')]

    Param(
        [Parameter(
            Position = 0,
            HelpMessage = "Enter a computername to filter on.",
            ParameterSetName = "result"
        )]
        [Parameter(ParameterSetName = "raw")]
        [Alias("cn")]
        [string]$Computername,

        [Parameter(
            Position = 1,
            HelpMessage = "Enter the path to the archive folder.",
            ParameterSetName = "result"
        )]
        [Parameter(ParameterSetName = "raw")]
        [ValidateScript( { Test-Path -path $_ })]
        [Alias("path")]
        [string]$ArchivePath = $PSRemoteOpArchive,

        [Parameter(ParameterSetName = "result")]
        [Parameter(ParameterSetName = "raw")]
        [Alias("Last")]
        [int]$Newest,

        [Parameter(ParameterSetName = "raw",
            HelpMessage = "Display the raw contents of the result file. This can be useful when you get an error parsing the data file.")]
        [switch]$Raw
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

    Write-Verbose "Filtering for $filter"
    $data = Get-ChildItem -Path $ArchivePath -filter $filter | Sort-Object -Property LastWriteTime -Descending

    if ($Newest -gt 0) {
        Write-Verbose "Getting newest $newest results"
        $data = $data | Select-Object -First $Newest
    }
    foreach ($file in $data) {
        Write-Verbose "Processing $($file.fullname)"
        #Test if file is CMS protected
        Try {
            Write-Verbose "Testing for CMS Message"
            $null = Get-CmsMessage -Path $file.Fullname -ErrorAction Stop
            $hash = Unprotect-CmsMessage -Path $file.fullname | Out-String | Convert-HashtableString
        }
        Catch {
            Write-Verbose "Not a CMS Message  or this is a non-Windows platform. $($_.exception.message)"
            $hash = Import-PowerShellDataFile -Path $file.fullname
        }
        if ($Raw) {
            Get-Content -Path $file.Fullname
        }
        else {

            $hash.Add("Path", $file.fullname)
            $obj = New-Object -typename psobject -Property $hash
            $obj.psobject.typenames.insert(0, "RemoteOpResult")
            $obj
        }


    }

    Write-Verbose "Ending $($myinvocation.MyCommand)"
} #end PSGet-RemoteOperationResult

Function Wait-PSRemoteOperation {
    [cmdletbinding(DefaultParameterSetName = "folder")]
    [Outputtype("None")]
    [Alias("wro")]
    Param(
        [Parameter(
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            HelpMessage = "Specify the path to a PSRemoteOperation file.",
            ParameterSetName = "file"
        )]
        [alias("fullname")]
        [ValidateNotNullOrEmpty()]
        [string]$FilePath,

        [Parameter(ParameterSetName = "folder")]
        [ValidateNotNullOrEmpty()]
        [string]$Path = $PSRemoteOpPath,

        [Parameter(
            ParameterSetName = "folder",
            HelpMessage = "Wait for results from a specific computer"
        )]
        [ValidateNotNullOrEmpty()]
        [alias("cn")]
        [string]$Computername,

        [Parameter(HelpMessage = "Specify a timeout value in seconds between 5 and 300.")]
        [ValidateRange(5, 300)]
        [int32]$Timeout
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
    } #begin

    Process {
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Using these PSBoundparameters"
        $PSBoundParameters | Out-String | Write-Verbose

        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Using parameter set $($pscmdlet.ParameterSetName)"

        if ($pscmdlet.ParameterSetName -eq 'file') {
            $target = $FilePath
        }
        else {
            if ($Computername) {
                $target = "$PSRemoteOpPath\$($computername)_*.psd1"
            }
            else {
                $target = "$PSremoteOpPath\*.psd1"
            }
        }
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Watching $target"
        if ($Timeout) {
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Waiting $Timeout seconds"
        }
        $timer = 0
        do {
            Start-Sleep -Seconds 1
            $timer++
            if ($timeout -AND ($timer -gt $Timeout)) {
                Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Timeout exceeded"
                Break
            }
        } while (Test-Path -path $Target )
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Total waiting time $timer seconds."
    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"

    } #end

} #close Wait-PSRemoteOperation

Function Get-PSRemoteOperation {
    [cmdletbinding()]
    [OutputType("RemoteOp")]
    [alias('grop')]

    Param(
        [Parameter(
            Position = 0,
            HelpMessage = "Enter a computername to filter on."
        )]
        [Alias("cn")]
        [string]$Computername,

        [Parameter(
            Position = 1,
            HelpMessage = "Enter the path to the operations folder."
        )]
        [ValidateScript( { Test-Path -path $_ })]
        [string]$Path = $PSRemoteOpPath
    )

    Write-Verbose "Starting $($myinvocation.MyCommand)"
    Write-Verbose "Getting pending remote operations from $Path"
    if ($computername) {
        Write-Verbose "Using computername $Computername"
        $filter = "$($computername)_*.psd1"
    }
    else {
        $filter = "*.psd1"
    }

    Write-Verbose "Filtering for $filter"
    $data = Get-ChildItem -Path $Path -filter $filter | Sort-Object -Property LastWriteTime -Descending

    foreach ($file in $data) {
        Write-Verbose "Processing $($file.fullname)"
        #Test if file is CMS protected
        Try {
            Write-Verbose "Testing for CMS Message"
            $null = Get-CmsMessage -Path $file.Fullname -ErrorAction Stop
            $hash = Unprotect-CmsMessage -Path $file.fullname | Out-String | Convert-HashtableString
        }
        Catch {
            Write-Verbose "Not a CMS Message  or this is a non-Windows platform. $($_.exception.message)"
            $hash = Import-PowerShellDataFile -Path $file.fullname
        }

        $hash.Add("Path", $file.fullname)
        $obj = New-Object -typename psobject -Property $hash
        $obj.psobject.typenames.insert(0, "RemoteOp")
        $obj
    }

    Write-Verbose "Ending $($myinvocation.MyCommand)"
} #end PSGet-RemoteOperation