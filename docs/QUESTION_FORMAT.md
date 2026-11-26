# Question lot format

A **lot** is one `.json` file in `assets/questions/partN/`. It holds a **list of
exercises** of that part only (the part comes from the folder). Dropping a new file
in a folder is enough: it is bundled at the next build and joins the random draw.
No code or `pubspec.yaml` change is needed.

An **exercise** is what is shown together on screen: a sentence, a text with
blanks, or one to three documents, with their questions. The per-part schemas
are described in the README of each folder:

- [`assets/questions/part5/README.md`](../assets/questions/part5/README.md)
- [`assets/questions/part6/README.md`](../assets/questions/part6/README.md)
- [`assets/questions/part7/README.md`](../assets/questions/part7/README.md)

## Rules shared by all parts

| Field | Rule |
|---|---|
| `id` | Unique across **all** lots and **never changed** (missed questions are tracked by id). |
| `choices` | Exactly 4 non-empty strings. |
| `answerIndex` | Position of the right choice in `choices`, starting at 0. |
| `explanation` | Required, written in **English**. |
| `category` | Optional. Feeds the per-category statistics (see below). |
| `audio` | Optional, reserved for the future Listening parts (e.g. `"audio/part3/conv-001.mp3"`). |

Question ids used for tracking: Part 5 uses the exercise `id`; Parts 6 and 7 use
`<exercise id>#<n>` (n starts at 1, in the order of `questions`).

## Draw rules

- Part 5: drawn question by question.
- Parts 6 and 7: drawn as a whole exercise (its questions need its text).
- Mock exam: 30 Part 5 questions, 4 Part 6 exercises, 10 single-document and
  5 multiple-document (2 with two documents, 3 with three) Part 7 exercises:
  100 questions in 75 minutes, correction at the end.

## Categories

| Part | Allowed `category` values |
|---|---|
| 5 | `grammar`, `vocabulary` |
| 6 | `grammar`, `vocabulary`, `connector`, `sentence_insertion` |
| 7 | `main_idea`, `detail`, `inference`, `purpose`, `not_true`, `vocabulary_in_context`, `sentence_insertion` |

## Document types (Parts 6 and 7)

`email`, `letter`, `memo`, `notice`, `advertisement`, `article`, `text_message`,
`online_chat`, `form`, `invoice`, `schedule`, `job_ad`, `web_page`, `review`.
Each type has its own look in the app.

## Validation

```bash
dart run tool/validate_questions.dart
```

Checks every lot (missing fields, `answerIndex` out of range, duplicate ids,
blank markers, question counts, unknown categories or document types). It also runs
in GitHub Actions, so a malformed lot never reaches a build.
