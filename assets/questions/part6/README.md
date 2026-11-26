# Part 6: Text Completion

A lot is a JSON list. **One exercise = one short text (e-mail, letter, notice, article...)
with 4 blanks = 4 questions** about the same text.

```json
[
  {
    "id": "p6-001",
    "documentType": "email",
    "text": "Dear Ms. Lee,\nThank you for [1] our store. [2] ...",
    "questions": [
      {
        "blank": 1,
        "category": "grammar",
        "choices": ["visit", "visiting", "visited", "visits"],
        "answerIndex": 1,
        "explanation": "'for' is followed by a gerund."
      },
      { "blank": 2, "category": "sentence_insertion", "choices": ["...", "...", "...", "..."], "answerIndex": 0, "explanation": "..." }
    ]
  }
]
```

| Field | Required | Rule |
|---|---|---|
| `id` | yes | Unique across all lots, never changed. Questions are tracked as `<id>#1` to `<id>#4`. |
| `documentType` | yes | One of the document types listed in docs/QUESTION_FORMAT.md. |
| `text` | yes | Contains the markers `[1]`, `[2]`, `[3]`, `[4]`, each exactly once. |
| `questions` | yes | Exactly 4, with `blank` = 1, 2, 3, 4 in order. |
| `questions[].choices` | yes | Exactly 4 strings: a word, a phrase, or a **whole sentence** (sentence insertion, as in the real exam). |
| `questions[].answerIndex` | yes | 0 to 3. |
| `questions[].explanation` | yes | In English. |
| `questions[].category` | no | `grammar`, `vocabulary`, `connector` or `sentence_insertion`. |

Official style: usually one of the four blanks asks to insert a full sentence.

Shared rules: [docs/QUESTION_FORMAT.md](../../../docs/QUESTION_FORMAT.md).
Validate with `dart run tool/validate_questions.dart`.
