var gmap;
var iconNow;
var recenticon;
var iconcount = 2;

                
function load() 
{
  if (GBrowserIsCompatible()) 
  	{
    gmap = new GMap2(document.getElementById("map"));
    gmap.addControl(new GLargeMapControl());
    gmap.addControl(new GMapTypeControl());
    gmap.setCenter(new GLatLng(37.4419, -122.1419), 13);
    getRecentReadings();
    resize();
	
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
	
  	}
}

window.onresize = resize;

function resize() 
{
    var myWidth, myHeight;
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
    map.style.width = (myWidth-230) + 'px'; 
    
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
    });
}

function getBreadcrumbs(id) 
{
	var bounds = new GLatLngBounds();
	GDownloadUrl("/readings/last/" + id, function(data, responseCode) 
	{
		var xml = GXml.parse(data);
		var lats = xml.documentElement.getElementsByTagName("latitude");
		var lngs = xml.documentElement.getElementsByTagName("longitude");
		var alts = xml.documentElement.getElementsByTagName("altitude");
		var spds = xml.documentElement.getElementsByTagName("speed");
		var dirs = xml.documentElement.getElementsByTagName("direction");
		
		gmap.clearOverlays();
		
		iconcount = 2;
			
		for(var i = 0; i < lats.length; i++) {
        	var point = new GLatLng(lats[i].firstChild.nodeValue, lngs[i].firstChild.nodeValue);
         	bounds.extend(point)
			
         	if(i == 0)
		 	 	{ 	
				gmap.setCenter(point, 13);
			 	gmap.addOverlay(createNow(point, alts[i].firstChild.nodeValue, spds[i].firstChild.nodeValue, dirs[i].firstChild.nodeValue));
				gmap.openInfoWindowHtml(point, "Latitude: " + point.lat() + "<br/>" + "Longitude: " + point.lng()+ "<br/>" + "Direction: " + dirs[0].firstChild.nodeValue + "<br/>" + "Speed: " + spds[0].firstChild.nodeValue + "<br/>" + "Altitude: " + alts[0].firstChild.nodeValue);
				}
			else
				{
				gmap.addOverlay(createPast(point, alts[i].firstChild.nodeValue, spds[i].firstChild.nodeValue, dirs[i].firstChild.nodeValue));
				iconcount++;
				}
	    }
    

		var zoom = gmap.getBoundsZoomLevel(bounds);
		if(zoom > 15)
			zoom = 15;
		gmap.setZoom(zoom); 
	});
}
		
	function createNow(point, alt, spd, dir) 
		{    
   		var marker = new GMarker(point, recenticon);
		GEvent.addListener(marker, "click", function() 
			{
        	marker.openInfoWindowHtml("Latitude: " + point.lat() + "<br/>" + "Longitude: " + point.lng()+ "<br/>" + "Direction: " + dir + "<br/>" + "Speed: " + spd + "<br/>" + "Altitude: " + alt);
        	});
		
        return marker;
		}
	
	function createPast(point, alt, spd, dir) 
		{   
		iconNow = new GIcon();
   		iconNow.image = "/icons/" + iconcount + ".png";
   		iconNow.shadow = "/images/ublip_marker_shadow.png";
    	iconNow.iconSize = new GSize(22, 35);
    	iconNow.iconAnchor = new GPoint(11, 34);
    	iconNow.infoWindowAnchor = new GPoint(15, 0);
				 
   		var marker = new GMarker(point, iconNow);
		
		GEvent.addListener(marker, "click", function() 
			{
        	marker.openInfoWindowHtml("Latitude: " + point.lat() + "<br/>" + "Longitude: " + point.lng()+ "<br/>" + "Direction: " + dir + "<br/>" + "Speed: " + spd + "<br/>" + "Altitude: " + alt);
			iconcount++;
        	});
		
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






