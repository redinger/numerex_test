var gmap;
var map;
var localicon;
var zoom = 5;
var resultCount = 15;

function load()
{
   if (GBrowserIsCompatible())
	  {
	  
	  	map = document.getElementById("map");
      gmap = new GMap2(map);
		  gmap.addControl(new GOverviewMapControl());
		  gmap.addControl(new GLargeMapControl());
		  gmap.addControl(new GMapTypeControl());
      gmap.setCenter(new GLatLng(38.06539235133249, -97.294921875), zoom);
		
		GEvent.addListener(gmap, "zoomend", function(oldLevel, newLevel) {
			zoom = newLevel;
		});
alert ("doing sushi search");		
		    doSearch("sushi", "75214");
		}
}

function createMarker(point, html)
{
	
	localicon = new GIcon();
    localicon.image = "/icons/ublip_silver.png";
    localicon.shadow = "/images/ublip_marker_shadow.png";
    localicon.iconSize = new GSize(22, 35);
    localicon.iconAnchor = new GPoint(11, 34);
    recenticon.infoWindowAnchor = new GPoint(15, 0);
	
  		alert ("inside createMarker function");
		var marker = new GMarker(point, localicon);
			GEvent.addListener(marker, "click", function() {
			marker.openInfoWindowHtml(createMarkerText(html));
			gmap.panTo(point);
  		});
		return marker;
}

function createMarkerText(html)
{
	 return html;
}

function doSearch(query, zip)
{
    alert ("doing search");
	gmap.clearOverlays();
    
    GDownloadUrl("/local/query?query=" + query + "&zip=" + zip + "&resultCount=" + resultCount, function(data, responseCode) {
      alert ("search done starting parse");
	  var bounds = new GLatLngBounds();
			var xml = GXml.parse(data);
			var locations = xml.documentElement.getElementsByTagName("Result");
			alert ("parse done about to enter for loop" + locations.length); //here is the last spot I got to
			for(var i=0; i < locations.length; i++)
			{
				alert ("inside for loop");
          var title = locations[i].getElementsByTagName("Title")[0].firstChild.nodeValue;
          var address = locations[i].getElementsByTagName("Address")[0].firstChild.nodeValue;
          var city = locations[i].getElementsByTagName("City")[0].firstChild.nodeValue;
          var state = locations[i].getElementsByTagName("State")[0].firstChild.nodeValue;
          var lat = locations[i].getElementsByTagName("Latitude")[0].firstChild.nodeValue;
          var lng = locations[i].getElementsByTagName("Longitude")[0].firstChild.nodeValue;
          var distance = locations[i].getElementsByTagName("Distance")[0].firstChild.nodeValue;
          
          var html = "<strong>" + title + "</strong><br />" + address + "<br />" + city + "," + state + "<br />" + "Distance: " + distance + " miles" + "<br /><a href='#' class='link'>Blip this location</a>";
          
          var point = new GLatLng(parseFloat(lat), parseFloat(lng));
				  bounds.extend(point);
				 
				  gmap.addOverlay(createMarker(point, html));
				  
				  if(i == 0)
				  {
					   gmap.openInfoWindowHtml(point, html);
				  }
			}
		       // Recenter and zoom based on bounds
		       zoom = gmap.getBoundsZoomLevel(bounds);
          gmap.setCenter(bounds.getCenter(), zoom);
		});
}