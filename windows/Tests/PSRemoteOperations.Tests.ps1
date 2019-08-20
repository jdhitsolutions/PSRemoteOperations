# run this test under Windows PowerShell

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingComputerNameHardcoded', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringwithPlainText', '')]
Param()


$moduleName = (($MyInvocation.mycommand).name -split "\.")[0]
$ModuleManifestName = "$modulename.psd1"
$ModuleManifestPath = "$PSScriptRoot\..\..\$ModuleManifestName"

If (Get-Module $modulename) {
    Remove-module $moduleName
}
import-module $ModuleManifestPath -Force

Describe $ModuleName {
    $myModule = Test-ModuleManifest -Path $ModuleManifestPath

    Context Manifest {
        It 'Passes Test-ModuleManifest' {
            $myModule | Should Not BeNullOrEmpty
        }
        It "Should NOT have a root module" {
            $myModule.RootModule | Should BeNullOrEmpty
        }
        It "Contains exported commands" {
            $myModule.ExportedCommands | Should Not BeNullOrEmpty
        }
        It "Should have a module description" {
            $myModule.Description | Should Not BeNullOrEmpty
        }
        It "Should have a company" {
            $myModule.Description | Should Not BeNullOrEmpty
        }
        It "Should have an author of 'Jeff Hicks'" {
            $mymodule.Author | Should Be 'Jeff Hicks'
        }
        It "Should have tags" {
            $mymodule.Tags | Should Not BeNullOrEmpty
        }

        It "Should have a license URI" {
            $mymodule.LicenseUri | should Not BeNullOrEmpty
        }

        It "Should have a project URI" {
            $mymodule.ProjectUri | Should Not BeNullOrEmpty
        }
    }
    Context Exports {
        $exported = Get-Command -Module $ModuleName -CommandType Function
        $names = 'New-PSRemoteOperation', 'Invoke-PSRemoteOperation', 'Get-PSRemoteOperationResult',
        'Register-PSRemoteOperationWatcher',
        'Wait-PSRemoteOperation','New-PSRemoteOperationForm','Get-PSRemoteOperation',
        'Import-PSRemoteOpPath','Register-PSRemoteOpPath'

        It "Should export $($names.count) functions" {
            $names.Count -eq $exported.count | Should be $True
        }
        foreach ($name in $names) {
            It "Should have an exported command of $name" {
                $exported.name | Should Contain $name
            }
        }

        $aliasHash = @{
            nro = "New-PSRemoteOperation"
            iro = "Invoke-PSRemoteOperation"
            row = "Register-PSRemoteOperationWatcher"
            gro = "Get-PSRemoteOperationResult"
            nrof = "New-PSRemoteOperationForm"
            grop = "Get-PSRemoteOperation"
        }
        $aliasHash.GetEnumerator() | foreach-object {

            It "Should have an alias of $($_.key)" {
                (Get-Alias -Name $_.key).ResolvedCommandName | Should be $_.value
            }
        }
        It "Should create a RemoteOpResults type extension" {
            Get-TypeData RemoteOpResult | Should be $True
        }
    }
    Context Structure {
        It "Should have a Docs folder" {
            Get-Item $PSScriptRoot\..\..\docs | Should Be $True
        }
        foreach ($cmd in $myModule.ExportedFunctions.keys) {
            It "Should have a markdown help file for $cmd" {
                "$PSScriptRoot\..\..\docs\$cmd.md" | Should Exist
            }
        }
        It "Should have an external help file" {
            "$PSScriptRoot\..\..\en-us\*.xml" | Should Exist
            "$PSScriptRoot\..\..\en-us\*.txt" | Should Exist
        }

        It "Should have an about file" {
            "$PSScriptRoot\..\..\docs\about_$ModuleName.md"| Should Exist
        }
        It "Should have a license file" {
            "$PSScriptRoot\..\..\license.*" | Should Exist
        }

        It "Should have a changelog file" {
            "$PSScriptRoot\..\..\changelog*" | Should Exist
        }

        It "Should have a README.md file" {
            "$PSScriptRoot\..\..\README.md" | Should Exist
        }
    }
} -Tag module

InModuleScope PSRemoteOperations {

    Describe New-PSRemoteOperation {
        $params = (Get-Command New-PSRemoteOperation).parameters
        It "Should have a mandatory Computername parameter" {
            ($params["computername"].attributes).where( {$_.TypeId -match 'parameter'}).Mandatory | Should Be $True
        }

        It "Should have a mandatory ScriptBlock or ScriptPath parameter" {
            ($params["scriptblock"].attributes).where( {$_.TypeId -match 'parameter'}).Mandatory | Should Be $True
            ($params["scriptpath"].attributes).where( {$_.TypeId -match 'parameter'}).Mandatory | Should Be $True
        }
        It "Should create a psd1 file" {
            {New-PSRemoteOperation -Computername Foo -Path TestDrive:\ -Scriptblock {1}} | Should Not Throw
            Test-Path TestDrive:\foo*.psd1 | Should be $True

            #Should have a filename using the pattern computername_guid.psd1"
            $guidrx = "[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}"
            $template = "foo_$guidrx.psd1"
            (Get-Item Testdrive:\*.psd1).name -match $Template | Should be $True

            #get the file contents to use in the next set of tests
            $script:in = Import-PowerShellDataFile Testdrive:\foo_*.psd1
        }

        It "Should create a file with a Computername value of Foo" {
            $script:in.Computername | Should Be "Foo"
        }
        It "Should have a Scriptblock value of 1" {
            $script:in.Scriptblock | Should be 1
        }
        It "Should have a UTC CreatedAt value" {
            $script:in.CreatedAt -match "UTC" | Should be $true
            $script:in.CreatedAt -match $(get-date -format MM/dd/yyyy) | Should be $true
        }

        It "Should accept multiple computernames" {
            $files = New-PSRemoteOperation -Computername Foo1, Foo2, Foo3 -Path TestDrive:\ -Scriptblock {Get-Volume C:} -Passthru
            $files.count | Should Be 3
        }
    } -tag command

    Describe Invoke-PSRemoteOperation {
        New-PSRemoteOperation -Computername $env:computername -Path TestDrive: -Scriptblock {Get-Service bits}
        New-Item -path TestDrive:\ -Name Archive -ItemType directory

        Context Input {
            $params = (Get-Command Invoke-PSRemoteOperation).parameters
            It "Should have a mandatory Path parameter ending in .psd1" {
                ($params["Path"].attributes).where( {$_.TypeId -match 'parameter'}).Mandatory | Should Be $True
                ($params["Path"].attributes).where( {$_.TypeId -match 'pattern'}).regexPattern | Should Be '\.psd1$'
            }
        }
        Context Process {
            $file = (Get-childitem testdrive:\*.psd1).fullname

            Mock 'Get-Date' {[datetime]::new(2019, 1, 1)}

            #I'd like to mock this but there doesn't appear to be a way
            #Mock New-PSSession {}

            Mock Convert-Path { $file }

            Invoke-PSRemoteOperation -Path $file -ArchivePath testdrive:\archive #-Verbose

            It "Should call Convert-Path" {
                Assert-MockCalled Convert-Path
            }

            It "Should call Get-Date" {
                Assert-MockCalled Get-Date
            }
            #save result for the next set of tests
            $script:result = Get-ChildItem TestDrive:\archive\*.psd1
            $script:rcontent = get-item $script:result | get-content
            $script:rdata = Import-powershelldatafile $script:result
        }

        Context Output {

            It "Should create an archive file" {
                $script:result | Should Not BeNullOrEmpty
            }
            It "Should show Completed as True" {
                $script:rdata.Completed | Should be 'True'
            }
            It "Should show the local computername" {
                $script:rdata.Computername | Should be $env:computername
            }
            It "Should show the scriptblock" {
                $script:rdata.Scriptblock.trim() | Should be "Get-Service bits"
            }
            It "Should show a date of 01/01/2019" {
                $script:rdata.Date -match "01\/01\/2019\s(\d{2}:){2}00\sUTC" | Should be $True
            }
        }
    } -tag command

    Describe Get-PSRemoteOperationResult {
        #copy the results from an earlier test to avoid duplication
        New-Item -path TestDrive: -Name Archive -ItemType directory
        $fake = Join-Path -Path TestDrive:\Archive -ChildPath "$($env:computername)_$(New-Guid).psd1"

        $script:rcontent | Out-File -FilePath $fake

        $r = Get-PSRemoteOperationResult -ArchivePath $fake
        It "Should get a result" {
            $fake | Should Exist
            $r | Should Not BeNullOrEmpty
        }

        It "Should write a RemoteOpResult object" {
            $r.psobject.typenames[0] | Should Be  "RemoteOpResult"
        }

        It "Should get an array of strings when using -RAW" {
            $r = Get-PSRemoteOperationResult -ArchivePath $fake -Raw
            $r | Should BeOftype "String"
            $r -is [array] | Should Be True
        }
    } -tag command

    Describe Register-PSRemoteOperationWatcher {
        New-Item -path TestDrive: -Name Archive -ItemType directory

        Mock New-JobTrigger { [Microsoft.PowerShell.ScheduledJob.ScheduledJobTrigger]::new()}
        Mock Register-ScheduledJob {}

        #create a fake credential for the pester test
        $cred = New-Object PSCredential foo, (ConvertTo-SecureString "password" -AsPlainText -Force)
        $testparams = @{
            Credential  = $cred
            Name        = 'TestWatch'
            Path        = 'Testdrive:\'
            ArchivePath = 'Testdrive:\Archive'
        }
        Register-PSRemoteOperationWatcher @testparams

        It "Should call New-Jobtrigger" {
            Assert-MockCalled New-JobTrigger
        }
        it "Should call Register-ScheduledJob" {
            Assert-MockCalled Register-ScheduledJob
        }
    } -tag command

}
