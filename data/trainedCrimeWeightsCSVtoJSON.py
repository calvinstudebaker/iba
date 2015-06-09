import csv
import json
import sys

csvfile = open(sys.argv[1], 'r')
jsonfile = open(sys.argv[2], 'w')

fieldnames = ("Crime","Score")
reader = csv.DictReader( csvfile, fieldnames)
arr = []
for row in reader:
	if row["Crime"] == "Crime Score": continue 
	d = dict()
	entry = row["Crime"]
	location = entry.split()[0]
	weight = entry.split()[1]
	tokens = location.split("|")

	print tokens
	d["location"] = {"__type": "GeoPoint", "latitude" : float(tokens[1]), "longitude" : float(tokens[2])}

	d["weight"] = float(weight)
	arr.append(d)

json.dump({"results" : arr}, jsonfile)
print("done")