import re
import unidecode
import os

NO_OF_CHARS = 256

#*
#* The character of the text which doesn’t match with the current character of the pattern
#* is called the Bad Character. Upon mismatch, we shift the pattern until:
#*   1) The mismatch becomes a match
#*   2) Pattern P moves past the mismatched character.
#*
def badCharHeuristic(str1, size):

  # Initialize all occurrence as -1
  badChar = [-1]*NO_OF_CHARS

  # Fill the actual value of last occurrence
  for i in range(size):
    badChar[ord(str1[i])] = i;

  # Return initialized list
  return badChar

#*
#* Boyer Moore Algorithm for Pattern Searching
#*   Worst case: O(mn)   (all characters of the text and pattern are same)
#*   Best case:  O(m/n)  (all all the characters of the text and pattern are different)
#*
def BM_search(txt, pat):

  m = len(pat)
  n = len(txt)
  pattern_found = False
  shift = -1

  # Create the bad character list by calling
  # the preprocessing function badCharHeuristic()
  # for given pattern
  badChar = badCharHeuristic(pat, m)

  # s is shift of the pattern with respect to text
  s = 0
  while(s <= n-m):
    j = m-1

    # Keep reducing index j of pattern while
    # characters of pattern and text are matching
    # at this shift s

    while j>=0 and pat[j] == txt[s+j]:
      j -= 1

    # If the pattern is present at current shift,
    # then index j will become -1 after the above loop
    if j<0:
      pattern_found = True
      shift = s
    #! DBG  print("Pattern start at = {}".format(s))
      '''
      Shift the pattern so that the next character in text
      aligns with the last occurrence of it in pattern.
      The condition s+m < n is necessary for the case when
      pattern occurs at the end of text
      '''
      s += (m-badChar[ord(txt[s+m])] if s+m<n else 1)
    else:
      '''
      Shift the pattern so that the bad character in text
      aligns with the last occurrence of it in pattern. The
      max function is used to make sure that we get a positive
      shift. We may get a negative shift if the last occurrence
      of bad character in pattern is on the right side of the
      current character.
      '''
      s += max(1, j-badChar[ord(txt[s+j])])
  return pattern_found, shift

#*
#* Apply normalization rules
#*
def applRules(str1):

  # Rule #1: Remove punctuation marks
  str1 = re.sub(r'[^\w\s]', "", str1)
  # Rule #2: Substitute multiple spaces with single space
  str1 = re.sub("\s\s+", " ", str1.replace(',', ' '))
  # Rule #3: Change to lowercase
  str1 = str1.lower()
  # Rule #4: Remove accents
  str1 = unidecode.unidecode(str1)

  return str1

#!
#! DBG Prints table of formatted text format options
#!
# def printColorTable():

#   for style in range(8):
#     for fg in range(30,38):
#       s1 = ''
#       for bg in range(40,48):
#         format = ';'.join([str(style), str(fg), str(bg)])
#         s1 += '\x1b[%sm %s \x1b[0m' % (format, format)
#       print(s1)
#     print('\n')

#*
#* Driver program to test above function
#*
def main():

  #! DBG
  #! printColorTable()
  #!

  ###? Test set
  row1 = "630000001001YYY01122021                Michele - Montemurró                      74123 TA TARANTO                        "
  row1a = applRules(row1)
  pat1 = "MICHELE MONTEMURRO"
  pat1a = applRules(pat1)

  row2 = "630000001001YY2VIA DOMENICO   ACCLAVIO,    73                          IT85C0103015803000063203525                           "
  row2a = applRules(row2)
  pat2 = "VIA DOMENICO ACCLAVIO 73"
  pat2a = applRules(pat2)

  row3 = "630000001001YY2VIA DOMENICO   ACCLAVIO,    73                          VIA DOMENICO   ACCLAVIO,    72IT85C0103015803000063203525                           "
  row3a = applRules(row3)
  pat3 = "VIA DOMENICO ACCLAVIO 73"
  pat3a = applRules(pat3)

  pat4 = "STRINGA NON PRESENTE"
  pat4a = applRules(pat4)
  ###? End test set

  os.system('cls')

  rc, s = BM_search(row1a, pat1a)
  if (not rc):
    print("\nPattern #1 <\x1b[6;30;41m{}\x1b[0m>\n\tnot found in <\x1b[6;30;45m{}\x1b[0m>\n".format(pat1, row1))
  else:
    print("\nPattern #1 <\x1b[6;30;43m{}\x1b[0m>\n\tfound in: <\x1b[6;30;42m{}\x1b[0m>\n".format(pat1, row1[s:]))

  rc, s = BM_search(row2a, pat2a)
  if (not rc):
    print("\nPattern #2 <\x1b[6;30;41m{}\x1b[0m>\n\tnot found in <\x1b[6;30;45m{}\x1b[0m>\n".format(pat2, row2))
  else:
    print("\nPattern #2 <\x1b[6;30;43m{}\x1b[0m>\n\tfound in: <\x1b[6;30;42m{}\x1b[0m>\n".format(pat2, row2[s:]))

  rc, s = BM_search(row3a, pat3a)
  if (not rc):
    print("\nPattern #3 <\x1b[6;30;41m{}\x1b[0m>\n\tnot found in <\x1b[6;30;45m{}\x1b[0m>\n".format(pat3, row3))
  else:
    print("\nPattern #3 <\x1b[6;30;43m{}\x1b[0m>\n\tfound in: <\x1b[6;30;42m{}\x1b[0m>\n".format(pat3, row3[s:]))

  rc, s = BM_search(row2a, pat4a)
  if (not rc):
    print("\nPattern #4 <\x1b[6;30;41m{}\x1b[0m>\n\tnot found in <\x1b[6;30;45m{}\x1b[0m>\n".format(pat4a, row2a))
  else:
    print("\nPattern #4 <\x1b[6;30;43m{}\x1b[0m>\n\tfound in: <\x1b[6;30;42m{}\x1b[0m>\n".format(pat4a, row2[s:]))

if __name__ == '__main__':
    main()

