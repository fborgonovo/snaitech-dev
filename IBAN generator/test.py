
if __name__ == '__main__':

  convTable = {
    'A' : 10, 'H' : 17,	'O' : 24,	'V' : 31,
    'B' : 11, 'I' : 18,	'P' : 25,	'W' : 32,
    'C' : 12, 'J' : 19,	'Q' : 26,	'X' : 33,
    'D' : 13, 'K' : 20,	'R' : 27,	'Y' : 34,
    'E' : 14, 'L' : 21,	'S' : 28,	'Z' : 35,
    'F' : 15, 'M' : 22,	'T' : 29,
    'G' : 16, 'N' : 23,	'U' : 30
  }

  tmpIban = 'CH750034633221115556T'
  print("IBAN: {}".format(tmpIban))

  # Remove leading 0s
  tmpIban = tmpIban.lstrip('0')
  print("IBAN: {}".format(tmpIban))

  # Convert text characters
  tmpIban1 = ""
  for ch in tmpIban:
    if ch.isalpha():
      ch = str(convTable.get(ch))
    tmpIban1 += ch

  # Iteratively compute the remainder of divide by 97+1
  #remainder = eval(tmp1 % tmp2)
  #print("IBAN: {}".format(tmpIban))
  #print("remainder: {}".format(remainder))

  remainder = int(tmpIban1[0 : 9]) % 97
  pos = 9
  tmp2 = ""
  while pos < len(tmpIban1):
    # SUBSTRING($tmpIban, $pos, MIN($pos + 7, SIZE($tmpIban)))
    # l = len(tmpIban1)
    # t = tmpIban1[pos : min(pos + 7, l)]
    tmp2 += str(remainder) + tmpIban1[pos : min(pos + 7, len(tmpIban1))]
    remainder = int(tmp2) % 97
    pos = pos + 7
  print(remainder)
  checksum = 98 - remainder

  result = '0' if (checksum < 10) else '' + str(checksum)

  print(result)