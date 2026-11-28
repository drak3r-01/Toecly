# Recap: corrections and level for Part 5 (Incomplete Sentences)

## Target level
- B2+ to C1, the real TOEIC level. No B1 items and no simple sentences.
- No item should be solvable by memorizing a basic rule.

## Problems in the previous B1 corpus
- Too much basic grammar: simple passive, common prepositions, quantifiers.
- Vocabulary too common. Missing business vocabulary at TOEIC level (finance, contracts, HR, logistics, regulation).
- Ungrammatical distractors that are easy to eliminate (e.g. p5-087 "is process", p5-115 "has read to"). Each distractor must be grammatically possible in some other reading of the sentence.

## Rules for new questions
1. Test what makes candidates succeed on the TOEIC: subjunctive after verbs of request or recommendation, reduced participle clauses, complex connectors (notwithstanding, provided that, in lieu of, given that), inversion, word forms (noun/adjective/adverb derivation), collocations, fixed phrasal verbs and prepositions.
2. All four choices must be plausible: same part of speech, same register, and each correct in some other sentence. Only one fits here.
3. Length: the four choices have about the same length (within 1 word when they are the same kind). The correct answer must not be the longest.
4. Answer position: balanced across A, B, C and D.
5. Only one defensible answer. Re-read each item looking for a second choice that works (e.g. "valued" vs "valuable" in p6-084 shows the trap).
6. Sentence of 9 to 15 words, business context, one blank.
7. Explanation in English: state the rule and why the other three fail.
8. Category: `grammar` or `vocabulary`, with the exact label (p6-095 shows a label can be wrong).

## What to remove or rewrite
- B1-level questions in the current corpus, and any question whose correct answer is clearly the longest.
- The validation (`dart run tool/validate_questions.dart`) must stay green.

## Second C1 pass (2026-11-28)
- A level audit found the bank mostly B2 with few real C1 items. 185 of the 574 questions were removed: B1/B2 grammar (basic gerund/infinitive patterns, simple tenses, `no sooner` repeats, comparatives), items with malformed distractors (`curbed to`, `lodged in`, `siezed`), homophone gimmicks (`gauge/gauze/gaze`) and items with a second defensible answer (`held to the view`, `not until` vs `only after`).
- 10 items were repaired (malformed distractor replaced, explanation updated).
- 177 new C1 questions were added (ids p5-2001 and above): 190 grammar and 376 vocabulary in total. Every new item was solved blind by an independent reviewer; items with a double key or a trivial form were dropped. Next free id: p5-2200.
- Explanations name the words instead of referring to option positions, since choices are shuffled at draw time.
- Length bias check: in all 566 questions, the correct answer is never the only longest or only shortest choice.
- Known gap: grammar is about a third of the bank, less than on the real test. Add grammar items first next time (inversion, mandative subjunctive, reduced clauses, word forms with long derived nouns).
