var gmap;
var iconNow;
var alarmIcon;
var recenticon;
var iconcount = 2;
var prevSelectedRow;
var prevSelectedRowClass;
var currSelectedDeviceId;
var defaultEventType = "normal_et2";

            
function load() 
{
  if (GBrowserIsCompatible()) {
  	gmap = new GMap2(document.getElementById("map"));
    gmap.addControl(new GLargeMapControl());
    gmap.addControl(new GMapTypeControl());
    gmap.setCenter(new GLatLng(37.4419, -122.1419), 13);
    getRecentReadings();
	
	recenticon = new GIcon();
    recenticon.image = "/icons/1.png";
    recenticon.shadow = "/images/ublip_marker_shadow.png";
    recenticon.iconSize = new GSize(22, 35);
    recenticon.iconAnchor = new GPoint(11, 34);
    recenticon.infoWindowAnchor = new GPoint(15, 0);		
	
	iconALL = new GIcon();
    iconALL.image = "/icons/ublip_marker.png";
    iconALL.shadow = "/images/ublip_marker_shadow.png";
    iconALL.iconSize = new GSize(23, 34);
    iconALL.iconAnchor = new GPoint(11, 34);
    iconALL.infoWindowAnchor = new GPoint(15, 0);
	
	// Displayed for exceptions
	alarmIcon = new GIcon();
    alarmIcon.image = "/icons/ublip_red.png";
    alarmIcon.shadow = "/images/ublip_marker_shadow.png";
    alarmIcon.iconSize = new GSize(23, 34);
    alarmIcon.iconAnchor = new GPoint(11, 34);
    alarmIcon.infoWindowAnchor = new GPoint(15, 0);
  }
}

window.onresize = resize;

function resize() {
    /*var myWidth, myHeight;
    if( typeof( window.innerWidth ) == 'number' ) {
        //Non-IE
        myWidth = window.innerWidth;
        myHeight = window.innerHeight;
    } else if( document.documentElement && ( document.documentElement.clientWidth || document.documentElement.clientHeight ) ) {
        //IE 6+ in 'standards compliant mode'
        myWidth = document.documentElement.clientWidth;
        myHeight = document.documentElement.clientHeight;
    } else if( document.body && ( document.body.clientWidth || document.body.clientHeight ) ) {
        //IE 4 compatible
        myWidth = document.body.clientWidth;
        myHeight = document.body.clientHeight;
    }
    
    var hoffset = 75+50;
    var main = document.getElementById("main_container");
    var map = document.getElementById("map");
    
    main.style.height = (myHeight-hoffset) + 'px';
    map.style.height = (myHeight-hoffset-20) + 'px';
    map.style.width = (myWidth-230) + 'px'; */
    
    gmap.checkResize();
}

function getRecentReadings() {
	gmap.clearOverlays();
    var bounds = new GLatLngBounds();
    GDownloadUrl("/readings/recent", function(data, responseCode) {
        var xml = GXml.parse(data);
        var lats = xml.documentElement.getElementsByTagName("lat");
        var lngs = xml.documentElement.getElementsByTagName("lng");
		
	for(var i = 0; i < lats.length; i++) {
        	var point = new GLatLng(lats[i].firstChild.nodeValue, lngs[i].firstChild.nodeValue);
         	bounds.extend(point)
			var names = xml.documentElement.getElementsByTagName("name");
			
			

			
         	if(i == 0)
		 	 	{ 	
				gmap.setCenter(point, 13);
			 	gmap.addOverlay(createDisplayAll(point, names[i].firstChild.nodeValue));
				gmap.openInfoWindowHtml(point, "Device Id: " + names[0].firstChild.nodeValue + "<br/>" + "Latitude: " + point.lat() + "<br/>" + "Longitude: " + point.lng());
				}
			else
				{
				gmap.addOverlay(createDisplayAll(point, names[i].firstChild.nodeValue));
				}
	    }
		
        gmap.setCenter(bounds.getCenter(), gmap.getBoundsZoomLevel(bounds)-1); 
		
		// Hide the View All link and change the device_name text
		document.getElementById("device_name").innerHTML = "All Devices";
		document.getElementById("view_all_link").style.visibility = "hidden";
		// Deselect highlighted row
		if(prevSelectedRow != undefined)
			prevSelectedRow.className = prevSelectedRowClass;
			
		// Hide the action panel
		document.getElementById("action_panel").style.visibility = "hidden";
    });
}

function getBreadcrumbs(id, name) {
	var bounds = new GLatLngBounds();
	GDownloadUrl("/readings/last/" + id, function(data, responseCode) 
	{
		var xml = GXml.parse(data);
		var lats = xml.documentElement.getElementsByTagName("latitude");
		var lngs = xml.documentElement.getElementsByTagName("longitude");
		var alts = xml.documentElement.getElementsByTagName("altitude");
		var spds = xml.documentElement.getElementsByTagName("speed");
		var dirs = xml.documentElement.getElementsByTagName("direction");
		var times = xml.documentElement.getElementsByTagName("created-at");
		var event_type = xml.documentElement.getElementsByTagName("event-type");
		var notes = xml.documentElement.getElementsByTagName("note");
				
		gmap.clearOverlays();
		
		iconcount = 2;
		
	
		
		for(var i = 0; i < lats.length; i++) {
        	var point = new GLatLng(lats[i].firstChild.nodeValue, lngs[i].firstChild.nodeValue);
         	bounds.extend(point)
			
			if (notes.firstChild)
  				{ 
				note = notes[i].firstChild.nodeValue ;
				}
				else
				{ 
				note = " ";
				}
    
	     	if(i == 0)
		 	 	{ 
					
				gmap.setCenter(point, 13);
  
			 	gmap.addOverlay(createNow(point, alts[i].firstChild.nodeValue, spds[i].firstChild.nodeValue, dirs[i].firstChild.nodeValue, times[i].firstChild.nodeValue, event_type[i].firstChild.nodeValue, note));
				gmap.openInfoWindowHtml(point, "Latitude: " + point.lat() + "<br/>" + "Longitude: " + point.lng()+ "<br/>" + "Speed: " + (spds[0].firstChild.nodeValue/10)*1.15 + "<br/>" + "Altitude: " + alts[0].firstChild.nodeValue + "<br/>" + "Time: " + times[0].firstChild.nodeValue + "<br/>" + note);
				}
			else
				{
				gmap.addOverlay(createPast(point, event_type[i].firstChild.nodeValue));
				gmap.addOverlay(createArrow(point, alts[i].firstChild.nodeValue, spds[i].firstChild.nodeValue, dirs[i].firstChild.nodeValue/10, times[i].firstChild.nodeValue, note)); //dividing by ten till middleware issue is fixed.
			
				iconcount++;
				}
	    }
    
		var zoom = gmap.getBoundsZoomLevel(bounds);
		if(zoom > 15)
			zoom = 15;
		gmap.setZoom(zoom); 
		
		// Update the name in the map panel and display the View All link
		document.getElementById("device_name").innerHTML = name;
		document.getElementById("view_all_link").style.visibility = "visible";
		// Highlight the table rows and save the old reference to revert back
		// Deselect highlighted row
		if(prevSelectedRow != undefined)
			prevSelectedRow.className = prevSelectedRowClass;
			
		var currRow = document.getElementById("row"+id);
		prevSelectedRow = currRow;
		prevSelectedRowClass = currRow.className;
		currRow.className = "selected_row";
		
		// Save a global reference to device id
		currSelectedDeviceId = id;
		// Display the action panel
		document.getElementById("action_panel").style.visibility = "visible";
	});
}
		
	function createNow(point, alt, spd, dir, time, event_type, note) { 
	   
   		var marker;
		
		if (alt == "")
			{
				alt = "unknown";
			}
			
		if(event_type == defaultEventType)
			marker = new GMarker(point, recenticon);
			
		else if(event_type == "DEFAULT")
			marker = new GMarker(point, recenticon);
			
		else
			marker = new GMarker(point, alarmIcon);
			
		GEvent.addListener(marker, "click", function() 
			{
        	marker.openInfoWindowHtml("Latitude: " + point.lat() + "<br/>" + "Longitude: " + point.lng()+ "<br/>" + "Speed: " + (spd/10)*1.15 + "<br/>" + "Altitude: " + alt + "<br/>" + "Time: " + time + "<br/>" + note);
        	});
		
        return marker;
		}
	
	function createArrow(point, alt, spd, dir, time, note) {
		
		if (alt == "")
			{
				alt = "unknown";
			}   
		
		if(dir >= 337.5 || dir < 22.5)
				{
					icondir = "n";
				}
				else if(dir >= 22.5 && dir < 67.5)
				{
					icondir = "ne";
				}
				else if(dir >= 67.5 && dir < 112.5)
				{
					icondir = "e";
				}
				else if(dir >= 112.5 && dir < 157.5)
				{
					icondir = "se";
				}
				else if(dir >= 157.5 && dir < 202.5)
				{
					icondir = "s";
				}
				else if(dir >= 202.5 && dir < 247.5)
				{
					icondir = "sw";
				}
				else if(dir >= 247.5 && dir < 292.5)
				{
					icondir = "w";
				}
				else if(dir >= 292.5 && dir < 337.5)
				{
					icondir = "nw";
				}
		
		iconArrow = new GIcon();
   		iconArrow.image = "/icons/arrows/" + icondir + ".png";
   		iconArrow.iconSize = new GSize(45, 45);
    	iconArrow.iconAnchor = new GPoint(22.5, 45);
    	iconArrow.infoWindowAnchor = new GPoint(15, 0);
				
		var arrow = new GMarker(point, iconArrow);
		
		GEvent.addListener(arrow, "click", function() 
			{
        	arrow.openInfoWindowHtml("Latitude: " + point.lat() + "<br/>" + "Longitude: " + point.lng()+ "<br/>" + "Speed: " + (spd/10)*1.15 + "<br/>" + "Altitude: " + alt + "<br/>" + "Time: " + time + "<br/>" + note);
			});
		
		return arrow;
		}	
		
function createPast(point, event_type) 
		{   
				
		iconNow = new GIcon();
   		iconNow.image = "/icons/" + iconcount + ".png";
   		iconNow.shadow = "/images/ublip_marker_shadow.png";
    	iconNow.iconSize = new GSize(22, 35);
    	iconNow.iconAnchor = new GPoint(11, 34);
    	iconNow.infoWindowAnchor = new GPoint(15, 0);
		
		var marker;
		
		if(event_type == defaultEventType)
			marker = new GMarker(point, iconNow);
		else 
			marker = new GMarker(point, alarmIcon);

        return marker;
		
		}	

	function createDisplayAll(point, name) 
		{   
					 
   		var marker = new GMarker(point, iconALL);
		
		GEvent.addListener(marker, "click", function() 
			{
        	marker.openInfoWindowHtml("Device Id: " + name + "<br/>" + "Latitude: " + point.lat() + "<br/>" + "Longitude: " + point.lng());
			
        	});
		
        return marker;
		}
		
// Goes to specified URL and appends id
function go(url) {
	document.location.href = url + '/' + currSelectedDeviceId;
}

// Generic function to create a marker with custom icon and html
function createMarker(point, icon, html) {
	var marker = new GMarker(point, icon);
	GEvent.addListener(marker, "click", function() {
		marker.openInfoWindowHtml(html);
		gmap.panTo(point);
	});
	return marker;
}