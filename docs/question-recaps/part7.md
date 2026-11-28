# Recap: corrections and level for Part 7 (Reading Comprehension)

## Target level
- B2+ to C1, the real TOEIC level. No simple texts and no questions answered by a single keyword.
- Texts must be longer and denser than before: single document about 150 to 250 words, multiple documents about 300 to 400 words in total.

## Problems in the previous corpus
- **Longest answer too often correct**: on detail questions it was the only longest choice in 41% of cases; on main idea in 84%, and on purpose in 70%. A candidate can guess without reading the text.
- Detail questions too literal: the answer is often a copy of a sentence in the text. The real TOEIC paraphrases.
- Texts too short (about 115 words for single documents, about 210 words for multiple documents).
- Weak distractors, often unrelated to the document.

## Rules for new questions
1. **Paraphrase required**: the correct answer rewrites the text (synonyms, different structure). Distractors may reuse exact words from the text, but with a false meaning (misreading, wrong person, wrong date, unmet condition).
2. **Length**: the four choices have the same length within ±20%. The correct answer is never the only longest. Do not write a "complete" answer as a trap.
3. **Vary the types**: main idea, detail, inference, purpose, vocabulary in context, NOT-true, sentence insertion. No more than 40% detail questions in a lot.
4. **Inference**: the answer must follow from the text, not from outside knowledge. Check that no other answer also fits.
5. **Multiple documents**: the five questions must require cross-referencing at least two documents (e.g. the date in a notice and the conditions in an e-mail, an expert's name and the subject of an article). At least one question per exercise must require all three documents.
6. **Only one defensible answer** per question. Re-read the text looking for a second plausible choice.
7. Explanation in English: quote the sentence (or documents) that justifies the answer and say why the others fail.
8. Calculations: give all amounts in the text, and check each result.

## What to remove or rewrite
- Detail questions whose correct answer is clearly the longest.
- Single-document texts under 150 words and multiple-document sets under 300 words.
- Questions whose answer is a word-for-word copy of a sentence in the text.
- The validation (`dart run tool/validate_questions.dart`) must stay green.

## Multi-document pass (lots 37 to 43)
- Audit: only 4 of 124 sets had several documents, although the mock exam draws 5 multi-document sets (2 with two documents, 3 with three). Not-true (17), vocabulary-in-context (6) and sentence-insertion (2) questions were also rare.
- Added 36 multi-document sets (lots 37 to 42, ids p7-371 to p7-406): 18 with two documents and 18 with three. Each has exactly 5 questions, 300 to 400 words in total, at least one inference question, at most 2 detail questions, and cross-references between documents (calculations over several documents, conditions in one document applied to a case in another, time zones, discounts, deadlines).
- Added 6 single-document sets (lot 43, ids p7-407 to p7-412) with 4 sentence-insertion questions, plus not-true and vocabulary items.
- The bank now holds 166 sets (40 multi-document) and 702 questions.
- Checked: no explanation refers to the position of a choice (choices are shuffled at draw time); the correct answer is the only longest choice in about 9% of the new questions; answer positions are balanced.
- Next: keep adding multi-document sets with different document combinations, and have each new set solved blind by a second reader before merging.
