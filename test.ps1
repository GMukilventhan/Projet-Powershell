$uniqueRandomNumbers = @()

for ($i = 0; $i -lt 10; $i++) {
    $uniqueRandomNumbers += Get-Random -Minimum 0 -Maximum 9
}
Get-Random -Count 3 