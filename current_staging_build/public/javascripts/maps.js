var map;
var gmap;
var base_url = 'http://localhost:3000/'
var service_url = base_url + 'devices/';
var utils_url = base_url + 'utils/';
var devices = [];

function setMap(pos) {
	map = document.getElementById("map");
	map.style.left = pos.x + 'px';
	map.style.top = pos.y + 'px';
	map.style.width = pos.w + 'px';
	map.style.height = pos.h + 'px';
}

function init() {
	if (GBrowserIsCompatible()) {	
		gmap = new GMap2(document.getElementById("map"));
		gmap.addControl(new GMapTypeControl());
		gmap.addControl(new GSmallMapControl(), new GControlPosition(G_ANCHOR_TOP_RIGHT, new GSize(10,30)));
		gmap.setCenter(new GLatLng(37.4419, -96.1419), 5);
		gmap.enableScrollWheelZoom();
		
		GEvent.addListener(gmap, "click", function(marker, point) {
			if(marker) {
				loadDeviceDetails(marker);
			}
		});
	}
}

function showMap(visible) {
	if(visible)
		map.style.visibility = "visible";
	else
		map.style.visibility = "hidden";
}

function addMarkers(markers) {
	var b = new GLatLngBounds();
	for(i=0; i < markers.length; i++) {
		var p = new GLatLng(markers[i].lat, markers[i].lng);
		var marker = new GMarker(p);
		marker.id  = markers[i].id;
		// Store a global reference to markers
		devices.push(marker);
		gmap.addOverlay(marker);
		b.extend(p);
	}
	gmap.setCenter(b.getCenter(), gmap.getBoundsZoomLevel(b));
}

function loadDeviceDetails(marker) {
	marker.openInfoWindowHtml('<div id="details"><img src="/images/loading.gif" /><p />loading...</div>');
	GDownloadUrl(service_url + marker.id + '.xml', function(data, responseCode) {
		var xml = GXml.parse(data);
		document.getElementById('details').innerHTML = formatDeviceDetails(xml);
	});
}

function formatDeviceDetails(xml) {
	var name = xml.getElementsByTagName('name')[0].firstChild.nodeValue;
	var lat = xml.getElementsByTagName('latitude')[0].firstChild.nodeValue;
	var lng = xml.getElementsByTagName('longitude')[0].firstChild.nodeValue;
	var imei = xml.getElementsByTagName('imei')[0].firstChild.nodeValue;
	var img = getYahooMapTile(lat, lng);
	
	//var html = name + '<br />' + lat + '<br />' + lng + '<br />' + imei + '<br /><img id="zoom" src="/images/spacer.gif" />';
	
	var html = '<table width="100%" id="details_table" border="1">';
	html += '<tr><td colspan="2" class="title">' + name + '</td></tr>';
	html += '<tr><td>Speed<br />Direction<br />GPIO</td><td width="150" align="center"><img id="zoom" /><br />(Lat: ' + lat + ', Lng:' + lng + ')</td></tr>';
	html += '</table>';
	
	return html;
}

function getYahooMapTile(lat, lng) {
	var url = utils_url + 'yahoo_tile?lat=' + lat + '&lng=' + lng;
	var img;
	
	GDownloadUrl(url, function(data, responseCode) {
		var xml = GXml.parse(data);
		img = xml.getElementsByTagName('Result')[0].firstChild.nodeValue;
		document.getElementById('zoom').src = img;
	});
	
	return img;
}

function centerMap(index) {
	for(var i=0; i < devices.length; i++) {
		if(devices[i].id == index) {
			loadDeviceDetails(devices[i]);
			return;
		}
	}
}

window.onUnload = GUnload;
