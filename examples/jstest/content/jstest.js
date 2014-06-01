function test(task,id) {
   var div = document.getElementById(id);
   div.className = "testing";
   try {
      if (task()) {
         div.className = "good";
      } else {
         div.className = "bad";
      }
   } catch (ex) {
      div.className = "bad";
   }
}

function requestTest() {
   var xmlhttp = new XMLHttpRequest();
   xmlhttp.open("GET","http://www.milowski.com/",false);
   xmlhttp.send(null);
   return xmlhttp.status>=200 < xmlhttp.status<300
}

function linkTest() {
   var div = document.getElementById("links");
   var a = document.createElement("a");
   a.setAttribute("href","http://www.mesonet.info/data/station/DW8568/");
   a.setAttribute("title","Click on this external link to test.");
   a.appendChild(document.createTextNode("[external link]"));
   div.appendChild(a);

   return true;
}

function runTests() {
   alert("Testing!");
   test(function() { return true; },"jsworking");
   test(requestTest,"requests");
   test(linkTest,"links");
}
