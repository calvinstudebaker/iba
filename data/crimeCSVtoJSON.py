#script to convert crime csv file from DataSF to Parse-ready json
#usage python crimeCSVtoJSON.py [source csv file] [destination json file]

import csv
import json
import sys

csvfile = open(sys.argv[1], 'r')
jsonfile = open(sys.argv[2], 'w')

fieldnames = ("IncidntNum","Category","Descript","DayOfWeek", "Date", "Time","PdDistrict","Resolution","Address","X","Y","Location","PdId")
reader = csv.DictReader( csvfile, fieldnames)
arr = []
for row in reader:
	if row["Category"] == "Category": continue 

	csvDate = row["Date"]
	tokens = csvDate.split("/")
	month = tokens[0]
	day = tokens[1]
	year = tokens[2]
	category = row["Category"]
	d = dict()

	if int(year) < 2009: continue
	if category in ["BAD CHECKS", "EMBEZZLEMENT", "FORGERY/COUNTERFEITING", "BRIBERY", "FRAUD", "RECOVERED VEHICLE", "SUICIDE"]: 
		continue
	elif category in ["ASSAULT", "BURGLARY", "KIDNAPPING", "LARCENY/THEFT", "ROBBERY", "SEX OFFENSES, FORCIBLE", "STOLEN PROPTERY", "VEHICLE THEFT", "WEAPON LAWS"]:
		d["weight"] = 10
	elif category == "DRUG NARCOTIC":
		d["weight"] = 9
	elif category in ["LOITERING", "PROSTITUTION"]:
		d["weight"] = 8
	elif category in ["ARSON", "DISORDERLY CONDUCT", "DRUNKENNESS", "SECONDARY CODES"]:
		d["weight"] = 7
	elif category  == "DRIVING UNDER THE INFLUENCE":
		d["weight"] = 6
	elif category in ["VANDALISM", "WARRANTS"]:
		d["weight"] = 5
	elif category in ["EXTORTION", "LIQUOR LAWS", "SEX OFFENSES, NON FORCIBLE", "SUSPICIOUS OCC", "TRESPASS"]:
		d["weight"] = 4
	elif category in ["GAMBLING", "TREA"]:
		d["weight"] = 3
	elif category in ["FAMILY OFFENSES", "MISSING PERSON", "PORNOGRAPHY/OBSCENE MAT"]:
		d["weight"] = 2
	else:
		d["weight"] = 1

	
	d["indicentId"] = int(row["IncidntNum"])
	d["category"] = row["Category"]
	d["descript"] = row["Descript"]
	

	time = year + "-" + month + "-" + day + "T" + row["Time"] + ":00.000Z"

	d["timestamp"] = {"__type": "Date", "iso": time}

	d["pdDiscrict"] = row["PdDistrict"]
	d["resolution"] = row["Resolution"]
	d["addresss"] = row["Address"]

	d["location"] = {"__type": "GeoPoint", "latitude" : float(row["Y"]), "longitude" : float(row["X"])}
	
	d["pdId"] = int(row["PdId"])

	arr.append(d)

json.dump({"results" : arr}, jsonfile)
print("done")