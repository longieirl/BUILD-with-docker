import sys
import json

print 'Updating BUILD MongoDB instance with hostname rather than IP address'

with open(sys.argv[1].decode('string-escape'), 'r+') as jsonFile:
    data = json.load(jsonFile)

    # Using hostname instead rather than IP address
    data["db"]["hosts"] = sys.argv[2].decode('string-escape')

    jsonFile.seek(0)
    json.dump(data, jsonFile, indent=4)