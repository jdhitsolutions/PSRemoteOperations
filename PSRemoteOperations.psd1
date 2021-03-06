#
# Module manifest for module 'PSRemoteOperations'
#

@{

# Script module or binary module file associated with this manifest.
RootModule = ""

# Version number of this module.
ModuleVersion = '3.3.1'

# Supported PSEditions
CompatiblePSEditions = @("Desktop","Core")

# ID used to uniquely identify this module
GUID = '62bc09fe-38bf-426d-aa3c-e6c2cf6bb528'

# Author of this module
Author = 'Jeff Hicks'

# Company or vendor of this module
CompanyName = 'JDH Information Technology Solutions, Inc.'

# Copyright statement for this module
Copyright = '(c) 2018-2019 JDH Information Technology Solutions, Inc. All rights reserved.'

# Description of the functionality provided by this module
Description = 'A PowerShell module for executing commands remotely in a non-remoting environment using a shared folder structure such as Dropbox.'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.1'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules =  if ($PSEdition -eq 'core') {
    'core\PSRemoteOperations.psm1'
}
else {
    'windows\PSRemoteOperations.psm1'
}

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = if ($PSEdition -eq 'Core') {
        'New-PSRemoteOperation', 'Invoke-PSRemoteOperation', 'Get-PSRemoteOperationResult', 'Wait-PSRemoteOperation',
        'Get-PSRemoteOperation','Register-PSRemoteOpPath','Import-PSRemoteOpPath'
    }
    else {
        #Windows PowerShell gets everything
        'New-PSRemoteOperation', 'Invoke-PSRemoteOperation', 'Get-PSRemoteOperationResult', 'Register-PSRemoteOperationWatcher',
        'Wait-PSRemoteOperation', 'New-PSRemoteOperationForm', 'Get-PSRemoteOperation','Register-PSRemoteOpPath',
        'Import-PSRemoteOpPath'
    }

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = @()

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = if ($PSEdition -eq 'core') {
    'nro', 'iro', 'gro', 'wro','grop'
}
else {
    'nro', 'iro', 'row', 'gro', 'nrof', 'wro','grop'
}

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags         = @("Remoting", "ScheduledJob")

            # A URL to the license for this module.
            LicenseUri   = 'https://github.com/jdhitsolutions/PSRemoteOperations/blob/master/license.txt'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/jdhitsolutions/PSRemoteOperations'

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            ReleaseNotes = 'http://bit.ly/2KsYbu2'

            # ExternalModuleDependencies = "PSScheduledJob"

        } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
#HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}



