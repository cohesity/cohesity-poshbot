function Format-PBCohesityObject {
    param (
        [Parameter(
            Position = 0)]
        $Object,
        [Parameter(
            Position = 1)]
        [string] $FunctionName
    )

    if (($object.count -eq 0) -or (-not $object)) {
        $msg = 'No {0} found'
        switch ($functionname) {
            'Get-PBCohesityCluster' {$msg -f 'cluster information'}
            'Get-PBCohesityProtectionJobs.ps1' {$msg -f 'cluster protection jobs'}
            'Get-PBCohesityActiveProtectionJobs.ps1' {$msg -f 'active protection job'}
            'Get-PBCohesityAlerts.ps1'  {$msg -f 'alerts in critical or warning status'}
            'Get-PBCohesityResolvedAlerts.ps1' {$msg -f 'resloved alerts'}
            'Get-PBCohesityUser.ps1' {$msg -f 'all users'}
            'Get-PBCohesityCreateJob.ps1' {$msg -f 'create protection job'}
            'Get-PBCohesityStartJob.ps1' {$msg -f 'start job' }
            'Get-PBCohesityStopJob.ps1' {$msg -f 'stop job' }
            'Get-PBCohesityResumeJob.ps1' {$msg -f 'resume job' }
            'Get-PBCohesityClusters.ps1' {$msg -f 'all cluster ip addresses' }
            'Get-PBCohesityProtectionRunGraph.ps1' {$msg -f 'protection run graph' }
            'Get-PBCohesityChangeCluster.ps1' {$msg -f 'change cluster' }
            'Get-PBCohesityHelp.ps1' {$msg -f 'command help' }
            'Get-PBCohesityResolveAlerts.ps1' {$msg -f 'resolve alerts' }
            'Get-PBCohesityLatestAlerts.ps1' {$msg -f 'latest alerts' }

        default {$msg -f 'objects'}
        }
    } else {
        $object | Format-List | Out-String -Width 120
    }
}

