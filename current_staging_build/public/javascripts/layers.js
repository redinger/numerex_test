var traffic;

function toggleLayer(field, layer_name) {
	// Layer on
	if(field.checked) {
		if(layer_name == 'traffic') {
			traffic = new GTrafficOverlay();
			gmap.addOverlay(traffic);
		}
	// Layer off
	} else {
		if(layer_name == 'traffic') {
			gmap.removeOverlay(traffic);
		}
	}
}

