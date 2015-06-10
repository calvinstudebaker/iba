#script to make sure all ticket id's are stored as ints rather than strings
#usage: python sanitizeTicketsJSON.py [source json file] [destination json file]
import json
import sys

oldjson = open(sys.argv[1], 'r')
newjson = open(sys.argv[2], 'w')

newArr = []
oldObject = json.load(oldjson)
oldArr = oldObject["results"]

try:
	for row in oldArr:
		row["ticketId"] = int(row["ticketId"])
		newArr.append(row)
finally:
	json.dump({"results" : newArr}, newjson)
	print('done')