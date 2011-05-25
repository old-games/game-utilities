var bass=false;
function BassApi(){this.init(this);}
 BassApi.prototype={
	ress:[2149,2198,4116,4127,4210,12309,16405,16410,16413,18502,18572,18619,24590,24599,26668,28703,59538,59542,60096,60150,60520,60521,60600,60601,60602,60603,60604,60605,60606,60607],
	api:new InstApi(),
	dsk:false,
	badver:false,
	stage:0,
	onprogress:false,
	onlog:false,
	wf:0,
	dskf:false,
	delta:0,
	init:function(obj){
		obj.api.raiseOnError=true;
		obj.api.onServerStop=function(){
			alert("Это окно можно закрыть.");
		};
		bass=obj;
	},
	log:function(s){
		this.api.raiseOnError=false;
		this.api.log(s);
		this.api.raiseOnError=true;
	},
	locateScumm:function(){
		var pth=this.api.userdir().result,i,fl,r,rpaths=[".scummvm.rc","Library/Preferences/ScummVM Preferences","Application Data/ScummVM/scummvm.ini"];
		this.log("userdir is "+pth);
		for (i=0;i<rpaths.length;i++)
		{
			fl=pth+"/"+rpaths[i];
			r=this.api.hasfile(fl);
			if (r.result){return fl;}
		}
		this.log("scumm not found");
		return false;
	},
	finddisks:function(ini){
		var i,res=[],inis=ini.split(']'),ps,pth;
		for (i=0;i<inis.length;i++){
			if (inis[i].search(/gameid=sky/)>-1)
			{
				ps=inis[i].split("path=");
				pth=ps[1].split("\n")[0];
				pth=pth.replace("\r","").replace("\t","");
				res.push(pth);
			}
		}
		return res;
	},
	procEx:function(e){
		var s;
		s=e.message;
		if (s==="API Error"){s+=":"+e.r+":"+e.d;}
		this.log("Client exception :"+s);
		return s;
	},
	locateDsk:function(){
		var n='dsk',m='stage',r,f,p,i;
		try{
			r=this.api.hasvar(n).result;
			if (r)
			{
				this.dsk=this.api.getvar(n).result;
				this.log("bass from svr "+this.dsk);
				r=this.api.hasvar(m).result;
				if (r){this.stage=this.api.getvar(m).result;}
				return true;
			}
		}catch(e){}
		try{
			this.log("locating scumm");
			r=this.locateScumm();
			if (!r){return false;}
			this.log("SCUMM FOUND AT "+r);
			f=this.api.getfile(r);
			p=this.api.unescape(f.result);
			p=this.finddisks(p);
			for (i=0;i<p.length;i++)
			{
				if (this.checkDsk(p[i])>0){
					return this.setDsk(p[i]);
				}
			}
		}catch(e2)
		{
			this.procEx(e2);
		}
		return false;
	},
	getDskDnr:function(p){
		if (!p){p=this.dsk;}
		var x=p.charAt(p.length-1);
		if (x!=='\\' && x!=='/'){p+='/';}
		return [p+"sky.dsk",p+"sky.dnr"];
	},
	checkDsk:function(p){
		var r,x,f,cnt;
		try{
			x=this.getDskDnr(p);
			r=this.api.hasfile(x[0]);
			if (!r.result){return false;}
			r=this.api.hasfile(x[1]);
			if (!r.result){return false;}
			f=this.api.fopen(x[1]).result;
			cnt=this.api.fread(f,4);
			this.api.fclose(f);
			cnt=parseInt(cnt.result,16);
			this.log("count is "+cnt);
			if (cnt===5097){
				return 1;
			}else{
				this.badver=x[0];
				return -1;
			}
		}catch(e)
		{
			this.procEx(e);
		}
		return 0;
	},
	setDsk:function(p){
		var r;
		try{
			r=this.api.setvar('dsk',p);
			this.dsk=p;
			return true;
		}catch(e){
			this.procEx(e);
		}
		return false;
	},
	preparePatch:function(){
		var x=this.getDskDnr(false);
		try{
		this.delta=0;
		this.log("prepare files");
		this.api.backup(x[0]);
		this.api.backup(x[1]);
		this.api.clearmaps();
		this.dskf=this.api.makemap(x[0]).result;
		if (this.stage===0)
		{
			this.wf=this.api.fopen(x[1]).result;
			this.api.setvar("dnr",this.wf);
		}else{
			this.wf=this.api.getvar("dnr").result;}
		this.api.fseek(this.wf,4);
		this.api.setvar("stage",1);
		this.stage=1;
		this.log("files prepared");
		this.api.cantstop("");
		}catch(e)
		{
			this.onprogress(-666,this.procEx(e));
		}
	},
	applyPatch:function(someparam){
		this.preparePatch();
		if (this.stage===0)
		{
			this.log("bad patch stage");
			return false;
		}
		this.api.async(this.onstep);
		this.api.getvar("stage");
		return true;
	},
	progress:function(x){
		if (this.onprogress)
		{
			this.onprogress(parseInt(x*100/5097,10),0);
		}
	},
	finishPatch:function(r) {
		bass.api.sync();
		try{
			bass.api.procResult(r);
			bass.api.flush(bass.wf);
			bass.onprogress(666);
		}catch(e)
		{
			var x=bass.getDskDnr(false);
			bass.api.restore(x[0]);
			bass.api.restore(x[1]);
			bass.onprogress(-666,bass.procEx(e));
		}finally{
			bass.api.fclose(bass.wf);
			bass.wf=false;
			bass.stage=0;
			bass.api.remvar("stage");
			bass.api.canstop();
		}
	},
	rotbts:function(b,c){
		var r=0,i;
		for(i=0;i<c;i++)
		{
			r<<=8;
			r|=(b&0xFF);
			b>>=8;
		}
		return r;
	},
	getnums:function(s){
		var s1,id,ofs,sz,fl;
		s1=s.substr(0,4);
		id=parseInt(s1,16);
		id=this.rotbts(id,2);
		s1=s.substr(4,6);
		ofs=parseInt(s1,16);
		ofs=this.rotbts(ofs,3);
		if (ofs>0x800000){
			ofs=(ofs&0x7FFFFF)<<4;}
		s1=s.substr(10,6);
		fl=parseInt(s1,16);
		fl=this.rotbts(fl,3);
		sz=(fl&0x3FFFFF);
		fl=(fl&0xC00000);
		return [id,ofs,sz,fl];
	},
	setnums:function(s,o,sz,flg){
		if (o>0x7FFFFF){
			o=(o>>4)+0x800000;}
		o=this.rotbts(o,3);
		var s1=o.toString(16);
		while(s1.length<6){
			s1='0'+s1;}
		s=s.substr(0,4)+s1+s.substr(10,6);
		sz=this.rotbts(sz+flg,3);
		s1=sz.toString(16);
		while(s1.length<6){
			s1='0'+s1;}
		s=s.substr(0,10)+s1;
		return s;
	},
	procres:function(f){
	  var c=false,o=parseInt(f[1],10),s=parseInt(f[2],10),ad=0,v,i,r;
	  if (this.delta!==0)
	  {
		c=true;
		o+=this.delta;
		if (o>0x7FFFFF) {while ((o&0x0F)!==0){ad++;o++;}}
		if (ad>0)
		{
			v='';
			for (i=0;i<ad;i++){
				v+="00";}
			this.api.mapval(this.dskf,v,f[1],0);
			this.delta+=ad;
		}
	  }
	  for (i=0;i<this.ress.length;i++){
	  if (this.ress[i]===f[0])
	  {
		r=this.api.mapres(this.dskf,""+f[0]+".bin",f[1],f[2]);
		this.delta+=parseInt(r.delta,10);
		if (r.delta!==0)
		{
			s=parseInt(r.result,10);
			c=true;
		}
		break;
	  }}
	  return [c,o,s];
	},
	onstep:function(r){
		var p,st,rs,c,wc,ps,ns,j;
		bass.api.sync();
		try{
			r=parseInt(bass.api.procResult(r).result,10);
			c=500;
			if (r+500>5098){
				c=5098-r;}
			p=bass.api.fread(bass.wf,8*c,1);
			st=p.result;
			wc=false;
			ns='';
			for (j=0;j<c;j++)
			{
				ps=st.substr(j*16,16);
				rs=bass.getnums(ps);
				p=bass.procres(rs);
				if (p[0])
				{
					wc=true;
					ps=bass.setnums(ps,p[1],p[2],rs[3]);
				}
				ns+=ps;
			}
			if (wc)
			{
				bass.api.fseek(bass.wf,-8*c,1);
				bass.api.fwrite(bass.wf,ns,1);
			}
			r+=c;
			if (r>=5098)
			{
				bass.api.async(bass.finishPatch);
				bass.api.applymaps();
				return true;
			}
			bass.progress(r);
		}catch(e){
			bass.onprogress(-666,bass.procEx(e));
			return false;
		}
		bass.api.async(bass.onstep);
		bass.api.setvar('stage',r);
	}
 };