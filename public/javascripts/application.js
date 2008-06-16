// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
//<script>
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
		if(array[i].match(/[\w\-\.\+]+\@[a-zA-Z0-9\.\-]+\.[a-zA-z0-9]{2,4}$/)==null){alert(FormField.title + " is not a valid  format"); FormField.focus(); return false}
		}	
	//alert(FormField.name);
	return true;
	}

//</script>





