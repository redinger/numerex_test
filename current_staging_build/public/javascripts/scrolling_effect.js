// scrolling effect start
 var ieHoffset_extra=document.all? 15 : 0
 var dsocleft=document.all? iecompattest().scrollLeft : pageXOffset
 var dsoctop=document.all? iecompattest().scrollTop : pageYOffset
 var addtional_value=10;
 var distance_top;
 var temp_value1;
 var temp_value2;
 from_main? temp_value1 = 128 : temp_value1 = 160     
 from_main? temp_value2 = 115 : temp_value2 = 155     
 
 
 var bName = navigator.appName;  
  if (bName == "Microsoft Internet Explorer" ){       
    var Hoffset =  (document.documentElement.clientWidth - ieHoffset_extra) - (document.documentElement.clientWidth - ieHoffset_extra)/2  + addtional_value
    var Voffset =  document.documentElement.clientHeight - temp_value1    
    var  HoffsetArrow =  (document.documentElement.clientWidth - ieHoffset_extra) - (document.documentElement.clientWidth - ieHoffset_extra)/2 + 20
    var  VoffsetArrow = document.documentElement.clientHeight - temp_value1*3      
    from_main? distance_top = 115 : distance_top = 160
  }
  else{  
    var Hoffset = ieNOTopera? iecompattest().clientWidth+ieHoffset_extra : window.innerWidth+ieHoffset_extra -  (document.documentElement.clientWidth - ieHoffset_extra)/2 - addtional_value
    var Voffset=  ieNOTopera? iecompattest().clientHeight : window.innerHeight - temp_value2
    var  HoffsetArrow = ieNOTopera? iecompattest().clientWidth+ieHoffset_extra : window.innerWidth+ieHoffset_extra -  (document.documentElement.clientWidth - ieHoffset_extra)/2
    var  VoffsetArrow = ieNOTopera? iecompattest().clientHeight : window.innerHeight - temp_value2*3
     from_main? distance_top = 115 :  distance_top = 150
 }
 var thespeed=3 
 var ieNOTopera=document.all&&navigator.userAgent.indexOf("Opera")==-1
 var myspeed=0
 if (from_main)
    var cross_obj=document.all? document.all.header_ddd : document.getElementById? document.getElementById("header_ddd") : document.header_ddd
 else
    var cross_obj=document.all? document.all.map : document.getElementById? document.getElementById("map") : document.map
 
  var arrow_obj = document.all? document.all.arrow_expand : document.getElementById? document.getElementById("arrow_expand") : document.arrow_expand
 
function iecompattest(){
    return (document.compatMode && document.compatMode!="BackCompat")? document.documentElement : document.body
}

function positionit(){
    var dsocleft=document.all? iecompattest().scrollLeft : pageXOffset
    var dsoctop=document.all? iecompattest().scrollTop : pageYOffset
    var window_width=ieNOTopera? iecompattest().clientWidth+ieHoffset_extra : window.innerWidth+ieHoffset_extra
    var window_height=ieNOTopera? iecompattest().clientHeight : window.innerHeight 
    
    if (document.all||document.getElementById){ 
        cross_obj.style.left= fullScreenMap? 30 : parseInt(dsocleft)+parseInt(window_width)-Hoffset +"px"                
        arrow_obj.style.left = fullScreenMap? "1%" : parseInt(dsocleft)+parseInt(window_width)-HoffsetArrow +"px"                
        var scrolltop = 0;
        if(document.documentElement.scrollTop >= 0 && document.documentElement.scrollTop <= distance_top)
          scrolltop =  document.documentElement.scrollTop;
        else
         scrolltop = distance_top;
        cross_obj.style.top= fullScreenMap? 150 : (dsoctop+parseInt(window_height)-Voffset -  scrolltop)+"px"
        arrow_obj.style.top= fullScreenMap? "50%" : (dsoctop+parseInt(window_height)-VoffsetArrow -  scrolltop)+"px"
    }
    else if (document.layers){
         cross_obj.left=dsocleft+window_width-Hoffset
         cross_obj.top=dsoctop+window_height-Voffset  
         arrow_obj.left=dsocleft+window_width-HoffsetArrow
         arrow_obj.top=dsoctop+window_height-VoffsetArrow          
    }
}

function scrollwindow(){
  window.scrollBy(0,myspeed)  
}

function initializeIT(){
  positionit()
    if (myspeed!=0){
    scrollwindow()
    }
}

if (document.all||document.getElementById||document.layers)
setInterval("positionit()",20)

// scrolling effect end

