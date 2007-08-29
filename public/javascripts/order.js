var states = [{name:'Alabama',value:'AL'},{name:'Alaska',value:'AK'},{name:'Arizona',value:'AZ'},{name:'Arkansas',value:'AR'},{name:'California',value:'CA'},{name:'Colorado',value:'CO'},{name:'Connecticut',value:'CT'},{name:'Delaware',value:'DE'},{name:'Florida',value:'FL'},{name:'Georgia',value:'GA'},{name:'Hawaii',value:'HI'},{name:'Idaho',value:'ID'},{name:'Illinois',value:'IL'},{name:'Indiana',value:'IN'},{name:'Iowa',value:'IA'},{name:'Kansas',value:'KS'},{name:'Kentucky',value:'KY'},{name:'Louisiana',value:'LA'},{name:'Maine',value:'ME'},{name:'Maryland',value:'MD'},{name:'Massachusetts',value:'MA'},{name:'Michigan',value:'MI'},{name:'Minnesota',value:'MN'},{name:'Mississippi',value:'MS'},{name:'Missouri',value:'MO'},{name:'Montana',value:'MT'},{name:'Nebraska',value:'NE'},{name:'Nevada',value:'NV'},{name:'New Hampshire',value:'NH'},{name:'New Jersey',value:'NJ'},{name:'New Mexico',value:'NM'},{name:'New York',value:'NY'},{name:'North Carolina',value:'NC'},{name:'North Dakota',value:'ND'},{name:'Ohio',value:'OH'},{name:'Oklahoma',value:'OK'},{name:'Oregon',value:'OR'},{name:'Pennsylvania',value:'PA'},{name:'Rhode Island',value:'RI'},{name:'South Carolina',value:'SC'},{name:'South Dakota',value:'SD'},{name:'Tennessee',value:'TN'},{name:'Texas',value:'TX'},{name:'Utah',value:'UT'},{name:'Vermont',value:'VT'},{name:'Virginia',value:'VA'},{name:'Washington',value:'WA'},{name:'Washington DC',value:'DC'},{name:'West Virginia',value:'WV'},{name:'Wisconsin',value:'WI'},{name:'Wyoming',value:'WY'}];

function initStep1() {
	document.getElementById('ship_first_name').focus();
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
		option.innerHTML = states[i].name
		option.value = states[i].value;
		e.appendChild(option);
	}
}

function calculateTotal(e) {
	var subtotal = 264.90;
	var tax = subtotal * 0.0825;
	var index = e.selectedIndex;
	var shipping = parseFloat(e.options[index].value);
	var total = subtotal+tax+shipping;
	total = parseFloat(Math.round(total*100)/100);
	document.getElementById('total').innerHTML = '$' + total + '0';
}

function toggleOrderButton(checked) {
	var order_btn = document.getElementById('order_btn');
	if(checked)
		order_btn.disabled = false;
	else
		order_btn.disabled = true;
}

function validateShipForm(form) {
	resetFields(form);
	
	var ship_first_name = form.ship_first_name.value.trim();
	if(ship_first_name.length < 1) {
		alert('Please enter a valid shipping first name');
		form.ship_first_name.className = 'error_short';
		form.ship_first_name.focus();
		return false;
	}
	
	var ship_last_name = form.ship_last_name.value.trim();
	if(ship_last_name.length < 1) {
		alert('Please enter a valid shipping last name');		
		form.ship_last_name.className = 'error_short';
		form.ship_last_name.focus();
		return false;
	}
	
	var ship_address = form.ship_address.value.trim();
	if(ship_address.length < 4) {
		alert('Please enter a valid shipping address');		
		form.ship_address.className = 'error_long';
		form.ship_address.focus();
		return false;
	}
	
	var ship_city = form.ship_city.value.trim();
	if(ship_city.length < 2) {
		alert('Please enter a valid shipping city');		
		form.ship_city.className = 'error_short';
		form.ship_city.focus();
		return false;
	}
	
	var ship_state = form.ship_state
	
	return true;
}

function resetFields(form) {
	form.ship_first_name.className = 'short_text';
	form.ship_last_name.className = 'short_text';
	form.ship_address.className = 'long_text';
	form.ship_city.className = 'short_text';
}