# Integrazione iOS — Bougassaaa squad

Questo pacchetto va estratto nella radice del repository GitHub esistente. Inserisce il progetto Xcode in `ios/Bougassaaa-iOS/` e il controllo manuale GitHub Actions in `.github/workflows/ios-check.yml`.

Per avviare il controllo, dopo aver aggiunto questi file al repository, apri GitHub Actions e avvia `iOS build and smoke check`. Il job macOS esegue controlli del motore, una build per simulatore senza firma e l'avvio su un simulatore iPhone. Non firma né carica l'app per App Store. Questo pacchetto è stato preparato localmente e non è stato inviato al repository o eseguito in Actions.

Leggi `ios/Bougassaaa-iOS/README.md`, `ios/Bougassaaa-iOS/AppStore/Preparazione.md` e `ios/Bougassaaa-iOS/AppStore/Senza-Mac.md` per funzionalità, verifiche e passaggi mancanti.
