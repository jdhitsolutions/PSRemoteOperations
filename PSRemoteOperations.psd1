#
# Module manifest for module 'PSRemoteOperations'
#

@{
    RootModule           = "PSRemoteOperations.psm1"
    ModuleVersion        = '4.1.0'
    CompatiblePSEditions = @("Desktop", "Core")
    GUID                 = '62bc09fe-38bf-426d-aa3c-e6c2cf6bb528'
    Author               = 'Jeff Hicks'
    CompanyName          = 'JDH Information Technology Solutions, Inc.'
    Copyright            = '(c) 2018-2021 JDH Information Technology Solutions, Inc. All rights reserved.'
    Description          = 'A PowerShell module for executing commands remotely in a non-remoting environment using a shared folder structure such as Dropbox.'
    PowerShellVersion    = '5.1'

    # TypesToProcess = @()
    # FormatsToProcess = @()

    FunctionsToExport    = 'New-PSRemoteOperation', 'Invoke-PSRemoteOperation', 'Get-PSRemoteOperationResult', 'Register-PSRemoteOperationWatcher', 'Wait-PSRemoteOperation', 'New-PSRemoteOperationForm', 'Get-PSRemoteOperation', 'Register-PSRemoteOpPath', 'Import-PSRemoteOpPath'
    CmdletsToExport      = @()
    VariablesToExport    = @()
    AliasesToExport      = 'nro', 'iro', 'row', 'gro', 'nrof', 'wro', 'grop'

    PrivateData          = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags         = @("Remoting", "ScheduledJob", "operations", "remoteManagement")

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
