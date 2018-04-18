
#Generate Key Header - for Generate-NewRelicHeader
$ApiKey_encom_project = '5e9757cb8b3b42c7575d69fa57eef950c9de9c4356f8f7e'

#get a list of Servers/IID back based on search - Get-NewRelicServerInfo
$labelFilter = @{"filter[labels]"="MIGRATION:Fm1" }
$labelName = @{"filter[name]"="MIGRATION" }

#List of metrics to be queried against; also give to/from, and polling period for sampling
$NewRelicArrayMetrics = @("ProcessSamples/SYSTEM/Scan64","ProcessSamples/SYSTEM/ruby","ProcessSamples/SYSTEM/BESClient","ProcessSamples/SYSTEM/powershell","ProcessSamples/SYSTEM/mcshield","ProcessSamples/SYSTEM/TrustedInstaller")
$FromDate = "2017-04-23T04:46:00+00:00"
$ToDate =   "2017-04-27T06:33:00+00:00"
$Period = "600"


#Get-NewRelicServerInfo -ApiKey '5e9757cb8b3b42c7575d69fa57eef950c9de9c4356f8f7e'
Generate-NewRelicHeader -ApiKey $ApiKey_encom_project

Get-NewRelicServerInfo -NRFilter $labelFilter
#Get-NewRelicServerInfo -NRFilter $labelName
#Get-NewRelicServerInfo -NRFilter @{"filter[name]"="ssd"}
#Get-NewRelicServerInfo

#Export out to file
Export-NewRelicServerMetics -NRheader $NRheaders -NRProcessMetrics $NewRelicArrayMetrics  -NRToDateTime $ToDate -NRFromDateTime $FromDate -NRPollPeriod $Period




