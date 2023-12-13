#
# * Compute and verify an IBAN
#
# An international bank account number, known as an IBAN, consists of up to 34
# alphanumeric characters. An IBAN is comprised of:
#
# - A country code (taken from the ISO:3166 standard)
# - A two-digit control number
# - A number, referred to as the 'Basic Bank Account Number' (BBAN) that includes:
#   > The domestic bank account number
#   > The branch identifier (also known as a 'sort code' in the UK and Ireland)
#   > Potential routing information
#
# The Italian clearing system is used with 5 digits identifying the banking company
# (Codice ABI), followed by a 5-digit CAB (Codice di Avviamento Bancario) identifying
# the branch, followed by the account number.

def computeChecksum(tmpIban):
  # Remove leading 0s
  tmpIban = tmpIban.lstrip('0')
  # Iteratively compute the remainder of divide by 97
  remainder = eval(tmpIban+'% 97')
  pos = 9
  while pos < SIZE(tmpIban):
    tmp = TOSTRING(remainder) & SUBSTRING(tmpIban, pos, MIN(pos + 7, SIZE(tmpIban)))
    remainder = Integer.valueOf(tmp) % 97
    pos := pos + 7
  # Checksum is complement to 98
  checksum = 98 - remainder
  return IF(checksum < 10, '0', '') & TOSTRING(checksum);

def computeIban(bankNumber, accountNb, countryCode):
  if EMPTY(accountNb):
    return null

  # Build IBAN in order to compute checksum
  tmpIban = bankNumber & this.transcodeAlphaToDigit(accountNb & countryCode & '00')
  chksum = this.computeChecksum(tmpIban)
  # Rebuild IBAN with checksum
  return countryCode & chksum & bankNumber & accountNb

def verifyIban(iban):
  #
  #####################################################################
  # 1) Move the first four digits of the IBAN to the end of the string.
  #
  #    example: 0034633221115556TCH75
  #
  # 2) Using the values in the following conversion table, convert the
  #    country code, and any other letters in the account identifier,
  #    into numbers.
  #
  #    Example: Switzerland – 'CH' becomes 1217
  #    Example: Luxembourg – 'LU' becomes 2130
  #    Example: Italy – 'IT' becomes 1829
  #
  #    example string becomes: 003463322111555629121775
  #
  # 3) Compute the Modulo 97-10 of this number
  #
  # 4) Calculate the checksum as (97+1) minus the remainder
  #
  # 5) Verify that the checksum generated matches the digits in
  #    position 3 and 4 of the IBAN
  #####################################################################
  # Conversion table:
  # A = 10	H = 17	O = 24	V = 31
  # B = 11	I = 18	P = 25	W = 32
  # C = 12	J = 19	Q = 26	X = 33
  # D = 13	K = 20	R = 27	Y = 34
  # E = 14	L = 21	S = 28	Z = 35
  # F = 15	M = 22	T = 29
  # G = 16	N = 23	U = 30
  #####################################################################
  #
  countryCode = SUBSTRING(iban, 0, 2)
  checkSum = SUBSTRING(iban, 2, 4)
  tmpIban = this.transcodeAlphaToDigit(SUBSTRING(iban, 4) & countryCode) & '00'
  newCheckSum = this.computeChecksum(tmpIban)
  return checkSum == newCheckSum

if __name__ == '__main__':

    bankNumber =
    accountNb =
    countryCode = "CH"

    computeIban()