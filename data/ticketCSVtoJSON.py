import csv
import json
import sys
import time
import urllib2	#uses Google Maps API to convert address to geopoint


csvfile = open(sys.argv[1], 'r')
oldjson = open(sys.argv[2], 'r')
newjson = open(sys.argv[3], 'w')

fieldnames = (
	"ticket_id",
	"ag",
	"citation",
	"issue_datetime", 
	"plate", 
	"vin",
	"make",
	"body",
	"cl",
	"location",
	"badge",
	"violation",
	"violation_description",
	"meter",
	"fine_amt",
	"penalty_1",
	"penalty_2",
	"penalty_4",
	"penalty_5",
	"pay_amt",
	"outstanding",
	"s",
	"geopoint"
)

reader = csv.DictReader( csvfile, fieldnames)
rowCount = 0
oldObject = json.load(oldjson)
arr = oldObject["results"]
oldRowCount = arr[len(arr)-1]["ticketId"]

try:
	for row in reader:
		if row["ticket_id"] == "ticket_id": continue #skip first line of csv
		if int(row["ticket_id"]) <= oldRowCount: continue #get to next non-processed line
		if rowCount > 2400 : break	#limit API calls to not overflow daily limit
		
		d = dict()
		csvDate = row["issue_datetime"]
		tokens = csvDate.split()
		date = tokens[0]
		timeOfDay = tokens[1]
		dateTime = date + "T" + timeOfDay + ".000Z"
		d["timestamp"] = {"__type": "Date", "iso": dateTime}

		d["ticketId"] = int(row["ticket_id"])
		d["violationId"] = row["violation"]
		d["violationDescription"] = row["violation_description"]

		address = row["location"]
		d["address"] = address

		url = "http://maps.googleapis.com/maps/api/geocode/json?address=" + address.replace(" ", "+") + ",+San+Francisco"
		response = urllib2.urlopen(url)
		data = json.load(response)
		if data['status'] == 'OK':
			location = data["results"][0]["geometry"]["location"]
			d["location"] = {"__type": "GeoPoint", "latitude" : float(location["lat"]), "longitude" : float(location["lng"])}

			arr.append(d)
			
		else:
			print(data['status'])
			print(rowCount)
			print(data)

		rowCount+=1
		#pause to not exceed google api usage limits
		time.sleep(2)
finally:
	json.dump({"results" : arr}, newjson)
	print("done")