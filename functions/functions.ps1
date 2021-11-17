
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

        [switch]$Passthru,

        [Parameter(HelpMessage = "Specify which version of PowerShell to use for the remote operation.")]
        [ValidateSet("Desktop", "Core")]
        [string]$PSVersion = "Desktop"

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
            $Who = "$([System.Environment]::UserDomainName)\$([system.environment]::UserName)"

            $out = @"
@{
CreatedOn = '$([System.Environment]::Machinename)'
CreatedBy = '$($Who)'
CreatedAt = '$((Get-Date).toUniversalTime())'
Computername = '$($Computer.ToUpper())'
PSVersion = '$PSVersion'
Status = 'Pending'

"@

            if ($ArgumentList) {

                $opArgs = Convert-HashtableToCode $ArgumentList
                $out += "ArgumentList = $opargs"
                $out += "`n"
            }

            if ($Scriptblock) {
                $out += "Scriptblock = '$($scriptblock.tostring().trim())'"
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
            $fname = "$($Computer.ToUpper())_$(New-Guid).psd1"
            $outFile = Join-Path -Path $Path -ChildPath $fname #.toLower()

            Write-Verbose "Creating datafile $outfile"
            if ($PSCmdlet.ShouldProcess($outFile, "Creating PSRemote Operations File")) {

                if ($PSBoundParameters.ContainsKey("To")) {
                    Write-Verbose "Creating a CMS file"
                    Protect-CmsMessage -To $PSBoundParameters.Item("to") -Content $out -OutFile $outFile
                }
                else {
                    $out | Out-File -FilePath $outFile -Force -Encoding ascii
                }
                if ($Passthru) {
                    Get-Item -Path $outFile
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
        #this code was updated 13 Nov 2020 to allow running different PowerShell version (Issue #12)

        #convert paths to plain filesystem paths
        $cPath = Convert-Path $path
        Write-Verbose "Processing $cPath"

        $parent = Split-Path -Path $cPath -Parent
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
            Write-Verbose "Detected CMS recipient $to"
            $raw = (Unprotect-CmsMessage -Path $cPath).split("`n")
            $in = $raw | Out-String | Convert-HashtableString
        }
        Catch {
            Write-Verbose "Not a CMS Message or this is a non-Windows platform. $($_.exception.message)"
            Write-Verbose "Import the data file to create a settings hashtable"
            $in = Import-PowerShellDataFile -Path $cPath
            $raw = Get-Content -Path $cpath
            Write-Verbose ($raw | Out-String)
            $To = $False
        }

        Write-Verbose "Using content:"
        $in | Out-String | Write-Verbose

        if ($PSCmdlet.ShouldProcess($cPath)) {

            <#
            This is probably a bit overly complicated, but it works and supports
            running the operation in different PowerShell versions, so I'm
            happy to let it be.
            #>
            $sb = {
                param($in, $cpath, $ArchivePath, $raw, $to)

                #uncomment for troubleshooting and development
                # $VerbosePreference = "Continue"
                # Start-Transcript c:\work\sb.log
                #set hashtable values to correct type
                if ($in.Scriptblock) {
                    Write-Verbose "Creating scriptblock"
                    $action = [scriptblock]::Create($in.Scriptblock)
                }
                else {
                    Write-Verbose "Getting script contents from $($in.FilePath)"
                    $action = Get-Content -Path $in.FilePath | Out-String
                }

                if ($in.ArgumentList) {
                    #arguments must be entered as a hashtable
                    Write-Verbose "Adding Parameters"
                    $actionParams = $in.ArgumentList

                    #convert True/False to switches.
                    $bool2switch = $actionparams.keys | Where-Object { $actionparams[$_] -match 'true|false' }
                    if ($bool2switch) {
                        foreach ($item in $bool2Switch) {
                            Write-Host "Treating $item as a switch"
                            $txt = $actionParams[$item]
                            Write-Host "converting $txt"
                            if ($txt -eq 'true') {
                                $asSwitch = $True -as [switch]
                            }
                            else {
                                $asSwitch = $False -as [switch]
                            }
                            $actionParams[$item] = $asSwitch
                        }
                    }
                    Write-Verbose ($actionParams | Out-String)
                }

                $psrunspace = [powershell]::Create()

                if ($in.Initialization) {
                    Write-Verbose "Adding initialization"
                    $init = [scriptblock]::Create($in.Initialization)
                    [void]$psrunspace.AddScript($init)
                }

                Write-Verbose "Adding action"
                [void]$psrunspace.Addscript($action)

                if ($actionParams) {
                    Write-Verbose "Adding parameters"
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
                ($Raw | Select-Object -Skip 1 | Select-Object -SkipLast 1 ).Foreach( { $resultData += "$_`n" })

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
            } #cmd scriptblock

            #invoke a private function to actually run the commands.
            #using a function so it can be mocked for Pester tests
            #powershell.exe -noprofile -command $sb -args $in, $cpath, $ArchivePath, $raw, $to
            _psInvoke -scriptblock $sb -parameters @($in, $cpath, $ArchivePath, $raw, $to)

        } #should process
    }#process

    #old code
    <#     Process {
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
            $in = $raw | Out-String | Convert-HashtableString
        }
        Catch {
            Write-Verbose "Not a CMS Message or this is a non-Windows platform. $($_.exception.message)"
            Write-Verbose "Import the data file to create a settings hashtable"
            $in = Import-PowerShellDataFile -Path $cPath
            $raw = Get-Content -Path $cpath
            Write-Verbose ($raw | Out-String)
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
            ($Raw | Select-Object -skip 1 | Select-Object -SkipLast 1 ).Foreach({ $resultData += "$_`n" })

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
        } #should process
    }#process #>

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
        [ValidateScript( { Test-Path -Path $_ })]
        [Alias("path")]
        [string]$ArchivePath = $PSRemoteOpArchive,

        [Parameter(ParameterSetName = "result")]
        [Parameter(ParameterSetName = "raw")]
        [Alias("Last")]
        [int]$Newest,

        [Parameter(
            ParameterSetName = "raw",
            HelpMessage = "Display the raw contents of the result file. This can be useful when you get an error parsing the data file."
        )]
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
    $data = Get-ChildItem -Path $ArchivePath -Filter $filter | Sort-Object -Property LastWriteTime -Descending

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
            $chash = Unprotect-CmsMessage -Path $file.fullname -ErrorAction Stop | Out-String | Convert-HashtableString
        }
        Catch [System.Security.Cryptography.CryptographicException] {
            Write-Warning "Failed to unprotect the CMSMessage in $($file.fullname). Verify you have the proper DocumentEncryptionCertificate installed."
            Remove-Variable chash -ErrorAction SilentlyContinue
        }
        Catch {
            Write-Verbose "Not a CMS Message or this is a non-Windows platform. $($_.exception.message)"
            $chash = Import-PowerShellDataFile -Path $file.fullname
        }
        if ($Raw) {
            Get-Content -Path $file.Fullname
        }
        else {
            $chash.Add("Path", $file.fullname)
            $obj = New-Object -TypeName psobject -Property $chash
            $obj.psobject.typenames.insert(0, "RemoteOpResult")
            $obj
        }

        #clear the variable so it doesn't accidently get re-used
        Remove-Variable chash -ErrorAction SilentlyContinue

    } #foreach file

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
        } while (Test-Path -Path $Target )
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
        [ValidateScript( { Test-Path -Path $_ })]
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
    $data = Get-ChildItem -Path $Path -Filter $filter | Sort-Object -Property LastWriteTime -Descending

    foreach ($file in $data) {
        Write-Verbose "Processing $($file.fullname)"
        #Test if file is CMS protected
        Try {
            Write-Verbose "Testing for CMS Message"
            $null = Get-CmsMessage -Path $file.Fullname -ErrorAction Stop
            $chash = Unprotect-CmsMessage -Path $file.fullname -ErrorAction Stop | Out-String | Convert-HashtableString
        }
        Catch [System.Security.Cryptography.CryptographicException] {
            Write-Warning "Failed to unprotect the CMSMessage in $($file.fullname). Verify you have the proper DocumentEncryptionCertificate installed."
            Remove-Variable chash -ErrorAction SilentlyContinue
        }
        Catch {
            Write-Verbose "Not a CMS Message or this is a non-Windows platform. $($_.exception.message)"
            $chash = Import-PowerShellDataFile -Path $file.fullname
        }

        if ($chash) {
            #convert hashtable into a custom object
            [pscustomobject]@{
                PSTypename   = "PSRemoteOp"
                PSVersion    = $chash.PSVersion
                CreatedOn    = $chash.CreatedOn
                StartTime    = $null
                Scriptblock  = $chash.Scriptblock
                Runtime      = $null
                EndTime      = $null
                Computername = $chash.computername
                CreatedBy    = $chash.CreatedBy
                CreatedAt    = $chash.CreatedAt
                Status       = $chash.status

            }
            <# $chash.Add("Path", $file.fullname)
            $obj = New-Object -TypeName psobject -Property $chash
            $obj.psobject.typenames.insert(0, "RemoteOp")
            $obj #>
        }
        #clear the variable so it doesn't accidently get re-used
        Remove-Variable chash -ErrorAction SilentlyContinue
    } #foreach file

    Write-Verbose "Ending $($myinvocation.MyCommand)"
} #end PSGet-RemoteOperation

Function Register-PSRemoteOpPath {
    [cmdletbinding(SupportsShouldProcess)]
    Param(
        [Parameter(Mandatory, HelpMessage = "Enter a filesystem path for the Remote Operations path")]
        [ValidateScript( { (Test-Path $_ ) -AND ((Get-Item $_).psprovider.name -eq "filesystem") })]
        [string]$PSRemoteOpPath,

        [Parameter(Mandatory, HelpMessage = "Enter a filesystem path for the Remote Operations archive path")]
        [ValidateScript( { (Test-Path $_) -AND ((Get-Item $_).psprovider.name -eq "filesystem") })]
        [string]$PSRemoteOpArchive
    )

    Write-Verbose "Starting $($MyInvocation.MyCommand)"

    $json = Join-Path -Path $PSScriptRoot -ChildPath psremoteoppath.json

    $data = [pscustomobject]@{
        PSRemoteOpPath    = $PSRemoteOpPath
        PSRemoteOpArchive = $PSRemoteOpArchive
        Updated           = (Get-Date -Format f)
    }
    Write-Verbose "Registering this data"
    $data | Out-String | Write-Verbose
    Write-Verbose "to $json"

    if ($PSCmdlet.ShouldProcess($json)) {
        $data | ConvertTo-Json | Out-File -FilePath $json
        #import the data
        Import-PSRemoteOpPath
    } #end whatif

    Write-Verbose "Ending $($MyInvocation.MyCommand)"
} #end Register-PSRemoteOpPath

Function Import-PSRemoteOpPath {
    [cmdletbinding(SupportsShouldProcess)]

    Param(
        [Parameter(HelpMessage = "Enter the path to the remote op path json file.")]
        [ValidateScript( { Test-Path $_ })]
        [string]$Path = (Join-Path -Path $PSScriptRoot -ChildPath psremoteoppath.json)
    )

    Write-Verbose "Ending $($MyInvocation.MyCommand)"
    Write-Verbose "Importing settings from $path"

    $in = Get-Content -Path $json | ConvertFrom-Json

    $in | Out-String | Write-Verbose

    if ($pscmdlet.shouldProcess($in.PSRemoteOpPath, "Set PSRemoteOpPath")) {
        $global:PSRemoteOpPath = $in.PSRemoteOPPath
    }
    if ($pscmdlet.shouldProcess($in.PSRemoteOpArchive, "Set PSRemoteOpArchive")) {
        $global:PSRemoteOpArchive = $in.PSRemoteOpArchive
    }

    Write-Verbose "Ending $($MyInvocation.MyCommand)"

} #end Import-PSRemoteOpPath