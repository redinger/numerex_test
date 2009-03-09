var gas_icon;

function getLocal(field, query) {
	if(field.checked) {
		var point = gmap.getCenter();
		var url = '/local/query?query=' + escape(query) + '&lat=' + point.lat() + '&lng=' + point.lng();
		
		if(gas_icon == undefined) {
			gas_icon = new GIcon();
			gas_icon.image = "/icons/gas.png";
    		gas_icon.iconSize = new GSize(34, 34);
    		gas_icon.iconAnchor = new GPoint(17, 34);
    		gas_icon.infoWindowAnchor = new GPoint(17, 0);
		}
		
		GDownloadUrl(url, function(data, responseCode){
			var xml =GXml.parse(data);
			var locations = xml.documentElement.getElementsByTagName("Result");
			
			for(var i=0; i < locations.length; i++) {
				var title = locations[i].getElementsByTagName("Title")[0].firstChild.nodeValue;
          		var address = locations[i].getElementsByTagName("Address")[0].firstChild.nodeValue;
				var city = locations[i].getElementsByTagName("City")[0].firstChild.nodeValue;
	          	var state = locations[i].getElementsByTagName("State")[0].firstChild.nodeValue;
	          	var lat = locations[i].getElementsByTagName("Latitude")[0].firstChild.nodeValue;
	          	var lng = locations[i].getElementsByTagName("Longitude")[0].firstChild.nodeValue;
	          	var distance = locations[i].getElementsByTagName("Distance")[0].firstChild.nodeValue;
				var html = "<strong>" + title + "</strong><br />" + address + "<br />" + city + "," + state + "<br />" + "Distance: " + distance + " miles";
				var point = new GLatLng(parseFloat(lat), parseFloat(lng));
				gmap.addOverlay(createMarker(point, gas_icon, html));
			}
		});
	}
}