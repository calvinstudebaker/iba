/*
main.js
This file defines all cloud functions that will run on Parse Cloud
These functions can be invoked from the command line using curl with REST API
or from iOS using Parse API
*/

var jobs = require("cloud/jobs.js");
var meterDataURL = "https://data.sfgov.org/resource/7egw-qt89.json";
var crimeDataURL = "https://data.sfgov.org/api/views/tmnf-yvry/rows.json";


//given four GeoPoints that define a region, return an array of
//locations and weights of all crimes within that region
//TODO: make sure southwest and northeast are valid, get time field from request
Parse.Cloud.define("crimesInRegion", function(request, response){
	var nearLeft = request.params.nearLeft;
	var nearRight = request.params.nearRight;
	var farLeft = request.params.farLeft;
	var farRight = request.params.farRight;

	console.log(nearLeft);
	console.log(nearLeft.latitude);
	console.log(nearLeft.longitude);

	var minLatitude = Math.min(nearLeft.latitude, nearRight.latitude, farLeft.latitude, farRight.latitude);
	var maxLatitude = Math.max(nearLeft.latitude, nearRight.latitude, farLeft.latitude, farRight.latitude);
	var minLongitude = Math.min(nearLeft.longitude, nearRight.longitude, farLeft.longitude, farRight.longitude);
	var maxLongitude = Math.max(nearLeft.longitude, nearRight.longitude, farLeft.longitude, farRight.longitude);

	var southwestPoint = new Parse.GeoPoint(minLatitude, minLongitude);
	var northeastPoint = new Parse.GeoPoint(maxLatitude, maxLongitude);

	console.log(southwestPoint);
	console.log(northeastPoint);

	var Crime = Parse.Object.extend("CrimeSample");
	var query = new Parse.Query(Crime);
	query.withinGeoBox("location", southwestPoint, northeastPoint).limit(1000);
	query.find({
		success: function(results) {
			var data = [];
			var maxWeight = 0;
			var minWeight = 11;
			for (var entryIndex in results) {
				var current = new Object();
				var entry = results[entryIndex];
				var weight = entry.get("weight");
				current["location"] = entry.get("location");
				current["weight"] = weight;
				if (weight < minWeight) { minWeight = weight;}
				if (weight > maxWeight) { maxWeight = weight;}
				data.push(current);
			}
			console.log(data.length + " crimes found with a max weight of " + maxWeight
				+ " and  min weight of " + minWeight +":");
			console.log(data);
			response.success(data);
		},
		error: function(error){
			response.error("Unable to retrieve objects. Error: " + error.code + " " + error.messsage);
		}
	});
});

Parse.Cloud.define("ticketsInRegion", function(request, response){
	var nearLeft = request.params.nearLeft;
	var nearRight = request.params.nearRight;
	var farLeft = request.params.farLeft;
	var farRight = request.params.farRight;

	// console.log(nearLeft);
	// console.log(nearLeft.latitude);
	// console.log(nearLeft.longitude);

	var minLatitude = Math.min(nearLeft.latitude, nearRight.latitude, farLeft.latitude, farRight.latitude);
	var maxLatitude = Math.max(nearLeft.latitude, nearRight.latitude, farLeft.latitude, farRight.latitude);
	var minLongitude = Math.min(nearLeft.longitude, nearRight.longitude, farLeft.longitude, farRight.longitude);
	var maxLongitude = Math.max(nearLeft.longitude, nearRight.longitude, farLeft.longitude, farRight.longitude);

	var southwestPoint = new Parse.GeoPoint(minLatitude, minLongitude);
	var northeastPoint = new Parse.GeoPoint(maxLatitude, maxLongitude);

	console.log(southwestPoint);
	console.log(northeastPoint);

	var Ticket = Parse.Object.extend("Ticket");
	var query = new Parse.Query(Ticket);
	query.withinGeoBox("location", southwestPoint, northeastPoint).limit(1500);
	query.find({
		success: function(results) {
			var data = [];
			for (var entryIndex in results) {
				var current = new Object();
				var entry = results[entryIndex];
				var weight = 1;
				current["location"] = entry.get("location");
				current["weight"] = weight;
				data.push(current);
			}
			console.log(data.length + " tickets found:");
			console.log(data);
			response.success(data);
		},
		error: function(error){
			response.error("Unable to retrieve objects. Error: " + error.code + " " + error.messsage);
		}
	});
});

Parse.Cloud.define("pricesInRegion", function(request, response){
	var nearLeft = request.params.nearLeft;
	var nearRight = request.params.nearRight;
	var farLeft = request.params.farLeft;
	var farRight = request.params.farRight;

	// console.log(nearLeft);
	// console.log(nearLeft.latitude);
	// console.log(nearLeft.longitude);

	var minLatitude = Math.min(nearLeft.latitude, nearRight.latitude, farLeft.latitude, farRight.latitude);
	var maxLatitude = Math.max(nearLeft.latitude, nearRight.latitude, farLeft.latitude, farRight.latitude);
	var minLongitude = Math.min(nearLeft.longitude, nearRight.longitude, farLeft.longitude, farRight.longitude);
	var maxLongitude = Math.max(nearLeft.longitude, nearRight.longitude, farLeft.longitude, farRight.longitude);

	var southwestPoint = new Parse.GeoPoint(minLatitude, minLongitude);
	var northeastPoint = new Parse.GeoPoint(maxLatitude, maxLongitude);

	console.log(southwestPoint);
	console.log(northeastPoint);

	var ParkingMeter = Parse.Object.extend("ParkingMeter");
	var query = new Parse.Query(ParkingMeter);
	query.withinGeoBox("location", southwestPoint, northeastPoint).limit(2000);
	query.find({
		success: function(results) {
			var data = [];
			var minPrice = 20;
			var maxPrice = 0;
			for (var entryIndex in results) {
				var current = new Object();
				var entry = results[entryIndex];
				var price = entry.get("hourlyRateEstimate");
				current["location"] = entry.get("location");
				current["weight"] = price;
				if(price < minPrice) {minPrice = price;}
				if(price > maxPrice) {maxPrice = price;}
				data.push(current);
			}
			console.log(data.length + " meters found with a low price of " + minPrice
				+ " and a high price of " + maxPrice + ":");
			console.log(data);
			response.success(data);
		},
		error: function(error){
			response.error("Unable to retrieve objects. Error: " + error.code + " " + error.messsage);
		}
	});
});


Parse.Cloud.define("carStatusChanged", function(request, response) {
	var reqParams = request.params;
	var status = reqParams.status;
	var car = reqParams.car;

	var Car = Parse.Object.extend("Car");
	var query = new Parse.Query(Car);

	//query.equalTo("objectId", car);
	//query.find();
	var carId = reqParams.car;
	query.get(carId, {
		success: function(carObject) {
			var isMove = carObject.get("isMoving");
			var isPark = carObject.get("isParked");

			var possibleUpdates = {
				BEGAN: 1,
				STOPPED: 2,
				PARKED: 3
			};

			if (isMove && status === possibleUpdates.PARKED) {
				carObject.save(null, {
					success: function(carObject) {
						carObject.set("isMoving", false);
						carObject.set("isParked", true);
						console.log("Switched the car status to PARKED!");
					}
				})

			} 
			else if (isPark && (status === possibleUpdates.BEGAN || status === possibleUpdates.STOPPED)) {
				carObject.save(null, {
					success: function(carObject) {
						carObject.set("isMoving", true);
						carObject.set("isParked", false);
						console.log("Switched the car status to MOVING!");
					}
				})
			}
			response.success("Updated data here!");
		},
		error: function(object, error) {
			console.log("Trying to find a Car failed! Error code: " + error.message);
			response.error("Unable to find a Car! Error: " + error.code + ", " + error.message);
		}
	});
})

Parse.Cloud.define("carDinged", function(request, response) {

	var query = new Parse.Query("Car");
	query.equalTo("objectId", request.params.carId);
	query.find({
		success: function(results) {
			if (results.length > 0) {

				var car = results[0];

				var installationId = car.get("installation").id;
				
				var push = require("cloud/push.js");
				var pushDict = {
					"pushText": "We've detected that your car has been dinged.",
					"pushType": "CAR_DINGED", 
					"installationId": installationId
				};

				console.log("trying to send push to: " + installationId);

				var result = push.sendPush(pushDict);
				response.success("Sending push to " + installationId);

			} else {
				response.error("Couldn't find a car with that id");
			}
		},
		error: function() {
			response.error("Car lookup failed");
		}
	});
})


//inject initial data into ParkingMeter table from dataSF.org
Parse.Cloud.job("putMeterData", function(request, response){
	jobs.putMeterDataFromURL(meterDataURL, request, response);
});

//inject initial data into Crime table from dataSF.org
Parse.Cloud.job("putCrimeData", function(request, response){
	jobs.putCrimeDataFromURL(crimeDataURL, request, resopnse);
});

//To run hourly, detecting cars that are parked in street sweeping zones
Parse.Cloud.job("activeSweepingRoutes", function(request, resposnse){
	var days = ["Sun", "Mon", "Tues", "Wed", "Thu", "Fri", "Sat"];
	var d = new Date();
	var hour = d.getHours().toString();
	if (hour.length == 1) {
		hour = "0" + hour;
	}

	var StreetSweepingRoute = Parse.Object.extend("StreetSweepingRoute");
	var query = new Parse.Query(StreetSweepingRoute);
	query.startsWith("start_time", hour);
	query.equals("weekday", days[d.getDay()]);

	query.find({
		success: function(results){
			var data = [];
			for (var entryIndex in results){
				var currentRoute = new Object();
				var entry = results[entryIndex];
				currentRoute["streetName"] = entry.get("streetname");
				currentRoute["rightFromAddress"] = entry.get("right_from_address");
				currentRoute["rightToAddress"] = entry.get("right_to_address");
				currentRoute["leftFromAddress"] = entry.get("left_from_address");
				currentRoute["leftToAddress"] = entry.get("left_to_address");
				currentRoute["endTime"] = entry.get("end_time");
				data.push(currentRoute);
			}
			console.log(data.length + " active routes found: ");
			console.log(data);
			response.success(data);
		},
		error: function(error){
			response.error("Unable to retrieve routes. Error: " + error.code + " " + error.message);
		}
	});
});
