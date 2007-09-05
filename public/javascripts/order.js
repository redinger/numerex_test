var states = [{name:'Alabama',value:'AL'},{name:'Alaska',value:'AK'},{name:'Arizona',value:'AZ'},{name:'Arkansas',value:'AR'},{name:'California',value:'CA'},{name:'Colorado',value:'CO'},{name:'Connecticut',value:'CT'},{name:'Delaware',value:'DE'},{name:'Florida',value:'FL'},{name:'Georgia',value:'GA'},{name:'Hawaii',value:'HI'},{name:'Idaho',value:'ID'},{name:'Illinois',value:'IL'},{name:'Indiana',value:'IN'},{name:'Iowa',value:'IA'},{name:'Kansas',value:'KS'},{name:'Kentucky',value:'KY'},{name:'Louisiana',value:'LA'},{name:'Maine',value:'ME'},{name:'Maryland',value:'MD'},{name:'Massachusetts',value:'MA'},{name:'Michigan',value:'MI'},{name:'Minnesota',value:'MN'},{name:'Mississippi',value:'MS'},{name:'Missouri',value:'MO'},{name:'Montana',value:'MT'},{name:'Nebraska',value:'NE'},{name:'Nevada',value:'NV'},{name:'New Hampshire',value:'NH'},{name:'New Jersey',value:'NJ'},{name:'New Mexico',value:'NM'},{name:'New York',value:'NY'},{name:'North Carolina',value:'NC'},{name:'North Dakota',value:'ND'},{name:'Ohio',value:'OH'},{name:'Oklahoma',value:'OK'},{name:'Oregon',value:'OR'},{name:'Pennsylvania',value:'PA'},{name:'Rhode Island',value:'RI'},{name:'South Carolina',value:'SC'},{name:'South Dakota',value:'SD'},{name:'Tennessee',value:'TN'},{name:'Texas',value:'TX'},{name:'Utah',value:'UT'},{name:'Vermont',value:'VT'},{name:'Virginia',value:'VA'},{name:'Washington',value:'WA'},{name:'Washington DC',value:'DC'},{name:'West Virginia',value:'WV'},{name:'Wisconsin',value:'WI'},{name:'Wyoming',value:'WY'}];

function initStep1(focus_field) {
	document.getElementById(focus_field).focus();
	populateStates('ship_state', default_ship_state);
}

function toggleBilling(e) {
	var b = document.getElementById("billing_container");
	if(e.checked) {
		b.style.visibility = 'hidden';
	} else {
		var len = document.getElementById('bill_state').options.length;
		if(len == 0)
			populateStates('bill_state', default_bill_state);
		b.style.visibility = 'visible';
	}
}

function populateStates(id, default_state) {
	var e = document.getElementById(id);
	var option = document.createElement('option');
	option.innerHTML = '- Please select -';
	option.value = '';
	e.appendChild(option);

	for(var i=0; i < states.length; i++) {
		var option = document.createElement('option');
		option.innerHTML = states[i].name;
		option.value = states[i].value;
		
		if(states[i].value == default_state)
			option.selected = 'selected';
			
		e.appendChild(option);
	}
}

function calculateTotal(e) {
	var subtotal = 264.90;
	var tax = subtotal * 0.0825;
	var index = e.selectedIndex;
	var shipping = parseFloat(e.options[index].value);
	var total = subtotal+tax+shipping;
	total = parseFloat(Math.round(total*100)/100) + '0';
	document.getElementById('display_total').innerHTML = '$' + total;
	document.getElementById('total').value = total;
}

function toggleOrderButton(checked) {
	var order_btn = document.getElementById('order_btn');
	if(checked)
		order_btn.disabled = false;
	else
		order_btn.disabled = true;
}

// Validate shipping/billing form in step1
function validateShipForm(form) {
	resetShippingFields(form);
	
	// Shipping validation
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
	
	var ship_state = form.ship_state.options[form.ship_state.selectedIndex].value;
	if(ship_state == '') {
		alert('Please select a shipping state');
		form.ship_state.className = 'error_select';
		form.ship_state.focus();
		return false;
	}
	
	var ship_zip = form.ship_zip.value.trim();;
	if(ship_zip.length < 5) {
		alert('Please enter a valid shipping zip code');
		form.ship_zip.className = 'error_short';
		form.ship_zip.focus();
		return false;
	}
	
	// Billing validation
	var is_billing_same = form.bill_toggle.checked;
	
	// If billing is different than shipping
	if(!is_billing_same) {
		var bill_first_name = form.bill_first_name.value.trim();
		if(bill_first_name.length < 1) {
			alert('Please enter a valid billing first name');
			form.bill_first_name.className = 'error_short';
			form.bill_first_name.focus();
			return false;
		}
		
		var bill_last_name = form.bill_last_name.value.trim();
		if(bill_last_name.length < 1) {
			alert('Please enter a valid billing last name');
			form.bill_last_name.className = 'error_short';
			form.bill_last_name.focus();
			return false;
		}
		
		var bill_address = form.bill_address.value.trim();
		if(bill_address.length < 1) {
			alert('Please enter a valid billing address');
			form.bill_address.className = 'error_short';
			form.bill_address.focus();
			return false;
		}
		
		var bill_city = form.bill_city.value.trim();
		if(bill_city.length < 1) {
			alert('Please enter a valid billing city');
			form.bill_city.className = 'error_short';
			form.bill_city.focus();
			return false;
		}
		
		var bill_state = form.bill_state.options[form.bill_state.selectedIndex].value;
		if(bill_state == '') {
			alert('Please select a billing state');
			form.bill_state.className = 'error_select';
			form.bill_state.focus();
			return false;
		}
		
		var bill_zip = form.bill_zip.value.trim();
		if(bill_zip.length < 5) {
			alert('Please enter a valid billing zip code');
			form.bill_zip.className = 'error_short';
			form.bill_zip.focus();
			return false;
		}
		
	}
	
	// Email validation
	var email = form.email.value.trim();
	if(!validateEmail(email)) {
		alert('Please enter a valid email address');
		form.email.className = 'error_long';
		form.email.focus();
		return false;
	}
	
	// Make sure the passwords are the proper length
	var password = form.password.value.trim();
	var confirm_password = form.confirm_password.value.trim();
	
	if(password.length < 6) {
		alert('Please specify a password of the proper length');
		form.password.className = 'error_long';
		form.password.focus();
		return false;
	}
	
	if(confirm_password.length < 6) {
		alert('Please specify a confirmation password of the proper length');
		form.confirm_password.className = 'error_long';
		form.confirm_password.focus();
		return false;
	}
	
	// Make sure the passwords match
	if(password != confirm_password) {
		alert('Please make sure your passwords match');
		form.password.className = 'error_long';
		form.password.focus();
		return false;
	}
	
	var subdomain = form.subdomain.value.trim();
	if(!validateSubdomain(subdomain)) {
		alert('Please make sure your web address contains only letters and numbers');
		form.subdomain.className = 'error_short';
		form.subdomain.focus();
		return false;
	} else {
		form.subdomain.value = subdomain;
	}
	
	return true;
}

// Validate cc form in step 2
function validateCCForm(form) {
	resetCCFields(form);
	// Verify the credit card
	var cc_number = form.cc_number.value.trim();
	
	if(!isNumeric(cc_number) || cc_number.length < 13) {
		alert('Please enter a valid credit card number');
		form.cc_number.className = 'error_short';
		form.cc_number.focus();
		return false;
	}
	
	// Verify the security code
	var cvv2 = form.cvv2.value.trim();
	if(!isNumeric(cvv2) || cvv2.length < 3) {
		alert('Please enter a valid security code');
		form.cvv2.className = 'error_super_short';
		form.cvv2.focus();
		return false;
	}
	return false;
}

// Returns null if invalid, else returns email address
function validateEmail(email) {
	var exp = /^[\w\-\.\+]+\@[a-zA-Z0-9\.\-]+\.[a-zA-z0-9]{2,4}$/;
	return email.match(exp);
}

// Make sure the subdomain is alphanumeric
function validateSubdomain(subdomain) {
	var exp = /^[0-9a-zA-Z]+$/;
	return subdomain.match(exp);
}

// Make sure value is numeric
function isNumeric(val) {
	var exp = /^[0-9]+$/;
	return val.match(exp);
}

// Reset shipping fields so they don't display errors
function resetShippingFields(form) {
	form.ship_first_name.className = form.bill_first_name.className = 'short_text';
	form.ship_last_name.className = form.bill_last_name.className = 'short_text';
	form.ship_address.className = form.bill_address.className = 'long_text';
	form.ship_city.className = form.bill_city.className = 'short_text';
	form.ship_state.className = form.bill_state.className = '';
	form.ship_zip.className = form.bill_zip.className = 'short_text';
	form.email.className = 'long_text';
	form.password.className = form.confirm_password.className = 'long_text';
	form.subdomain.className = 'short_text';
}

// Reset cc fields so they don't display errors
function resetCCFields(form) {
	form.cc_number.className = 'short_text';
	form.cvv2.className = 'super_short_text';
}