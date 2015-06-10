/*
main.js
This file defines all cloud functions that will run on Parse Cloud
These functions can be invoked from the command line using curl with REST API
or from iOS using Parse API
*/

//given four GeoPoints that define a region, return an array of
//locations and weights of all crimes within that region
Parse.Cloud.define("crimesInRegion", function(request, response){
	//Get bounding points that enclose the viewport passed by the client
	var boundingBox = require("cloud/boundingBox.js");
	var points = boundingBox.getBoundingPoints(request.params);

	var data = [];

	console.log("Southwest: " + points.southwest + " Northeast: " + points.northeast);

	//Add crimes to response data
	var Crime = Parse.Object.extend("TrainedCrime");
	var query = new Parse.Query(Crime);
	query.withinGeoBox("location", points.southwest, points.northeast).limit(1000);

	//Add user reported damage to response data
	var UserGeneratedReport = Parse.Object.extend("UserGeneratedReport");
	var userQuery = new Parse.Query(UserGeneratedReport);
	userQuery.withinGeoBox("location", points.southwest, points.northeast).limit(1000);

	query.find().then(function(results){
		for (var entryIndex in results) {
			var current = new Object();
			var entry = results[entryIndex];
			var weight = entry.get("weight");
			current["location"] = entry.get("location");
			current["weight"] = weight;
			data.push(current);
		}
		console.log(data);

		return userQuery.find();

	}, function(error){
		response.error("Unable to retrieve crime entries. Error: " + error.code + " " + error.messsage);
	}).then(function(results){
		for (var entryIndex in results) {
			var current = new Object();
			var entry = results[entryIndex];
			var weight = entry.get("damageRating") * 10; //magnitude fix
			current["location"] = entry.get("location");
			current["weight"] = weight;
			data.push(current);
		}
		console.log(data);

		//Send back an array of locations and weights
		response.success(data);
	}, function(error){
		response.error("Unable to retrieve user generated reports. Error: " + error.code + " " + error.messsage);
	});
});

Parse.Cloud.define("ticketsInRegion", function(request, response){
	//Get bounding points that enclose the viewport passed by the client
	var boundingBox = require("cloud/boundingBox.js");
	var points = boundingBox.getBoundingPoints(request.params);

	var data = [];

	//Add tickets to the response data
	var Ticket = Parse.Object.extend("Ticket");
	var query = new Parse.Query(Ticket);
	query.withinGeoBox("location", points.southwest, points.northeast);

	//Add user reported tickets to the response data
	var UserGeneratedReport = Parse.Object.extend("UserGeneratedReport");
	var userQuery = new Parse.Query(UserGeneratedReport);
	userQuery.withinGeoBox("location", points.southwest, points.northeast).limit(1000);

	query.find().then(function(results){
		for (var entryIndex in results) {
			var current = new Object();
			var entry = results[entryIndex];
			var weight = 1;
			current["location"] = entry.get("location");
			current["weight"] = weight;
			data.push(current);
		}
		console.log(data);

		return userQuery.find();

	}, function(error){
		response.error("Unable to retrieve ticket entries. Error: " + error.code + " " + error.messsage);
	}).then(function(results){
		for (var entryIndex in results) {
			var current = new Object();
			var entry = results[entryIndex];
			var weight = entry.get("ticketCost") * 10; //magnitude fix
			current["location"] = entry.get("location");
			current["weight"] = weight;
			data.push(current);
		}
		console.log(data);

		//Send back an array of locations and weights
		response.success(data);
	}, function(error){
		response.error("Unable to retrieve user generated reports. Error: " + error.code + " " + error.messsage);
	});

});

Parse.Cloud.define("pricesInRegion", function(request, response){
	//Get bounding points that enclose the viewport passed by the client
	var boundingBox = require("cloud/boundingBox.js");
	var points = boundingBox.getBoundingPoints(request.params);

	var data = [];

	//Add parking meter prices to the response data
	var ParkingMeter = Parse.Object.extend("ParkingMeter");
	var query = new Parse.Query(ParkingMeter);
	query.withinGeoBox("location", points.southwest, points.northeast).limit(2000);

	//Add user reported prices to the response data
	var UserGeneratedReport = Parse.Object.extend("UserGeneratedReport");
	var userQuery = new Parse.Query(UserGeneratedReport);
	userQuery.withinGeoBox("location", points.southwest, points.northeast).limit(1000);

	query.find().then(function(results){
		for (var entryIndex in results) {
			var current = new Object();
			var entry = results[entryIndex];
			var price = entry.get("hourlyRateEstimate");
			current["location"] = entry.get("location");
			current["weight"] = price;
			data.push(current);
		}
		console.log(data);

		return userQuery.find();

	}, function(error){
		response.error("Unable to retrieve parking meter entries. Error: " + error.code + " " + error.messsage);
	}).then(function(results){
		for (var entryIndex in results) {
			var current = new Object();
			var entry = results[entryIndex];
			var weight = entry.get("priceRating") * 10; //magnitude fix
			current["location"] = entry.get("location");
			current["weight"] = weight;
			data.push(current);
		}
		console.log(data);

		//Send back an array of locations and weights
		response.success(data);
	}, function(error){
		response.error("Unable to retrieve user generated reports. Error: " + error.code + " " + error.messsage);
	});
});

/**
 *@function
 *
 *Update the status (started/stopped/parked) of the specified car.
 *Intended to be called by Audi servers when an Audi car changes state.
 *A push notification is sent to the phone installation associated with the given car indicating the change.
 *Can be called over REST API with the following format (using the specified Parse Keys):
 *curl -X POST \
 * -H "X-Parse-Application-Id: D7gVBFc0P2dkb4XoronMmAbDGybOfKJQZKhg6akQ" \
 * -H "X-Parse-REST-API-Key: knFgO4NiKYTvfi5kTqyQpb5jl5puxqbUCSVp0SP8" \
 * -H "Content-Type: application/json" \
 * -d '{"carId":"CVBPW2AfQx", "status": 1}' \
 * https://api.parse.com/1/functions/carStatusChanged
 *@param {string} carId - the unique identifier for the car whose status should change
 *@param {int} status - the new status of the car. Options: 1 = Began (Car started moving), 2 = Stopped (Car went into Park), 3 = Parked (Car in Park and turned off)
 *@returns an HTTP response that, if successful, contains the Parse Car object that has been changed, and if unsuccessful, contains an error message.
 */
Parse.Cloud.define("carStatusChanged", function(request, response) {
	var status = request.params.status;

	var Car = Parse.Object.extend("Car");
	var query = new Parse.Query(Car);
	query.include("installation");

	query.get(request.params.carId, {
		success: function(carObject) {
			var isMove = carObject.get("isMoving");
			var isPark = carObject.get("isParked");

			var possibleUpdates = {
				BEGAN: 1,
				STOPPED: 2,
				PARKED: 3
			};

			var promise = new Parse.Promise();

			if (isMove && status === possibleUpdates.PARKED) {
				carObject.set("isMoving", false);
				carObject.set("isParked", true);
				carObject.save(null,{
			        success: function (object) { 
			        	console.log("Switched the car status to PARKED!");
			        	
			        	// Send the update push
			        	var push = require("cloud/push.js");
			        	var installationId = object.get("installation").id;
			        	var carLocation = object.get("location");
			        	var pushDict = {
							"pushText": "We've detected that your car has parked. Would you like to keep track of the parking meter?",
							"pushType": "CAR_PARKED", 
							"installationId": installationId,
							"optional" : {"carLocation" : carLocation}
						};
						console.log("trying to send push to: " + installationId);
						push.sendPush(pushDict);

			            response.success(object);
			        }, 
			        error: function (object, error) { 
			            response.error(error);
			        }
			    });
			} else if (isPark && (status === possibleUpdates.BEGAN || status === possibleUpdates.STOPPED)) {
				carObject.set("isMoving", true);
				carObject.set("isParked", false);
				carObject.save(null,{
                    success: function (object) { 
	                    console.log("Switched the car status to MOVING!");
						
						// Send the update push
			        	var push = require("cloud/push.js");
			        	var installationId = object.get("installation").id;

			        	var pushDict = {
							"pushText": "We've detected that your car is moving.",
							"pushType": "CAR_MOVING", 
							"installationId": installationId
						};
						console.log("trying to send push to: " + installationId);
						push.sendPush(pushDict);


	                    response.success(object);
			        }, 
			        error: function (object, error) { 
			         	response.error(error);
			        }
			    });
			} else {
				response.success("Nothing to update");
			}
		},
		error: function(object, error) {
			console.log("Trying to find a Car failed! Error code: " + error.message);
			response.error("Unable to find a Car! Error: " + error.code + ", " + error.message);
		}
	});
});

/**
 *Notify the specified car that it has been dinged
 *Intended to be called by Audi servers when a ding event is detected
 *Can be called over REST API with the following format (using the specified Parse Keys):
 *curl -X POST \
 * -H "X-Parse-Application-Id: D7gVBFc0P2dkb4XoronMmAbDGybOfKJQZKhg6akQ" \
 * -H "X-Parse-REST-API-Key: knFgO4NiKYTvfi5kTqyQpb5jl5puxqbUCSVp0SP8" \
 * -H "Content-Type: application/json" \
 * -d '{"carId":"CVBPW2AfQx"}' \
 * https://api.parse.com/1/functions/carDinged
 *@param {string} carId - the unique identifier for the car whose status should change
 *@returns an HTTP response that, if successful, returns a success message with the phone 
 * installation id that has been notified with a push notification, 
 * and if unsuccessful, returns an error message.
 */
Parse.Cloud.define("carDinged", function(request, response) {

	var query = new Parse.Query("Car");
	query.equalTo("objectId", request.params.carId);
	query.include("installation");
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

				push.sendPush(pushDict);
				response.success("Sending push to " + installationId);

			} else {
				response.error("Couldn't find a car with that id");
			}
		},
		error: function() {
			response.error("Car lookup failed");
		}
	});
});

//Runs hourly on the half hour, detecting cars that will soon be parked in street sweeping zones
//false positives may occur. uses approximate address of car, and street sweeping
//public data is inaccurate in terms of on/off weeks of the month, so
//this function assumes every week is active.
Parse.Cloud.job("alertCarsInSweepingZones", function(request, response){
	var push = require("cloud/push.js");
	var _ = require("underscore.js");
	
	//Get the hour and day in question
	var days = ["Sun", "Mon", "Tues", "Wed", "Thu", "Fri", "Sat"];
	var HALF_HOUR = 30 * 60 * 1000; //half hour in milliseconds
	var MINUTES_IN_HOUR = 60;
	var PDT_OFFSET = -7;
	var d = new Date();
	var soon = new Date(d.getTime() + HALF_HOUR); //add a half hour
	var timezoneOffset = soon.getTimezoneOffset() / MINUTES_IN_HOUR;
	timezoneOffset = PDT_OFFSET - timezoneOffset;
	var hour = (soon.getHours() + timezoneOffset).toString();
	var day = days[soon.getDay()];
	if (hour.length == 1) {
		hour = "0" + hour;
	}

	//Find all parked cars
	var StreetSweepingRoute = Parse.Object.extend("StreetSweepingRoute");
	var carQuery = new Parse.Query("Car");
	carQuery.equalTo("isParked", true);
	carQuery.exists("location");
	carQuery.exists("installation");
	carQuery.exists("address");
	carQuery.include("installation");

	carQuery.find().then(function(parkedCars){
		
		//Chain together sweeping queries in a parse promise
		var sweepPromise = Parse.Promise.as();

		//Check each parked car to see if it is in any sweeping routes
		_.each(parkedCars, function(parkedCar){
			var address = parkedCar.get("address").toUpperCase();
			var firstSpace = address.indexOf(" ");
			if (firstSpace != -1 && address.length > firstSpace+1){
				//Get streetname and streetnumber of parked car
				var streetname = address.substring(firstSpace + 1);
				var streetnumber = parseInt(address.substring(0, firstSpace));

				//Query to check that streetnumber is within the left addresses swept
				var withinLeftAddressQuery = new Parse.Query(StreetSweepingRoute);
				withinLeftAddressQuery.greaterThanOrEqualTo("left_to_address", streetnumber);
				withinLeftAddressQuery.lessThanOrEqualTo("left_from_address", streetnumber);

				//Query to check that streetnumber is within the right addresses swept
				var withinRightAddressQuery = new Parse.Query(StreetSweepingRoute);
				withinRightAddressQuery.greaterThanOrEqualTo("right_to_address", streetnumber);
				withinRightAddressQuery.lessThanOrEqualTo("right_from_address", streetnumber);

				//compound the two queries together, if either are true then the car could be in danger
				var sweepingQuery = Parse.Query.or(withinLeftAddressQuery, withinRightAddressQuery);

				//route must be on the same street and active at the right time
				var startTimeQuery = new Parse.Query(StreetSweepingRoute);
				sweepingQuery.startsWith("start_time", hour);
				sweepingQuery.equalTo("weekday", day);
				sweepingQuery.startsWith("streetname", streetname);
				sweepingQuery.limit(1); //one active route is all it takes to be illegally parked

				//Check if there is a sweeping route that intersects with this parked car
				sweepPromise = sweepPromise.then(function(){
					return sweepingQuery.count().then(function(activeRouteCount){
						if(activeRouteCount > 0){
							//Send push notification
							var installationId = parkedCar.get("installation").id;
							var pushDict = {
								"pushText": "Street sweeping starting in 30 minutes! Move your car as soon as possible.",
								"pushType": "STREET_SWEEPING", 
								"installationId": installationId
							};
							push.sendPush(pushDict);
							console.log("Sending street sweeping notification to: " + installationId);
						}
					}, function(error){
						response.error("Unable to retrieve sweeping routes. Error: " + error.code + " " + error.message);
					});
				}); 
			}
		});

		return sweepPromise;
	}, function(error){
		response.error("Unable to retrieve parked cars. Error: " + error.code + " " + error.message);
	}).then(function(){
		response.success("Every car in street sweeping zones notified!");
	}, function(error){
		response.error("Unable to send all push notifications to cars in sweeping zones. Error: " + error.code + " " + error.message);
	});
});
