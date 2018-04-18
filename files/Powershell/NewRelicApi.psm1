
function Generate-NewRelicHeader {
  <#
  .SYNOPSIS
  Simple function that creates headers hash for new relic
  .DESCRIPTION
  Creates a new array object, then adds the API Key/value for New relic.  Return as a global variable to to be used in other functions
  .EXAMPLE
  Generate-NewRelicHeader -ApiKey '<your api key>'
  .PARAMETER ApiKey
  Key you get from New relic d
  .PARAMETER logname
  The name of a file to write failed computer names to. Defaults to errors.txt.
  #>
  [CmdletBinding()]
  param(
  
  [Parameter(Mandatory=$True, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, HelpMessage='get this value from RPM dashboard')]
  [Alias('key')]
  [string[]]$ApiKey
  )
    if ($NRheaders) {Remove-Variable -Name $Global:NRheaders}
    $Global:NRheaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $Global:NRheaders.Add("X-Api-Key",$ApiKey )

    $InfoUpdate = 'Your API key:' + $ApiKey + ' has been added to the global $NRheaders variable.  Use this variable in your -Header property when using the Invoke-Restmethod cmd-let when Talking to New Relic :)'

    Write-Host $InfoUpdate


}

function Get-NewRelicServerInfo {
  <#
  .SYNOPSIS
  pulls back host Name, Host ID from new Relic based on seach parameter
  .DESCRIPTION
  New Relic APi requires knowing the 'Host ID'. of the server you want data for.  This function allows you to search either by Host ID, Name, or label
  and Return those into a set of variables that can be used
  .RETURN VALUE
  $NRServerhash = Key/Pair value of Server Name and Host ID
  $NRServerHosts = Array of Server Names
  $NRServerHosts = Key/Pair value of Server Name and Host ID
  .PARAMETER NRHeader
 Hash that resolves to your New Relic API header; defaults to $NRheaders
  .PARAMETER NRFilter
 Filter type, can be by Name (wild cards), label, or Host ID
  .EXAMPLE
  Get-NewRelicServerInfo -NRHeader $NRHeaders -NRFilter @{"filter[name]"="ssd"}
    .EXAMPLE
  Get-NewRelicServerInfo -NRHeader {"X-Api-Key"="<your API key>" } -NRFilter {"filter[labels]"="NSG:hammerdb" }

  #>
  [CmdletBinding()]
  param(
  
  [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, HelpMessage='enter in hash key:x-api-key value:<your New Relic API key>')]
  [Alias('header')]$NRheader = $Global:NRHeaders,
  [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, HelpMessage='String making up filter (label, name, host) and value of response')]
  [Alias('payload')]$NRFilter = $null
  )
  
  $Global:ResponseServers = Invoke-RestMethod 'https://api.newrelic.com/v2/servers.json' -Headers $NRheaders  -Body $NRFilter  
  $Global:NRServerIDs = $ResponseServers.servers.id
  $Global:NRServerHosts = $ResponseServers.servers.host
  $Global:NRServerHash = $ResponseServers.servers | Select-Object -Property id,host

  $InfoUpdate = 'Variables have been updated based on the servers found. $NRHosts contains a list of Host names found in your project; $NRServerIDs contains a list of New Relic Server Id''s.  $NRServerHash contains hastable of ID and Host name.'

  $InfoUpdate

}








function Export-NewRelicServerMetics {
  <#
  .SYNOPSIS
  Spits out CSV of Metrics from new Relic, based on a) server list provided, and b) process metrics to monitor
  .DESCRIPTION
  Takes hash for host Id, Name from New relic as input. Also takes array of metrics to grab.  Gets CPU/Memory OS metrics, as well as
  individual metrics for process defined.  spits back output into a CSV vile under '
  .EXAMPLE (TBD)
  Export-NewRelicServerMetics -NRheader $NRheaders -NRProcessMetrics $NewRelicArrayMetrics  -NRToDateTime $ToDate -NRFromDateTime $FromDate -NRPollPeriod $Period
  .PARAMETER (TBD)

  #>
  [CmdletBinding()]
  param($NRProcessMetrics,$NRheader = $Global:NRHeaders,$NRFromDateTime, $NRToDateTime,$NRPollPeriod,$NRhash= $Global:NRServerHash)



$Global:MetricCollection = New-Object System.Collections.ArrayList($null)


    $NRhash.GetEnumerator() | ForEach-Object {

        $Global:PerformanceMetricsHash=@{}



        $ID = $_.id
        $PerformanceMetricsHash.Add("Server_Id",$_.id)
        $PerformanceMetricsHash.Add("Host_Name",$_.host)

        #Memory Block

        $PayloadTotalMemoryMetric = @{"names[]"="System/Memory/Used/bytes";"from" =$NRFromDateTime;"to" =$NRToDateTime; "period" = $NRPollPeriod;"summarize" = "true"}
        $Global:ResponseTotalMemoryMetric= Invoke-RestMethod "https://api.newrelic.com/v2/servers/$ID/metrics/data.json" -Headers $NRheaders -Body  $PayloadTotalMemoryMetric -ContentType "application/json"

        $TotalMemoryUsed = ($ResponseTotalMemoryMetric.metric_data.metrics.timeslices.values.average_value)/(1GB)
        $TotalMemory = ($ResponseTotalMemoryMetric.metric_data.metrics.timeslices.values.average_exclusive_time)/(1TB)

        if ($TotalMemory) {$TotalMemoryPercentUsed = (($TotalMemoryUsed /  $TotalMemory)*100)}
          else  {$TotalMemoryPercentUsed = "0"}


        $PerformanceMetricsHash.add("Memory_Total_Avail(GB)",$TotalMemory)
        $PerformanceMetricsHash.add("Memory_Average_Used(GB)",$TotalMemoryUsed)
        $PerformanceMetricsHash.add("Memory_Total_Percent_Used(%)",$TotalMemoryPercentUsed)

        #Cpu Block

        $PayloadCPUTotalMetric = @{"names[]"="System/CPU/System/percent";"from" =$NRFromDateTime;"to" =$NRToDateTime; "period" = $NRPollPeriod;"summarize" = "true"}
        $Global:ResponseCPUTotalMetric= Invoke-RestMethod "https://api.newrelic.com/v2/servers/$ID/metrics/data.json" -Headers $NRheaders -Body  $PayloadCPUTotalMetric -ContentType "application/json"

        $CPUPercentUsed = ($ResponseCPUTotalMetric.metric_data.metrics.timeslices.values.average_value)
        #$CPUResponseTime = ($ResponseCPUTotalMetric.metric_data.metrics.timeslices.values.average_response_time)

        $PerformanceMetricsHash.add("CPU_Average_Used_(%)",$CPUPercentUsed)
        #$PerformanceMetricsHash.add("CPU_Average_Response_Time(MS)",$CPUResponseTime)




        foreach ($Metric in $NRProcessMetrics) 
            {
            
         
            
            $MetricsHash = @{}
            
            $PayloadProcessMetric = @{"names[]"=$Metric;"from" =$NRFromDateTime;"to" =$NRToDateTime; "period" = $NRPollPeriod;"summarize" = "true"}
            $ResponseProcessMetrics = Invoke-RestMethod "https://api.newrelic.com/v2/servers/$ID/metrics/data.json" -Headers $NRheaders -Body  $PayloadProcessMetric -ContentType "application/json"

            
            $average_value = ($ResponseProcessMetrics.metric_data.metrics.timeslices.values.average_value) #/(1GB)
            $average_exclusive_time = ($ResponseProcessMetrics.metric_data.metrics.timeslices.values.average_exclusive_time)/(1TB)
            
 

            
            
   
            $MetricsHash.add(($Metric+ "__CPU_Average_used(%)"),$average_value)
            $MetricsHash.add(($Metric+ "__Memory_Average_Used(GB)"),$average_exclusive_time)
            
            

            
            $Global:PerformanceMetricsHash += $MetricsHash
            
            


            }

           

            $MetricCollection.Add((New-Object PSObject -Property $PerformanceMetricsHash))

        }
  






$MetricCollection | Export-Csv -Path C:\temp\newRelicOutput.csv
}

