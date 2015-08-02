import sys
import json

print 'Number of arguments:', len(sys.argv)
print 'Updating BUILD MongoDB instance with: ', str(sys.argv[1])

with open('BUILD/BUILD/server/config.json', 'r+') as jsonFile:
    data = json.load(jsonFile)

    data["db"]["hosts"] = sys.argv[1].decode('string-escape')

    jsonFile.seek(0)
    json.dump(data, jsonFile, indent=4)