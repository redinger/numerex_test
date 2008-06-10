// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
//<script>
function ValidateForm(){
var emailID=document.getElementById('email');
	return CheckEmail(emailID,"");
 }


function CheckEmail(FormField,notification_prompt){
	var array = FormField.value.split(",");
	if ((FormField.value=="" || FormField.value == notification_prompt))
	{
		return true; // TODO only disallow blank if FLAG not checked
		alert(FormField.title + " cannot be blank"); FormField.focus();
		return false
	}
	for(var i=0;i< array.length;i++)	{
		if(array[i].match(/(^([^@\s]+)@((?:[-_a-z0-9]+\.)+[a-z]{2,})$)|(^$)/i)==null){alert(FormField.title + " is not a valid  format"); FormField.focus(); return false}
		}	
	//alert(FormField.name);
	return true;
	}
//</script>





