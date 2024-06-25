<#
Script Name: ENG-CancellazioneAADUserWebuild.ps1
Description: Questo script PowerShell è progettato per eliminare gli utenti da Azure Active Directory (AAD) utilizzando un elenco fornito in un file Excel.

Author: Nicolò Bertucci

Date: 17/04/2024
Last edit date: 25/06/2024

Patch notes:
- Aggiunto sistema log
- Fix cancellazione utenti guest che contengono il singolo apice
#>

# Importa il modulo necessario per lavorare con file Excel
Import-Module -Name ImportExcel

Connect-AzureAD | Out-Null

# Controllo esistenza folder logs
if (-not (Test-Path ".\logs")) {
    # Creazione della folder qualora non esistesse
    New-Item -ItemType Directory -Force -Path ".\logs" | Out-Null
}

# Definizione funzione di Log dello script
$DateFile = (Get-Date).ToString("yyyyMMdd-HHmm")
$Logfile = ".\logs\" + $DateFile + "-cancellazioneAADGuestUsersWebuild.log"
function WriteLog {
    Param ([string]$LogString)
    $TimeLog = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
    $LogMessage = "$TimeLog $LogString"
    Add-Content $LogFile -Value $LogMessage
}

WriteLog "[INFO] Cancellazione utenti Guest"

### MAIN ###

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
    try {
        $user = Get-AzureADUser -Filter "UserPrincipalName eq '$($guest -replace "'", "''")'"
        if ($user) {
            Remove-AzureADUser -ObjectId $user.ObjectId
            Write-Host "Cancellato il seguente utente: $guest"
            WriteLog "[INFO] Cancellato il seguente utente: $guest"
        } else {
            Write-Host "Utente non trovato: $guest"
            WriteLog "[WARNING] Utente non trovato: $guest"
        }
    } catch {
        Write-Warning "Errore durante la cancellazione dell'utente: $guest"
        WriteLog "[ERROR] Errore durante la cancellazione dell'utente: $guest"
    }
}
