Add-PSSnapin Microsoft.Sharepoint.PowerShell -ErrorAction "SilentlyContinue"	
#staging	$srv1 = "appsrv1"	$srv2 = "appsrv2"	
#prod	#$srv1 = "appsrvprod1"	#$srv2 = "appsrvprod2"	
$service = "Excel Calculation Services"	
function WaitForJobToFinish()	{ 	    $JobName = "*job-service-instance*"	    $job = Get-SPTimerJob | ?{ $_.Name -like $JobName }	    if ($job -eq $null) 	    {	        Write-Host 'Timer job not found'	    }	    else	    {	        $JobFullName = $job.Name	        Write-Host -NoNewLine "Waiting to finish job $JobFullName"	        	        while ((Get-SPTimerJob $JobFullName) -ne $null) 	        {	            Write-Host -NoNewLine .	            Start-Sleep -Seconds 2	        }	        Write-Host  "Finished waiting for job.."	    }	}	
Write-Host -ForeGroundColor Yellow "Restarting service $service on $srv1"	
WaitForJobToFinish	
Get-SPServiceInstance -server $srv1 | where-object {$_.TypeName -eq $service} | Stop-SPServiceInstance -Confirm:$false	
WaitForJobToFinish	
Get-SPServiceInstance -server $srv1 | where-object {$_.TypeName -eq $service} | Start-SPServiceInstance -Confirm:$false	
WaitForJobToFinish	
Write-Host -ForeGroundColor Yellow "Restarting service $service on $srv2"	
Get-SPServiceInstance -server $srv2 | where-object {$_.TypeName -eq $service} | Stop-SPServiceInstance -Confirm:$false	
WaitForJobToFinish	
Get-SPServiceInstance -server $srv2 | where-object {$_.TypeName -eq $service} | Start-SPServiceInstance -Confirm:$false	
Write-Host -ForeGroundColor Green "End of Script you can close the window"