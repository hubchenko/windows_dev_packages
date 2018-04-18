## -------------------------------------------------------------------------------------------------------------
## 
##
##      Description: Collect information of BladeSystem from OneView
##
## DISCLAIMER
## The sample scripts are not supported under any HP standard support program or service.
## The sample scripts are provided AS IS without warranty of any kind. 
## HP further disclaims all implied warranties including, without limitation, any implied 
## warranties of merchantability or of fitness for a particular purpose. 
##
##    
## Scenario
##     	Use HP OneView to collect information about servers
##		
##
## Input parameters:
##         OVApplianceIP      : Address of OneView appliance
##         OVAdminName        : name of OneView administrator
##         OVAdminPassword    : password of OneView administrator
##         Enclosures         : List of enclosures
##         OneViewModule      ; OneView PS modules - Minimum is HPOneView 1.20
##
##
## History: 
##         March-2015: v1.0 - Initial release
##
## Contact: Dung.HoangKhac@hp.com


Param ( [string]$OVApplianceIP="", 
        [string]$OVAdminName="", 
        [string]$OVAdminPassword="",
        [string]$OneViewModule = "HPOneView.120",  # "C:\OneView\PowerShell\HPOneView.120.psm1",

        [string[]]$Enclosures = "" 

       )


## -------------------------------------------------------------------------------------------------------------
##
##                     Function New-InventoryFiles
##
## -------------------------------------------------------------------------------------------------------------
Function New-InventoryFiles 
{

Param ([string]$Enclosure)


    # ---------------------------
    #  Generate Output files

    $TimeStamp = get-date -format MMMyyyy 

    $script:Fwfile  = "$Enclosure-FW-$TimeStamp.CSV"
    $script:Srvfile = "$Enclosure-Servers-$TimeStamp.CSV"
    $script:SNPFile  = "$Enclosure-Parts-$TimeStamp.CSV"
    $script:IPSFile = "$Enclosure-IPs-$TimeStamp.CSV"
    $script:ConFile = "$Enclosure-Connections-$TimeStamp.CSV"
    $script:UplFile = "$Enclosure-UpLinks-$TimeStamp.CSV"

    # ---Generate header for Firmware CSV file
    $FirmwareCSV = New-Item $script:FwFile  -type file -force
    Set-content -Path $script:FwFile -Value "Location,Model,FW,iLOModel,iLOFW" 

    # ---Generate header for Srv CSV file
    $SrvCSV = New-Item $script:SrvFile  -type file -force
    Set-content -Path $script:SrvFile -Value "Location,Server Model,CPU Type,CPU Count,CPU Cores,Memory(GB)"
    

    # ---Generate header for Parts CSV file
    $SNPCSV = New-Item $script:SNPFile  -type file -force
    Set-content -Path $script:SNPFile -Value "Location,Device,S/N,Part Number,Spare Part Number" 


    # ---Generate header for Memory CSV file
    $IPsCSV = New-Item $script:IPsFile  -type file -force
    Set-content -Path $script:IPsFile -Value "Location,Device,IP Address,FQDN"
                    

    # ---Generate header for Connections CSV file
    $ConCSV = New-Item $script:ConFile  -type file -force
    Set-content -Path $script:ConFile -Value "Location,Type,Port,MAC,WWPN,WWNN,Network,Device,Model"

    # ---Generate header for UpLink CSV file
    $UplCSV = New-Item $script:UplFile  -type file -force
    Set-content -Path $script:UplFile -Value "Location,PortName,RemotePortDescription,RemoteChassisID,RemoteMgmtAddress,RemoteSystemName,RemoteSystemDescription"      

}



# -------------------------------------------------------------------------------------------------------------##                  Main Entry### -------------------------------------------------------------------------------------------------------------   # -----------------------------------#    Always reload module   $LoadedModule = get-module $OneviewModuleif ($LoadedModule -ne $NULL){    remove-module $OneviewModule}import-module $OneViewModule  # ---------------------------# Connect to OneView appliancewrite-host "`n Connect to the OneView appliance..."Connect-HPOVMgmt -appliance $OVApplianceIP -user $OVAdminName -password $OVAdminPassword# ----------------------------# Scan thru enclosures$AllSNParts        = @()$AllFW             = @()$AllIPs            = @()$AllConnections    = @()$AllUpLinks        = @()$ServerInv         = @()Foreach ($encl in $Enclosures){    $ThisEnclosure = get-HPOVEnclosure | where Name -Match $encl    if ($ThisEnclosure -eq $NULL)    {        write-log " Enclosure $encl does not exist. Skip it"     }    else    {        # ---- Getting inventory        #        # ---------------------------------        # Enclosure        write-host -ForegroundColor CYAN "`n Collecting information for enclosure --> $Encl"         $EnclName = $ThisEnclosure.Name        New-InventoryFiles -Enclosure $EnclName        $Location     = "$EnclName - "        $Model        = $ThisEnclosure.EnclosureType        $SerialNumber = $ThisEnclosure.serialNumber        $PartNumber   = $ThisEnclosure.PartNumber        $SparePart    = ""        # ------------"Location,Device,S/N,Part Number,Spare Part Number"         $AllSNParts +="$Location,$Model,$SerialNumber,$PartNumber,$SparePart"        # ---------------------------------        # Device Bay        $DeviceBays = $ThisEnclosure.DeviceBays        foreach ( $uri in $ThisEnclosure.DeviceBays.deviceUri)        {            if (($uri -ne $NULL) -and ($uri.Startswith('/')) )            {                $ThisBay = Send-HPOVRequest $Uri                $OneViewProfileName = $ThisBay.name                $BaySlot            = $ThisBay.position                $spUri              = $ThisBay.ServerProfileUri                if (($spUri -ne $NULL) -and ($spUri.Startswith('/')) )                {                    $ThisProfile      = send-HPOVRequest -uri $spUri                    $Connections      = $ThisProfile.Connections                    Foreach($ThisConnection in $Connections)                    {                        $NetworkName = $ICName = $ICModel = ""                        $netUri = $ThisConnection.networkuri                                        if (($netUri -ne $NULL) -and ($netUri.Startswith('/')) )                        {                            $Thisnetwork = send-hpovRequest $neturi                            $NetworkName = $ThisNetwork.name                        }                        $IcUri = $ThisConnection.interconnecturi                                        if (($IcUri -ne $NULL) -and ($IcUri.Startswith('/')) )                        {                            $ThisIC  = send-hpovRequest $IcUri                            $ICName  = $ThisIC.name                            $ICName  = $ICName.replace(',','-')                            $ICModel = $ThisIC.Model                        }                        $Location       = "$Enclname - Bay $BaySlot"                        $Type           = $ThisConnection.FunctionType                        $Port           = $ThisConnection.PortId                        $MAC            = $ThisConnection.mac                        $WWPN           = $ThisConnection.wwpn                        $WWNN           = $ThisConnection.wwnn                        $Network        = $NetworkName                        $ConnectTo      = $ICName                        $InterConnect   = $ICModel                        #---------------- "Location,Type,Port,MAC,WWPN,WWNN,Network,Device,Model"                        $AllConnections +="$Location,$Type,$Port,$MAC,$WWPN,$WWNN,$Network,$ConnectTo,$InterConnect"                     }                }                                                 # --------------------------                #   Collect IPs of iLO                                $Location     = "$Enclname - Bay $BaySlot";                $Model        = $ThisBay.mpModel;                $IP           = $ThisBay.mpIPAddress;                $FQDN         = $ThisBay.mpDNsName                # ---------"Location,Device,IP Address,FQDN"                $AllIPs += "$Location,$Device,$IP,$FQDN"                # --------------------------                #   Collect Firmware: ROM and iLO                                                                $Location = "$Enclname - Bay $BaySlot";                $Model    = $ThisBay.shortModel;                $FW       = $ThisBay.romVersion;                $iLOModel = $ThisBay.mpModel;                $iLOFW    = $ThisBay.mpFirmwareVersion;                # ------- "Location,Model,FW,iLOModel,iLOFW"                 $AllFW += "$Location,$Model,$FW,$iLOModel,$iLOFW"                # --------------------------                #   Collect S/N and PArt Numbers of Servers                $Location     = "$Enclname - Bay $BaySlot"                $Model        = $ThisBay.shortModel                $SerialNumber = $ThisBay.serialNumber                $PartNumber   = ""                $SparePart    = ""                # ------------"Location,Device,S/N,Part Number,Spare Part Number"                 $AllSNParts +="$Location,$Model,$SerialNumber,$PartNumber,$SparePart"                # --------------------------                #   Collect S/N and PArt Numbers of iLO                $Location     = "$Enclname - Bay $BaySlot"                $Model        = $ThisBay.mpModel                $SerialNumber = ""                $PartNumber   = $ThisBay.partNumber                $SparePart    = ""                # ------------"Location,Device,S/N,Part Number,Spare Part Number"                 $AllSNParts +="$Location,$Model,$SerialNumber,$PartNumber,$SparePart"                                                             # --------------------------                #   Collect Servers config                                $Location  = "$Enclname - Bay $BaySlot";                $Model     = $ThisBay.shortModel;                $CPU       = $ThisBay.processorType;                $CPUCount  = $ThisBay.processorCount;                $Core      = $ThisBay.processorCoreCount;                $Memory    = "$([int]($ThisBay.memoryMB) / 1KB) GB"                # ------------"Location,Server Model,CPU Type,CPU Count,CPU Cores,Memory(GB)"                                                                                                 $ServerInv += "$Location,$Model,$CPU,$CPUCount,$Core,$Memory"                               }        }        # ---------------------------------------        # FanBays                        foreach( $ThisFan in $ThisEnclosure.FanBays)        {                # --------------------------                #   Collect S/N and PArt Numbers of Fans                $Location     = "$Enclname - Fan $($ThisFan.bayNumber)"                $Model        = $ThisFan.model                $SerialNumber = ""                $PartNumber   = $ThisFan.partNumber                $SparePart    = $ThisFan.sparepartNumber                # ------------"Location,Device,S/N,Part Number,Spare Part Number"                 $AllSNParts +="$Location,$Model,$SerialNumber,$PartNumber,$SparePart"        }        # ---------------------------------------        # PowerSupply                        foreach( $ThisPDU in $ThisEnclosure.powerSupplyBays)        {                # --------------------------                #   Collect S/N and PArt Numbers of PDUs                $Location     = "$Enclname - PDU $($ThisPDU.bayNumber)";                $Model        = $ThisPDU.model;                $SerialNumber = $ThisPDU.serialNumber;                $PartNumber   = $ThisPDU.partNumber;                $SparePart    = $ThisPDU.sparepartNumber                # ------------"Location,Device,S/N,Part Number,Spare Part Number"                 $AllSNParts +="$Location,$Model,$SerialNumber,$PartNumber,$SparePart"        }              # ---------------------------------------        # OA                        foreach( $ThisOA in $ThisEnclosure.oa)        {            $OAslot = $ThisOa.bayNumber            # --------------------------            #   Collect firmware of OA            $Location = "$Enclname - OA $OAslot";            $Model    = "On-board Administrator";            $FW       = $ThisOA.fwVersion + ' ' + $ThisOA.fwBuilddate                       # ------- "Location,Model,FW,iLOModel,iLOFW"             $AllFW += "$Location,$Model,$FW,,"            # --------------------------            #   Collect OA IPs            $Location     = "$Enclname - OA $OAslot";            $Model        = "On-board Administrator";            $IP           = $ThisOA.ipAddress;            $FQDN         = $ThisOa.fqdnHostName            # ---------"Location,Device,IP Address,FQDN"            $AllIPs += "$Location,$Device,$IP,$FQDN"        }                    # ---------------------------------------        # Interconnects        foreach ($uri in $ThisEnclosure.InterConnectBays.interconnecturi)        {            if (($uri -ne $NULL) -and ($uri.Startswith('/')) )            {                $ThisInterConnecturi = Send-HPOVRequest $uri                # --------------------------                #   Collect FW of Interconnect devices                $ICName = $ThisInterConnecturi.name                $ICName = $ICName -replace(',','-')                $Location = $ICName                $Model    = $ThisInterConnecturi.productname                $FW       = $ThisInterConnecturi.firmwareVersion                # ------- "Location,Model,FW,iLOModel,iLOFW"                 $AllFW += "$Location,$Model,$FW,,"                            # --------------------------                #   Collect S/N and PArt Numbers of Interconnect Devices                $Location     = $ICName                $Model        = $ThisInterConnecturi.productname                $SerialNumber = $ThisInterConnecturi.serialNumber                $PartNumber   = "";                $SparePart    = ""                # ------------"Location,Device,S/N,Part Number,Spare Part Number"                 $AllSNParts +="$Location,$Model,$SerialNumber,$PartNumber,$SparePart"                # --------------------------                #   Collect IPs of Interconnect Devices                                $Location     = $ICname;                $Model        = $ThisInterConnecturi.productname;                $IP           = $ThisInterConnecturi.interconnectIP;                $FQDN         = ""                                 # ---------"Location,Device,IP Address,FQDN"                $AllIPs += "$Location,$Device,$IP,$FQDN"                # --------------------------                #   Collect Uplinks of Interconnect Devices                $ListofUpLinks  = $ThisInterConnecturi.Ports | where PortName -like 'X*' | where PortStatus -eq 'Linked'                foreach ($UpLink in $ListofUplinks)                {                    $PortName = $UPLink.PortName                    $neighbor = $Uplink.Neighbor                    $RemoteChassisID   = $neighbor.RemoteChassisID                    $RemoteMgmtAddress = $neighbor.RemoteMgmtAddress                    $RemotePortDescription = $neighbor.RemotePortDescription                    $remoteSystemName = $neighbor.remoteSystemName                    $RemoteSystemDescription = $neighbor.RemoteSystemDescription                    if (-not [string]::IsNullOrEmpty($RemoteSystemDescription))                    {                        $RemoteSystemDescription = $RemoteSystemDescription.replace("`n","/").replace("`r","/").split('/')[0]                        $RemoteSystemDescription = $RemoteSystemDescription.Replace(', ', '-')                    }                    "$Location,$PortName,$RemotePortDescription,$RemoteChassisID,$RemoteMgmtAddress,$RemoteSystemName,$RemoteSystemDescription"                     $AllUpLinks += "$Location,$PortName,$RemotePortDescription,$RemoteChassisID,$RemoteMgmtAddress,$RemoteSystemName,$RemoteSystemDescription"                 }                                                $Location     = $ICname;                $Model        = $ThisInterConnecturi.productname;                $IP           = $ThisInterConnecturi.interconnectIP;                $FQDN         = ""            }        }    }    add-content -path $script:ConFile   -Value $AllConnections    add-content -path $script:SNPFile   -Value $AllSNParts    add-content -path $script:FWFile    -Value $AllFW    add-content -path $script:IPSFile   -Value $AllIPs    add-content -path $script:SrvFile   -Value $ServerInv    add-content -path $script:UplFile   -Value $AllUpLinks   Disconnect-HPOVMgmt}