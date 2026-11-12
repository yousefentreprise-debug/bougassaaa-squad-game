# Verifica build remota senza Mac personale

Il progetto iOS può usare i runner macOS standard di GitHub Actions. Yousef ha un account GitHub collegato e il repository pubblico identificato è `yousefentreprise-debug/bougassaaa-squad-game`. Al controllo, il repository aveva un workflow Pages attivo ma nessun workflow iOS; il workflow incluso in questo pacchetto non è ancora stato aggiunto al repository né eseguito.

## Come attivare il controllo tecnico

1. Estrarre l'archivio nella radice del repository. La cartella `ios/Bougassaaa-iOS/` contiene progetto, sorgenti e test; `.github/workflows/ios-check.yml` deve restare alla radice.
2. Aggiungere questi file a una modifica del repository e attendere che siano disponibili sul branch desiderato. Questa preparazione non li ha pubblicati.
3. In GitHub, aprire Actions e avviare manualmente `iOS build and smoke check`.
4. Verificare esito, log, screenshot di lancio e diagnostiche. La workflow controlla il motore, compila per iOS Simulator senza firma, installa e avvia su un simulatore iPhone. Lo screenshot attesta solo l'avvio, non la qualità del gameplay o l'accessibilità.

Il repository è pubblico: GitHub documenta l'accesso ai runner standard macOS per i repository pubblici senza consumo di minuti a pagamento. Il workflow non usa runner large; storage/limiti e condizioni possono cambiare e vanno controllati nella pagina GitHub Actions del repository. Non è stato eseguito alcun runner in questo incarico.

## Per distribuire su App Store

Un test su simulatore non è una build firmata o un IPA. Dopo un controllo verde restano firma con il team Apple autorizzato, bundle ID definitivo al posto di `com.example.bougassaaasquad`, archivio iOS su macOS, prova su dispositivi e passaggi App Store Connect. L'account/team Apple Developer effettivo di Yousef non è stato controllato, quindi non ne presumo né presenza né assenza.

Yousef ha dichiarato di essere autorizzato a usare i nomi degli streamer. Per la distribuzione restano da verificare l'ambito di quella autorizzazione e i diritti dei ritratti/loghi usati, in particolare il marchio 21.com.

Fonti di riferimento:
- GitHub Actions runner hosted: https://docs.github.com/en/actions/reference/runners/github-hosted-runners
- GitHub Actions usage and billing: https://docs.github.com/en/actions/concepts/billing-and-usage
- Apple App Store Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- Apple upload build help: https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/
