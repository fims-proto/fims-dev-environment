param(
    [string]$KratosAdminApi = "http://127.0.0.1:4434",
    [string]$Email
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

if ([string]::IsNullOrWhiteSpace($Email)) {
    $Email = Read-Host "User email address"
}

if ([string]::IsNullOrWhiteSpace($Email)) {
    Write-Host "Email address is mandatory"
    exit 1
}

$payload = @{
    schema_id = "default"
    traits = @{
        email = $Email
    }
} | ConvertTo-Json -Depth 4

try {
    $response = Invoke-WebRequest -Method Post -Uri "$KratosAdminApi/identities" -ContentType "application/json" -Body $payload -UseBasicParsing
    if ($response.StatusCode -ne 201) {
        Write-Host "[!] Create user request failed:"
        Write-Host $response.Content
        exit 1
    }

    $content = $response.Content | ConvertFrom-Json
    Write-Host "User $Email created:"
    Write-Host "==> User id: $($content.id)"
}
catch {
    Write-Host "[!] Create user request failed:"
    $body = Get-ResponseBodyFromError -ErrorRecord $_
    if ([string]::IsNullOrWhiteSpace($body)) {
        Write-Host $_.Exception.Message
    }
    else {
        Write-Host $body
    }
    exit 1
}
