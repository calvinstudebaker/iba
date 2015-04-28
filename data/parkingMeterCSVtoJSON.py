import csv
import json
import sys

csvfile = open(sys.argv[1], 'r')
jsonfile = open(sys.argv[2], 'w')

fieldnames = (
	"POST_ID",
	"MS_ID",
	"MS_SPACEID",
	"CAP_COLOR", 
	"METER_TYPE", 
	"SMART_METE",
	"ACTIVESENS",
	"JURISDICTI",
	"ON_OFF_STR",
	"OSP_ID",
	"STREET_NUM",
	"STREETNAME",
	"STREET_SEG",
	"RATEAREA",
	"SFPARKAREA",
	"LOCATION"
)

colorCodes = {
	"Black" : "Motorcycle", 
	"Brown" : "Tour Bus", 
	"Green" : "Short Term", 
	"Grey" : "Standard", 
	"Purple" : "Boat Trailer", 
	"Red" : "Six Wheeled", 
	"Yellow" : "Commercial"
}

offStreetLotCodes = {
	0 : "On Street",
	890 : "Pier 48 Lot", 
	891 : "Pier 52 Lot", 
	892 : "Pier 1/2 Motorcycle Lot", 
	901 : "24th and Capp Lot", 
	902 : "California and Steiner Lot",
	903 : "8th and Clement Lot", 
	904 : "9th and Clement Lot", 
	905 : "Castro Theater Lot",
	906 : "18th and Collingwood Lot",
	907 : "Mission and Norton Lot",
	908 : "21st and Geary Lot",
	909 : "18th and Geary Lot",
	910 : "20th and Irving Lot",
	911 : "8th and Irving Lot",
	913 : "7th and Irving Lot",
	914 : "Junipero Serra and Ocean Lot",
	915 : "19th and Ocean Lot",
	916 : "Pierce Street Garage",
	918 : "24th and Noe Lot",
	919 : "Felton and San Bruno Lot",
	920 : "SF General Hospital Lot",
	922 : "West Portal Lot",
	923 : "Claremont and Ulloa Lot",
	924 : "Phelan Loop Lot"
}

hourlyRateEstimates = {
	"Area 1" : 3.50,
	"Area 2" : 3.00,
	"Area 3" : 2.00,
	"Area 5" : 3.00,
	"MC1" : 0.70,
	"MC2" : 0.60,
	"MC3" : 0.40,
	"MC5" : 2.00,
	"Port 1" : 2.50,
	"Port 2" : 2.50,
	"Port 3" : 2.00,
	"Port 4" : 2.00,
	"Port 5" : 3.00,
	"Port 6" : 3.00,
	"Port 7" : 3.00,
	"Port 8" : 3.00,
	"Port 9" : 1.00,
	"Port 10" : 1.00,
	"Port 11" : 1.00,
	"Port 12" : 1.00,
	"PortMC1" : 0.25,
	"PortMC2" : 0.50,
	"Tour Bus" : 4.50
}

reader = csv.DictReader( csvfile, fieldnames)
arr = []
for row in reader:
	if row["POST_ID"] == "POST_ID": continue 
	d = dict()
	
	d["meterId"] = row["POST_ID"]
	d["multispaceId"] = row["MS_ID"]
	d["spaceNumber"] = int(row["MS_SPACEID"])
	
	color = row["CAP_COLOR"]
	if color in colorCodes:
		d["vehicleType"] = colorCodes[color]
	else:
		d["vehicleType"] = "Standard"
	
	d["isMultiSpace"] = (row["METER_TYPE"] == "MS")
	d["isSmartMeter"] = (row["SMART_METE"] == "Y")
	d["hasActiveSensor"] = (row["ACTIVESENS"] == "Y")
	d["isOffStreet"] = (row["ON_OFF_STR"] == "OFF")

	lotCode = int(row["OSP_ID"])
	if lotCode in offStreetLotCodes:
		d["offStreetLot"] = offStreetLotCodes[lotCode]
	else:
		d["offStreetLot"] = "On Street"
	
	d["address"] = row["STREET_NUM"] + " " + row["STREETNAME"]
	d["streetSegment"] = row["STREET_SEG"]
	d["hourlyRateEstimate"] = float(hourlyRateEstimates[row["RATEAREA"]])

	location = row["LOCATION"]
	latLong = location.replace("(", " ").replace(")", " ").replace(",", " ").split()
	d["location"] = {"__type": "GeoPoint", "latitude" : float(latLong[0]), "longitude" : float(latLong[1])}

	arr.append(d)

json.dump({"results" : arr}, jsonfile)
print("done")