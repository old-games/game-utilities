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
	cliasync:new HttpClient(),
	ival:false,
	onServerStop:false,
	onError:false,
	raiseOnError:false,
	sync:function() {
		this.client.isAsync=false;
		this.client.callback=false;
	},
	init:function(obj){
		obj.cliasync.isAsync=true;
		if (!obj.client2) obj.client2=new HttpClient();
		obj.ival=window.setInterval(function(){try{obj.client2.makeRequest("/api/hb");}catch(e){window.clearInterval(obj.ival);}},4000);
	},
	async:function(callback){
		this.client.isAsync=true;
		this.client.callback=callback;
	},
	normalize:function(s){
		s=s.replace(/\\/g,"\\\\");
		return s;
	},
	unescape:function(s){
		s=s.replace(/[|]n/g,"\n").replace(/[|]r/g,"\r").replace(/[|]t/g,"\t");
		s=s.replace(/[|]!/g,"\"").replace(/[|][|]/g,"|");
		return s;
	},
	procResult:function (s){
		if (!s)
		{
			if (this.raiseOnError)
				throw "no api result";
			return false;
		}
		s=this.normalize(s);
		var res=eval('('+s+')');
		if (this.raiseOnError && res.r!=0)
		{
			res.message="API Error";
			throw res;
		}
		return res
	},
	call:function(query){
		var s="";
		try{
			s=this.client.makeRequest("/api/"+query,null);
		}catch(e){
			s="{r:-10 d:'send error '+e}";
		}
		if (this.client.isAsync)
			return 0;
		return this.procResult(s);
	},
	log:function(s){
		return this.call("log?s="+s);
	},
	close:function(){
		this.raiseOnError=false;
		window.clearInterval(this.ival);
		this.async(false);
		this.call("close");
		if (this.onServerStop)
			this.onServerStop();
		return 0;
	},
	cantstop:function(page){
		return this.call("cantstop?pg="+page);
	},
	canstop:function(){
		return this.call("canstop");
	},
	userdir:function(){
		return this.call("system/userdir");
	},
	hasfile:function(file) {
		return this.call("system/hasfile?fl="+file);
	},
	getfile:function(file) {
		return this.call("system/getfile?fl="+file);
	},
	matchfile:function(file,rx) {
		return this.call("system/matchfile?fl="+file+"&rx="+rx);
	},
	backup:function(file) {
		return this.call("system/backup?fl="+file);
	},
	restore:function(file) {
		return this.call("system/restore?fl="+file);
	},
	copy:function(file1,file2) {
		return this.call("system/copy?fl="+file1+"&new="+file2);
	},
	move:function(file1,file2) {
		return this.call("system/move?fl="+file1+"&new="+file2);
	},
	remove:function(file) {
		return this.call("system/remove?fl="+file);
	},
	setvar:function(vr,vl) {
		return this.call("vars/setvar?vr="+vr+"&vl="+vl);
	},
	getvar:function(vr) {
		return this.call("vars/getvar?vr="+vr);
	},
	hasvar:function(vr) {
		return this.call("vars/hasvar?vr="+vr);
	},
	remvar:function(vr) {
		return this.call("vars/remvar?vr="+vr);
	},
	fcreate:function(file) {
		return this.call("file/create?fl="+file);
	},
	fopen:function(file) {
		return this.call("file/open?fl="+file);
	},
	resopen:function(res) {
		return this.call("file/resopen?res="+res);
	},
	fclose:function(fid) {
		return this.call("file/close?fid="+fid);
	},
	flush:function(fid) {
		return this.call("file/flush?fid="+fid);
	},
	fseek:function(fid,pos,ofs) {
		return this.call("file/seek?fid="+fid+"&pos="+pos+(ofs?("&ofs="+ofs):""));
	},
	fread:function(fid,sz,be) {
		return this.call("file/read?fid="+fid+"&sz="+sz+(be?("&be="+be):""));
	},
	fwrite:function(fid,val,be) {
		return this.call("file/write?fid="+fid+"&val="+val+(be?("&be="+be):""));
	},
	hasres:function(res) {
		return this.call("resource/hasres?res="+res);
	},
	ressize:function(res) {
		return this.call("resource/ressize?res="+res);
	},
	insertres:function(file,res,ofs,oldsz) {
		return this.call("resource/insertres?fl="+file+"&res="+res+"&ofs="+ofs+"&osz="+oldsz);
	},
	insertval:function(file,val,ofs,oldsz,be) {
		return this.call("resource/insertres?fl="+file+"&val="+val+"&ofs="+ofs+"&osz="+oldsz+(be?("&be="+be):""));
	},
	makemap:function(file) {
		return this.call("resource/makemap?fl="+file);
	},
	applymap:function(mid) {
		return this.call("resource/applymap?mid="+mid);
	},
	applymaps:function() {
		return this.call("resource/applymaps");
	},
	clearmap:function(mid) {
		return this.call("resource/clearmap?mid="+mid);
	},
	clearmaps:function() {
		return this.call("resource/clearmaps");
	},
	mapres:function(mid,res,ofs,oldsz) {
		return this.call("resource/mapres?mid="+mid+"&res="+res+"&ofs="+ofs+"&osz="+oldsz);
	},
	mapval:function(mid,val,ofs,oldsz,be) {
		return this.call("resource/mapval?mid="+mid+"&val="+val+"&ofs="+ofs+"&osz="+oldsz+(be?("&be="+be):""));
	},
	mapfile:function(mid,file,ofs,oldsz) {
		return this.call("resource/mapfile?mid="+mid+"&fl="+file+"&ofs="+ofs+"&osz="+oldsz);
	},
	selectdir:function(callback) {
		this.cliasync.callback=callback
		this.cliasync.makeRequest("/api/system/selectdir");
	},
	dirresult:function(r){
		var p=this.raiseOnError;
		this.raiseOnError=false;
		r=this.procResult(r);
		this.raiseOnError=p;
		return r;
	}

}