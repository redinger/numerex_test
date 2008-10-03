function select_action(obj,from)
{  
  var Index = document.getElementById("group_type").selectedIndex;
  var selected_text = document.getElementById("group_type").options[Index].text;              
    if (selected_text == "New group")
    {
         szNewURL = "/devices/new_group";         
        window.location.href=szNewURL;            
    }
    else if (selected_text == "Edit groups")
    {
         szNewURL = "/devices/groups"; 
        window.location.href=szNewURL;                
    }
    else
    {
      if (from=='from_devices')
      {         
           szNewURL = "/devices?group_type="+document.getElementById('group_type').value;         
           window.location.href=szNewURL;                                
      }
      else 
      {            
           szNewURL = "/home/show_devices?group_type="+document.getElementById('group_type').value+"&frm=" + from;          
           document.location.href=szNewURL;                                                  
       }  
    }
}


