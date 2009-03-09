var devices = [];

function load() {
  if (GBrowserIsCompatible()) {
  	gmap = new GMap2(document.getElementById("map"));
    gmap.addControl(new GLargeMapControl());
    gmap.addControl(new GMapTypeControl());
    gmap.setCenter(new GLatLng(37.4419, -122.1419), 13);

	iconALL = new GIcon();
    iconALL.image = "/icons/ublip_marker.png";
    iconALL.shadow = "/images/ublip_marker_shadow.png";
    iconALL.iconSize = new GSize(23, 34);
    iconALL.iconAnchor = new GPoint(11, 34);
    iconALL.infoWindowAnchor = new GPoint(11, 34);
	
		var device_id = document.location.href.split("/")[5];
	
		if(device_id == undefined) {
			getRecentReadings('');
			setInterval("getRecentReadings('')", 30000);
		} else {
			getRecentReadings(device_id);
			setInterval("getRecentReadings('" + device_id + "')", 30000);
		}
	}
}

function getRecentReadings(device_id) {
    var bounds = new GLatLngBounds();
    GDownloadUrl("/readings/recent/" + device_id, function(data, responseCode) {
        var xml = GXml.parse(data);
		var ids = xml.documentElement.getElementsByTagName("id");
		var names = xml.documentElement.getElementsByTagName("name");
        var lats = xml.documentElement.getElementsByTagName("lat");
        var lngs = xml.documentElement.getElementsByTagName("lng");
		var dts = xml.documentElement.getElementsByTagName("dt");
		var addresses = xml.documentElement.getElementsByTagName("address");
		var notes = xml.documentElement.getElementsByTagName("note");
		
		gmap.clearOverlays();
		
		for(var i = 0; i < lats.length; i++) {
			if(lats[i].firstChild) {
				// Check for existence of address
				var address = "N/A";
				if(addresses[i].firstChild != undefined)
					address = addresses[i].firstChild.nodeValue;
					
				// Check for existence of note
				var note = '';
				if(notes[i].firstChild != undefined)
					note = notes[i].firstChild.nodeValue;
					
				var device = {id: ids[i].firstChild.nodeValue, name: names[i].firstChild.nodeValue, lat: lats[i].firstChild.nodeValue, lng: lngs[i].firstChild.nodeValue, address: address, dt: dts[i].firstChild.nodeValue, note: note};
				devices.push(device);
		        var point = new GLatLng(device.lat, device.lng);
				gmap.addOverlay(createMarker(device.id, point, iconALL, createDeviceHtml(device.id)));
		        bounds.extend(point)
			}
		}
		
        gmap.setCenter(bounds.getCenter(), gmap.getBoundsZoomLevel(bounds)); 
    });
}

// Generic function to create a marker with custom icon and html
function createMarker(id, point, icon, html) {
	var marker = new GMarker(point, icon);
	marker.id = id; // Assign a unique id to the marker
	GEvent.addListener(marker, "click", function() {
		marker.openInfoWindowHtml(html);
		gmap.panTo(point);
	});
	return marker;
}

// Create html for selected device
function createDeviceHtml(id) {
	var device = getDeviceById(id);
	
	var html = '<div class="dark_grey"><span class="blue_bold">' + device.name + '</span> was last seen at ' + '<br /><span class="blue_bold">' + device.address + '</span><br /><span class="blue_bold">' + device.dt + '</span><br />';
	
	if(device.note != '')
		html += '<br /><strong>Note:</strong> ' + device.note + '<br/>';
		
	html += '<br /><a href="javascript:gmap.setZoom(15);">Zoom in</a> | <a href="/reports/all/' + id + '">View details</a></div>';
	return html;
}

// Get a device object based on id
function getDeviceById(id) {
	for(var i=0; i < devices.length; i++) {
		var device = devices[i];
		if(device.id == id)
			return device;
	}
}