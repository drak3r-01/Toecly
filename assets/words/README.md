# Word cards

TOEIC business vocabulary shown as flashcards in the app (Practice tab, "Word cards").
A lot is a JSON list of cards, one file per lot (`lot01.json`, `lot02.json`, ...). Adding a
file to this folder is enough, no need to touch `pubspec.yaml`.

```json
[
  {
    "id": "w-001",
    "word": "allocate",
    "partOfSpeech": "verb",
    "definition": "to distribute money, time or resources for a particular purpose",
    "example": "The board decided to allocate more funds to research.",
    "fr": "allouer, attribuer"
  }
]
```

| Field | Required | Rule |
|---|---|---|
| `id` | yes | `w-NNN`, unique across all lots, never changed (it keys the saved progress). |
| `word` | yes | The word or expression, in its base form. |
| `partOfSpeech` | yes | `noun`, `verb`, `adjective`, `adverb`, `preposition`, `conjunction` or `phrase`. |
| `definition` | yes | In English, short, no use of the word itself. |
| `example` | yes | One realistic business sentence in English using the word. |
| `fr` | no | French translation(s), shown on the back of the card. |

## Generation guidelines

- TOEIC level: business and workplace vocabulary (finance, contracts, HR, logistics, meetings),
  upper-intermediate to C1. No everyday basics.
- Each word is useful in Parts 5 to 7 (collocations, word families, connectors).
- Do not reuse an existing `id` or an existing `word`.

Validate with `dart run tool/validate_words.dart` (also run by the CI).
