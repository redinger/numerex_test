function select_action(obj,from)
{  
  var Index = document.getElementById("type1").selectedIndex;
  var selected_text = document.getElementById("type1").options[Index].text;              
    if (selected_text == "New group")
    {
         szNewURL = "http://"+document.location.hostname+"/devices/new_group"         
        window.location.href=szNewURL;            
    }
    else if (selected_text == "Edit groups")
    {
         szNewURL = "http://"+document.location.hostname+"/devices/groups" 
        window.location.href=szNewURL;                
    }
    else
    {
      if (from=='from_devices')
      {         
           szNewURL = "http://"+document.location.hostname+"/devices?type="+document.getElementById('type1').value         
           window.location.href=szNewURL;                                
      }
      else         
         new Ajax.Updater('to_update', '/home/show_devices?frm='+from, {asynchronous:true, evalScripts:true, parameters:'type='+escape($F('type1'))});javascript:getRecentReadings(true,document.getElementById('type1').value);
    }
}


