// Switch between devices on reports view but keep the timeframe, if it exists
function changeDevice(device_id, report_type, start_date, end_date) {
	var url = '/reports/' + report_type + '/' + device_id;
	
	 url  =url+ "?end_date=" + end_date + "&start_date=" + start_date;	
     
	document.location.href= url;
}

// Get the value of a query parameter based on key
function getQryParam(key) {
	var qry = document.location.search.substring(1);
	var params = qry.split('&');
	
	for(var i=0; i<params.length; i++) {
		var index = params[i].indexOf('=');
		if(index > 0) {
			var paramkey = params[i].substring(0, index);
			var paramvalue = params[i].substring(index+1);
			if(key == paramkey)
				return paramvalue;
			
		}
	}
}

// Draw geofence - need to refactor with geofence.js
function drawGeofence(p, r) {
	var cColor = "#0066FF";
	var cWidth = 5;
	var Cradius = r;   
 	var d2r = Math.PI/180; 
 	var r2d = 180/Math.PI; 
 	var Clat = (Cradius/3963)*r2d; 
	var Clng = Clat/Math.cos(p.lat()*d2r); 
	var Cpoints = []; 
	
	for (var i=0; i < 33; i++)
	{ 
    	var theta = Math.PI * (i/16); 
    	var CPlng = p.lng() + (Clng * Math.cos(theta)); 
    	var CPlat = p.lat() + (Clat * Math.sin(theta)); 
    	var P = new GLatLng(CPlat,CPlng);
    	Cpoints.push(P); 
  	}
  
  	gmap.addOverlay(new GPolyline(Cpoints,cColor,cWidth)); 
}

function displayTripOverview(trip_id, marker) {
	
	// Handle the initial display of the map with the first trip
	if(trip_id == undefined)
		trip_id = readings[0].id;

	gmap.clearOverlays();
	
	highlightRow(trip_id);
	
	var bounds = new GLatLngBounds();
	
	var count = 0; // Use count to limit looping. Just grab the start/stop address for the trip and stop looping
	for(i=0; i < readings.length && count <= 1; i++) {
		
		var reading = readings[i];
		var point = new GLatLng(reading.lat, reading.lng);
		if(reading.id == trip_id) {
			if(reading.start) {
				gmap.addOverlay(createMarker(trip_id, point, getMarkerType(count, reading), createTripHtml(reading),count));
				bounds.extend(point);
				count++;
			} else if(reading.stop) {
				gmap.addOverlay(createMarker(trip_id, point, getMarkerType(count, reading), createTripHtml(reading),count));
				bounds.extend(point);
				count++;
			}
		}
	}
	
	gmap.setCenter(bounds.getCenter(), (gmap.getBoundsZoomLevel(bounds)-1));

}

// Create html for selected reading
function createTripHtml(reading) {
	var html = '<div class="dark_grey"><span class="blue_bold">' + reading.address + '<br />' + reading.dt + '</span><br />';
	html += '<br /><a href="/reports/trip_detail/' + reading.id + '">View trip details</a>'
	return html;
}



