function IsIE() {
	var ua=navigator.userAgent.toLowerCase(); 
	if (ua.indexOf("msie")!==-1){
		return true;}
	return false;
}
var isie=IsIE(),thegame=false;
function objofs(obj){
	var x=0,y=0;
	do{
		x+=obj.offsetLeft;
		y+=obj.offsetTop;
	}while(obj=obj.offsetParent);
	return [x,y];
}
function setopa(obj,perc){
	if (isie){
		obj.style.filter = 'alpha(opacity=' + perc + ')';
	}else{
		obj.style.opacity=perc/100;}
		
}

function Sprite(parent,img,sz,sprts,z,noactive,hidden){this.init(parent,img,sz,sprts,z,noactive,hidden);}
Sprite.prototype={
	init:function(parent,img,sz,sprts,z,noactive,hidden){
		this.obj=false;
		this.loop=true;
		this.active=true;
		this.played=false;
		this.parent=parent;
		this.img=img;
		this.curspr=0;
		this.w=sz[2];
		this.h=sz[3];
		this.x=sz[0];
		this.y=sz[1];
		this.from=0;
		this.to=sprts-1;
		if (noactive)
		{
			this.loop=false;
			this.active=false;
		}
		this.hidden=hidden;
		this.id=parent.objid();
		if (!z){z=1;}
		this.z=z;
		this.sprites=sprts;
		this.destx=0;
		this.desty=0;
		this.dx=0;
		this.dy=0;
		this.moveing=false;
		this.moved=false;
	},
	setup:function(visible){
		var v='',obj;
		if (!visible){
			v=isie?"filter:alpha(opacity=0);":"opacity:0;";}
		if (this.hidden){
			v+="visibility:hidden;";}
		document.getElementById('objects').innerHTML+='<div width="'+this.w+'px" height="'+this.h+'px" style="position:absolute;width:'+this.w+'px;height:'+this.h+'px;'+
			'left:'+this.x+'px;top:'+this.y+'px;z-index:'+this.z+';"><img src="'+this.img+'" id="spr'+this.id+'" style="position:absolute;z-index:'+this.z+';'+v+'"></div>';
		obj=document.getElementById('spr'+this.id);
		this.ypos=parseInt(obj.style.top,10);
		if (!this.ypos){
			this.ypos=0;}
		obj.style.clip='rect('+this.curspr*this.h+'px,'+this.w+'px,'+((this.curspr+1)*this.h-1)+'px,0px)';
		obj.style.top=''+this.ypos-this.curspr*this.h+'px';
	},
	loop:function(from,to){
		this.play(from,to,true);
	},
	play:function(from,to,loop,played){
		if (from<0 || to<0)
		{
			from=0;
			to=this.sprites-1;
		}
		this.played=played;
		this.loop=loop;
		this.from=from;
		this.curspr=from;
		this.to=to;
		this.active=true;
	},
	stop:function(){
		this.active=false;
	},
	getObj:function(){
		var dv;
		if (!this.obj)
		{
			this.obj=document.getElementById('spr'+this.id);
			if (!this.obj){
				return false;}
			this.obj.onmousemove=this.parent.onmousemove;
			this.obj.onclick=this.parent.onclick;
			dv=this.obj.parentNode;
			dv.onmousemove=this.parent.onmousemove;
			dv.onclick=this.parent.onclick;
		}
		return this.obj;
	},
	sprite:function(sprite,played){
		this.play(sprite,sprite,false,played);
	},
	step:function(){
		var obj,dv,wx,nx,wy,ny,rct,up;
		obj=this.getObj();
		if (!obj)
		{
			return false;
		}
		if (this.moveing)
		{
			dv=obj.parentNode;
			if (this.dx!==0)
			{
				wx=parseInt(dv.style.left,10);
				nx=wx+this.dx;
				if ((this.destx>=nx && this.destx<=wx) || (this.destx<=nx && this.destx>=wx))
				{
					nx=this.destx;
					this.dx=0;
				}
				dv.style.left=nx;
				this.x=nx;
			}
			if (this.dy!==0)
			{
				wy=parseInt(dv.style.top,10);
				ny=wy+this.dy;
				if ((this.desty>=ny && this.desty<=wy) || (this.desty<=ny && this.desty>=wy))
				{
					ny=this.desty;
					this.dy=0;
				}
				dv.style.top=ny;
				this.y=ny;
			}
			if (this.dx===0 && this.dy===0)
			{
				this.moveing=false;
				if (this.moved){
					this.moved();}
			}
		}
		if (!this.active){
			return;}
		rct='rect('+this.curspr*this.h+'px,'+this.w+'px,'+((this.curspr+1)*this.h-1)+'px,0px)';
		obj.style.top=this.ypos-this.curspr*this.h;
		obj.style.clip=rct;
		up=1;
		if (this.from>this.to){
			up=-1;}
		if (this.curspr===this.to)
		{
			if (this.loop){
				this.curspr=this.from;
			}else{
				this.active=false;
				if (this.played){
					this.played();}
				}
		}else{
			this.curspr+=up;}
	},
	opa:function(perc){
		setopa(this.getObj(),perc);
	},
	hide:function(){
		this.hidden=true;
		this.getObj().style.visibility='hidden';
	},
	show:function(){
		this.hidden=false;
		this.getObj().style.visibility='visible';
	},
	move:function(dx,dy,deltax,deltay,moved){
		var dv=this.getObj().parentNode;
		this.dx=dx;
		this.dy=dy;
		this.destx=parseInt(dv.style.left,10)+deltax;
		this.desty=parseInt(dv.style.top,10)+deltay;
		this.moved=moved;
		this.moveing=true;
	},
	place:function(x,y){
		var dv=this.getObj().parentNode;
		dv.style.left=parseInt(x,10)+"px";
		dv.style.top=parseInt(y,10)+"px";
	},
	pos:function(){
		var dv=this.getObj().parentNode;
		return [parseInt(dv.style.left,10),parseInt(dv.style.top,10)];
	}
};

function Region(sz,title,onclick){this.init(sz,title,onclick);}
Region.prototype={
	init:function(sz,title,onclick,debug,parent){
		this.x=sz[0];
		this.y=sz[1];
		this.w=sz[2];
		this.h=sz[3];
		this.title=title;
		this.onclick=onclick;
	},
	active:function(x,y){
		if (x>=this.x && x<=this.x+this.w && y>=this.y && y<=this.y+this.h){
			return true;}
		return false;
	},
	getTitle:function(){
		if (!this.title){
			return "";}
		return this.title;
	},
	click:function(x,y){
		if (this.onclick){
			return this.onclick(x,y);}
		return false;
	}
};

function Screen(bg,w,h){this.init(bg,w,h);}
Screen.prototype={
	anim_delay:2,
	init:function(bg,w,h){
		this.objs=[];
		this.jobjs=[];
		this.regs=[];
		this.animpos=0;
		this.h=h;
		this.w=w;
		this.bg=bg;
		var dv=document.getElementById('main_img');
		dv.style.height=h;
		dv.style.width=w;
		dv.style.marginTop=-h/2;
		dv.style.marginLeft=-w/2;
		this.obj=document.getElementById('bgimg');
		this.obj.style.width=w;
		this.obj.style.height=h;
		this.obj.onmousemove=this.onmousemove;
		this.obj.onclick=this.onclick;
	},
	setup:function(visible){
		var i;
		this.clear();
		if (!this.bg)
		{
			this.obj.style.visibility='hidden';
		}else{
			this.obj.src=this.bg;}
		this.opa=(visible?100:0);
		if (!visible){
			this.obj.style.opacity=0;}
		if (this.bg){
			this.obj.style.visibility='visible';}
		for(i=0;i<this.objs.length;i++){
			this.objs[i].setup(visible);}
	},
	clear:function(){
		var i;
		this.obj.src="";
		document.getElementById('objects').innerHTML="";
		for(i=0;i<this.objs.length;i++){
			this.objs[i].obj=false;}
	},
	fadein:function(f){
		this.endfade=false;
		this.opa=0;
		this.fade=5;
	},
	fadeout:function(on_end){
		this.endfade=on_end;
		this.opa=100;
		this.fade=-5;
	},
	objid:function(obj){
		return this.objs.length;
	},
	addobj:function(obj){
		this.objs[this.objs.length]=obj;
	},
	addjobj:function(obj){
		this.jobjs[this.jobjs.length]=obj;
	},
	addreg:function(reg){
		this.regs[this.regs.length]=reg;
	},
	opaall:function(perc){
		var i;
		setopa(this.obj,perc);
		for (i=0;i<this.jobjs.length;i++){
			setopa(this.jobjs[i],perc);}
		for (i=0;i<this.objs.length;i++){
			this.objs[i].opa(perc);}
	},
	step:function(){
		var i;
		this.working=true;
		if (this.fade!==0)
		{
			this.opa+=this.fade;
			if (this.fade<0 && this.opa<=0){this.opa=0;this.fade=0;}
			if (this.fade>0 && this.opa>=100){this.opa=100;this.fade=0;}
			this.opaall(this.opa);
			if (this.fade===0 && this.endfade){
				this.endfade();}
		}
		this.animpos++;
		if ((this.animpos%this.anim_delay)===0)
		{
			for (i=0;i<this.objs.length;i++){
				this.objs[i].step();}
			this.animpos=0;
		}
		this.working=false;
	},
	somemousemove:function(e,self){
		var x=0,y=0,f=false,t,dx,dy,xy,i;
		x=e.clientX + document.body.scrollLeft;
		y=e.clientY + document.body.scrollTop;
		xy=objofs(self.obj);
		dx=x-xy[0];
		dy=y-xy[1];
		t=document.getElementById('title');
		for(i=0;i<self.regs.length;i++){
			if (self.regs[i].active(dx,dy))
			{
				t.innerHTML=self.regs[i].getTitle();
				t.style.left=x-150;
				t.style.top=y-50;
				f=true;
			}
		}
		if (!f)
		{
			t.innerHTML="";
			t.style.left=-500;
		}
		//document.getElementById('log').innerHTML="move x="+dx+",y="+dy+"    ofs1:"+xy[0]+"   ofs2:"+xy[1];
	},
	onmousemove:function(evt){
			if (!evt){
				evt=window.event;}
			var sf=thegame.curscreen;
			sf.somemousemove(evt,sf);
	},
	someclick:function(e,self){
		var x=0,y=0,f=false,t,dx,dy,xy,i;
		x=e.clientX + document.body.scrollLeft;
		y=e.clientY + document.body.scrollTop;
		xy=objofs(self.obj);
		dx=x-xy[0];
		dy=y-xy[1];
		if (this.prevclickx===dx && this.prevclicky===dy){
			return;}
		this.prevclickx=dx;
		this.prevclicky=dy;
		for(i=0;i<self.regs.length;i++){
			if (self.regs[i].active(dx,dy))
			{
				self.regs[i].click(dx,dy);
			}}
	},
	onclick:function(evt){
		if (!evt){
			evt=window.event;}
		var sf=thegame.curscreen;
		sf.someclick(evt,sf);
	}
};

function Lever(obj){
	obj.ison=false;
	obj.on=function(){
		this.ison=true;
		this.play(0,3);
	};
	obj.off=function(){
		this.ison=false;
		this.play(3,0);
	};
	obj.swich=function(){
		if (this.ison){
			this.off();
		}else{
			this.on();}
	};
	return obj;
}

var rob,robdone,robdone_wlk,robdone_rot,robdone_screen,robdone_lever,robdy=0,robdiry=0;
function Foster(parent,x,y,dir){this.init(parent,x,y,dir);}
Foster.prototype={
	down:0,
	left:1,
	up:2,
	right:3,
	init:function(parent,x,y,dir){
		this.parent=parent;
		this.dir=dir;
		this.normalspr=new Sprite(parent,"foster.png",[x,y,64,112],50,2,true);
		parent.addobj(this.normalspr);
		this.pullspr=new Sprite(parent,"foster_pull.png",[300,100,64,112],6,2,true,true);
		parent.addobj(this.pullspr);
		this.pushspr=new Sprite(parent,"foster_push.png",[320,100,64,112],8,2,true,true);
		parent.addobj(this.pushspr);
		this.stop();
	},
	stop:function(dir,ondone){
		if (!dir){
			dir=this.dir;}
		switch(this.dir){
			case this.up:this.normalspr.sprite(44,ondone);break;
			case this.down:this.normalspr.sprite(40,ondone);break;
			case this.left:this.normalspr.sprite(42,ondone);break;
			case this.right:this.normalspr.sprite(46,ondone);break;
		}
	},
	walkdir:function(delta,dir,ondone){
		var dx=0,dy=0,delx=0,dely=0,from=0,end=0;
		rob=this;
		robdone=ondone;
		this.dir=dir;
		switch(dir){
			case this.up:from=0;end=44;dy=-5;dely=-delta;break;
			case this.down:from=10;end=40;dy=5;dely=delta;break;
			case this.left:from=20;end=42;dx=-5;delx=-delta;break;
			case this.right:from=30;end=46;dx=5;delx=delta;break;
		}
		this.rotate(this.dir,function(){
			rob.normalspr.play(from,from+9,true);
			rob.normalspr.move(dx,dy,delx,dely,function(){
				rob.stop(rob.dir,robdone);
			});
		});
	},
	walkto:function(x,y,ondone){
		var  ps,dx,dy,dirx,diry,r;
		ps=this.normalspr.pos();
		dx=x-ps[0];
		dy=y-ps[1];
		rob=this;
		robdone_wlk=ondone;
		dirx=this.right;
		if (dx<0){
			dirx=this.left;
			dx=-dx;
		}
		diry=this.down;
		if (dy<0){
			diry=this.up;
			dy=-dy;
		}
		if (Math.floor(Math.random()*1000)%2===0)
		{
			r=dx;dx=dy;dy=r;
			r=dirx;dirx=diry;diry=r;
		}
		if (dx){
			robdy=dy;
			robdiry=diry;
			this.walkdir(dx,dirx,function(){
				if (robdy) {rob.walkdir(robdy,robdiry,robdone_wlk);}
				else{ if (robdone_wlk) {robdone_wlk();}}
			});
		}else{
				if (dy) {rob.walkdir(dy,diry,robdone_wlk);}
				else {if (robdone_wlk) {robdone_wlk();}}
			}
	},
	rotate:function(dir,ondone){
		rob=this;
		robdone_rot=ondone;
		if (this.dir===dir)
		{
			if (ondone){
				ondone();}
			return;
		}
		switch(this.dir){
			case this.up:
				if (dir===this.right){this.normalspr.play(45,46,false,ondone);}
				if (dir===this.left){this.normalspr.play(43,42,false,ondone);}
				if (dir===this.down){this.normalspr.play(43,40,false,ondone);}
				break;
			case this.left:
				if (dir===this.right){this.normalspr.play(43,46,false,ondone);}
				if (dir===this.up){this.normalspr.play(43,44,false,ondone);}
				if (dir===this.down){this.normalspr.play(41,40,false,ondone);}
				break;
			case this.right:
				if (dir===this.left){this.normalspr.play(45,42,false,ondone);}
				if (dir===this.up){this.normalspr.play(45,44,false,ondone);}
				if (dir===this.down){this.normalspr.play(47,47,false,function(){
					rob.normalspr.play(40,40,false,robdone_rot);
				});}
				break;
			case this.down:
				if (dir===this.right){this.normalspr.play(47,46,false,ondone);}
				if (dir===this.left){this.normalspr.play(41,42,false,ondone);}
				if (dir===this.up){this.normalspr.play(41,44,false,ondone);}
				break;
		}
		this.dir=dir;
	},
	dontknow:function(ondone){
		rob=this;
		robdone=ondone;
		this.rotate(this.down,function(){
		rob.normalspr.play(48,49,false,function(){
			rob.normalspr.play(49,48,false,function(){
				rob.normalspr.sprite(40,robdone);
			});
		});
		});
	},
	pressscreen:function(ondone){
		rob=this;
		robdone_screen=ondone;
		this.walkto(320,100,function(){
			rob.rotate(rob.up,function(){
				rob.pushspr.show();
				rob.normalspr.hide();
				rob.pushspr.play(-1,-1,false,function(){
					rob.pushspr.hide();
					rob.normalspr.show();
					rob.stop();
					if (robdone_screen){
						robdone_screen();}
				});
			});
		});
		return false;
	},
	pulllever:function(ondone){
		rob=this;
		this.walkto(300,100,function(){
			rob.rotate(rob.up,function(){
				rob.pullspr.show();
				rob.normalspr.hide();
				rob.pullspr.play(0,2,false,function(){
					thegame.lever.on();
					rob.pullspr.play(2,5,false,function(){
						if (thegame.api.dsk)
						{
							thegame.patch();
						}else{
							thegame.lever.off();
							rob.normalspr.show();
							rob.pullspr.hide(0);
							rob.dontknow();
						}
					});
				});
			});
		});
	}
};


function GameApi(){this.init();}
GameApi.prototype={
	api:new BassApi(),
	bad_ver:"Не та версия BaSS. Хочу 0.0372.",
	no_ver:"Путь к Bass не найден.",
	ontimer:function(){
		if (!this.curscreen.working){
			this.curscreen.step();}
	},
	init:function(){
		var tit,pe,ms,xms,x;
		this.api.locateDsk();
		if (this.api.dsk)
		{
			document.editform.path.value=this.api.dsk;
		}else{
			document.editform.path.style.color='red';
			if (this.api.badver){
				document.editform.path.value=this.bad_ver;
			}else{
				document.editform.path.value=this.no_ver;}
		}
		document.onselectstart=function(){return false;};
		this.curscreen=false;
		thegame=this;
		tit=document.getElementById('title');
		pe=document.getElementById('pathedit');
		this.mainscreen=new Screen("scr.png",640,384);
		ms=this.mainscreen;
		ms.addobj(new Sprite(ms,"cons1.png",[188,128,38,28],4));
		ms.addobj(new Sprite(ms,"cons2.png",[284,108,58,24],8));
		this.lever=new Lever(new Sprite(ms,'lever.png',[348,104,14,24],4,1,true));
		ms.addobj(this.lever);
		ms.addreg(new Region([348,104,14,24],'Рычаг',this.onleverclick));
		ms.addreg(new Region([321,108,20,17],'Экран',this.onscreenclick));
		ms.addreg(new Region([180,198,210,100],false,this.robmove));
		ms.addjobj(tit);
		this.rob=new Foster(ms,150,150,0);
		x=new Sprite(ms,"scr_mask.png",[136,235,327,150],1,3,true);
		ms.addobj(x);
		x.sprite(0);
		this.lincscreen=new Screen("linc.png",640,384);
		xms=this.lincscreen;
		this.exit_btn=new Sprite(xms,"exit_btn.png",[582,87,38,82],3,1,true);
		xms.addobj(this.exit_btn);
		xms.addreg(new Region([582,87,38,82],false,this.back));
		xms.addjobj(tit);
		xms.addjobj(pe);
		this.donescreen=new Screen(false,640,384);
		this.donescreen.addjobj(document.getElementById('patchit'));
		if (this.api.stage>0)
		{
			this.patch();
		}else{
			this.setScreen(ms);}
		window.setInterval(function(){thegame.ontimer();},40);
	},
	endFadeOut:function(){
		thegame.curscreen=false;
		thegame.setScreen(thegame.nextscreen);
		document.getElementById('title').innerHTML="";
	},
	setScreen:function(scr){
		if (this.curscreen)
		{
			this.nextscreen=scr;
			this.curscreen.fadeout(this.endFadeOut);
			return;
		}
		this.curscreen=scr;
		scr.setup(false);
		scr.fadein();
	},
	onleverclick:function(){
		thegame.rob.pulllever();
	},
	onscreenclick:function(){
		thegame.rob.pressscreen(function(){
			thegame.exit_btn.sprite(0);
			document.getElementById('pathedit').style.left=50+"px";
			thegame.setScreen(thegame.lincscreen);
		});
	},
	back:function(){
		thegame.lever.ison=false;
		thegame.lever.sprite(0);
		thegame.rob.stop();
		thegame.exit_btn.play(-1,-1);
		document.getElementById('pathedit').style.left=-500+"px";
		thegame.setScreen(thegame.mainscreen);
	},
	robmove:function(dx,dy){
		thegame.rob.walkto(dx-32,dy-112);
	},
	mousemove:function(e){
		thegame.curscreen.onmousemove(e);
	},
	onclick:function(e){
		thegame.curscreen.onclick(e);
	},
	selectfolder:function(){
		this.api.api.selectdir(function(r){
			r=thegame.api.api.dirresult(r);
			if (r.r===0)
			{
				if (r.result===""){
					return;}
				var p=thegame.api.checkDsk(r.result);
				if (p>0)
				{
					document.editform.path.style.color='lime';
					thegame.api.setDsk(r.result);
					document.editform.path.value=r.result;
				}else{
					document.editform.path.style.color='red';
					if (p===0){
						document.editform.path.value=thegame.no_ver;}
					if (p===-1){
						document.editform.path.value=thegame.bad_ver;}
				}
			}
		});
	},
	patch:function(){
		if (thegame.curscreen)
		{
			thegame.curscreen.opaall(0);
			thegame.curscreen=false;
		}
		thegame.setScreen(thegame.donescreen);
		document.getElementById('patchit').style.left=0+"px";
		thegame.api.onprogress=function(p,err){
			var perc=document.getElementById('percents');
			if (p<0)
			{
				perc.innerHTML=err;
				perc.style.color='red';
				document.endform.btn.style.visibility='visible';
			}else if (p>100)
			{
				perc.innerHTML='Готово';
				document.endform.btn.style.visibility='visible';
			}else{
				perc.innerHTML=p+"%";
			}
		};
		if (!thegame.api.applyPatch())
		{
			alert("Unrecoveable error in patch.");
		}
	},
	close:function(){
		this.api.api.close();
	}
};