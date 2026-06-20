param(
    [string]$KratosAdminApi = "http://127.0.0.1:4434",
    [string]$UserId
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

if ([string]::IsNullOrWhiteSpace($UserId)) {
    $UserId = Read-Host "User ID"
}

if ([string]::IsNullOrWhiteSpace($UserId)) {
    Write-Host "User ID is mandatory"
    exit 1
}

$payload = @{
    expires_in = "30m"
    identity_id = $UserId
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Method Post -Uri "$KratosAdminApi/recovery/link" -ContentType "application/json" -Body $payload -UseBasicParsing
    if ($response.StatusCode -ne 200) {
        Write-Host "[!] Create link request failed:"
        Write-Host $response.Content
        exit 1
    }

    $content = $response.Content | ConvertFrom-Json
    Write-Host "Recovery link created:"
    Write-Host "==> Expires in: 30 mins"
    Write-Host "==> Follow link: $($content.recovery_link)"
}
catch {
    Write-Host "[!] Create link request failed:"
    $body = Get-ResponseBodyFromError -ErrorRecord $_
    if ([string]::IsNullOrWhiteSpace($body)) {
        Write-Host $_.Exception.Message
    }
    else {
        Write-Host $body
    }
    exit 1
}
