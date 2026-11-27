# Recap: corrections and level for Part 6 (Text Completion)

## Target level
- B2+ to C1, the real TOEIC level. No simple texts and no obvious insertions.
- Texts should look like real TOEIC e-mails, notices and articles, with dense information.

## Problems in the previous corpus
- **Very strong length bias on sentence insertions**: the correct sentence was the only longest choice in 80% of cases (103 of 128). This is the most serious flaw, because a candidate can answer without reading.
- **Off-topic distractors**: in insertions, the wrong sentences have no link to the text (e.g. p6-011#2, p6-122#1, p6-103#1). The candidate eliminates them without understanding.
- Short texts (76 words on average): too little context for a real choice.
- B1-level grammar and connectors.

## Rules for new questions
1. **Insertions**: the three wrong sentences must be as long, as formal and as related to the topic as the correct one. Each should reuse a keyword or a close idea from the text but fail logically (contrast, cause, sequence, pronoun reference, verb tense).
2. Never make the correct sentence unique by length or tone. Check that exactly one sentence fits the blank logically and no other does.
3. **Words and grammar**: all four options must be grammatically possible in the sentence, and only one is correct. Test verb forms, fixed prepositions, adjectives/adverbs, connectors (however, in addition, nevertheless, as a result).
4. Word-option length: the same length within ±1 word when all four are single words.
5. Only one defensible answer per blank: no two synonyms that both fit.
6. Text of 120 to 180 words, with at least one piece of information to cross-check between paragraphs.
7. Four blanks per text, spread across grammar, vocabulary, connector and insertion (at least one insertion per text, as in the real exam).
8. Explanation in English: cite the rule, or the sentence in the text, that justifies the answer.

## What to remove or rewrite
- Insertions where the correct sentence is the only longest one or the only one about the subject.
- Texts under 100 words and B1-level questions.
- The validation (`dart run tool/validate_questions.dart`) must stay green.
