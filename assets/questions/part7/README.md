# Part 7: Reading Comprehension

A lot is a JSON list. **One exercise = 1 to 3 documents + their questions.**

- **Single document** (1 entry in `documents`): 2 to 4 questions.
- **Multiple documents** (2 or 3 entries): exactly 5 questions that cross-reference the documents
  (e.g. a job ad + a résumé + a reply e-mail).

```json
[
  {
    "id": "p7-001",
    "documents": [
      { "type": "job_ad", "title": "Sales Manager wanted", "text": "..." },
      { "type": "email", "title": "Application", "text": "..." }
    ],
    "questions": [
      {
        "prompt": "What is required for the position?",
        "category": "detail",
        "choices": ["A degree", "A car", "5 years of experience", "French"],
        "answerIndex": 2,
        "explanation": "The ad states '5 years minimum'."
      }
    ]
  }
]
```

| Field | Required | Rule |
|---|---|---|
| `id` | yes | Unique across all lots, never changed. Questions are tracked as `<id>#1`, `<id>#2`... |
| `documents` | yes | 1 to 3 items `{type, title?, text}`. `type`: see docs/QUESTION_FORMAT.md. |
| `questions` | yes | 2 to 4 (single) or exactly 5 (multiple). |
| `questions[].prompt` | yes | The question text. |
| `questions[].choices` | yes | Exactly 4 strings. |
| `questions[].answerIndex` | yes | 0 to 3. |
| `questions[].explanation` | yes | In English. |
| `questions[].category` | no | `main_idea`, `detail`, `inference`, `purpose`, `not_true`, `vocabulary_in_context` or `sentence_insertion`. |

**"Where does this sentence belong?" questions**: put the markers `[A]`, `[B]`, `[C]`, `[D]`
in the document text, write the sentence in `prompt`
(e.g. `"In which position marked [A], [B], [C] or [D] does the following sentence best belong? \"...\""`),
use `"choices": ["[A]", "[B]", "[C]", "[D]"]` and `"category": "sentence_insertion"`.

Shared rules: [docs/QUESTION_FORMAT.md](../../../docs/QUESTION_FORMAT.md).
Validate with `dart run tool/validate_questions.dart`.
