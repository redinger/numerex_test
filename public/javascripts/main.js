var gmap;
var prevSelectedRow;
var prevSelectedRowClass;
var currSelectedDeviceId;
var iconALL;
var dev_id;
var devices = []; // JS devices model
var readings = []; //JS readings model
var zoom = 3;
var fullScreenMap = false;
var grp_id;
var infowindow;
var new_drag_point;
var zoom_val = get_cookie("zvalue");
function load() 
{
  if (GBrowserIsCompatible()) {
  	gmap = new GMap2(document.getElementById("map"));
    gmap.addControl(new GLargeMapControl());
    gmap.addControl(new GMapTypeControl());
    gmap.setCenter(new GLatLng(37.0625, -95.677068), zoom);
	
	iconALL = new GIcon();
	
	
   // iconALL.image = "/icons/ublip_marker.png";
    iconALL.shadow = "/images/ublip_marker_shadow.png";
    iconALL.iconSize = new GSize(23, 34);
    iconALL.iconAnchor = new GPoint(11, 34);
    iconALL.infoWindowAnchor = new GPoint(11, 34);
	
	var infoWin = gmap.getInfoWindow();
    

	// Detect when info window is closed
	GEvent.addListener(infoWin, "closeclick", function() {
        dev_id=false;
		if(prevSelectedRow)
			highlightRow(0);
	});
	
	GEvent.addListener(gmap, "click", function(marker, point) {               
		if (marker) {
	    	highlightRow(marker.id);
	  	}
	});
    
	GEvent.addListener(gmap, "moveend", function(marker, point) {                     
       new_drag_point = gmap.getCenter();
	});
    
	GEvent.addListener(gmap, "dragend", function(marker, point) {              
       new_drag_point = gmap.getCenter();              
	});
    
	var page = document.location.href.split("/")[3];
	GEvent.addListener(gmap, "zoomend", function(oldZoom, newZoom) {        
		zoom = newZoom; 
        if(page == 'reports')        
          set_cookie("zvalue",zoom);        
        new_drag_point =  gmap.getCenter();         
	});
	
    
	// Only load this on home page
	var page = document.location.href.split("/")[3];            
	if(page == 'home' || page == 'admin' ||page=='devices')
        getRecentReadings(true,grp_id);                
	else if(page == 'reports' )
		getReportBreadcrumbs();
	else 
		getBreadcrumbs(device_id);
	
  }
}

function set_cookie ( name, value, exp_y, exp_m, exp_d, path, domain, secure )
{
  var cookie_string = name + "=" + escape ( value );

  if ( exp_y )
  {
    var expires = new Date ( exp_y, exp_m, exp_d );
    cookie_string += "; expires=" + expires.toGMTString();
  }
  cookie_string += "; path=/" ;
  document.cookie = cookie_string;
}

function get_cookie ( cookie_name )
{
  var results = document.cookie.match ( '(^|;) ?' + cookie_name + '=([^;]*)(;|$)' );  
  if ( results )
    return ( unescape ( results[2] ) );
  else
    return null;
}

if (parseInt(zoom_val) > 0)
{var zoom= parseInt(zoom_val);}
else
{var zoom= 15;}

// Display all devices on overview page
function getRecentReadings(redrawMap,id) {     
     grp_id =  id ;
	$("updating").style.visibility = 'visible';
    var bounds = new GLatLngBounds();
    var temp ;
    var no_data_flag=false;      
    
      temp="/readings/recent/" + id 
      
    GDownloadUrl(temp, function(data, responseCode) {
		devices = [];
		gmap.clearOverlays();
        var xml = GXml.parse(data);
		var ids = xml.documentElement.getElementsByTagName("id");
		var names = xml.documentElement.getElementsByTagName("name");
        var lats = xml.documentElement.getElementsByTagName("lat");
        var lngs = xml.documentElement.getElementsByTagName("lng");
		var dts = xml.documentElement.getElementsByTagName("dt");
		var addresses = xml.documentElement.getElementsByTagName("address");
		var statuses = xml.documentElement.getElementsByTagName("status");
		var notes = xml.documentElement.getElementsByTagName("note");
		var icon_id = xml.documentElement.getElementsByTagName("icon_id");		        
		for(var i = 0; i < lats.length; i++) {              
			if(lats[i].firstChild) {
                 if (lats[i].firstChild != null)
                 {
                    no_data_flag = true;
                 }
				// Check for existence of address
				var address = "N/A";
				if(addresses[i].firstChild != undefined)
					address = addresses[i].firstChild.nodeValue;
					
			 // check for the group image
			
			 var icon_id_1
			  if(icon_id[i].firstChild != undefined)
					icon_id_1 = icon_id[i].firstChild.nodeValue;
				  
                     if (icon_id_1 == 1)
                   iconALL.image=" /icons/ublip_marker.png" ;
                   else if (icon_id_1 == 2)
                   iconALL.image=" /icons/ublip_red.png" ;
                  else if (icon_id_1 == 3)
                   iconALL.image=" /icons/green_big.png" ;
                    else if (icon_id_1 == 4)
                   iconALL.image="/icons/yellow_big.png" ;
                    else if (icon_id_1 == 5)
                   iconALL.image="/icons/purple_big.png" ;
                     else if (icon_id_1 == 6)
                   iconALL.image="/icons/dark_blue_big.png" ;
                    else if (icon_id_1 == 7)
                   iconALL.image="/icons/grey_big.png" ;
                    else if (icon_id_1 == 8)
                   iconALL.image="/icons/orange_big.png" ;
                    else
                    
                    iconALL.image = "/icons/ublip_marker.png";
			  
				// Check for existence of note
				var note = '';
				if(notes[i].firstChild != undefined)
					note = notes[i].firstChild.nodeValue;
					
				var device = {id: ids[i].firstChild.nodeValue, name: names[i].firstChild.nodeValue, lat: lats[i].firstChild.nodeValue, lng: lngs[i].firstChild.nodeValue, address: address, dt: dts[i].firstChild.nodeValue, note: note, status: statuses[i].firstChild.nodeValue};
				devices.push(device);                
                 
				// Populate the table
              if (frm_index)
              {
				var row = $("row" + device.id);
                                if (row && row.getElementsByTagName) {
				  var tds = row.getElementsByTagName("td");                
				  tds[2].innerHTML = device.address;
				  if (tds.length == 4)
				  	{                     
                     tds[3].innerHTML = device.dt;                                                                
                     }
				  else
				  {                    
				  	tds[3].innerHTML = device.status;
					  tds[4].innerHTML = device.dt;
				  }                  
                 if (tds[1].innerHTML==tds[2].innerHTML)
                  {
                    tds[2].innerHTML = device.status;
                    tds[3].innerHTML = device.dt
                  }
                }   
              }	
		          var point = new GLatLng(device.lat, device.lng);                
				gmap.addOverlay(createMarker(device.id, point, iconALL, createDeviceHtml(device.id)));
		        bounds.extend(point);
			}
		}
		
		$("updating").style.visibility = 'hidden';
		
		// Don't continue if there's no data
		if (ids.length == 0)
        {
          if (new_drag_point)
            gmap.setCenter(new_drag_point, zoom);
          else
            gmap.setCenter(new GLatLng(37.0625, -95.677068), 3);
          
          return;        
        }
        
         if (no_data_flag)
         { 
            if(redrawMap == undefined || redrawMap == true) {      
                // If there's only one device let's not zoom all the way in
                var zl = (devices.length > 1) ? gmap.getBoundsZoomLevel(bounds) : 15;
                if (dev_id){                  
                	var device = getDeviceById(dev_id);
                    if (new_drag_point)
                      var point = new_drag_point;
                    else
	                  var point = new GLatLng(device.lat, device.lng);
                      
                     gmap.setCenter(point, zoom);			                                          
                     centerMap(dev_id);                                           
                 }
                else
                 {
                   if (new_drag_point)                     
                     gmap.setCenter(new_drag_point, zoom);	
                   else
                     gmap.setCenter(bounds.getCenter(), zl);			
                 }
            } else {
                // Do the AJAXY update
                if (new_drag_point)
                gmap.setCenter(new_drag_point, zoom);
                else
                gmap.setCenter(gmap.getCenter(), zoom);
            }
         }
         else
         {
            if (new_drag_point)
            gmap.setCenter(new_drag_point, 3);
            else
            gmap.setCenter(new GLatLng(37.0625, -95.677068), 3);
         }   
		// Hide the action panel
		// document.getElementById("action_panel").style.visibility = "hidden";
    });
}

// Center map on device and show details
function centerMap(id) {    
    dev_id = id;
	var device = getDeviceById(id);    
    if (new_drag_point)
      var point = new_drag_point; 
    else    
     var point = new GLatLng(device.lat, device.lng);   
     
    gmap.panTo(point);       
    gmap.openInfoWindowHtml(new GLatLng(device.lat, device.lng), createDeviceHtml(id));
    
}

// Get a device object based on id
function getDeviceById(id) {
	for(var i=0; i < devices.length; i++) {
		var device = devices[i];
		if(device.id == id)
			return device;
	}
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

// Center map on reading and show details
function centerMapOnReading(id) {    
	var reading = getReadingById(id);
	var point = new GLatLng(reading.lat, reading.lng);
	gmap.panTo(point);
	gmap.openInfoWindowHtml(point, createReadingHtml(id));
}

// Get a reading based on id
function getReadingById(id) {
	for(var i=0; i < readings.length; i++) {
		var reading = readings[i];
		if(reading.id == id)
			return reading;
	}
}

// Create html for selected reading
function createReadingHtml(id) {
	var reading = getReadingById(id);
	var html = '<div class="dark_grey"><span class="blue_bold">' + reading.address + '<br />' + reading.dt + '</span><br />';
			
	if(reading.note != '')
		html += '<br /><strong>Note:</strong> ' + reading.note + '<br/>';
		
	return html;
}

// When a device is selected let's highlight the row and deselect the current
// Pass 0 to deselect all
function highlightRow(id) {
	if(id == undefined)
		return;
		
	var row = document.getElementById("row"+id);
	
	// Set the previous state back to normal
	if(prevSelectedRow) {
		prevSelectedRow.className = prevSelectedRowClass;
	}
	
	// An id of 0 deselects all
	if(id > 0) {        
		prevSelectedRow = row;
		prevSelectedRowClass = row.className;
		
		// Hihlight the current row
		row.className = 'selected_row';
	}
}

// Breadcrumb view for reports pages - client reports model is already populated
function getReportBreadcrumbs() {
	for(var i = 0; i < readings.length; i++) {
		var id = readings[i].id;
		var point = new GLatLng(readings[i].lat, readings[i].lng);
		
		gmap.addOverlay(createMarker(id, point, getMarkerType(i, readings[i]), createReadingHtml(id)));
		
		if(i == 0) {
			gmap.setCenter(point, zoom);
			gmap.openInfoWindowHtml(point, createReadingHtml(id));
			highlightRow(id);
		}
	}
	
	// Display geofences if viewing geofence reports
	if(document.location.href.split("/")[4] == 'geofence' && geofences.length) {
		for(var i = 0; i < geofences.length; i++) {
			var bounds = geofences[i].bounds.split(',');
			var point = new GLatLng(parseFloat(bounds[0]), parseFloat(bounds[1]));
			drawGeofence(point, parseFloat(bounds[2]));
		}
	}
}

// Determines which icon to display based on event or display numbered icon
function getMarkerType(index, obj) {
	var event = obj.event;
	var speed = obj.speed;
	var icon = new GIcon();	
	icon.iconSize = new GSize(23, 34);
	icon.iconAnchor = new GPoint(11, 34);
	icon.infoWindowAnchor = new GPoint(11, 34);
    icon.shadow = "/images/ublip_marker_shadow.png";
	
	if(event.indexOf('geofen') > -1 || event.indexOf('stop') > -1) {
		icon.image = "/icons/" + (index+1) + "_red.png";
	} else {
	    icon.image = "/icons/" + (index+1) + ".png";
	}
	
	return icon;
}

// Breadcrumb view for device details/history
function getBreadcrumbs(id) {
	GDownloadUrl("/readings/last/" + id, function(data, responseCode) 
	{
		var xml = GXml.parse(data);
		var ids = xml.documentElement.getElementsByTagName("id");
		var lats = xml.documentElement.getElementsByTagName("lat");
		var lngs = xml.documentElement.getElementsByTagName("lng");
		var alts = xml.documentElement.getElementsByTagName("alt");
		var spds = xml.documentElement.getElementsByTagName("spd");
		var dirs = xml.documentElement.getElementsByTagName("dir");
		var dts = xml.documentElement.getElementsByTagName("dt");
		var addresses = xml.documentElement.getElementsByTagName("address");
		var events = xml.documentElement.getElementsByTagName("event_type");
		var notes = xml.documentElement.getElementsByTagName("note");
				
		for(var i = lats.length-1; i >= 0; i--) {
			if(lats[i].firstChild) {
				// Check for existence of address
				var address = "N/A";
				if(addresses[i].firstChild != undefined)
					address = addresses[i].firstChild.nodeValue;
					
				// Check for existence of note
				var note = '';
				if(notes[i].firstChild != undefined)
					note = notes[i].firstChild.nodeValue;
					
				var speed = spds[i].firstChild.nodeValue;
				var event = events[i].firstChild.nodeValue;
				var reading = {id: ids[i].firstChild.nodeValue, lat: lats[i].firstChild.nodeValue, lng: lngs[i].firstChild.nodeValue, address: address, dt: dts[i].firstChild.nodeValue, note: note, event: event};
				readings.push(reading);
		        var point = new GLatLng(reading.lat, reading.lng);
				
				// Different icon types
				var icon = getMarkerType(i, reading);
				
				if(i == 0) {
					gmap.addOverlay(createMarker(reading.id, point, recenticon, createReadingHtml(reading.id)));
					gmap.setCenter(point, zoom);
					gmap.openInfoWindowHtml(point, createReadingHtml(reading.id));
					highlightRow(reading.id);
				} else {
					gmap.addOverlay(createMarker(reading.id, point, icon, createReadingHtml(reading.id)));
				}
			}
		}
		
		/*iconcount = 2;
	
		for(var i = 0; i < lats.length; i++) {
        	var point = new GLatLng(lats[i].firstChild.nodeValue, lngs[i].firstChild.nodeValue);

			if(notes[i].childNodes.length != 0)
			{	
				gnote = notes[i].firstChild.nodeValue;
			}
			else
			{
				gnote = ""
			}
    
	     	if(i == 0)
		 	 	{ 
					
				gmap.setCenter(point, 13);
  
			 	gmap.addOverlay(createNow(point, alts[i].firstChild.nodeValue, spds[i].firstChild.nodeValue, dirs[i].firstChild.nodeValue, times[i].firstChild.nodeValue, event_type[i].firstChild.nodeValue, gnote));
				gmap.openInfoWindowHtml(point, "Latitude: " + point.lat() + "<br/>" + "Longitude: " + point.lng()+ "<br/>" + "Speed: " + (spds[0].firstChild.nodeValue/10)*1.15 + "<br/>" + "Altitude: " + alts[0].firstChild.nodeValue + "<br/>" + "Time: " + times[0].firstChild.nodeValue + "<br/>" + gnote);
				}
			else
				{
				gmap.addOverlay(createPast(point, event_type[i].firstChild.nodeValue, spds[i].firstChild.nodeValue));
				gmap.addOverlay(createArrow(point, alts[i].firstChild.nodeValue, spds[i].firstChild.nodeValue, dirs[i].firstChild.nodeValue/10, times[i].firstChild.nodeValue, gnote, event_type[i].firstChild.nodeValue)); //dividing by ten till middleware issue is fixed.
			
				iconcount++;
				}
	    }*/
	});
}
		
function createArrow(dir) {
	var iconDir;
	var icon;
	
	if(spd == 0 || event_type == "exitgeofen_et51" || event_type == "entergeofen_et11") {
		icondir = "none"	
	} else if(dir >= 337.5 || dir < 22.5) {
		icondir = "n";
	} else if(dir >= 22.5 && dir < 67.5) {
		icondir = "ne";
	} else if(dir >= 67.5 && dir < 112.5) {
		icondir = "e";
	} else if(dir >= 112.5 && dir < 157.5) {
		icondir = "se";
	} else if(dir >= 157.5 && dir < 202.5) {
		icondir = "s";
	} else if(dir >= 202.5 && dir < 247.5) {
		icondir = "sw";
	} else if(dir >= 247.5 && dir < 292.5) {
		icondir = "w";
	} else if(dir >= 292.5 && dir < 337.5) {
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
		
function createPast(point, event_type, spd) 
		{   
				
		iconNow = new GIcon();
   		iconNow.image = "/icons/" + iconcount + ".png";
   		iconNow.shadow = "/images/ublip_marker_shadow.png";
    	iconNow.iconSize = new GSize(22, 35);
    	iconNow.iconAnchor = new GPoint(11, 34);
    	iconNow.infoWindowAnchor = new GPoint(15, 0);
		
		var marker;
		
		if(event_type == "exitgeofen_et51" || event_type == "entergeofen_et11")
			{
			marker = new GMarker(point, alarmIcon);	
			}
			
		else if (spd == 0)	
			{
			marker = new GMarker(point, ParkedIcon);
			}	
				
		else
			{
			marker = new GMarker(point, iconNow);
			}	

        return marker;
		
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


// Toggle between full map view or split table/map view
function toggleMap() {
	var left = document.getElementById("left_panel");
	var right = document.getElementById("right_panel");
	var img = document.getElementById("toggler");
	var isIE = navigator.appName.indexOf("Microsoft Internet Explorer");
	
	if(fullScreenMap) { // Collapse map and display table
		left.style.visibility = 'visible';
		left.style.display = 'block';
		if(isIE > -1)
			left.width = "50%";
		else
			left.width = "100%";
		right.width = "50%";
		img.src = "/images/collapse.png";
		img.parentNode.title = "Expand map view";
		fullScreenMap = false;
	} else { // Expand map
		left.style.visibility = 'hidden';
		left.style.display = 'none';
		right.width = "100%";
		img.src = "/images/expand.png";
		img.parentNode.title = "Collapse map view";
		fullScreenMap = true;
	}
	
	gmap.checkResize();
}




