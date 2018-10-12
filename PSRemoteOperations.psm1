
#region main code

. $PSScriptRoot\functions.ps1
. $PSScriptRoot\Register-PSRemoteOperationWatcher.ps1

#endregion


#region private functions
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
        $data = $ast.find( {$args[0] -is [System.Management.Automation.Language.HashtableAst]}, $true)

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

        $hashtable.GetEnumerator() | foreach-object -begin {

            $out = @"
@{

"@
        }  -Process {
            Write-Verbose "Testing type $($_.value.gettype().name) for $($_.key)"
            #determine if the value needs to be enclosed in quotes
            if ($_.value.gettype().name -match "Int|double") {
                write-Verbose "..is an numeric"
                $value = $_.value
            }
            elseif ($_.value -is [array]) {
                #assuming all the members of the array are of the same type
                write-Verbose "..is an array"
                #test if an array of numbers otherwise treat as strings
                if ($_.value[0].Gettype().name -match "int|double") {
                    $value = $_.value -join ','
                }
                else {
                    $value = "'{0}'" -f ($_.value -join "','")
                }
            }
            elseif ($_.value -is [hashtable]) {
                $nested = Convert-HashTableToCode $_.value -Indent $($indent + 1)
                $value = "$($nested)"
            }
            else {
                write-Verbose "..defaulting as a string"
                $value = "'$($_.value)'"
            }
            $tabcount = "`t" * $Indent
            $out += "$tabcount$($_.key) = $value `n"
        }  -end {

            $tabcount = "`t" * ($Indent - 1)
            $out += "$tabcount}`n"

            $out

        }

    } #process
    End {
        Write-Verbose "Ending $($myinvocation.mycommand)"
    }
} #end function

#endregion

#add default properties for the custom result object
Update-Typedata -TypeName RemoteOpResult -DefaultDisplayPropertySet "Computername", "Date", "Scriptblock", "Filepath", "ArgumentList", "Completed", "Error" -force

#add AutoCompleters
. $PSScriptRoot\autocompleters.ps1

