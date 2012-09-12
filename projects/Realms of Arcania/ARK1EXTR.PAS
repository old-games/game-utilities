const
 anames:array[1..307] of string[15]=(
'PLAYM_UK','KDBACK.DAT','KCBACK.DAT','KLBACK.DAT','KSBACK.DAT','KARTE.DAT',
'BICONS','OBJECTS.NVF','LROUT.DAT','SROUT.DAT','HSROUT.DAT','FONT6','FONT8',
'GGSTS.NVF','TEXT.LTX','ICONS','MONSTER','MONSTER.TAB','COMPASS','MAPTEXT.LTX',
'ZUSTA_UK','FIGHTTXT.LTX','ANIS','ANIS.TAB','MFIGS','MFIGS.TAB','THORWAL.DAT',
'SERSKE.DAT','BREIDA.DAT','PEILINEN.DAT','ROVAMUND.DAT','NORDVEST.DAT',
'KRAVIK.DAT','SKELELLE.DAT','MERSKE.DAT','EFFERDUN.DAT','TJOILA.DAT',
'RUKIAN.DAT','ANGBODIRTAL.DAT','AUPLOG.DAT','VILNHEIM.DAT','BODON.DAT',
'OBERORKEN.DAT','PHEXCAER.DAT','GROENVEL.DAT','FELSTEYN.DAT','EINSIEDL.DAT',
'ORKANGER.DAT','CLANEGH.DAT','LISKOR.DAT','THOSS.DAT','TJANSET.DAT','ALA.DAT',
'ORVIL.DAT','OVERTHORN.DAT','ROVIK.DAT','HJALSING.DAT','GUDDASUN.DAT',
'KORD.DAT','TREBAN.DAT','ARYN.DAT','RUNINSHA.DAT','OTTARJE.DAT','SKJAL.DAT',
'PREM.DAT','DASPOTA.DAT','RYBON.DAT','LJASDAHL.DAT','VARNHEIM.DAT',
'VAERMHAG.DAT','TYLDON.DAT','VIDSAND.DAT','BRENDHIL.DAT','MANRIN.DAT',
'FTJOILA.DAT','FANGBODI.DAT','HJALLAND.DAT','RUNIN.DAT','THORWAL.LTX',
'SERSKE.LTX','BREIDA.LTX','PEILINEN.LTX','ROVAMUND.LTX','NORDVEST.LTX',
'KRAVIK.LTX','SKELELLE.LTX','MERSKE.LTX','EFFERDUN.LTX','TJOILA.LTX',
'RUKIAN.LTX','ANGBODIR.LTX','AUPLOG.LTX','VILNHEIM.LTX','BODON.LTX',
'OBERORKE.LTX','PHEXCAER.LTX','GROENVEL.LTX','FELSTEYN.LTX','EINSIEDL.LTX',
'ORKANGER.LTX','CLANEGH.LTX','LISKOR.LTX','THOSS.LTX','TJANSET.LTX','ALA.LTX',
'ORVIL.LTX','OVERTHOR.LTX','ROVIK.LTX','HJALSING.LTX','GUDDASUN.LTX',
'KORD.LTX','TREBAN.LTX','ARYN.LTX','RUNINSHA.LTX','OTTARJE.LTX','SKJAL.LTX',
'PREM.LTX','DASPOTA.LTX','RYBON.LTX','LJASDAHL.LTX','VARNHEIM.LTX',
'VAERMHAG.LTX','TYLDON.LTX','VIDSAND.LTX','BRENDHIL.LTX','MANRIN.LTX',
'F_TJOILA.LTX','F_ANGBOD.LTX','HJALLAND.LTX','L_RUNIN.LTX','TAVERN.TLK',
'SPSTAR.NVF','GUERTEL.NVF','HAFEN.LTX','FACE.NVF','HYGBACK.NVF','HYGGELIK.NVF',
'SKULL.NVF','OUTRO1.NVF','OUTRO2.NVF','OUTRO3.NVF','TOWNPAL.DAT','THORWAL.XMI',
'SUMMARY.XMI','TEMPLE.XMI','TERMS.XMI','SMITH.XMI','INN.XMI','HEALER.XMI',
'CAMP.XMI','VICTORY.XMI','SAMPLE.AD','ATTIC','POPUP.DAT','____1','____2',
'F092.TLK','HERBERG.TLK','____3','DASPOTA1.TLK','DASPOTA2.TLK','DASPOTA3.TLK',
'INFO1.TLK','INFO2.TLK','INFO3.TLK','INFO4.TLK','INFO5.TLK','INFO6.TLK',
'INFO7.TLK','SCHMIED.TLK','GHANDEL.TLK','KHANDEL.TLK','WHANDEL.TLK','F115.TLK',
'EREMIT.TLK','HYGGELIK.TLK','WEAPONS.NVF','BUCH.DAT','SPELLOBJ.NVF',
'IN_HEADS.NVF','TEMPICON','SHIPSL.NVF','STONESL.NVF','MARBLESL.NVF',
'TFLOOR1.NVF','TDIVERSE.NVF','HOUSE1.NVF','HOUSE2.NVF','HOUSE3.NVF',
'HOUSE4.NVF','FEATURE.LTX','FEATURE1.LTX','FEATURE2.LTX','FEATURE3.LTX',
'FEATURE4.LTX','FEATURE5.LTX','FEATURE6.LTX','FEATURE7.LTX','FEATURE8.LTX',
'FIGHTOBJ.NVF','SCENARIO.LST','KDLBACK.DAT','KCLBACK.DAT','KLLBACK.DAT',
'KSLBACK.DAT','FIGHT.LST','SKARTE.NVF','GAMES.NAM','ITEMNAME','MONNAMES',
'THORWAL1.LTX','THORWAL2.LTX','DUNGEON.XMI','COMBAT.XMI','PLAYM_US','ZUSTA_US',
'ANI.DAT','WEAPANI.DAT','MONSTER.DAT','BSKILLS.DAT','ITEMS.DAT','CHARTEXT.LTX',
'SPELLTXT.LTX','WONDER.LTX','STRASSE.LTX','NSC.LTX','NARIELL.NPC','HARIKA.NPC',
'CURIAN.NPC','ARDORA.NPC','GARSVIK.NPC','ERWO.NPC','FINGER.NVF','LTURM.NVF',
'WFIGS','WFIGS.TAB','SPLASHES.DAT','FEATURE9.LTX','PHEX1.LTX','PHEX2.LTX',
'WILD.LTX','WAFFINFO.LTX','SHIP.DNG','F046.DNG','F051.DNG','F061.DNG',
'F076.DNG','F094.DNG','F100.DNG','F108.DNG','F126.DNG','F129.DNG','F131.DNG',
'OBER.DNG','PREM.DNG','THORWAL.DNG','FINAL.DNG','SHIP.DDT','F046.DDT',
'F051.DDT','F061.DDT','F076.DDT','F094.DDT','F100.DDT','F108.DDT','F126.DDT',
'F129.DDT','F131.DDT','OBER.DDT','PREM.DDT','THORWAL.DDT','FINAL.DDT',
'SHIP.DTX','F046.DTX','F051.DTX','F061.DTX','F076.DTX','F094.DTX','F100.DTX',
'F108.DTX','F126.DTX','F129.DTX','F131.DTX','OBER.DTX','PREM.DTX',
'THORWAL.DTX','FINAL.DTX','TFLOOR2.NVF','STORY.LTX','FX1.VOC','FX2.VOC',
'FX3.VOC','FX4.VOC','FX5.VOC','FX6.VOC','FX7.VOC','FX8.VOC','FX9.VOC',
'FX10.VOC','FX11.VOC','FX12.VOC','FX13.VOC','FX14.VOC','FX15.VOC','FX16.VOC',
'FX17.VOC','FX18.VOC');
type
 ifil=record
  nme:string[25];
  ofs:longint;
  sze:word;
  shit:array[1..$60] of byte;
  end;
 dfil=record
  nme:array[1..12] of char;
  ofs:longint;
  end;
var
 ihd:array[0..34] of ifil;
 hda:array[1..308] of longint absolute ihd;
 dhd:array[1..39] of dfil absolute ihd;
 f,g:file;
 i,j,k,ii:integer;
 fp,fsz,l1:longint;
 buf:array[0..$7FFF] of byte;
 lia:array[0..$1FFF] of longint absolute buf;
 ch:char;
 s:string;
procedure SplitNVF(nm:string);
 begin
  {$I-}
  Reset(f,1);
  {$I+}
  if IOResult<>0 then begin
   Writeln(' cannot open!');
   Exit;
   end;
  fsz:=FileSize(f);
  fp:=0;
  i:=0;
  repeat
   Str(i:3,s);
   if s[1]=' ' then s[1]:='0';
   if s[2]=' ' then s[2]:='0';
   s:=nm+s+'.NVF';
   Writeln(s);
   Assign(g,s);
   Rewrite(g,1);
   Blockread(f,buf,3);
   Blockwrite(g,buf,3);
   j:=word((@buf[1])^);
   k:=4*j+4;
   Blockread(f,buf,k);
   Blockwrite(g,buf,k);
   Inc(fp,k+3);
   l1:=0;
   for ii:=1 to j do
    Inc(l1,lia[ii]);
   Inc(fp,l1);
   Blockread(f,buf,l1);
   Blockwrite(g,buf,l1);
   Close(g);
   Inc(i);
  until fp=fsz;
  Close(f);
  Erase(f);
 end;
begin
 Writeln('Splitting BLADE.DAT:');
 Assign(f,'blade.dat');
 {$I-}
 Reset(f,1);
 {$I+}
 if IOResult<>0 then Writeln(' cannot open!')
 else begin
  Blockread(f,hda,308*4);
  hda[308]:=FileSize(f);
  for i:=1 to 307 do
   begin
   Writeln(anames[i]);
   Seek(f,hda[i]);
   Assign(g,anames[i]);
   Rewrite(g,1);
   j:=(hda[i+1]-hda[i]) shr 15;
   for k:=1 to j do
    begin
    Blockread(f,buf,$8000);
    Blockwrite(g,buf,$8000);
    end;
   j:=(hda[i+1]-hda[i]) and $7FFF;
   Blockread(f,buf,j);
   Blockwrite(g,buf,j);
   Close(g);
   end;
  Close(f);
  end;
 Writeln('Splitting DSAGEN.DAT:');
 Assign(f,'dsagen.dat');
 {$I-}
 Reset(f,1);
 {$I+}
 if IOResult<>0 then Writeln(' cannot open!')
 else begin
  Blockread(f,dhd,sizeof(dhd));
  dhd[39].ofs:=FileSize(f);
  for i:=1 to 38 do
   begin
   s:=dhd[i].nme;
   j:=Pos(#0,s);
   if j>0 then byte(s[0]):=Lo(j-1);
   Writeln(s);
   Seek(f,dhd[i].ofs);
   Assign(g,s);
   Rewrite(g,1);
   j:=(dhd[i+1].ofs-dhd[i].ofs) shr 15;
   for k:=1 to j do
    begin
    Blockread(f,buf,$8000);
    Blockwrite(g,buf,$8000);
    end;
   j:=(dhd[i+1].ofs-dhd[i].ofs) and $7FFF;
   Blockread(f,buf,j);
   Blockwrite(g,buf,j);
   Close(g);
   end;
  Close(f);
  end;
 Writeln('Loading INTRODAT.DIR');
 Assign(f,'introdat.dir');
 {$I-}
 Reset(f,1);
 {$I+}
 if IOResult<>0 then Writeln(' cannot open!')
 else begin
  Blockread(f,ihd,sizeof(ihd));
  Close(f);
  Writeln('Splitting INTRODAT.VOL:');
  Assign(f,'introdat.vol');
  {$I-}
  Reset(f,1);
  {$I+}
  if IOResult<>0 then Writeln(' cannot open!')
  else begin
   for i:=1 to 34 do
    begin
    Writeln(ihd[i].nme);
    Seek(f,ihd[i].ofs);
    Assign(g,ihd[i].nme);
    Rewrite(g,1);
    if ihd[i].sze>$7FFF then begin
     Blockread(f,buf,$8000);
     Blockwrite(g,buf,$8000);
     end;
    j:=ihd[i].sze and $7FFF;
    Blockread(f,buf,j);
    Blockwrite(g,buf,j);
    Close(g);
    end;
   Close(f);
   end;
  end;
 Write('Split collections of graphic files into single files? (Y/N) ');
 Readln(ch);
 if (ch<>'Y') and (ch<>'y') then Halt(0);
 Writeln('Splitting ANIS:');
 Assign(f,'anis');
 {$I-}
 Reset(f,1);
 {$I+}
 if IOResult<>0 then Writeln(' cannot open!')
 else begin
  fsz:=FileSize(f);
  fp:=0;
  i:=0;
  repeat
   Str(i:4,s);
   if s[1]=' ' then s[1]:='0';
   if s[2]=' ' then s[2]:='0';
   if s[3]=' ' then s[3]:='0';
   s:='ANIS'+s+'.BOB';
   Writeln(s);
   Assign(g,s);
   Rewrite(g,1);
   Blockread(f,buf,8);
   Seek(f,fp);
   l1:=lia[1];
   Inc(fp,l1);
   while l1>$8000 do
    begin
    Blockread(f,buf,$8000);
    Blockwrite(g,buf,$8000);
    Dec(l1,$8000);
    end;
   Blockread(f,buf,l1);
   Blockwrite(g,buf,l1);
   Blockread(f,buf,6);
   l1:=buf[4]*3;
   Blockread(f,buf[6],l1);
   Inc(l1,6);
   Blockwrite(g,buf,l1);
   Inc(fp,l1);
   Close(g);
   Inc(i);
  until fp=fsz;
  Close(f);
  Erase(f);
  end;
 Writeln('Splitting MFIGS:');
 Assign(f,'mfigs');
 SplitNVF('MFIGS');
 Writeln('Splitting MONSTER:');
 Assign(f,'monster');
 SplitNVF('MONST');
 Writeln('Splitting WFIGS:');
 Assign(f,'wfigs');
 SplitNVF('WFIGS');
end.