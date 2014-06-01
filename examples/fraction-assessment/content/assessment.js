function App() {
}

App.prototype.init = function(id) {
   var app = this;
   this.loadApp();
   this.loadData(id);
   this.selected = Math.round((this.tests.length-1)*Math.random());
   this.position = 0;
   this.display = {};
   this.display.container = document.getElementById("display");
   this.display.l = document.getElementById("l");
   this.display.r = document.getElementById("r");
   this.display.sign = document.getElementById("sign");
   this.display.answer = document.getElementById("answer");
   this.display.previous = document.getElementById("previous");
   this.display.next = document.getElementById("next");
   this.display.done = document.getElementById("done");
   this.finished = document.getElementById("finished");
   this.displayId();
   this.selector = new NumberSelector(document.getElementById("number-selector"),5);
   this.answer = {
      n: document.getElementById("answer-n"),
      d: document.getElementById("answer-d")
   };
   this.selector.container.style.position = "absolute";
   this.selector.container.style.top = this.display.answer.offsetTop+"px";
   var left = (window.innerWidth - this.selector.container.offsetWidth)/2;
   this.selector.container.style.left = left+"px";
   this.selector.container.style.display = "none";
   this.finished.style.display = "none";
   this.display.container.style.display = "block";

   this.setupTest();

   this.display.next.addEventListener("click",function() {
      app.nextQuestion();
   });

   this.display.previous.addEventListener("click",function() {
      app.previousQuestion();
   });

   this.display.done.addEventListener("click",function() {
      app.submit();
   });

   app.selector.onCancel = function() {
      app.selector.container.style.display = "none";
   }

   this.answer.n.addEventListener("click",function() {
      if (app.answer.n.textContent!="?") {
         app.selector.setNumber(app.answer.n.textContent);
      } else {
         app.selector.setNumber(0);
      }
      app.selector.container.style.display = "block";
      app.selector.onAccept = function() {
         app.selector.container.style.display = "none";
         app.clear(app.answer.n);
         app.answer.n.appendChild(document.createTextNode(app.selector.number.textContent));
         app.answers[app.position].n = parseInt(app.selector.number.textContent);
      }
   },false);
   this.answer.d.addEventListener("click",function() {
      if (app.answer.d.textContent!="?") {
         app.selector.setNumber(app.answer.d.textContent);
      } else {
         app.selector.setNumber(0);
      }
      app.selector.container.style.display = "block";
      app.selector.onAccept = function() {
         app.selector.container.style.display = "none";
         var d = parseInt(app.selector.number.textContent);
         if (d==0) { return; }
         app.clear(app.answer.d);
         app.answer.d.appendChild(document.createTextNode(app.selector.number.textContent));
         app.answers[app.position].d = d;
      }
   },false);
}

App.prototype.loadApp = function() {
   var xmlhttp = new XMLHttpRequest();
   xmlhttp.open("GET","./app.xhtml",false);
   xmlhttp.send(null);
   if (xmlhttp.status>=200 < xmlhttp.status<300) {
      var node = document.importNode(xmlhttp.responseXML.documentElement,true);
      document.body.appendChild(node);
   }
}

App.prototype.setupTest = function() {
   var number = this.tests[this.selected].length;
   this.answers = [];
   for (var i=0; i<number; i++) {
      this.answers.push({});
   }
   this.displayQuestion();
}

App.prototype.nextQuestion = function() {
   if (this.position<(this.answers.length-1)) {
      this.position++;
      this.displayQuestion();
   }
}

App.prototype.previousQuestion = function() {
   if (this.position>0) {
      this.position--;
      this.displayQuestion();
   }
}

App.prototype.submit = function() {
   this.grade();
   var answered = 0;
   var correct = 0;
   for (var i=0; i<this.answers.length; i++) {
      if (this.answers[i].correct) {
         correct++;
      }
      if (this.answers[i].answered) {
         answered++;
      }
   }
   var answeredSpan = document.getElementById('answered');
   var correctSpan = document.getElementById('correct');
   this.clear(answeredSpan);
   this.clear(correctSpan);
   answeredSpan.appendChild(document.createTextNode(answered+"/"+this.answers.length));
   correctSpan.appendChild(document.createTextNode(correct+"/"+this.answers.length));
   this.finished.style.display = "block";
   this.display.container.style.display = "none";
   HTTP("POST",window.shell.getService(), {
      contentType: "application/xml",
      body: '<assessment correct="'+correct+'" answered="'+answered+'" total="'+this.answers.length+'"/>',
      headers: { "Authorization": "Bearer "+window.shell.getAccessToken() },
      onFailure: function(status) {
         alert("Unable to post results, status "+status);
      }
   });
}

App.prototype.primes = [ 2, 3, 5, 7, 11, 13, 17, 19, 29, 31, 37, 41, 43, 47, 53, 61, 67, 71, 73, 79, 83, 89, 97 ];

App.prototype.grade = function() {
   var test = this.tests[this.selected];
   var key = [];
   for (var i=0; i<test.length; i++) {
      var solution = {
         n: test[i].add ? test[i].l.n*test[i].r.d + test[i].r.n*test[i].l.d : test[i].l.n*test[i].r.d - test[i].r.n*test[i].l.d,
         d: test[i].l.d*test[i].r.d
      }
      //alert(JSON.stringify(test[i])+" -> "+JSON.stringify(solution));
      var simplified = this.simplify(solution);
      //alert(JSON.stringify(test[i])+" -> "+JSON.stringify(simplified));
      key.push(simplified);
   }
   for (var i=0; i<this.answers.length; i++) {
      this.answers[i].solution = key[i];
      if (this.answers[i].n && this.answers[i].d) {
         this.answers[i].answered = true;
         if (this.answers[i].d==0) {
            this.answers[i].correct = false;
            continue;
         }
         this.answers[i].simplified = this.simplify(this.answers[i]);
         this.answers[i].correct = this.answers[i].simplified.n==key[i].n && this.answers[i].simplified.d==key[i].d;
      } else {
         this.answers[i].answered = false;
         this.answers[i].correct = false;
      }
   }
}

App.prototype.simplify = function(f) {
   if (f.n==0 || f.d==0) { return f; }
   var nf = this.factor(f.n);
   var df = this.factor(f.d);
   for (var i=0; i<nf.length; i++) {
      if (nf[i]>0 && df[i]>0) {
         if (nf[i]>df[i]) {
            nf[i] = nf[i]-df[i];
            df[i] = 0;
         } else {
            df[i] = df[i]-nf[i];
            nf[i] = 0;
         }
      }
   }
   return {
      n: this.unfactor(nf),
      d: this.unfactor(df)
   };
}

App.prototype.unfactor = function(nf) {
   var n = 1;
   for (var i=0; i<this.primes.length; i++) {
      n = n*Math.pow(this.primes[i],nf[i]);
   }
   return n;
}

App.prototype.factor = function(n) {
   var f = [];
   for (var i=0; i<this.primes.length; i++) {
      var exp = 0;
      while (n>0 && (n%this.primes[i])==0) {
         n = n/this.primes[i];
         exp++;
      }
      f.push(exp);
   }
   return f;
}

App.prototype.clear = function(e) {
   while (e.firstChild) {
      e.removeChild(e.firstChild);
   }
}

App.prototype.loadData = function(id) {
   var testData = document.getElementById(id);
   var current = testData.firstChild;
   this.tests = [];
   while (current) {
      if (current.nodeType==Node.ELEMENT_NODE && current.className=="assessment") {
         var question = current.firstChild;
         var test = [];
         while (question) {
            if (question.nodeType==Node.ELEMENT_NODE && question.className=="question") {
               var text = question.textContent;
               var q = this.parseQuestion(question.textContent);
               if (q) {
                  //alert(JSON.stringify(q));
                  test.push(q);
               }
            }
            question = question.nextSibling;
         }
         this.tests.push(test);
      }
      current = current.nextSibling;
   }
}

App.prototype.parseQuestion = function(expr) {
   var sum = new RegExp("\\s*(\\d+)\\/(\\d+)\\s*([+-])\\s*(\\d+)\\/(\\d+)\\s*");
   var parts = sum.exec(expr);
   if (!parts) {
      throw "Cannot parse: "+expr;
   }
   if (parts.index>=0) {
      var question = {};
      question.l = { n: parseInt(parts[1]), d: parseInt(parts[2]) };
      question.add = parts[3]=="+";
      question.r = { n: parseInt(parts[4]), d: parseInt(parts[5]) };
      return question;
   }
}

App.prototype.displayId = function() {
   var idDiv = document.getElementById('id');
   this.clear(idDiv);
   idDiv.appendChild(document.createTextNode(this.selected));
}

App.prototype.displayQuestion = function() {
   if (this.position>0) {
      this.display.previous.style.display = "block";
   } else {
      this.display.previous.style.display = "none";
   }
   if (this.position==(this.answers.length-1)) {
      this.display.next.style.display = "none";
      this.display.done.style.display = "block";
   } else {
      this.display.next.style.display = "block";
      this.display.done.style.display = "none";
   }
   this.clear(this.display.l);
   this.clear(this.display.sign);
   this.clear(this.display.r);
   var q = this.tests[this.selected][this.position];
   this.displayFraction(this.display.l,q.l);
   this.display.sign.appendChild(document.createTextNode(q.add ? "+" : "-"));
   this.displayFraction(this.display.r,q.r);
   if (app.answers[app.position].n) {
      app.clear(app.answer.n);
      app.answer.n.appendChild(document.createTextNode(app.answers[app.position].n));
   } else {
      app.clear(app.answer.n);
      app.answer.n.appendChild(document.createTextNode("?"));
   }
   if (app.answers[app.position].d) {
      app.clear(app.answer.d);
      app.answer.d.appendChild(document.createTextNode(app.answers[app.position].d));
   } else {
      app.clear(app.answer.d);
      app.answer.d.appendChild(document.createTextNode("?"));
   }
}

App.prototype.displayFraction = function(container,f) {
   var n = document.createElement("div");
   n.className = "numerator";
   n.appendChild(document.createTextNode(f.n));
   container.appendChild(n);
   var d = document.createElement("div");
   d.className = "denominator";
   d.appendChild(document.createTextNode(f.d));
   container.appendChild(d);
}

function NumberSelector(e,limit) {
   this.container = e;
   this.limit = limit;
   var current = this.container.firstChild;
   while (current) {
      if (current.className=="number-display") {
         this.number = current.firstChild;
         while (this.number && this.number.className!="number") {
            this.number = this.number.nextSibling;
         }
      } else if (current.className=="number-row") {
         var key = current.firstChild;
         while (key) {
            if (key.className=="number-key") {
               this.addKey(key);
            } else if (key.className=="number") {
               this.number = key;
            }
            key = key.nextSibling;
         }
      }
      current = current.nextSibling;
   }
   while (this.number.firstChild) {
      this.number.removeChild(this.number.firstChild);
   }
   this.number.appendChild(document.createTextNode("0"));
}

NumberSelector.prototype.addKey = function(key) {
   var label = key.textContent;
   if (key.firstChild.className) {
      label = key.firstChild.className;
   }
   var control = this;
   key.addEventListener("mousedown", function() {
      key.className = "selected number-key";
   },false);
   key.addEventListener("mouseup", function() {
      key.className = "number-key";
   },false);
   key.addEventListener("click",function() {
      if (label=="C") {
         control.number.removeChild(control.number.firstChild);
         control.number.appendChild(document.createTextNode("0"));
         return;
      } else if (label=="accept") {
         if (control.onAccept) {
            control.onAccept();
         }
         return;
      } else if (label=="cancel") {
         if (control.onCancel) {
            control.onCancel();
         }
         return;
      } else if (label=="-") {
         return;
      }
      if (control.number.textContent.length==control.limit) {
         return;
      }
      var text = control.number.textContent;
      if (control.number.textContent=="0") {
         if (label=="0") { return; }
         text = "";
      }
      control.number.removeChild(control.number.firstChild);
      control.number.appendChild(document.createTextNode(text+label));
   },false);
}

NumberSelector.prototype.setNumber = function(n) {
   var text = n+"";
   while (this.number.firstChild) {
      this.number.removeChild(this.number.firstChild);
   }
   this.number.appendChild(document.createTextNode(text));
}

var app = new App();

window.onload = function() {
   app.init("test-data");  
}
