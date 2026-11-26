# Part 5: Incomplete Sentences

A lot is a JSON list. **One exercise = one sentence with one blank = one question.**

```json
[
  {
    "id": "p5-001",
    "sentence": "The meeting has been ___ until next Monday.",
    "choices": ["postpone", "postponed", "postponing", "postpones"],
    "answerIndex": 1,
    "category": "grammar",
    "explanation": "Passive voice: 'has been' + past participle."
  }
]
```

| Field | Required | Rule |
|---|---|---|
| `id` | yes | Unique across all lots, never changed. |
| `sentence` | yes | Must contain the blank marker `___` (three underscores). |
| `choices` | yes | Exactly 4 strings. |
| `answerIndex` | yes | 0 to 3. |
| `explanation` | yes | In English. |
| `category` | no | `grammar` or `vocabulary`. |

Official style: test grammar (tenses, prepositions, connectors, word forms) and
business vocabulary. Common test types: word form, preposition, conjunction, pronoun,
verb tense, meaning of a word.

Shared rules: [docs/QUESTION_FORMAT.md](../../../docs/QUESTION_FORMAT.md).
Validate with `dart run tool/validate_questions.dart`.
