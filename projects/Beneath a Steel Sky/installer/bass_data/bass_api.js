function BassApi(){}
 BassApi.prototype={
	api:new InstApi(),
	dsk:false,
	init:function(){
		this.api.raiseOnError=true;
		this.api.onServerStop=function(){
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
		var rpaths=[".scummvm.rc","Library/Preferences/ScummVM Preferences","ScummVM/scummvm.ini"];
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
	locateDsk:function(){
		try{
			this.log("locating scumm");
			r=this.locateScumm();
			if (!r)
				return false;
			this.log("SCUMM FOUND AT "+r);
			this.dsk=r;
		}catch(e)
		{
			this.log("error locating dsk:"+e.r+":"+e.d);
		}
	}
 }