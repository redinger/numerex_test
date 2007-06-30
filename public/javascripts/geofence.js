var gmap;
var map;

function load() {
	if (GBrowserIsCompatible()) {
		map = document.getElementById("map");
	    gmap = new GMap2(map);
	    gmap.addControl(new GLargeMapControl());
	    gmap.addControl(new GMapTypeControl());
	    gmap.setCenter(new GLatLng(37.4419, -122.1419), 9);
	}
}

// Convert address to lat/lng
function geocode(address)
{
	var geocoder = new GClientGeocoder();

	geocoder.getLatLng(
    	address,
		function(point) {
      		if (!point) {
        		alert(address + " cannot be located.");
      		} else {
				gmap.clearOverlays();
        		gmap.setCenter(point, 9);
        		//var marker = new GMarker(point);
        		//map.addOverlay(marker);
        		gmap.openInfoWindowHtml(point, address);
				
				// Draw the fence
				var r = document.getElementById("radius")[document.getElementById("radius").selectedIndex].value;
				drawCircle(point, r);
				
				/* Save the fence to the database
				var name = document.getElementById("geofence_form").geofence_name.value;
				GDownloadUrl("/geofence/save_geofence?perimeter=" + point.lat() + "," + point.lng() + "," + r + "&device_id=1&name=" + name);
				
				document.getElementById("geofence").innerHTML = prevHTML;
				
				document.getElementById("geofence_select").options[1] = new Option(name);
				document.getElementById("geofence_select").selectedIndex = 1;*/
				
      		}
    	}
  	);
}

function drawCircle(p, r) {
	var cColor = "#3366ff";
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