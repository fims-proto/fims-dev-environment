param(
    [string]$KratosAdminApi = "http://127.0.0.1:4434"
)

function Get-ResponseBodyFromError {
    param([Parameter(Mandatory = $true)] $ErrorRecord)

    try {
        $stream = $ErrorRecord.Exception.Response.GetResponseStream()
        if ($null -eq $stream) {
            return ""
        }

        $reader = New-Object System.IO.StreamReader($stream)
        return $reader.ReadToEnd()
    }
    catch {
        return ""
    }
}

try {
    $response = Invoke-WebRequest -Method Get -Uri "$KratosAdminApi/identities" -Headers @{ Accept = "application/json" } -UseBasicParsing
    if ($response.StatusCode -ne 200) {
        Write-Host "[!] List identities request failed:"
        Write-Host $response.Content
        exit 1
    }

    $content = $response.Content | ConvertFrom-Json
    Write-Host "==> Identities:"
    $content | ConvertTo-Json -Depth 20
}
catch {
    Write-Host "[!] List identities request failed:"
    $body = Get-ResponseBodyFromError -ErrorRecord $_
    if ([string]::IsNullOrWhiteSpace($body)) {
        Write-Host $_.Exception.Message
    }
    else {
        Write-Host $body
    }
    exit 1
}
