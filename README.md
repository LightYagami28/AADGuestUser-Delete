# 🛠️ Script per la Cancellazione di Utenti Guest su Azure Active Directory

## Descrizione
Questo script PowerShell automatizza il processo di eliminazione degli utenti **Guest** su **Azure Active Directory (AAD)** utilizzando un file Excel come input. Lo script estrae gli indirizzi email degli utenti da rimuovere, li modifica per includere l'estensione "Guest", e utilizza il comando `Remove-AzureADUser` per eliminarli. Riceverai notifiche per ogni eliminazione completata, semplificando la gestione di elenchi di utenti e migliorando l'efficienza.

## Funzionalità

- **Importazione da Excel**: Lo script legge gli indirizzi email degli utenti da un file Excel.
- **Elaborazione automatica degli utenti Guest**: Modifica automaticamente gli indirizzi email per identificare correttamente gli utenti Guest.
- **Cancellazione automatica**: Utilizza il comando `Remove-AzureADUser` per eliminare gli utenti dall'AAD.
- **Notifiche**: Fornisce feedback di successo per ogni eliminazione eseguita.

## Prerequisiti

Prima di eseguire lo script, assicurati di avere:

- **Permessi amministrativi** su Azure Active Directory.
- **PowerShell** con il modulo **AzureAD** installato. Se non lo hai già, puoi installarlo eseguendo il comando:

  ```powershell
  Install-Module AzureAD
  ```

- **File Excel** con una colonna contenente gli indirizzi email degli utenti da cancellare.

## Installazione

1. **Clona questo repository** o scarica lo script direttamente:
   ```bash
   git clone https://github.com/CringedNico/AADGuestUser-Delete.git
   ```

2. **Configura lo script**:
   - Assicurati che il file Excel con gli indirizzi email degli utenti sia nella cartella corretta.
   - Verifica che la colonna contenente gli indirizzi email sia formattata correttamente.

## Utilizzo

1. **Esegui lo script**:
   Avvia PowerShell, naviga nella cartella dello script, ed esegui il seguente comando:

   ```powershell
   Import-Module AzureAD
   .\Remove-GuestUsers.ps1 -ExcelFilePath "C:\Percorso\Del\File.xlsx"
   ```

2. **Monitoraggio del processo**:
   Lo script modificherà gli indirizzi email per identificare gli utenti Guest e procederà alla loro eliminazione. Riceverai messaggi di conferma per ogni utente rimosso.

## Dettagli Tecnici

- **Modifica degli indirizzi email**: Lo script aggiunge automaticamente l'estensione Guest (es. `user@domain.com` diventa `user@domain.com#EXT#`).
- **Comando di cancellazione**: Utilizza il cmdlet `Remove-AzureADUser` per eliminare l'utente.
- **Gestione degli errori**: Eventuali errori verranno gestiti e riportati nei messaggi di errore.

## Esempio di Output

```
Cancellazione in corso per l'utente: user1@domain.com#EXT#
Utente eliminato con successo: user1@domain.com#EXT#
Cancellazione in corso per l'utente: user2@domain.com#EXT#
Utente eliminato con successo: user2@domain.com#EXT#
```

## Sicurezza

- **Verifica l'elenco degli utenti**: Assicurati che gli utenti nel file Excel siano corretti prima di eseguire lo script, poiché la cancellazione è irreversibile.
- **Ambiente di test**: Esegui lo script in un ambiente di test per provare con un piccolo gruppo di utenti prima di utilizzarlo su un'intera directory.

## Supporto

Se incontri problemi o hai domande, puoi aprire una segnalazione su [GitHub](https://github.com/CringedNico/AADGuestUser-Delete/issues) o contattare il manutentore del progetto.
