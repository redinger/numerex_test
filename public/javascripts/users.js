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

function ValidateForm(){
var emailID=document.getElementById('email').value.replace(/^\s/,"");
	if ((emailID.length <= 0))
	{
		//return true; // TODO only disallow blank if FLAG not checked
		alert("Email can't be blank."); 
        document.getElementById('email').focus();
		return false
	}
    var emailID=document.getElementById('email')
	return CheckEmail(emailID,"");
 }


function CheckEmail(FormField,notification_prompt){    
	var array = FormField.value.split(",");                
	for(var i=0;i< array.length;i++)	{
		if(array[i].match(/[\w\-\.\+]+\@[a-zA-Z0-9\.\-]+\.[a-zA-z0-9]{2,3}$/)==null){alert(FormField.title + " is not in a valid  format"); FormField.focus(); return false}
		}	
	//alert(FormField.name);
	return true;
	}
