function BassApi(){this.init(this);}
 BassApi.prototype={
	api:new InstApi(),
	dsk:false,
	init:function(obj){
		obj.api.raiseOnError=true;
		obj.api.onServerStop=function(){
			alert("Server stopped! You need to close this page.");
		}
	},
	log:function(s){
		this.api.raiseOnError=false;
		this.api.log(s);
		this.api.raiseOnError=true;
	},
	locateScumm:function(){
		pth=this.api.userdir().result;
		this.log("userdir is "+pth);
		var rpaths=[".scummvm.rc","Library/Preferences/ScummVM Preferences","Application Data/ScummVM/scummvm.ini"];
		for (i=0;i<rpaths.length;i++)
		{
			var fl=pth+"/"+rpaths[i];
			r=this.api.hasfile(fl);
			if (r.result)
				return fl;
		}
		this.log("scumm not found");
		return false;
	},
	finddisks:function(ini){
		var res=new Array(),inis=ini.split(']');
		for (i=0;i<inis.length;i++)
			if (inis[i].search(/gameid=sky/)>-1)
			{
				var ps=inis[i].split("path="),pth=ps[1].split("\n")[0];
				pth=pth.replace("\r","").replace("\t","");
				res.push(pth);
			}
		return res;
	},
	locateDsk:function(){
		try{
			this.log("locating scumm");
			r=this.locateScumm();
			if (!r)
				return false;
			this.log("SCUMM FOUND AT "+r);
			f=this.api.getfile(r);
			p=this.api.unescape(f.result);
			p=this.finddisks(p);
			this.dsk=p;
		}catch(e)
		{
			s=e.message;
			if (s=="API Error")
				s+=":"+e.r+":"+e.d;
			this.log("error locating dsk:"+s);
		}
		return false;
	}
 }