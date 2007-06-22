var gmap;
var icon;
var recenticon;
var iconcount = 2;

                
function load() {
  if (GBrowserIsCompatible()) {
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
	
  }
}

window.onresize = resize;

function resize() {
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
			if(lats[i].firstChild.nodeValue != 0) {
		        var point = new GLatLng(lats[i].firstChild.nodeValue, lngs[i].firstChild.nodeValue);
		        gmap.addOverlay(new GMarker(point, icon));
		        bounds.extend(point)
			}
        }
		
        gmap.setCenter(bounds.getCenter(), gmap.getBoundsZoomLevel(bounds)-1); 
    });
}

function getBreadcrumbs(id) {
	var bounds = new GLatLngBounds();
	GDownloadUrl("/readings/last/" + id, function(data, responseCode) {
		var xml = GXml.parse(data);
		var lats = xml.documentElement.getElementsByTagName("latitude");
		var lngs = xml.documentElement.getElementsByTagName("longitude");
		gmap.clearOverlays();
			
		for(var i = 0; i < lats.length; i++) {
        	var point = new GLatLng(lats[i].firstChild.nodeValue, lngs[i].firstChild.nodeValue);
         	bounds.extend(point)
         
         	if(i == 0) {
            	gmap.setCenter(point, 13);
			 	gmap.addOverlay(new GMarker(point, recenticon));
			} else {
				icon = new GIcon();
   				icon.image = "/icons/" + iconcount + ".png";
   				icon.shadow = "/images/ublip_marker_shadow.png";
    			icon.iconSize = new GSize(22, 35);
    			icon.iconAnchor = new GPoint(11, 34);
    			icon.infoWindowAnchor = new GPoint(15, 0);
				
				gmap.addOverlay(new GMarker(point, icon));
				iconcount++;
			}
        }

		var zoom = gmap.getBoundsZoomLevel(bounds);
		if(zoom > 15)
			zoom = 15;
		
		gmap.setZoom(zoom); 


	});
}
