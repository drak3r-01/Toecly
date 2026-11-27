# Récap corrections et niveau : Part 6 (Text Completion)

## Niveau cible
- B2+ à C1, équivalent du vrai TOEIC. Pas de textes simples ni d'insertions évidentes.
- Les textes doivent ressembler à des e-mails, notices et articles de vrai TOEIC, avec de la densité d'information.

## Ce qui ne va pas aujourd'hui
- **Biais de longueur très fort sur les phrases à insérer** : la bonne phrase est seule la plus longue dans 80 % des cas (103 sur 128). C'est le défaut le plus grave, car on répond sans lire.
- **Distracteurs hors sujet** : dans les insertions, les mauvaises phrases n'ont aucun lien avec le texte (ex. p6-011#2, p6-122#1, p6-103#1). Le candidat élimine sans comprendre.
- Textes courts (76 mots en moyenne) : trop peu de contexte pour un vrai choix.
- Grammaire et connecteurs de niveau B1.

## Règles pour les nouvelles questions
1. **Insertions** : les trois mauvaises phrases doivent être aussi longues, aussi formelles et aussi liées au sujet que la bonne. Chacune doit reprendre un mot-clé du texte ou une idée proche, mais échouer par la logique (contraste, cause, chronologie, pronom de référence, temps verbal).
2. Ne jamais rendre la bonne phrase unique par sa longueur ou son ton. Vérifier que la bonne phrase est la seule qui s'insère logiquement à ce blanc, et qu'aucune autre ne tient.
3. **Choix de mots et grammaire** : les quatre mots ou formes doivent être grammaticalement possibles dans la phrase, et seul le bon est juste. Tester formes verbales, prépositions fixes, adjectifs/adverbes, connecteurs (however, in addition, nevertheless, as a result).
4. Longueur d'un choix : même longueur à ±1 mot près quand les quatre choix sont des mots simples.
5. Une seule réponse défendable par blanc : pas de synonymes qui tiennent tous deux.
6. Texte de 120 à 180 mots, avec au moins une information à croiser entre deux paragraphes.
7. Quatre blancs par texte, répartis entre grammaire, vocabulaire, connecteur et insertion (une insertion au moins par texte, comme le TOEIC réel).
8. Explication en anglais : citer la règle ou la phrase du texte qui justifie la réponse.

## Ce qu'il faut retirer ou réécrire
- Les insertions où la bonne phrase est seule la plus longue ou seule à reprendre le sujet.
- Les textes de moins de 100 mots et les questions de niveau B1.
- La validation (`dart run tool/validate_questions.dart`) doit rester verte.
