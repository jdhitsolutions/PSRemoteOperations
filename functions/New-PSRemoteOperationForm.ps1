Function New-PSRemoteOperationForm {
    [cmdletbinding()]
    [OutputType("None", [system.io.fileinfo])]
    [Alias('nrof')]
    Param(
        [ValidateScript({Test-Path -Path $_ })]
        [Parameter(HelpMessage = "The folder where the remote operation file will be created.")]
        [string]$Path = $PSRemoteOpPath,
        [Parameter(HelpMessage = "Specify which version of PowerShell to use for the remote operation.")]
        [ValidateSet("Desktop", "Core")]
        [string]$PSVersion = "Desktop"
    )

    if ($isWindows -or ($PSedition -eq 'Desktop' )) {
        Try {
            Add-Type -AssemblyName PresentationFramework -ErrorAction stop
        }
        Catch {
            Write-Warning "Failed to load required WPF assemblies."
            Throw $_
            #bail out
            return
        }

        [xml]$xaml = @"
<Window x:Name="form"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="PS Remote Operations v$PSVersion" Height="500" Width="425">
    <Grid Margin="0,4,0.4,-3.6">
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="311*"/>
            <ColumnDefinition Width="106*"/>
        </Grid.ColumnDefinitions>
        <Label x:Name="label" Content="Computername" HorizontalAlignment="Left" Margin="20,16,0,0" VerticalAlignment="Top" Width="112" Height="30"/>
        <ComboBox x:Name="comboComputername" HorizontalAlignment="Left" Margin="120,17,0,0" VerticalAlignment="Top" Width="180" ToolTip="Select a computer from the list or enter a new one" Height="22" IsEditable="True" TabIndex="0"/>
        <CheckBox x:Name="chkWhatIf" TabIndex = "8" Content="WhatIf" HorizontalAlignment="Left" Margin="23.8,17,0,0" VerticalAlignment="Top" RenderTransformOrigin="1.387,-14.475" Grid.Column="1" Height="15" Width="55"/>
        <Button x:Name="btnCreate" TabIndex = "10" Content="_Create" HorizontalAlignment="Left" Margin="104,410,0,0" VerticalAlignment="Top" Width="75" AutomationProperties.AcceleratorKey="C" Height="20"/>
        <Button x:Name="btnCancel" TabIndex = "11" Content="C_ancel" HorizontalAlignment="Left" Margin="230,410,0,0" VerticalAlignment="Top" Width="75" RenderTransformOrigin="0.547,0.994" Height="19" AutomationProperties.AcceleratorKey="A"/>
        <RadioButton x:Name="radioScriptblock" Content="Scriptblock" HorizontalAlignment="Left" Margin="20,48,0,0" VerticalAlignment="Top" Height="15" Width="78" TabIndex="1"/>
        <RadioButton x:Name="radioScriptfile" TabIndex="3" Content="Script File" HorizontalAlignment="Left" Margin="20,194,0,0" VerticalAlignment="Top" Height="15" Width="70"/>
        <TextBox x:Name="txtFile" TabIndex = "4" HorizontalAlignment="Left" Height="23" Margin="99,192,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="259" ToolTip="Enter the path to a ps1 file on the REMOTE computer" Grid.ColumnSpan="2"/>
        <TextBox x:Name="txtScriptBlock" TabIndex="2" AcceptsReturn="True" HorizontalAlignment="Left" Margin="44,73,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="319" Height="106" FontFamily="Consolas" ScrollViewer.VerticalScrollBarVisibility="Auto" ToolTip="Enter a scriptblock to run on the remote computer. Enter the contents only without the {}." Text="scriptblock here" BorderThickness="2" Grid.ColumnSpan="2"/>
        <TextBox x:Name="txtInitialization" TabIndex = "5" AcceptsReturn="True" HorizontalAlignment="Left" Margin="44,245,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="319" Height="41" FontFamily="Consolas" ScrollViewer.VerticalScrollBarVisibility="Auto" ToolTip="Enter initialization command such as dot sourcing scripts or importing modules" BorderThickness="2" Grid.ColumnSpan="2"/>
        <TextBox x:Name="txtArguments" TabIndex = "6" AcceptsReturn="True" HorizontalAlignment="Left" Margin="44,323,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="319" Height="41" FontFamily="Consolas" ScrollViewer.VerticalScrollBarVisibility="Auto" ToolTip="enter a set of parameters like Name = foo one per line. You don't need to include quotes. Enable a switch as $True." BorderThickness="2" Grid.ColumnSpan="2"/>
        <Label x:Name="label1" Content="Initialization" HorizontalAlignment="Left" Margin="20,218,0,0" VerticalAlignment="Top" Height="25" Width="74"/>
        <Label x:Name="label2" Content="Arguments" HorizontalAlignment="Left" Margin="20,296,0,0" VerticalAlignment="Top" Height="26" Width="69"/>
        <Label x:Name="label3" Content="To:" HorizontalAlignment="Left" Margin="20,378,0,0" VerticalAlignment="Top" Height="26" Width="22"/>
        <ComboBox x:Name="ComboTo" TabIndex = "7" IsEditable = "True" HorizontalAlignment="Left" Height="23" Margin="44,378,0,0" VerticalAlignment="Top" Width="316" ToolTip="Enter CMS To: recipient" Grid.ColumnSpan="2"/>
        <CheckBox x:Name="chkPassthru" TabIndex = "9" Content="Passthru" HorizontalAlignment="Left" Margin="23.8,37,0,0" VerticalAlignment="Top" RenderTransformOrigin="1.387,-14.475" Grid.Column="1" Height="15" Width="67"/>
        <TextBox x:Name="statusbar" HorizontalAlignment="Stretch" Width="auto"  Padding = "10,0,0,10" Margin="0,433,0,0" Text="Loading" VerticalAlignment = "Center" Height="30" Grid.ColumnSpan="3"/>
        </Grid>
</Window>
"@

        $reader = New-Object System.Xml.XmlNodeReader $xaml
        $form = [Windows.Markup.XamlReader]::Load($reader)
        $form.WindowStartupLocation = [System.Windows.WindowStartupLocation]::CenterScreen
        $form.background = "#dce4de"

        #connect to controls
        $btnCancel = $form.findname("btnCancel")
        $btnCancel.Add_click( {
                $script:nroParams = $null
                $form.close()
            })

        $btnOK = $form.findname("btnCreate")
        $btnOK.Add_Click( {
                if ($cmbComputername.text -notmatch "\w+") {
                    $status.text = "You must select a computername."
                    #bail out and go back to the form
                    return
                }
                else {
                    $script:nroParams = @{
                        Computername = $cmbComputername.Text
                        Path         = $Path
                    }
                }

                if ($chkWhatIf.IsChecked) {
                    $script:nroParams.Add("WhatIf", $True)
                }

                if ($chkPassthru.IsChecked) {
                    $script:nroParams.Add("Passthru", $True)
                }

                if ($comboTo.text -match "\w") {
                    $script:nroParams.Add("To", $ComboTo.Text)
                }

                if ($txtInit.text) {
                    $script:nroParams.Add("Initialization", [scriptblock]::Create($txtInit.Text))
                }

                if ($txtArgs.text) {
                    if ($txtArgs.text -match "\w+(\s+)?=(\s+)?\w+") {
                        $txtArgs.text.Split("`n") |
                            ForEach-Object -Begin { $h = [ordered]@{ } } -Process {
                                $items = $_.split("=")
                                $h.add($items[0].trim(), $items[1].trim())
                            } -End {
                                $script:nroParams.Add("ArgumentList", $h)
                            }
                    } #if argument text matches x = y
                    else {
                        $status.text = "Arguments must follow the form parameter = value each on a new line"
                        $script:nroParams.remove("ArgumentList")
                        return
                    }
                }

                if ($radioSB.IsChecked) {
                    if ($txtSB.text -match "\w+") {
                        $script:nroParams.Add("Scriptblock", [scriptblock]::Create($txtSB.text))
                    }
                    else {
                        $status.text = "You must enter code for the scriptblock."
                        #bail out
                        return
                    }
                }
                else {
                    #$radioFile must be checked instead
                    if ($txtfile.text -match "\w+") {
                        $script:nroParams.Add("Scriptpath", $txtFile.Text)
                    }
                    else {
                        $status.text = "You must enter path to the .ps1 file on the REMOTE computer."
                        #bail out
                        return
                    }
                }

                $form.Close()
            })

        $cmbComputername = $form.findname("comboComputername")
        (Get-ChildItem -Path $PSRemoteOpArchive -File).foreach( { ($_.name).split("_", 2)[0] }) | Select-Object -Unique | Sort-Object |
            ForEach-Object {
                [void]$cmbComputername.items.add($_)
            }

        $radioSB = $form.FindName("radioScriptblock")
        $radioSB.Add_Click( {
                $txtSB.IsEnabled = $True
                $txtFile.IsEnabled = $False
            })
        $txtSB = $form.Findname("txtScriptBlock")
        $txtSB.Text = $Null
        $radioSB.IsChecked = $True
        $txtSB.IsEnabled = $True

        $radioFile = $form.FindName("radioScriptfile")
        $radioFile.Add_Click( {
                $txtSB.IsEnabled = $False
                $txtFile.IsEnabled = $True
            })
        $txtFile = $form.findname("txtFile")

        $radiofile.IsChecked = $False
        $txtFile.IsEnabled = $False

        $chkWhatif = $form.FindName("chkWhatIf")
        $chkPassthru = $form.FindName("chkPassthru")
        $txtInit = $form.FindName("txtInitialization")
        $txtArgs = $form.FindName("txtArguments")
        $status = $form.findname("statusbar")

        $ComboTo = $form.findname("ComboTo")
        $certs = Get-ChildItem -Path Cert:\CurrentUser\my -DocumentEncryptionCert
        if ($certs) {
            foreach ($cert in $certs) {
                [void]$comboTo.items.Add($cert.subject.trim())
            }
        }

        $form.Add_Loaded( {
                $cmbComputername.focus()
                $status.text = "Ready"
            })

        [void]$form.showDialog()

        if ($script:nroParams) {
            if ($chkWhatif.IsChecked) {
                $msg = "PSRemoteOperation WhatIf Values `n $($script:nroParams | Out-String )"
                Write-Host $msg -ForegroundColor green
            }
            $script:nroParams.Add("PSVersion",$PSVersion)
            New-PSRemoteOperation @script:nroParams
        }
    } #if Windows
    else {
        Write-Warning "This requires a Windows platform that supports WPF."
    }
} #close New-PSRemoteOperationForm