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

## Generation guidelines (C1 level, no bias)

Target: **C1**, the real TOEIC level. Dense, realistic texts (articles, notices, e-mails, reports, reviews, product sheets).

**Text length**: single document 150 to 250 words; multiple documents 300 to 400 words in total. Single document: 2 to 4 questions. Multiple documents: exactly 5 questions, at least one requiring all the documents and at least two requiring a cross-reference between two documents.

**Question types**: vary them. No more than 35% detail questions in a lot. Mix main idea, purpose, inference, vocabulary in context, NOT-true and sentence insertion. Each exercise needs at least one inference question.

**Answers**:
1. The correct answer **paraphrases** the text. No word-for-word copy of a sentence.
2. Wrong answers reuse words from the text but with a false meaning: a misreading, the wrong person, the wrong date, an unmet condition.
3. Exactly one defensible answer. Re-read the text looking for a second choice that works.
4. **No length bias**: the four choices have the same length within ±20%. The correct answer is never the only longest. Do not write a "complete" answer as a trap.
5. For main idea: distractors are partial topics of the text; the correct answer covers the whole.
6. Position: spread A, B, C, D at about 25% in each lot.

**Calculations**: give every amount and detail needed in the text, and check each result.

**Explanation** (English): quote the sentence or documents that justify the answer, and say why the others fail.

**Category**: `main_idea`, `detail`, `inference`, `purpose`, `not_true`, `vocabulary_in_context` or `sentence_insertion`.

**Before submitting a lot**: `dart run tool/validate_questions.dart` must pass.

Reference recap: [docs/question-recaps/part7.md](../../../docs/question-recaps/part7.md).
