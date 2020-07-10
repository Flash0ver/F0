$Name = 'F0.'

$StrongNameKeyFile = "$Name.snk"
$PublicKeyFile = "$Name.publickey"
$PublicKeyPrefix = '0024000004800000940000000602000000240000525341310004000001000100'
$PublicKeyTokenText = 'Public key token is '
#$TargetPublicKeyStart = 'f0'
$TargetPublicKeyTokenStart = 'f0'

$ShouldCreateNewStrongNameKey = $true

Write-Host "Started to create a new strong-name keyfile '$StrongNameKeyFile' where 'public key token' starts with '$TargetPublicKeyTokenStart'..."

while ($ShouldCreateNewStrongNameKey) {
    sn -k $StrongNameKeyFile | Out-Null
    sn -p $StrongNameKeyFile $PublicKeyFile | Out-Null
    $Output = sn -tp $PublicKeyFile

    #$FirstPublicKeyLine = $Output[5]
    $PublicKeyTokenLine = $Output[11]

    # if (-not $FirstPublicKeyLine.StartsWith($PublicKeyPrefix)) {
    #     throw "Unexpected prefix of Public Key: $FirstPublicKeyLine"
    # }
    if (-not $PublicKeyTokenLine.StartsWith($PublicKeyTokenText)) {
        throw "Unexpected text of Public Key Token: $PublicKeyTokenLine"
    }

    #$TrimmedPublicKey = $FirstPublicKeyLine.Substring($PublicKeyPrefix.Length)
    $PublicKeyToken = $PublicKeyTokenLine.Substring($PublicKeyTokenText.Length)

    <#
    if ($TrimmedPublicKey.Length -lt $TargetPublicKeyStart.Length) {
        throw "Target '$TargetPublicKeyStart':$($TargetPublicKeyStart.Length) is longer than available '$TrimmedPublicKey':$($TrimmedPublicKey.Length)."
    }
    elseif ($TrimmedPublicKey.StartsWith($TargetPublicKeyStart)) {
        $ShouldCreateNewStrongNameKey = $false
    }
    else {
        Write-Host "Created with '$($TrimmedPublicKey.Substring(0, $TargetPublicKeyStart.Length))', continuing ..."
    }
    #>

    if ($PublicKeyToken.Length -lt $TargetPublicKeyTokenStart.Length) {
        throw "Target '$TargetPublicKeyTokenStart':$($TargetPublicKeyTokenStart.Length) is longer than available '$PublicKeyToken':$($PublicKeyToken.Length)."
    }
    elseif ($PublicKeyToken.StartsWith($TargetPublicKeyTokenStart)) {
        $ShouldCreateNewStrongNameKey = $false
    }
    else {
        Write-Host "Created with '$($PublicKeyToken.Substring(0, $TargetPublicKeyTokenStart.Length))', continuing ..."
    }
}

Remove-Item -Path $PublicKeyFile

Write-Host "Successfully created a new cryptographic key pair, where the Public Key Token is starting with '$TargetPublicKeyTokenStart', stored in file '$StrongNameKeyFile'." -ForegroundColor Green
Write-Host 'Public Key:' -ForegroundColor Yellow

$Output | ForEach-Object -Process {
    Write-Host $_
}
