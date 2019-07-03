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
            'Get-PBCohesityAlerts.ps1'  {$msg -f 'alerts'}
            'Get-PBCohesityResolvedAlerts.ps1' {$msg -f 'resloved alerts'}
            'Get-PBCohesityUser.ps1' {$msg -f 'all users'}
            'Get-PBCohesityCreateJob.ps1' {$msg -f 'all users'}
            'Get-PBCohesityStartJob.ps1' {$msg -f 'startjob' }
            'Get-PBCohesityStopJob.ps1' {$msg -f 'stopjob' }
            'Get-PBCohesityResumeJob.ps1' {$msg -f 'resumejob' }
        default {$msg -f 'objects'}
        }
    } else {
        $object | Format-List | Out-String -Width 120
    }
}
