'''
file: ticketCSVtoJSON.py
script to convert raw csv data for 2012 parking tickets (data/tickets.csv)
into a json file that can be imported into the Parse database. The csv
tickets only have an address, no lattitude/longitude GeoPoint, so this script
uses Google Maps API to geotag each ticket. Only 2500 API requests are allowed
per day, so this script is run everyday to geotag 2450 more tickets.
Usage: python ticketCSVtoJSON.py tickets.csv old_file.json new_file.json
First argument: tickets.csv is a csv file acquired from ParkRoulette that holds
every ticket issued in SF in 2012
Second argument: current json converted ticket data, this file will be the starting point
for new ticket json data, and will remain unchanged.
Third argument: destination file for new ticket json data.
'''
import csv
import json
import sys
import time
import urllib2	#uses Google Maps API to convert address to geopoint

#open input/output files
csvfile = open(sys.argv[1], 'r')
oldjson = open(sys.argv[2], 'r')
newjson = open(sys.argv[3], 'w')

#filednames in the csv file
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

#create reader for the csv data
reader = csv.DictReader( csvfile, fieldnames)
rowsRead = 0

#load old json data (already-processed tickets)
oldObject = json.load(oldjson)
arr = oldObject["results"]
oldRowCount = int(arr[len(arr)-1]["ticketId"])
print "oldID = " + str(oldRowCount)

try:
	for row in reader:
		if row["ticket_id"] == "ticket_id": continue #skip first line of csv
		if int(row["ticket_id"]) <= oldRowCount: continue #get to next non-processed line
		if rowsRead > 2450 : break	#limit API calls to not overflow daily limit
		print "rowsRead = " + str(rowsRead) + " id = " + row["ticket_id"] #print progress

		#create new ticket row
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

		#geotag the ticket with a GeoPoint
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
			if data['status'] == 'OVER_QUERY_LIMIT': break

		rowsRead+=1
		#pause to not exceed google api usage limits
		time.sleep(2)
finally:
	#save results in new json file
	json.dump({"results" : arr}, newjson)
	print("done")