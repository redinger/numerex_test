var states = ['Alabama','Alaska','Arizona','Arkansas','California','Colorado','Connecticut','Delaware','Florida','Georgia','Hawaii','Idaho','Illinois','Indiana','Iowa','Kansas','Kentucky','Louisiana','Maine','Maryland','Massachusetts','Michigan','Minnesota','Mississippi','Missouri','Montana','Nebraska','Nevada','New Hampshire','New Jersey','New Mexico','New York','North Carolina','North Dakota','Ohio','Oklahoma','Oregon','Pennsylvania','Rhode Island','South Carolina','South Dakota','Tennessee','Texas','Utah','Vermont','Virginia','Washington','Washington DC','West Virginia','Wisconsin','Wyoming'];

function initStep1() {
	populateStates('ship_state');
}

function toggleBilling(e) {
	var b = document.getElementById("billing_container");
	if(e.checked) {
		b.style.visibility = 'hidden';
	} else {
		var len = document.getElementById('bill_state').options.length;
		if(len == 0)
			populateStates('bill_state');
		b.style.visibility = 'visible';
	}
}

function populateStates(id) {
	var e = document.getElementById(id);
	var option = document.createElement('option');
	option.innerHTML = '- Please select -';
	option.value = '';
	e.appendChild(option);

	
	for(var i=0; i < states.length; i++) {
		var option = document.createElement('option');
		option.innerHTML = states[i]
		option.value = '';
		e.appendChild(option);
	}
}