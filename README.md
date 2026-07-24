# MediStock

Application iOS de gestion des stocks de médicaments pour le groupe pharmaceutique **Rebonnté** (projet 16 - parcours iOS OpenClassrooms).

L'application permet à l'équipe du pôle Supply Chain de :
- créer un compte et s'identifier ;
- gérer les rayons du stock ;
- gérer les médicaments présents par rayon ;
- gérer le stock (quantité) de chaque médicament ;
- consulter l'historique des changements appliqués à chaque médicament.

## Stack technique

- **SwiftUI** (iOS 17.5+)
- **Firebase** : Authentication, Firestore (SPM)
- Xcode, Swift 5.0

## Mise en route

1. Cloner le repo.
2. Créer un projet Firebase et y enregistrer l'app iOS avec le bundle ID `com.juliencotte.MediStock` (voir [documentation Firebase](https://firebase.google.com/docs/ios/setup)).
3. Télécharger le `GoogleService-Info.plist` généré et le glisser dans le dossier `MediStock/` depuis Xcode (case "Copy items if needed" cochée). Ce fichier est volontairement ignoré par git (`.gitignore`) car il contient des identifiants propres à chaque environnement.
4. Ouvrir `MediStock.xcodeproj`, laisser Xcode résoudre les dépendances Swift Package Manager, puis lancer le build.

## Suivi du projet

Ce projet part d'une base de code existante à corriger et compléter. L'avancement (corrections, améliorations, choix techniques) est journalisé au fil de l'eau dans un `TASKS.md` local (non commité, notes de travail personnelles).

Convention de travail : une branche par fonctionnalité ou correctif.
