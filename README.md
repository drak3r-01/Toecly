# Toecly

Application d'entraînement au **TOEIC** (Reading, Parties 5 à 7), **100 % hors ligne**, en Flutter.
Cibles : Android (`.apk`) et Windows (`.exe`). Aucun compte, aucun appel réseau.

> État : **socle du projet** (architecture, thème, navigation, chargement des questions, stockage, builds).
> Les écrans fonctionnels (entraînement, examen blanc, révision) restent à développer.

## Architecture

```
lib/
  main.dart                  Point d'entrée
  app/                       Application : thème, routes, services partagés
    theme/                   Thèmes Material 3 clair/sombre + choix du mode
    navigation/              Barre du bas (téléphone) / rail latéral (PC), transitions
  core/                      Briques réutilisables : parties TOEIC, score, widgets
  data/
    questions/               Modèles, parsing JSON (isolate), tirage aléatoire
    storage/                 Sauvegarde locale (shared_preferences) : historique, erreurs, stats
  features/                  Un dossier par écran : dashboard, practice, mock_exam, review, settings
assets/questions/part5|6|7/  Fichiers JSON de questions (voir docs/QUESTION_FORMAT.md)
```

## Lancer en développement

```bash
flutter pub get
flutter run -d windows          # fenêtre Windows
flutter run -d chrome           # aperçu navigateur
flutter run                     # appareil / émulateur Android connecté
```

Aperçu navigateur sans rien installer (Docker) : `docker compose up web-preview` puis http://localhost:8080

## Compiler l'APK avec Docker (sans Android Studio)

```bash
docker compose run --rm build-apk
```

Résultat : `build/app/outputs/flutter-apk/app-release.apk`

## Compiler le `.exe` en local sur Windows

Prérequis : Flutter + Visual Studio avec la charge « Développement Desktop en C++ ».

```bash
flutter build windows --release
```

Résultat : `build\windows\x64\runner\Release\toecly.exe`. Le `.exe` a besoin des DLL et du dossier `data\`
placés à côté de lui : distribuer **tout le dossier** `Release`.

## Release automatique (GitHub Actions)

Pousser un tag de version déclenche `.github/workflows/build.yml` : build APK (Ubuntu) et Windows (zip) en parallèle,
puis création d'une release GitHub avec les deux fichiers.

```bash
git tag v0.1.0
git push origin v0.1.0
```

## Ajouter des questions

1. Créer un fichier `.json` dans `assets/questions/part5/`, `part6/` ou `part7/` (format : [docs/QUESTION_FORMAT.md](docs/QUESTION_FORMAT.md)).
2. Garder des `id` de question uniques et définitifs.
3. Recompiler : le fichier est embarqué et ses questions rejoignent automatiquement le tirage.

Pour une nouvelle partie (ex. listening), créer le dossier `assets/questions/partN/` et l'ajouter à la liste `assets:` de `pubspec.yaml`
(Flutter ne lit pas les sous-dossiers récursivement).

## Tests

```bash
flutter analyze
flutter test
```
