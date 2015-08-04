import sys
import json

print 'Updating BUILD MongoDB instance with hostname rather than IP address: ', str(sys.argv[1])

with open('BUILD/BUILD/server/config.json', 'r+') as jsonFile:
    data = json.load(jsonFile)

    # Using hostname instead rather than IP address
    data["db"]["hosts"] = 'build-DB-01'

    jsonFile.seek(0)
    json.dump(data, jsonFile, indent=4)