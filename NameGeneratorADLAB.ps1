# ----- Edit these Variables for your own Use Case ----- #
$PASSWORD_FOR_USERS            = "Password1"
$NUMBER_OF_ACCOUNTS_TO_CREATE  = 1000
$OU_PATH                       = "OU=Users,OU=Employees,$(([ADSI]'').distinguishedName)"
# ------------------------------------------------------ #

$Consonants = 'b','c','d','f','g','h','j','k','l','m','n','p','q','r','s','t','v','w','x','z','ch','ck','sh'
$Vowels     = 'a','e','i','o','u','y','oo','ai'

function New-RandomName {
    param(
        [int]$MinLength = 3,
        [int]$MaxLength = 7
    )

    # Randomizes name length
    $length = Get-Random -Minimum $MinLength -Maximum ($MaxLength + 1)

    $chars  = New-Object System.Collections.Generic.List[string]

    for ($i = 0; $i -lt $length; $i++) {
        if ($i % 2 -eq 0) {
            # even number → consonant
            $chars.Add($Consonants[(Get-Random -Minimum 0 -Maximum $Consonants.Count)])
        } else {
            # odd number → vowel
            $chars.Add($Vowels[(Get-Random -Minimum 0 -Maximum $Vowels.Count)])
        }
    }

    -join $chars
}

# convert password so AD will accept it
$SecurePassword = ConvertTo-SecureString $PASSWORD_FOR_USERS -AsPlainText -Force

for ($i = 1; $i -le $NUMBER_OF_ACCOUNTS_TO_CREATE; $i++) {

    $firstName = New-RandomName
    $lastName  = New-RandomName
    $username  = "$firstName.$lastName"

    Write-Host "Creating user: $username" -BackgroundColor Black -ForegroundColor Orange

    New-ADUser -AccountPassword       $SecurePassword `
               -GivenName             $firstName `
               -Surname               $lastName `
               -DisplayName           $username `
               -Name                  $username `
               -EmployeeID            $username `
               -PasswordNeverExpires  $true `
               -Path                  $OU_PATH `
               -Enabled               $true
}
