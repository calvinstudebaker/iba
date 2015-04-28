import csv
import json
import sys
import urllib2	#uses Google Maps API to convert address to geopoint

csvfile = open(sys.argv[1], 'r')
jsonfile = open(sys.argv[2], 'w')

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
arr = []
for row in reader:
	if row["ticket_id"] == "ticket_id": continue 
	
	d = dict()

	csvDate = row["issue_datetime"]
	tokens = csvDate.split()
	date = tokens[0]
	time = tokens[1]
	dateTime = date + "T" + time + ".000Z"
	d["timestamp"] = {"__type": "Date", "iso": dateTime}

	d["ticketId"] = row["ticket_id"]
	d["violationId"] = row["violation"]
	d["violationDescription"] = row["violation_description"]

	address = row["location"]
	d["address"] = address

	#Only allowed 25,000 requests per day, do this later with only 25,000 rows (will take 3 days to get entire file)

	# url = "http://maps.googleapis.com/maps/api/geocode/json?address=" + address.replace(" ", "+") + ",+San+Francisco"
	# response = urllib2.urlopen(url)
	# data = json.load(response)

	# location = data["results"][0]["geometry"]["location"]
	# d["location"] = {"__type": "GeoPoint", "latitude" : float(location["lat"]), "longitude" : float(location["lng"])}

	arr.append(d)

json.dump({"results" : arr}, jsonfile)
print("done")