//File containing all background jobs

exports.putMeterDataFromURL = function(url, request, response){
	var ParkingMeter = Parse.Object.extend("ParkingMeter");
	Parse.Cloud.httpRequest({
		url: url,
		success: function(res){
			var data = res.data;

			//Every possible key from original data
			// activesens
			// on_off_str
			// sfparkarea
			// location
			// ratearea
			// street_num
			// street_seg
			// ms_id
			// cap_color
			// post_id
			// smart_mete
			// meter_type
			// jurisdicti
			// osp_id
			// ms_spaceid
			// streetname

			for(var i = 0; i < data.length; i++){
				var entry = new ParkingMeter();
				var meter = data[i];
				var streetname = meter["streetname"];
				var location = meter["location"];
				var geopoint = new Parse.GeoPoint(parseFloat(location.latitude), parseFloat(location.longitude));

				entry.set("has_active_sensor", meter.activesens);
				entry.set("is_smart_meter", meter.smart_mete);
				entry.set("location", geopoint);
				entry.set("on_off_street", meter.on_off_str);
				entry.set("street_number", meter.street_num);
				entry.set("street_name", meter.streetname);
				entry.set("meter_id", meter.post_id);

				// console.log("Sending entry " + i + " to DB");
				entry.save(null, {
					success: function(entry){
						console.log("SAVED TO DB!");
					},
					error: function(entry, error){
						console.error("Failed to create new object, with error code: " + error.message);
						response.error("save did not work");
					}
				});
			}
			response.success("saved all entries to DB");
		},
		error: function(res){
			console.error("request to meter url failed with response code: " + res.status);
			response.error("request to meter url failed with response code: " + res.status);
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