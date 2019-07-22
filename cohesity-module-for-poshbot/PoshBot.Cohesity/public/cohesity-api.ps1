
<#
.SYNOPSIS
function to call Cohesity API
.DESCRIPTION
Get / Post / Put / Delete methods 

Description
-----------
used to manually make api calls
#>
    function apiauth($pass, $user, $domain, $ip){

        $global:APIROOT = 'https://' + $ip + '/irisservices/api/v1'
        $HEADER = @{'accept' = 'application/json'; 'content-type' = 'application/json'}
        $url = $APIROOT + '/public/accessTokens'
    
        try {
            $auth = Invoke-RestMethod -Method Post -Uri $url  -Header $HEADER -Body $(
                ConvertTo-Json @{
                    'domain' = $domain;
                    'password' = $pass;
                    'username' = $user
                }) -SkipCertificateCheck
            $global:CURLHEADER = "authorization: $($auth.tokenType) $($auth.accessToken)"
    
            $global:AUTHORIZED = $true
            $global:HEADER = @{'accept' = 'application/json';
                'content-type' = 'application/json';
                'authorization' = $auth.tokenType + ' ' + $auth.accessToken
            }
        }
        catch {
            $global:AUTHORIZED = $false
            if($_.ToString().contains('"message":')){
                New-PoshBotCardResponse -Text (ConvertFrom-Json $_.ToString()).message
            }else{
                New-PoshBotCardResponse -Text $_.ToString()
            }
        }
    }

    # api call function
    $methods = 'get', 'post', 'put', 'delete'
    function api($method, $uri, $data){
        if (-not $global:AUTHORIZED){ New-PoshBotCardResponse  -Text 'Connect to a cohesity cluster'; break }
        if (-not $methods.Contains($method)){ New-PoshBotCardResponse  -Text "invalid api method: $method"; break }
        try {
            if ($uri[0] -ne '/'){ $uri = '/public/' + $uri}
            $url = $APIROOT + $uri
            $body = ConvertTo-Json -Depth 100 $data
            $result = Invoke-RestMethod -Method $method -Uri $url -Body $body -Header $HEADER  -SkipCertificateCheck
    
            New-PoshBotCardResponse  -Text ($result| Format-List | Out-String)
        }
        catch {
            if($_.ToString().contains('"message":')){
                New-PoshBotCardResponse -Text (ConvertFrom-Json $_.ToString()).message
            }else{
                New-PoshBotCardResponse -Text $_.ToString()
            }
        }
    }
    
    

