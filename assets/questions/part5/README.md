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

## Generation guidelines (C1 level, no bias)

Target: **C1**, the real TOEIC level. No B1 or B2 basics (e.g. `their`/`them`, common prepositions, simple passive).

**What to test**: subjunctive after verbs of request, inversion, participles and reduced clauses, complex connectors (*notwithstanding*, *provided that*, *in lieu of*, *given that*), word forms (noun / adjective / adverb derivation), business collocations, fixed phrasal verbs and prepositions.

**Choices**:
1. Four choices, exactly one correct, and no other choice defensible in the sentence. Re-read each item looking for a second choice that works.
2. The three wrong choices are grammatically possible in some other sentence but fail here. No obviously ungrammatical distractor.
3. All four choices share the same part of speech.
4. **No length bias**: the four choices have the same length within ±1 word. The correct answer is never the only longest or the only shortest.
5. **Balanced position**: across a lot, the correct answer falls about 25% on each of A, B, C, D.

**Sentence**: 10 to 18 words, realistic business context, one blank `___`.

**Explanation** (English): state the rule or meaning tested and why each of the three other choices fails.

**Category**: `grammar` or `vocabulary`, exact label.

**Before submitting a lot**: `dart run tool/validate_questions.dart` must pass. Check the two bias points above by hand.

Reference recap: [docs/question-recaps/part5.md](../../../docs/question-recaps/part5.md).
