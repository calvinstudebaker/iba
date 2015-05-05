/*
main.js
This file defines all cloud functions that will run on Parse Cloud
These functions can be invoked from the command line using curl with REST API
or from iOS using Parse API
*/

var jobs = require("cloud/jobs.js");
var meterDataURL = "https://data.sfgov.org/resource/7egw-qt89.json";
var crimeDataURL = "https://data.sfgov.org/api/views/tmnf-yvry/rows.json";

Parse.Cloud.define("putSweepingData", function(request, response){
	Parse.Cloud.httpRequest({
		url: "http://parq.parseapp.com/sfsweeproutes.json",
		success: function(res){
			var data = res.data;
			var entry = data[0];
			console.log("first entry: " + entry);
			for (var key in entry){
				var attrName = key;
				var attrVal = entry[key];
				// console.log(attrName + ": " + attrVal);
			}
			response.success("word");
		},
		error: function(res){
			console.error("request failed with response code: " + res.status);
			response.error("bad");
		}
	});
});

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

//inject initial data into ParkingMeter table from dataSF.org
Parse.Cloud.job("putMeterData", function(request, response){
	jobs.putMeterDataFromURL(meterDataURL, request, response);
});

//inject initial data into Crime table from dataSF.org
Parse.Cloud.job("putCrimeData", function(request, response){
	jobs.putCrimeDataFromURL(crimeDataURL, request, resopnse);
});

//Test function to make sure cloud code is working. Exemplifies using a separate
//javascript module (test.js)
Parse.Cloud.define("test", function(request, response){
	var test = require("cloud/test.js");
	var val = test.isACoolName('Ralph');
	response.success(val);
});
