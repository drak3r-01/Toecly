# Recap: corrections and level for Part 6 (Text Completion)

## Current state (2026-11-28)
- **165 exercises, 660 questions** in `lot01.json` to `lot17.json` (plus the two sample files). The 125 exercises of the previous bank (500 questions, 436 in the numbered lots plus 64 in the old legacy lot) were all rewritten, and 40 new exercises (`p6-601` to `p6-648`) were added. Ids of rewritten exercises are unchanged.
- Texts: 135 to 190 words (average 147), several paragraphs, figures, dates and names to cross-check. Nothing under 120 words.
- Explanations: every explanation quotes the word or sentence that decides the answer. None mentions the position of a choice, because choices are shuffled at draw time.
- Answer positions are exactly balanced: 25% each at A, B, C and D.
- Every exercise has at least one sentence insertion (about 1.1 per text on average). Insertion choices stay within 25% of each other in length and the answer is never the only longest or only shortest one. Word and phrase choices differ by at most one word in length.
- All 660 answers were solved blind (no key) by separate reviewers. 659 matched the key. Weak alternatives they pointed out were fixed in the 13 most doubtful blanks.

## Problems found in the previous corpus (all fixed)
- 32+ explanations referred to "the first option" or "first sentence", which is wrong after shuffling.
- 86 texts were under 120 words, with an average of 113.
- Many insertions had off-topic or silly distractors, or the correct sentence was the only longest or shortest.
- B1-level connectors (because, but, so) and spelling-trap distractors (offend/offer/offload).
- The old count of 500 mixed the legacy lot (64 questions) with 436 in the numbered lots.

## Rules for new questions
1. **Insertions**: the three wrong sentences are as long, as formal and as related to the topic as the correct one. Each reuses a keyword or idea from the text but fails logically (contrast, cause, sequence, pronoun reference, verb tense, a figure or date elsewhere in the text). The sentence that follows the blank should hold a cue ("this requirement", "By contrast") that only one candidate satisfies.
2. Exactly one sentence fits, and the correct one is never unique by length or tone.
3. **Words and grammar**: all four options are grammatically possible at first sight and only one is correct. Test verb forms, fixed prepositions, collocations and connectors (however, nevertheless, given that, provided that). Word options differ by at most one word.
4. Only one defensible answer per blank: no two synonyms that both fit.
5. Text of 135 to 190 words, with at least one piece of information to cross-check between paragraphs.
6. Four blanks per text, spread across grammar, vocabulary, connector and insertion.
7. Explanation in English, with no mention of the position of a choice.
8. `dart run tool/validate_questions.dart` must stay green.

## Next free ids
New exercises continue at `p6-651` and `lot18.json` (ids `p6-2xx` to `p6-5xx` and `p6-601` to `p6-648` are used).
