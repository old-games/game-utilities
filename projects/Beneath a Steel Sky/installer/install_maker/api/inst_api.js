function HttpClient() { }
  HttpClient.prototype = {
      xmlhttp:false,
      callback:false,
	  isAsync:false,

     onError:function(error) {
         alert(error);
     },

     init:function() {
       try {
            this.xmlhttp = new XMLHttpRequest();
       } catch (e) {
           var XMLHTTP_IDS = new Array('MSXML2.XMLHTTP.5.0','MSXML2.XMLHTTP.4.0','MSXML2.XMLHTTP.3.0','MSXML2.XMLHTTP','Microsoft.XMLHTTP');
           var success = false;
           for (var i=0;i < XMLHTTP_IDS.length && !success; i++) {
               try {
                   this.xmlhttp = new ActiveXObject(XMLHTTP_IDS[i]);
                   success = true;
               } catch (e) {}
           }
           if (!success) {
               this.onError('Unable to create XMLHttpRequest.');
           }
        }
     },

    makeRequest: function(url,payload) {
         if (!this.xmlhttp) {
             this.init();
         }
         this.xmlhttp.open('GET',url,this.isAsync);
         var self = this;
         this.xmlhttp.onreadystatechange = function() {
			self._readyStateChangeCallback(); 
		}
         this.xmlhttp.send(payload);
         if (!this.isAsync) {
             return this.xmlhttp.responseText;
         }
    },

    _readyStateChangeCallback:function() {
         switch(this.xmlhttp.readyState) {
            case 4:
               if (this.xmlhttp.status == 200) {
					if (this.callback)
						this.callback(this.xmlhttp.responseText);
               } else {
                   this.onError('HTTP Error Making Request: '+'['+this.xmlhttp.status+']'+this.xmlhttp.statusText);
               }
               break;
         }
     }
 }
 
function InstApi(){ this.init(this);}
InstApi.prototype = {
	client:new HttpClient(),
	client2:false,
	ival:false,
	onServerStop:false,
	sync:function() {
		this.client.isAsync=false;
		this.client.callback=false;
	},
	init:function(obj){
		if (!obj.client2) obj.client2=new HttpClient();
		obj.ival=window.setInterval(function(){obj.client2.makeRequest("/api/hb");},1000);
	},
	async:function(callback){
		this.client.isAsync=true;
		this.client.callback=callback;
	},
	call:function(query){
		return this.client.makeRequest("/api/"+query,null);
	},
	log:function(s){
		return this.call("log?s="+s);
	},
	close:function(){
		window.clearInterval(this.ival);
		this.async(false);
		res=this.call("close");
		if (this.onServerStop)
			this.onServerStop();
		return res;
	},
	someother:function(s){
		return this.call("other/some?q="+s);
	},
	badcall:function() {
		return this.call("other/bad");
	},
	badcall2:function() {
		return this.call("bad");
	}
}