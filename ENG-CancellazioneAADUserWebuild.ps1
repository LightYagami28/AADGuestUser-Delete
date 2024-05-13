<#
Script Name: ENG-CancellazioneAADUserWebuild.ps1
Description: Questo script PowerShell è progettato per eliminare gli utenti da Azure Active Directory (AAD) utilizzando un elenco fornito in un file Excel.
Author: Nicolò Bertucci
Date: 17/04/2024
#>

# Importa il modulo necessario per lavorare con file Excel
Import-Module -Name ImportExcel

Invoke-Expression -Command "Connect-AzureAD | Out-null"

# Ottiene i dati dal file di input
$file = $args[0]
$data = Import-Excel -Path $file

$column = $data | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
$mailboxes = $data | Select-Object -ExpandProperty $column

$guests = @()

foreach ($mailbox in $mailboxes) {
    $tmp = $mailbox -replace "@", "_"
    $tmp += "#EXT#@saliniimpregilo.onmicrosoft.com"
    $guests += $tmp
}

foreach ($guest in $guests) {
    Invoke-Expression -Command "Remove-AzureADUser -ObjectId $guest"
    Write-Host "Cancellato il seguente utente: $guest"
}