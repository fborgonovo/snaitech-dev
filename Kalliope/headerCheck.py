import re

regex = r'RestApiUsernameToken Username="([^"@]+)", Domain="([^"@]+){0,1}", Digest="([^"]+)", Nonce="([^"]+)", Created="(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z)"'

test_str = "RestApiUsernameToken Username=\"admin\", Domain=\"default\", Digest=\"+PJg7Tb3v98XnL6iJVv+v5hwhYjdzQ2tIWxvJB2cE40=\", Nonce=\"bfb79078ff44c35714af28b7412a702b\", Created=\"2016-04-29T15:48:26Z\""

matches = re.search(regex, test_str)

if matches:
    print ("Match was found at {start}-{end}: {match}".format(start = matches.start(), end = matches.end(), match = matches.group()))
    
    for groupNum in range(0, len(matches.groups())):
        groupNum = groupNum + 1
        
        print ("Group {groupNum} found at {start}-{end}: {group}".format(groupNum = groupNum, start = matches.start(groupNum), end = matches.end(groupNum), group = matches.group(groupNum)))