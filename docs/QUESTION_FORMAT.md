# Format des fichiers de questions

Chaque fichier JSON de `assets/questions/partN/` est un **lot** de questions d'une seule partie.
Ajouter un fichier dans un dossier existant suffit : il est embarqué au prochain build et
ses questions rejoignent le tirage au sort de la partie (aucun code à modifier).

```json
{
  "schemaVersion": 1,
  "part": 5,
  "batchId": "part5-2026-001",
  "title": "Titre libre (optionnel)",
  "groups": [
    {
      "passages": [{ "title": "Email (optionnel)", "text": "Texte à lire…" }],
      "audio": "assets/audio/part3/conv-001.mp3",
      "questions": [
        {
          "id": "p5-2026-001-q1",
          "prompt": "Énoncé de la question",
          "choices": ["A", "B", "C", "D"],
          "answerIndex": 0,
          "explanation": "Courte explication de la solution."
        }
      ]
    }
  ]
}
```

| Champ | Règle |
|---|---|
| `schemaVersion` | `1` actuellement. Une autre valeur est refusée. |
| `part` | Numéro de partie (1 à 7) ; doit correspondre au dossier. |
| `groups` | Un groupe = des questions qui partagent le même contexte. Partie 5 : un groupe sans `passages` ; Partie 6/7 : `passages` + plusieurs questions ; listening (futur) : `audio` + plusieurs questions. |
| `questions[].id` | **Unique dans toute l'app et ne change jamais** (sert à retrouver les questions ratées). |
| `answerIndex` | Position de la bonne réponse dans `choices`, en commençant à 0. |

Un lot invalide fait échouer le chargement avec un message qui nomme le fichier fautif.
