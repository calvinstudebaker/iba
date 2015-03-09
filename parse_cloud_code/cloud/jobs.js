//File containing all background jobs, such as initial data injection

exports.putMeterDataFromURL = function(url, request, response){
	var ParkingMeter = Parse.Object.extend("ParkingMeter");

	console.log ("HERE");
	Parse.Cloud.httpRequest({
		url: url,
		success: function(res){
			var data = res.data;
			var entry = new ParkingMeter();
			
			var meter = data[0];
			var streetname = meter["streetname"];
			console.log(streetname);
			var location = meter["location"];
			var geopoint = new Parse.GeoPoint(parseFloat(location.latitude), parseFloat(location.longitude));


			entry.set("has_active_sensor", meter.activesens);
			entry.set("is_smart_meter", meter.smart_mete);
			entry.set("location", geopoint);
			entry.set("on_off_street", meter.on_off_str);
			entry.set("street_number", meter.street_num);
			entry.set("street_name", meter.streetname);
			entry.set("meter_id", meter.post_id);

			console.log("Sending entry to DB");
			entry.save(null, {
				success: function(entry){
					console.log("SAVED TO DB!");
					response.success("saved");
				},
				error: function(entry, error){
					console.error("Failed to create new object, with error code: " + error.message);
					response.error("save did not work");
				}
			});
			
			//Every possible key
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
};

exports.putCrimeDataFromURL = function(url, request, response){
	var Crime = Parse.Object.extend("Crime");
	Parse.Cloud.httpRequest({
		url: url,
		success: function(res){
			var data = res.data;
			var entry = new Crime();
			
			var crime = data[0];

			
			

			console.log("Sending entry to DB");
			entry.save(null, {
				success: function(entry){
					console.log("SAVED TO DB!");
					response.success("saved");
				},
				error: function(entry, error){
					console.error("Failed to create new object, with error code: " + error.message);
					response.error("save did not work");
				}
			});
			
		},
		error: function(res){
			console.error("request failed with response code: " + res.status);
			response.error("bad");
		}
	});
}