#reagion class definitions


Enum PSRemoteOpStatus {
    Pending
    Running
    Completed
    Unknown
}

Enum PSRemoteOpVersion {
    Desktop
    Core
}

class PSRemoteOpBase {
    [datetime]$CreatedAt = (Get-Date)
    [string]$CreatedOn = [System.Environment]::MachineName
    [string]$CreatedBy = "$([system.Environment]::UserDomainName)\$([system.environment]::UserName)"
    [string]$Computername
    [PSRemoteOpStatus]$Status = "Pending"
    [PSRemoteOpVersion]$PSVersion = "Desktop"
    [hashtable]$ArgumentList
    [scriptblock]$Initialization
    [datetime]$StartTime
    [string]$PSRemoteOpPath
}

class PSRemoteOpScriptBlock:PSRemoteOpBase {
    [scriptblock]$Scriptblock
}

Class PSRemoteOpFile:PSRemoteOpBase {
    [string]$FilePath
}

Class PSRemoteOpResultScriptBlock:PSRemoteOpScriptBlock {
    [string]$Error
    [datetime]$EndTime
    [timespan]$RunTime
    [bool]$Completed
}

Class PSRemoteOpResultFile:PSRemoteOpFile {
    [string]$Error
    [datetime]$EndTime
    [timespan]$RunTime
    [bool]$Completed
}

#region private functions

Function _newPSRemoteOp {
    [cmdletbinding()]
    #specify the path to the PSD1 file
    Param(
        [Parameter(Position = 0, Mandatory, ValueFromPipelineByPropertyName)]
        [string]$FullName
    )

    Process {
        Write-Verbose "Creating PSRemoteOperation object from $Fullname"
        Try {
            $data = Import-PowerShellDataFile -Path $Fullname -ErrorAction Stop
            if ($data.scriptblock) {
                $obj = [PSRemoteOpScriptBlock]::New()
                $obj.CreatedAt = ([datetime]$data.createdat).ToLocalTime()
                $obj.CreatedBy = $data.CreatedBy
                $obj.CreatedOn = $data.CreatedOn
                $obj.Computername = $data.Computername
                $obj.scriptblock = [scriptblock]::Create($data.Scriptblock)
                $obj.ArgumentList = $data.ArgumentList
                $obj.Status = $data.status

                If ($data.StartTime -match "\d+") {
                    $obj.StartTime = $data.StartTime
                }
                $obj.PSRemoteOpPath = $(Convert-Path $FullName)
            }
            Else {
                $obj = [PSRemoteOpFile]::New()
                $obj.CreatedAt = ([datetime]$data.createdat).ToLocalTime()
                $obj.CreatedBy = $data.CreatedBy
                $obj.CreatedOn = $data.CreatedOn
                $obj.Computername = $data.Computername
                $obj.FilePath = $data.FilePath
                $obj.ArgumentList = $data.ArgumentList
                $obj.Status = $data.status

                If ($data.StartTime -match "\d+") {
                    $obj.StartTime = $data.StartTime
                }
            }
            #write the object to the pipeline
            $obj
        }
        Catch {
            Write-Warning "Failed to import $fullname. $($_.exception.message)"
        }
    }
}
Function Convert-HashtableString {
    [cmdletbinding()]
    Param(
        [parameter(Mandatory, HelpMessage = "Enter your hashtable string", ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]$Text
    )

    Begin {
        Write-Verbose "[BEGIN  ] Starting: $($MyInvocation.Mycommand)"
    } #begin

    Process {
        $tokens = $null
        $err = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseInput($Text, [ref]$tokens, [ref]$err)
        $data = $ast.find( { $args[0] -is [System.Management.Automation.Language.HashtableAst] }, $true)

        if ($err) {
            Throw $err
        }
        else {
            $data.SafeGetValue()
        }
    }

    End {
        Write-Verbose "[END    ] Ending: $($MyInvocation.Mycommand)"
    } #end

}

Function Convert-HashTableToCode {
    [cmdletbinding()]
    Param(
        [Parameter(Position = 0, ValueFromPipeline, Mandatory)]
        [ValidateNotNullorEmpty()]
        [hashtable]$Hashtable,
        [Alias("tab")]
        [int]$Indent = 1
    )

    Begin {
        Write-Verbose "Starting $($myinvocation.mycommand)"
    }
    Process {
        Write-Verbose "Processing a hashtable with $($hashtable.keys.count) keys"

        $hEnd = {

            $tabcount = "`t" * ($Indent - 1)
            $out += "$tabcount}`n"

            $out
        }
        $hEnd
    } #process
    End {
        Write-Verbose "Ending $($myinvocation.mycommand)"
    }
} #end function


Function _psInvoke {
    #  _psInvoke -scriptblock $sb -parameters @($in, $cpath, $ArchivePath, $raw, $to)
    [cmdletbinding()]
    Param(
        [scriptblock]$scriptblock,
        [object[]]$parameters
    )

    [hashtable]$In = $parameters[0]
    [string]$cpath = $parameters[1]
    [string]$ArchivePath = $parameters[2]
    $raw = $parameters[3]
    $to = $parameters[4]

    if ($in.PSVersion -match '7|Core') {
        Write-Verbose "Launching command using pwsh.exe"
        pwsh.exe -noprofile -command $sb -args $in, $cpath, $ArchivePath, $raw, $to
    }
    else {
        Write-Verbose "Launching command using powershell.exe"
        powershell.exe -noprofile -command $sb -args $in, $cpath, $ArchivePath, $raw, $to
    }
}
#endregion
