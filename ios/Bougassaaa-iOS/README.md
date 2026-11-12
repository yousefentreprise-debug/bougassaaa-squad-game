# Bougassaaa squad — progetto iOS

Progetto SwiftUI autonomo per iPhone e iPad, iOS 16+. Integra i contenuti della versione Wabi più recente disponibile al 12 novembre 2026; non modifica né sostituisce il gioco Wabi.

## Funzionalità integrate

- Sei livelli progressivi, con pattuglie mobili, muri, chiave dal livello 3 e laser dal livello 4.
- Scelta all'avvio tra Bougassaaa, Frira, Bingo e 7idan; il personaggio scelto diventa il protagonista e gli altri tre sono i personaggi da salvare.
- Bonus originali dei tre personaggi da salvare, scatto e regole di movimento, punteggio e stelle allineati al gioco Wabi.
- Italiano, darija, inglese, francese e spagnolo; italiano predefinito, con controllo lingua accessibile anche durante la partita.
- Ritratti dei personaggi e logo 21.com nei traguardi 2, 4 e 6; partita, preferenze e record salvati localmente.
- Regole, privacy e controlli touch accessibili, asset catalog Xcode, icona, manifest privacy e test del motore.

## Dati salvati e compatibilità

Il modello conserva `phase`, posizione, turno, limite, amici salvati, scudi, scatto, impatti e messaggio delle partite precedenti. I campi nuovi `level`, `keyCollected` e `character` sono opzionali e hanno fallback per le vecchie partite; la lingua vecchia o mancante apre in italiano. Nessun file esistente dell'archivio sorgente viene sovrascritto.

## Controlli eseguiti qui

Controllati i file JSON, plist, PrivacyInfo e schema Xcode, i percorsi dei sorgenti e la presenza degli asset. È stato confrontato il motore con la logica della versione Wabi corrente. Questo ambiente è Linux e non contiene Swift/Xcode o l'iOS SDK: quindi non è stata eseguita una compilazione Swift, la suite di test, un simulatore o una prova su iPhone. Il controllo definitivo del codice Swift deve ancora avvenire su macOS.

## Struttura pronta per il repository

Estrarre il pacchetto nella radice del repository: mette il progetto in `ios/Bougassaaa-iOS/` e il workflow in `.github/workflows/ios-check.yml`. Il workflow è manuale (`workflow_dispatch`): esegue test del motore, build iOS Simulator senza firma, avvio su simulatore iPhone e conserva i log/screenshot per un giorno. Non firma né carica l'app, non crea un record App Store Connect e non invia la build ad Apple.

Il repository collegato `yousefentreprise-debug/bougassaaa-squad-game` esiste ed è pubblico; al controllo era installato solo il workflow Pages, non un workflow iOS. Il pacchetto prepara quello iOS ma non è stato caricato o eseguito sul repository. La verifica remota richiede prima di aggiungere questi file al repository e poi l'avvio manuale di `iOS build and smoke check` nella scheda Actions. Nessun push o avvio remoto è stato fatto.

## App Store: stato e passi ancora necessari

Il progetto compila, se confermato da Xcode, solo per il simulatore senza firma con impostazioni correnti. Il bundle ID `com.example.bougassaaasquad` è un segnaposto. Per una distribuzione reale servono un bundle ID univoco, account/team Apple Developer con ruolo e firma appropriati, test su dispositivi, archiviazione per iOS, validazione, icona e screenshot finali, URL stabili di supporto e privacy, e completamento di prezzo/territori, rating e dichiarazioni di conformità da parte del titolare. Nessuno di questi passaggi è stato inviato o dichiarato completato.

Yousef ha dichiarato di essere autorizzato a usare i nomi degli streamer. Prima di una pubblicazione commerciale, verificare che l'autorizzazione copra anche la presentazione nell'app e gli usi pertinenti; resta inoltre da verificare l'autorizzazione per i ritratti importati e per il logo 21.com. Non sono stati contattati gli interessati.

Vedere `AppStore/Preparazione.md` e `AppStore/Senza-Mac.md` per testi di scheda, privacy proposta e flusso di build remoto. Questi file sono materiali di preparazione, non dati già inviati ad Apple.
