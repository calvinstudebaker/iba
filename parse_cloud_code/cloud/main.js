
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});


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

Parse.Cloud.define("putMeterData", function(request, response){
	var ParkingMeter = Parse.Object.extend("ParkingMeter");

	console.log ("HERE");
	Parse.Cloud.httpRequest({
		url: "https://data.sfgov.org/resource/7egw-qt89.json",
		success: function(res){
			var data = res.data;
			var entry = new ParkingMeter();
			
			var meter = data[0];
			var streetname = meter["streetname"];
			console.log(streetname);
			var location = meter["location"];
			var geopoint = new Parse.GeoPoint({latitude: location.latitude, longitude: location.longitude});


			entry.set("has_active_sensor", meter.activesens);
			entry.set("is_smart_meter", meter.smart_mete);
			entry.set("location", geopoint);
			entry.set("on_off_street", meter.on_off_str);
			entry.set("street_number", meter.street_num);
			entry.set("street_name", meter.streetname);
			entry.set("meter_id", meter.post_id);

			entry.save(null, {
				succss: function(entry){
					console.log("SAVED TO DB!");
					response.success(res.data[0].location);
				},
				error: function(entry, error){
					console.error("Failed to create new object, with error code: " + error.message);
					response.error("save did not work");
				}
			});

			
			// console.log(entry["activesens"]);
			// console.log(entry["on_off_str"]);
			// console.log(entry["sfparkarea"]);
			// console.log(entry["location"]["longitude"]);
			// console.log(entry["ratearea"]);
			// console.log(entry["street_num"]);
			// console.log(entry["street_seg"]);
			// console.log(entry["ms_id"]);
			// console.log(entry["cap_color"]);
			// console.log(entry["post_id"]);
			// console.log(entry["smart_mete"]);
			// console.log(entry["meter_type"]);
			// console.log(entry["jurisdicti"]);
			// console.log(entry["osp_id"]);
			// console.log(entry["ms_spaceid"]);
			// console.log(entry["streetname"]);
			
		},
		error: function(res){
			console.error("request failed with response code: " + res.status);
			response.error("bad");
		}
	});
});

Parse.Cloud.define("test", function(request, response){
	var test = require("cloud/test.js");
	var val = test.isACoolName('Ralph');
	response.success(val);
});


//from http://stackoverflow.com/questions/247483/http-get-request-in-javascript
// function httpGet(theUrl)
// {
//     var xmlHttp = null;

//     xmlHttp = new XMLHttpRequest();
//     xmlHttp.open( "GET", theUrl, false );
//     xmlHttp.send( null );
//     return xmlHttp.responseText;
// }
