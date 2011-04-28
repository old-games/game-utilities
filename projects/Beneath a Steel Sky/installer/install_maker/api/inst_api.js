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
           var XMLHTTP_IDS = new Array('MSXML2.XMLHTTP.5.0','MSXML2.XMLHTTP.4.0','MSXML2.XMLHTTP.3.0','MSXML2.XMLHTTP','Microsoft.XMLHTTP'),success = false;
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
	onError:false,
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
	normalize:function(s){
		s=s.replace(/\\/g,"\\\\");
		return s;
	},
	call:function(query){
		var s="";
		try{
			s=this.client.makeRequest("/api/"+query,null);
		}catch(e){
			s="{r:-10 d:'send error '+e}";
		}
		s=this.normalize(s);
		return eval('('+s+')');
	},
	log:function(s){
		return this.call("log?s="+s);
	},
	close:function(){
		window.clearInterval(this.ival);
		this.async(false);
		var res=this.call("close");
		if (this.onServerStop)
			this.onServerStop();
		return res;
	},
	userdir:function(){
		return this.call("system/userdir");
	},
	hasfile:function(file) {
		return this.call("system/hasfile?fl="+file);
	}
}