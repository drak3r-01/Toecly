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

## Generation guidelines (C1 level, no bias)

Target: **C1**, the real TOEIC level. Formal, professional texts (e-mails, notices, articles, reports, internal policies). Never use a B1 connector as the answer (`so`, `but`, `or`, `because`). Use instead *however*, *nevertheless*, *whereas*, *in the event of*, *as a result*, *provided that*.

**Text structure**: 135 to 190 words (never under 120), 4 blanks. At least one blank must be a sentence insertion. Spread the others across vocabulary, grammar, and connector or word form.

**Sentence insertion**:
1. The four sentences have the same length within ±20%, the same register and the same tone.
2. Each wrong sentence reuses a keyword or idea from the text but fails logically: contrast, cause, sequence, pronoun reference or verb tense.
3. Exactly one sentence fits the blank logically, and no other one does.
4. No off-topic distractors. Do not make the correct sentence the only one that mentions the subject.

**Words and forms**:
1. All four choices are grammatically possible in the sentence, and exactly one is correct.
2. All four share the same part of speech and register.
3. Test verb forms, fixed prepositions, adjectives and adverbs, collocations.

**Length bias**: within each lot, the correct answer is never the only longest or the only shortest. Spread A, B, C, D at about 25% each.

**Explanation** (English): quote the sentence or word in the text that justifies the answer, and say why the others fail. **Never mention the position, order or letter of a choice** ("first option", "option B", "the last sentence"): choices are shuffled at draw time.

**Category**: `grammar`, `vocabulary`, `connector` or `sentence_insertion`.

**Before submitting a lot**: `dart run tool/validate_questions.dart` must pass.

Reference recap: [docs/question-recaps/part6.md](../../../docs/question-recaps/part6.md).
