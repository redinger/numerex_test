function enablePasswords(enable) {
	if(enable) {
		document.getElementById("existing_password").disabled = !enable;
		document.getElementById("new_password").disabled = !enable;
		document.getElementById("confirm_new_password").disabled = !enable;
		document.getElementById("existing_password").focus();
	} else {
		document.getElementById("existing_password").disabled = !enable;
		document.getElementById("new_password").disabled = !enable;
		document.getElementById("confirm_new_password").disabled = !enable;
	}
}