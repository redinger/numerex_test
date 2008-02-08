// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults




var nsstyle='display:""'
if (document.layers)
var scrolldoc=document.scroll1.document.scroll2
function up(){
if (!document.layers) return
if (scrolldoc.top<0)
scrolldoc.top+=10
temp2=setTimeout("up()",50)
}
function down(){
if (!document.layers) return
if (scrolldoc.top-150>=scrolldoc.document.height*-1)
scrolldoc.top-=10
temp=setTimeout("down()",50)
}

function clearup(){
if (window.temp2)
clearInterval(temp2)
}

function cleardown(){
if (window.temp)
clearInterval(temp)
}

