# Add disks online in RAC/ASM environment


Function Get-TextInput($sTitle = "Data Entry Form", $sPrompt = "Please enter information:") {

  [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
  [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

  $objForm = New-Object System.Windows.Forms.Form 
  $objForm.Text = $sTitle
  $objForm.Size = New-Object System.Drawing.Size(300,200) 
  $objForm.StartPosition = "CenterScreen"

  $objForm.KeyPreview = $True
  $objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
      {$x=$objTextBox.Text;$objForm.Close()}})
  $objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
      {$objForm.Close()}})

  $OKButton = New-Object System.Windows.Forms.Button
  $OKButton.Location = New-Object System.Drawing.Size(75,120)
  $OKButton.Size = New-Object System.Drawing.Size(75,23)
  $OKButton.Text = "OK"
  $OKButton.Add_Click({$x=$objTextBox.Text;$objForm.Close()})
  $objForm.Controls.Add($OKButton)

  $CancelButton = New-Object System.Windows.Forms.Button
  $CancelButton.Location = New-Object System.Drawing.Size(150,120)
  $CancelButton.Size = New-Object System.Drawing.Size(75,23)
  $CancelButton.Text = "Cancel"
  $CancelButton.Add_Click({$objForm.Close()})
  $objForm.Controls.Add($CancelButton)

  $objLabel = New-Object System.Windows.Forms.Label
  $objLabel.Location = New-Object System.Drawing.Size(10,20) 
  $objLabel.Size = New-Object System.Drawing.Size(280,20) 
  $objLabel.Text = $sPrompt
  $objForm.Controls.Add($objLabel) 

  $objTextBox = New-Object System.Windows.Forms.TextBox 
  $objTextBox.Location = New-Object System.Drawing.Size(10,40) 
  $objTextBox.Size = New-Object System.Drawing.Size(260,20) 
  $objForm.Controls.Add($objTextBox) 

  $objForm.Topmost = $True

  $objForm.Add_Shown({$objForm.Activate()})
  [void] $objForm.ShowDialog()

  return $x

}

Function Get-TextBox($sTitle = "Entry Form", $sPrompt = "Enter information:", $sDefault = "") {

  [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
  $t = [Microsoft.VisualBasic.Interaction]::InputBox($sPrompt, $sTitle, $sDefault)
  return $t  

}

Function New-Popup {

<#
.Synopsis
Display a Popup Message
.Description
This command uses the Wscript.Shell PopUp method to display a graphical message
box. You can customize its appearance of icons and buttons. By default the user
must click a button to dismiss but you can set a timeout value in seconds to 
automatically dismiss the popup. 

The command will write the return value of the clicked button to the pipeline:
  OK     = 1
  Cancel = 2
  Abort  = 3
  Retry  = 4
  Ignore = 5
  Yes    = 6
  No     = 7

If no button is clicked, the return value is -1.
.Example
PS C:\> new-popup -message "The update script has completed" -title "Finished" -time 5

This will display a popup message using the default OK button and default 
Information icon. The popup will automatically dismiss after 5 seconds.
.Notes
Last Updated: April 8, 2013
Version     : 1.0

.Inputs
None
.Outputs
integer

Null   = -1
OK     = 1
Cancel = 2
Abort  = 3
Retry  = 4
Ignore = 5
Yes    = 6
No     = 7
#>

Param (
[Parameter(Position=0,Mandatory=$True,HelpMessage="Enter a message for the popup")]
[ValidateNotNullorEmpty()]
[string]$Message,
[Parameter(Position=1,Mandatory=$True,HelpMessage="Enter a title for the popup")]
[ValidateNotNullorEmpty()]
[string]$Title,
[Parameter(Position=2,HelpMessage="How many seconds to display? Use 0 require a button click.")]
[ValidateScript({$_ -ge 0})]
[int]$Time=0,
[Parameter(Position=3,HelpMessage="Enter a button group")]
[ValidateNotNullorEmpty()]
[ValidateSet("OK","OKCancel","AbortRetryIgnore","YesNo","YesNoCancel","RetryCancel")]
[string]$Buttons="OK",
[Parameter(Position=4,HelpMessage="Enter an icon set")]
[ValidateNotNullorEmpty()]
[ValidateSet("Stop","Question","Exclamation","Information" )]
[string]$Icon="Information"
)

#convert buttons to their integer equivalents
Switch ($Buttons) {
    "OK"               {$ButtonValue = 0}
    "OKCancel"         {$ButtonValue = 1}
    "AbortRetryIgnore" {$ButtonValue = 2}
    "YesNo"            {$ButtonValue = 4}
    "YesNoCancel"      {$ButtonValue = 3}
    "RetryCancel"      {$ButtonValue = 5}
}

#set an integer value for Icon type
Switch ($Icon) {
    "Stop"        {$iconValue = 16}
    "Question"    {$iconValue = 32}
    "Exclamation" {$iconValue = 48}
    "Information" {$iconValue = 64}
}

#create the COM Object
Try {
    $wshell = New-Object -ComObject Wscript.Shell -ErrorAction Stop
    #Button and icon type values are added together to create an integer value
    $wshell.Popup($Message,$Time,$Title,$ButtonValue+$iconValue)
}
Catch {
    #You should never really run into an exception in normal usage
    Write-Warning "Failed to create Wscript.Shell COM object"
    Write-Warning $_.exception.message
}

}

Function MultipleSelectionBox ($inputarray,$prompt,$listboxtype) {
 
# Taken from Technet - http://technet.microsoft.com/en-us/library/ff730950.aspx
# This version has been updated to work with Powershell v3.0.
# Had to replace $x with $Script:x throughout the function to make it work. 
# This specifies the scope of the X variable.  Not sure why this is needed for v3.
# http://social.technet.microsoft.com/Forums/en-SG/winserverpowershell/thread/bc95fb6c-c583-47c3-94c1-f0d3abe1fafc
#
# Function has 3 inputs:
#     $inputarray = Array of values to be shown in the list box.
#     $prompt = The title of the list box
#     $listboxtype = system.windows.forms.selectionmode (None, One, MutiSimple, or MultiExtended)
 
$Script:x = @()
 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
 
$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = $prompt
$objForm.Size = New-Object System.Drawing.Size(300,600) 
$objForm.StartPosition = "CenterScreen"
 
$objForm.KeyPreview = $True
 
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
    {
        foreach ($objItem in $objListbox.SelectedItems)
            {$Script:x += $objItem}
        $objForm.Close()
    }
    })
 
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
    {$objForm.Close()}})
 
$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(75,520)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
 
$OKButton.Add_Click(
   {
        foreach ($objItem in $objListbox.SelectedItems)
            {$Script:x += $objItem}
        $objForm.Close()
   })
 
$objForm.Controls.Add($OKButton)
 
$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(150,520)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.Add_Click({$objForm.Close()})
$objForm.Controls.Add($CancelButton)
 
$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(10,20) 
$objLabel.Size = New-Object System.Drawing.Size(280,20) 
$objLabel.Text = "Please make a selection from the list below:"
$objForm.Controls.Add($objLabel) 
 
$objListbox = New-Object System.Windows.Forms.Listbox 
$objListbox.Location = New-Object System.Drawing.Size(10,40) 
$objListbox.Size = New-Object System.Drawing.Size(260,20) 
 
$objListbox.SelectionMode = $listboxtype
 
$inputarray | ForEach-Object {[void] $objListbox.Items.Add($_)}
 
$objListbox.Height = 470
$objForm.Controls.Add($objListbox) 
$objForm.Topmost = $True
 
$objForm.Add_Shown({$objForm.Activate()})
[void] $objForm.ShowDialog()
 
Return $Script:x
}

Function generateFilename ($v, $c, $cID) {

    # get the datastore cluster
    $d = $v | get-datastore
    $dsc = Get-DatastoreCluster -id $d[0].extensiondata.parent

    # Get a view of the datastore cluster that includes children
    $dsc_view = $dsc | Get-View

    # Create an array of datastores so we can read their free space
    $kids = @()

    # Load array with ds objects
    foreach ($i in $dsc_view.ChildEntity) {
        
        $kids = $kids + (get-datastore -id $i.ToString())
    }

    # Go through the datastores, find the name of the one with the most free space
    $freeSpace = 0
    $freeSpaceName = ""
    foreach ($i in $kids) {
        if ($i.FreeSpaceMB -gt $freeSpace) {
            $freeSpace = $i.FreeSpaceMB
            $freeSpaceName = $i.Name
        }
    }

    # 
    $filename = "[$freeSpaceName] $v/shared-disk-bus-$c-node-$cID.vmdk" 
    
    return $filename
}

Function baloonTip($zsub = "Information", $zmsg = "This message is a pretty useless default!") {

    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
 
    $notification = New-Object System.Windows.Forms.NotifyIcon 
 
    #Define the icon for the system tray
    $notification.Icon = [System.Drawing.SystemIcons]::Information
 
    #Display title of balloon window
    $notification.BalloonTipTitle = $zsub
 
    #Type of balloon icon
    $notification.BalloonTipIcon = "Info"
 
    #Notification message
    $notification.BalloonTipText = $zmsg
 
    #Make balloon tip visible when called
    $notification.Visible = $True

    #Call the balloon notification
    $notification.ShowBalloonTip(15000)
    
    return $notification
}

# User Variables
$serverName = "kmhpvcentpa20.kmhp.com"

# System Setup
$ErrorActionPreference = "Continue"
Add-PSSnapin VMware.VimAutomation.Core


# MAIN

# Connect to vCenter
$bTip = baloonTip "Connecting to vCenter" "This can take a minute."
#New-Popup "I am about to connect to vCenter, this can take a minute." -Title "Note" -Buttons OK -Icon Information
connect-viserver -Server $serverName
$bTip.Visible = $False

# Get a string to match for server names
$result = Get-TextBox "Hostnames" "Enter a pattern to match hosts. Wildcards are required." "*"
if ($result.length -eq 0) {
    write-host "Cancelling at user request."
    return
}

# Get hosts matching that pattern

$candidates = (Get-VM $result | sort)
if ($candidates.count -eq 0) {
    New-Popup "No hosts match (Did you use a wildcard?)" -Title "No Matches" -Buttons OK -Icon Exclamation
    return
}

$selections = MultipleSelectionBox $candidates "Prompt" "MultiSimple"
if ($selections.length -eq 0) {
    write-host "Cancelling at user request"
    return
}

# Convert $servers into an array of strings from array of objects OR a single object
$servers = @() + $selections


# Get the number of disks to create
$diskCount = 0
do {
  $diskCount = [int](Get-TextBox "Disk Count" "How Many Shared Disks shall I create for you? [1-55]" 3)
} until ($diskCount -le 55 -and $diskCount -gt 0)

# ... and get their sizes
$diskSize = [int](Get-TextBox "Disk Size" "Size of disks in GB?" 10)
if ($diskSize.length -eq 0) {
    write-host "Cancelling at user request"
    return
}

$diskSize = $diskSize * 1GB / 1KB

$hostCount = $servers.Count

# Init objects
$vm = New-Object VMware.VimAutomation.ViCore.Impl.V1.Inventory.VirtualMachineImpl[] ($hostCount)
$view = New-Object VMware.Vim.VirtualMachine[] ($hostCount)
$vmspec = New-Object VMware.Vim.VirtualMachineCloneSpec[] ($hostCount)
$vmtaskMoRef = New-Object VMware.Vim.ManagedObjectReference[] ($hostCount)
$nodeNames = New-Object String[] ($hostCount)

$flag = 0

# Load information from vSphere on selected servers
write-host "Servers.Length = $servers.Length"

for($i=0;$i -lt $servers.Length; $i++){

  write-host "Loading information for server" $servers[$i]
  $vm[$i] = Get-VM -Name $servers[$i]
  write-host "Loading View for server" $vm[$i]

  $view[$i] = Get-View -Id $vm[$i].Id
}



# Create new objects representing new or existing drives and controllers
$CreateSpecNewController = New-Object VMware.Vim.VirtualMachineConfigSpec
$CreateSpecNewController.deviceChange = New-Object VMware.Vim.VirtualDeviceConfigSpec[] (2)
$CreateSpecNewController.deviceChange[0] = New-Object VMware.Vim.VirtualDeviceConfigSpec
$CreateSpecNewController.deviceChange[0].operation = "add"
$CreateSpecNewController.deviceChange[0].fileOperation = "create"
$CreateSpecNewController.deviceChange[0].device = New-Object VMware.Vim.VirtualDisk
$CreateSpecNewController.deviceChange[0].device.key = -100
$CreateSpecNewController.deviceChange[0].device.backing = New-Object VMware.Vim.VirtualDiskFlatVer2BackingInfo
$CreateSpecNewController.deviceChange[0].device.backing.fileName = ""
$CreateSpecNewController.deviceChange[0].device.backing.diskMode = "independent_persistent"
$CreateSpecNewController.deviceChange[0].device.backing.thinProvisioned = $false
$CreateSpecNewController.deviceChange[0].device.backing.split = $false
$CreateSpecNewController.deviceChange[0].device.backing.writeThrough = $false
$CreateSpecNewController.deviceChange[0].device.backing.eagerlyScrub = $true
$CreateSpecNewController.deviceChange[0].device.connectable = New-Object VMware.Vim.VirtualDeviceConnectInfo
$CreateSpecNewController.deviceChange[0].device.connectable.startConnected = $true
$CreateSpecNewController.deviceChange[0].device.connectable.allowGuestControl = $false
$CreateSpecNewController.deviceChange[0].device.connectable.connected = $true
$CreateSpecNewController.deviceChange[0].device.controllerKey = -101
$CreateSpecNewController.deviceChange[0].device.capacityInKB = $diskSize
$CreateSpecNewController.deviceChange[1] = New-Object VMware.Vim.VirtualDeviceConfigSpec
$CreateSpecNewController.deviceChange[1].operation = "add"
$CreateSpecNewController.deviceChange[1].device = New-Object VMware.Vim.ParaVirtualSCSIController
$CreateSpecNewController.deviceChange[1].device.key = -101
$CreateSpecNewController.deviceChange[1].device.controllerKey = 100
$CreateSpecNewController.deviceChange[1].device.busNumber = 1
$CreateSpecNewController.deviceChange[1].device.sharedBus = "noSharing"
$CreateSpecNewController.extraConfig = New-Object VMware.Vim.OptionValue[] (1)
$CreateSpecNewController.extraConfig[0] = New-Object VMware.Vim.OptionValue
$CreateSpecNewController.extraConfig[0].key = "scsi1:0.sharing"
$CreateSpecNewController.extraConfig[0].value = "multi-writer"

$CreateSpecExistingController = New-Object VMware.Vim.VirtualMachineConfigSpec
$CreateSpecExistingController.deviceChange = New-Object VMware.Vim.VirtualDeviceConfigSpec[] (1)
$CreateSpecExistingController.deviceChange[0] = New-Object VMware.Vim.VirtualDeviceConfigSpec
$CreateSpecExistingController.deviceChange[0].operation = "add"
$CreateSpecExistingController.deviceChange[0].fileOperation = "create"
$CreateSpecExistingController.deviceChange[0].device = New-Object VMware.Vim.VirtualDisk
$CreateSpecExistingController.deviceChange[0].device.key = -100
$CreateSpecExistingController.deviceChange[0].device.backing = New-Object VMware.Vim.VirtualDiskFlatVer2BackingInfo
$CreateSpecExistingController.deviceChange[0].device.backing.fileName = ""
$CreateSpecExistingController.deviceChange[0].device.backing.diskMode = "independent_persistent"
$CreateSpecExistingController.deviceChange[0].device.backing.thinProvisioned = $false
$CreateSpecExistingController.deviceChange[0].device.backing.split = $false
$CreateSpecExistingController.deviceChange[0].device.backing.writeThrough = $false
$CreateSpecExistingController.deviceChange[0].device.backing.eagerlyScrub = $true
$CreateSpecExistingController.deviceChange[0].device.connectable = New-Object VMware.Vim.VirtualDeviceConnectInfo
$CreateSpecExistingController.deviceChange[0].device.connectable.startConnected = $true
$CreateSpecExistingController.deviceChange[0].device.connectable.allowGuestControl = $false
$CreateSpecExistingController.deviceChange[0].device.connectable.connected = $true
$CreateSpecExistingController.deviceChange[0].device.controllerKey = -101
$CreateSpecExistingController.deviceChange[0].device.capacityInKB = $diskSize
$CreateSpecExistingController.extraConfig = New-Object VMware.Vim.OptionValue[] (1)
$CreateSpecExistingController.extraConfig[0] = New-Object VMware.Vim.OptionValue
$CreateSpecExistingController.extraConfig[0].key = "scsi1:0.sharing"
$CreateSpecExistingController.extraConfig[0].value = "multi-writer"

$specNewController = New-Object VMware.Vim.VirtualMachineConfigSpec
$specNewController.deviceChange = New-Object VMware.Vim.VirtualDeviceConfigSpec[] (2)
$specNewController.deviceChange[0] = New-Object VMware.Vim.VirtualDeviceConfigSpec
$specNewController.deviceChange[0].operation = "add"
$specNewController.deviceChange[0].device = New-Object VMware.Vim.VirtualDisk
$specNewController.deviceChange[0].device.key = -100
$specNewController.deviceChange[0].device.backing = New-Object VMware.Vim.VirtualDiskFlatVer2BackingInfo
$specNewController.deviceChange[0].device.backing.fileName = ""
$specNewController.deviceChange[0].device.backing.diskMode = "independent_persistent"
$specNewController.deviceChange[0].device.backing.thinProvisioned = $false
$specNewController.deviceChange[0].device.connectable = New-Object VMware.Vim.VirtualDeviceConnectInfo
$specNewController.deviceChange[0].device.connectable.startConnected = $true
$specNewController.deviceChange[0].device.connectable.allowGuestControl = $false
$specNewController.deviceChange[0].device.connectable.connected = $true
$specNewController.deviceChange[0].device.controllerKey = -101
$specNewController.deviceChange[0].device.capacityInKB = $diskSize
$specNewController.deviceChange[1] = New-Object VMware.Vim.VirtualDeviceConfigSpec
$specNewController.deviceChange[1].operation = "add"
$specNewController.deviceChange[1].device = New-Object VMware.Vim.ParaVirtualSCSIController
$specNewController.deviceChange[1].device.key = -101
$specNewController.deviceChange[1].device.controllerKey = 100
$specNewController.deviceChange[1].device.busNumber = 1
$specNewController.deviceChange[1].device.sharedBus = "noSharing"
$specNewController.extraConfig = New-Object VMware.Vim.OptionValue[] (1)
$specNewController.extraConfig[0] = New-Object VMware.Vim.OptionValue
$specNewController.extraConfig[0].key = "scsi1:0.sharing"
$specNewController.extraConfig[0].value = "multi-writer"

$specExistingController = New-Object VMware.Vim.VirtualMachineConfigSpec
$specExistingController.deviceChange = New-Object VMware.Vim.VirtualDeviceConfigSpec[] (1)
$specExistingController.deviceChange[0] = New-Object VMware.Vim.VirtualDeviceConfigSpec
$specExistingController.deviceChange[0].operation = "add"
$specExistingController.deviceChange[0].device = New-Object VMware.Vim.VirtualDisk
$specExistingController.deviceChange[0].device.key = -100
$specExistingController.deviceChange[0].device.backing = New-Object VMware.Vim.VirtualDiskFlatVer2BackingInfo
$specExistingController.deviceChange[0].device.backing.fileName = ""
$specExistingController.deviceChange[0].device.backing.diskMode = "independent_persistent"
$specExistingController.deviceChange[0].device.backing.thinProvisioned = $false
$specExistingController.deviceChange[0].device.connectable = New-Object VMware.Vim.VirtualDeviceConnectInfo
$specExistingController.deviceChange[0].device.connectable.startConnected = $true
$specExistingController.deviceChange[0].device.connectable.allowGuestControl = $false
$specExistingController.deviceChange[0].device.connectable.connected = $true
$specExistingController.deviceChange[0].device.controllerKey = -101
$specExistingController.deviceChange[0].device.capacityInKB = $diskSize
$specExistingController.extraConfig = New-Object VMware.Vim.OptionValue[] (1)
$specExistingController.extraConfig[0] = New-Object VMware.Vim.OptionValue
$specExistingController.extraConfig[0].key = "scsi1:0.sharing"
$specExistingController.extraConfig[0].value = "multi-writer"

## two private disks exist on bus[0] already: boot disk, /u01 application binaries
$bus = 1,-1,-1,-1;

# Determine the highest value already in use
$hd = Get-HardDisk -vm $vm[0]
for($j=0;$j -lt $hd.Length; $j++){
   $controller = [int](($hd[$j].ExtensionData.ControllerKey) - 1000)
   $unit_no    = [int]$hd[$j].ExtensionData.UnitNumber

   write-host $hd[$j].Filename " is on controller " $controller " and is unit # " $unit_no
   write-host "unit_no = " $unit_no ", bus[controller] = " $bus[$controller]
   if ($unit_no -gt $bus[$controller]) {
        $bus[$controller] = $unit_no
   }
    
}

write-host "The bus looks like " $bus


# Start on SCSI bus 1
$busID = 1

for($j=0;$j -lt $diskCount; $j++){

  
# If the current bus is full (15 devices) then increment until we find a bus that isn't
while ($bus[$busID] -ge 15) {
    $busID++
}
  

  if ($busID -gt 3) {
    write-host "All SCSI buses are full!"
    throw
  }

  $bus[$busID] += 1
  if ($bus[$busID] -eq 7) { $bus[$busID] += 1 }
  $deviceString = "scsi" + [string]($busID) + ":" + [string]$bus[$busID] + ".sharing"
  write-host "modulus of diskCount " $j " is scsi" $busID ":" $deviceString

  $CreateSpec = $CreateSpecNewController
  $CreateSpec.deviceChange[1].device.busNumber = $busID
  foreach ($VirtualSCSIController in ($view[0].Config.Hardware.Device | where {$_.DeviceInfo.Label -match "SCSI Controller"})) {
    if ($VirtualSCSIController.BusNumber -eq $busID) {
      $CreateSpec = $CreateSpecExistingController
      $CreateSpec.deviceChange[0].device.controllerKey = $VirtualSCSIController.Key

    }
  }
  $CreateSpec.extraConfig[0].key = $deviceString
  $Createspec.deviceChange[0].device.unitNumber = $bus[$busID]

  # Generate a filename for this disk so that it is stored on the datastore with most free space
  $fn = generateFilename $vm[0] $busID $bus[$busID]
  write-host "Generated filename was $fn"
  $CreateSpec.deviceChange[0].device.backing.filename = $fn
  

  # first VM creates the disks:
  write-host "create " $deviceString " on " $vm[0].Name " controllerKey = " $CreateSpec.deviceChange[0].device.controllerKey

  $taskMoRef = $view[0].ReconfigVM_Task($CreateSpec) 
  $task = Get-View $taskMoRef

  while("running","queued" -contains $task.Info.State){
    $task.UpdateViewData("Info.State")
  }
  if($task.Info.State -eq "error"){
    $task.UpdateViewData("Info.Error")
    $task.Info.Error.Fault.faultMessage | % {
      $_.Message
    } 
    write-host "Error!"
    exit
  }
  # refresh the view, to pickup any new device(s)
  $view[0] = Get-View -Id $vm[0].Id

  $backingFileName = ""
  foreach ($VirtualSCSIController in ($view[0].Config.Hardware.Device | where {$_.DeviceInfo.Label -match "SCSI Controller"})) {
    if ($VirtualSCSIController.BusNumber -eq $busID) {
      foreach ($VirtualDiskDevice in ($view[0].Config.Hardware.Device | where {$_.ControllerKey -eq $VirtualSCSIController.Key})) {
        if ($VirtualDiskDevice.UnitNumber -eq $bus[$busID]){
          $backingFileName = $VirtualDiskDevice.Backing.FileName
          write-host "filename = " $backingFileName

          # subsequent VMs attach to existing disks:
          for ($node = 1; $node -lt $hostCount; $node++){
            $spec = $SpecNewController
            $spec.deviceChange[1].device.busNumber = $busID
            foreach ($VirtualSCSIController in ($view[$node].Config.Hardware.Device | where {$_.DeviceInfo.Label -match "SCSI Controller"})) {
              if ($VirtualSCSIController.BusNumber -eq $busID) {
                $spec = $SpecExistingController
                $spec.deviceChange[0].device.controllerKey = $VirtualSCSIController.Key

              }
            }
            $spec.extraConfig[0].key = $deviceString
            $spec.deviceChange[0].device.unitNumber = $bus[$busID]
            $spec.deviceChange[0].device.backing.FileName = $VirtualDiskDevice.Backing.FileName

            write-host "attach " $deviceString " to " $vm[$node].Name " backingFilename = " $spec.deviceChange[0].device.backing.FileName " controllerKey = " $spec.deviceChange[0].device.controllerKey

            $taskMoRef = $view[$node].ReconfigVM_Task($spec) 
            $task = Get-View $taskMoRef

            while("running","queued" -contains $task.Info.State){
              $task.UpdateViewData("Info.State")
            }
            if($task.Info.State -eq "error"){
              $task.UpdateViewData("Info.Error")
              $task.Info.Error.Fault.faultMessage | % {
                $_.Message
              }
              exit
            }
            # refresh the view, to pickup any new device(s)
            $view[$node] = Get-View -Id $vm[$node].Id
          }
        }
      }
    }
  }
}

# Run away!!!!!
disconnect-viserver -Server $serverName