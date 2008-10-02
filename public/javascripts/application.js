function select_action(obj,from)
{  
  var Index = document.getElementById("group_type").selectedIndex;
  var selected_text = document.getElementById("group_type").options[Index].text;              
    if (selected_text == "New group")
    {
         szNewURL = "http://"+document.location.hostname+"/devices/new_group";         
        window.location.href=szNewURL;            
    }
    else if (selected_text == "Edit groups")
    {
         szNewURL = "http://"+document.location.hostname+"/devices/groups"; 
        window.location.href=szNewURL;                
    }
    else
    {
      if (from=='from_devices')
      {         
           szNewURL = "http://"+document.location.hostname+"/devices?group_type="+document.getElementById('group_type').value;         
           window.location.href=szNewURL;                                
      }
      else 
      {            
           szNewURL = "http://"+document.location.hostname+":3000/home/show_devices?group_type="+document.getElementById('group_type').value+"&frm=" + from;          
           document.location.href=szNewURL;                                                  
       }  
    }
}


