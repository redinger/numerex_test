// Switch between devices on reports view but keep the timeframe, if it exists
function changeDevice(device_id, report_type) {
	
	document.location.href='/reports/' + report_type + '/' + device_id + '?t=' + getQryParam('t');
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