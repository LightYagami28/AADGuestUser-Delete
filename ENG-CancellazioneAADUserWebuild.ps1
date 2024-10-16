<#
.SYNOPSIS
    Script per la cancellazione di utenti da Azure Active Directory (AAD) utilizzando un elenco fornito in un file Excel.

.DESCRIPTION
    Questo script PowerShell è progettato per eliminare gli utenti da Azure Active Directory (AAD) 
    utilizzando un elenco fornito in un file Excel.

.AUTHOR
    Nicolò Bertucci

.DATE
    17/04/2024
.LAST EDIT DATE
    25/06/2024

.PATCH NOTES
    - Aggiunto sistema log
    - Fix cancellazione utenti guest che contengono il singolo apice
#>

# Importa il modulo necessario per lavorare con file Excel
Import-Module -Name ImportExcel -ErrorAction Stop

# Connessione a Azure AD
try {
    Connect-AzureAD | Out-Null
    Write-Host "[INFO] Connessione a Azure AD riuscita."
} catch {
    Write-Error "[ERROR] Impossibile connettersi a Azure AD: $_"
    exit
}

# Controllo esistenza della cartella logs e creazione se non esiste
$logFolder = ".\logs"
if (-not (Test-Path $logFolder)) {
    New-Item -ItemType Directory -Force -Path $logFolder | Out-Null
}

# Definizione funzione di Log dello script
$DateFile = (Get-Date).ToString("yyyyMMdd-HHmm")
$LogFile = Join-Path -Path $logFolder -ChildPath "$DateFile-cancellazioneAADGuestUsersWebuild.log"

function WriteLog {
    param ([string]$LogString)
    $TimeLog = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
    $LogMessage = "$TimeLog $LogString"
    Add-Content -Path $LogFile -Value $LogMessage
}

WriteLog "[INFO] Inizio cancellazione utenti Guest."

### MAIN ###

# Ottiene il file di input dall'argomento
if ($args.Count -eq 0) {
    Write-Error "[ERROR] Nessun file di input fornito."
    exit
}

$file = $args[0]

# Importa i dati dal file di input
try {
    $data = Import-Excel -Path $file -ErrorAction Stop
} catch {
    Write-Error "[ERROR] Impossibile importare il file Excel: $_"
    exit
}

# Estrae gli indirizzi email
$column = $data | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
$mailboxes = $data | Select-Object -ExpandProperty $column

$guests = @()

# Creazione degli indirizzi email per gli utenti Guest
foreach ($mailbox in $mailboxes) {
    $tmp = $mailbox -replace "@", "_"
    $tmp += "#EXT#@saliniimpregilo.onmicrosoft.com"
    $guests += $tmp
}

# Cancellazione degli utenti Guest
foreach ($guest in $guests) {
    try {
        $user = Get-AzureADUser -Filter "UserPrincipalName eq '$($guest -replace "'", "''")'" -ErrorAction Stop
        if ($user) {
            Remove-AzureADUser -ObjectId $user.ObjectId -Confirm:$false
            Write-Host "Cancellato il seguente utente: $guest"
            WriteLog "[INFO] Cancellato il seguente utente: $guest"
        } else {
            Write-Host "Utente non trovato: $guest"
            WriteLog "[WARNING] Utente non trovato: $guest"
        }
    } catch {
        Write-Warning "Errore durante la cancellazione dell'utente: $guest - $_"
        WriteLog "[ERROR] Errore durante la cancellazione dell'utente: $guest - $_"
    }
}

WriteLog "[INFO] Cancellazione completata."
