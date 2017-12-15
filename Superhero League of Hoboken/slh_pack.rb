#!/usr/bin/env ruby

begin
    #require 'bundler/setup'
    require 'json'
    require 'resedit'
    if Resedit::VERSION != '1.8.1'
        raise LoadError.new("Wrong resedit version")
    end
rescue LoadError
    open("./Gemfile", "w") {|f|
        f.write('source "http://rubygems.org"')
        f.write("\ngem 'resedit', '1.8.1'\n")
        f.write("gem 'builder', '~>3.2.2'\n")
    }
    system("bundle install")
    abort
end

CONFIG = "execonfig.json"

class FontConvertCommand < Resedit::FontConvertCommand
    def initialize()
        super('*.fnt')
        @flags = { 0x01 => [0xFF00FF00], 0x10 => [0xFF0000FF], 0x11 => [0xFF00FFFF]}
    end

    def mkfont(file)
        @head = file.read(10).bytes
        @bpp = @head[1]
        raise "Unsupported font" if @bpp!=1 && @bpp!=8
        @bts = @head[2]
        @strt = @head[3]
        @cnt = @head[4]+1
        @hgt = @head[6]
        @wdt = @head[7]
        @flg = @head[8]
        @wds = nil
        @flgs = nil
        if @wdt == 0xff
            @wdt = 0
            @wds = file.read(@cnt).bytes
            @wds.each { |w|
                @wdt = w if w > @wdt
            }
        end
        if @flg == 0xff
            @flg = 0
            @flgs = file.read(@cnt).bytes
        end
        logd("reading font #{@resname} #{@strt} #{@cnt} #{@hgt} #{@wdt}")
        return Resedit::Font.new(@wdt, @hgt, bpp: @bpp)
    end


    def pack(file, stream)
        log('packing '+@resname)
        @strt = @font.minChar if @font.minChar < @strt
        @cnt = @font.maxChar+1 if @font.maxChar+1 > @cnt
        @head[3] = @strt
        @head[4] = @cnt-1
        flags = @flags.invert
        stream.write(@head.pack("C*"))
        if @head[7] == 0xff
            while @wds.length<@cnt
                @wds << 0
            end
            i = @strt
            while i < @cnt
                w = @font.charWidth(i)
                if w
                    @wds[i] = w
                end
                i += 1
            end
            stream.write(@wds.pack("C*"))
        end
        if @head[8] == 0xff
            while @flgs.length<@cnt
                @flgs << 0
            end
            i = @strt
            while i < @cnt
                f = @font.charFlags(i)
                if f and flags.include?(f)
                    @flgs[i] = flags[f]
                end
                i += 1
            end
            stream.write(@flgs.pack("C*"))
        end
        empty = []
        for i in 0..@bts*@hgt-1
            empty << 0
        end
        i = @strt
        while i < @cnt
            res = empty
            buf = @font.getChar(i)
            res = (@bpp==1 ? Resedit::BitConverter.bytes2Bits(buf,@wdt,@bts) : buf) if buf
            stream.write(res.pack("C*"))
            i += 1
        end
    end


    def unpack(file)
        log('unpacking '+@resname)
        i = @strt
        while i < @cnt
            buf = file.read(@hgt*@bts).bytes
            if @bpp==1
                res = Resedit::BitConverter.bits2Bytes(buf, @wdt)
            else
                res = buf
            end
            w = @wds[i] if @wds
            f = @flags[@flgs[i]] if @flgs
            @font.setChar(i, res, w, f)
            i += 1
        end
    end
end


class TextFormatter < Resedit::TextFormat

    def saveLines(fname, lines, meta)
        open(fname+'.txt','w:cp866') {|f|
            lines.each.with_index{|l,id|
                f.write(sprintf("%s: <%s>\n", meta[id]['addr'], l))
            }
        }
    end

    def loadLines(fname)
        lns = []
        buf = nil
        open(fname+".txt", "r:cp866:utf-8").each_line {|l|
            if l =~ /\d{2}:\d{3,4}: </
                if buf
                    buf = buf[0..-3] if buf[-2..-1] == ">\n"
                    lns += [buf]
                end
                buf = l[9..-1]
                buf = l[1..-1] if l[0]=='<'
            else
                raise "Wrong format" if !l
                buf += l
            end
        }
        if buf
            buf = buf[0..-3] if buf[-2..-1] == ">\n"
            lns += [buf]
        end
        return lns
    end
end


class ObjectConvert < Resedit::ITextConvert

    def mktext(file, format, encoding)
        txt = Resedit::Text.new(format, 'cp866')
        file.read(2)
        file.read().split("\x00").each{|l|
            txt.addLine(l)
        }
        return txt
    end

    def expectedLines; @text.lines.length end
    def unpack(file); end

    def pack(file, stream)
        buf = ''
        cfg = Resedit::Config.new(CONFIG)
        exe = cfg.enterOnFile(File.dirname(@resname))
        cfg.enter(["objects","words"], false)
        raise "No words in config" if cfg.length<1
        wofs=[]
        @text.lines.each{|l|
            wofs += [buf.length]
            buf += [l].pack("Z*")
        }
        stream.write([buf.length].pack("v"))
        stream.write(buf)
        log("modifying exe offsets")
        FileUtils.cp(exe, exe + '.bak') if !File.exist?(exe + '.bak')
        le = Resedit::Multiexe.new(exe, true)
        cfg.each{|o,w|
            ofs = wofs[w]+1
            le.change(":"+o, "0x"+ofs.to_s(16), "h4")
        }

        #le.print("changes")
        le.save(exe, "final")
    end
end

class ExeText < Resedit::ITextConvert
    def mktext(file, format, encoding)
        txt = Resedit::Text.new(format, 'cp866')
        cfg = Resedit::Config.new(CONFIG, [File.basename(@resname), "exestrings"])
        esc = Resedit::StdEscaper.new()
        cfg.each{|s|
            arr = s.split(" \t ")
            puts "#{arr}"
            txt.addLine(esc.unescape(arr[0]))
        }
        return txt
    end

    def expectedLines; @text.lines.length end
    def unpack(file); end
end

class TextConvertCommand < Resedit::TextConvertCommand

    def initialize()
        super('*.dat')
    end

    def getInterface(resname, params)
        f = File.basename(resname)
        if f.downcase=="object.dat"
            return ObjectConvert.new(resname, params)
        elsif f.downcase[-4,4]==".exe"
            return ExeText.new(resname, params)
        else
            return self
        end
    end


    def expectedLines()
        @segments.map{|s| s['count']}.reduce(0, :+)
    end

    def readHuff(node, tbl, pos)
        v = tbl[pos]
        n = node.addLeft( (v & 0x8000) != 0 ? v^0xFFFF : nil)
        readHuff(n,tbl,v) if !n.value
        v = tbl[pos+1]
        n = node.addRight( (v & 0x8000) != 0 ? v^0xFFFF : nil)
        readHuff(n,tbl,v) if !n.value
    end

    def mktext(file, format, encoding)
        txt = Resedit::Text.new(format,'cp866')
        if !format
            txt.formatter = TextFormatter.new('cp866')
            txt.escaper = nil
        end
        @segcnt = file.read(2).unpack('v')[0]
        @segments = []
        for i in 0..@segcnt-1
            @scnt,@size,@flags = file.read(6).unpack('vvv')
            @segments[i] = {'count'=>@scnt, 'sz'=>@size, 'flags'=>@flags, 'sztbl'=>nil}
        end
        for i in 0..@segcnt-1
            @segments[i]['sztbl'] = file.read( 2 * @segments[i]['count'] ).unpack('v*')
        end
        hcnt = file.read(2).unpack('v')[0]
        @huff = Resedit::Huffman.new(true)
        tbl = file.read(2*hcnt).unpack('v*')
        readHuff(@huff.tree, tbl, hcnt-2)
        @huff.debug()

        osz = file.read(2).unpack('v')[0]
        ofs = file.read(2*osz).unpack('v*')
        dsz = file.read(2).unpack('v')[0]

        @dict = file.read(dsz).unpack('Z*'*osz)

        return txt
    end

    def dictReplace(line)
        res = ''
        line.each_byte{|b|
            if (b >= 0x80)
                res += @dict[b-0x80]
            else
                res += b.chr
            end
        }
        return res
    end

    def unpack(file)
        log('unpacking '+@resname)
        for i in 0..@segcnt-1
            @segments[i]['sztbl'].each.with_index{|sz,j|
                meta = {'addr'=>sprintf("%02d:%03d", i,j)}
                line = @huff.decode(file.read(sz))
                line = dictReplace(line)
                @text.addLine(line, meta)
            }
        end
    end

    def packHuff(node, tbl)
        ret = [0,0]
        if node.left.value != nil
            ret[0] = node.left.value ^ 0xFFFF
        else
            tbl = packHuff(node.left, tbl)
            ret[0] = tbl.length - 2
        end
        if node.right.value != nil
            ret[1] = node.right.value ^ 0xFFFF
        else
            tbl = packHuff(node.right, tbl)
            ret[1] = tbl.length - 2
        end
        return tbl + ret
    end

    def pack(file, stream)
        log('packing '+@resname)
        #balance huffman
        bal = @huff.balancer()
        for i in 0..@text.lines.length-1
            bal.addData(@text.getLine(i)+"\0")
        end
        bal.balanceValues()

        #make segments buffers
        curln = 0
        for i in 0..@segcnt-1
            @segments[i]['buf'] = ''
            @segments[i]['sztbl'] = []
            for j in 0..@segments[i]['count']-1
                ln = @text.getLine(curln)
                curln += 1
                enc = @huff.encode(ln)
                @segments[i]['buf'] += enc
                @segments[i]['sztbl'] += [enc.length]
            end
            @segments[i]['size'] = @segments[i]['buf'].length
        end

        #build file
        stream.write([@segcnt].pack('v'))
        for i in 0..@segcnt-1
            s=@segments[i]
            stream.write( [s['count'], s['size'], s['flags'] ].pack('vvv') )
        end
        for i in 0..@segcnt-1
            stream.write( @segments[i]['sztbl'].pack('v*') )
        end
        #write huffman
        tbl = packHuff(@huff.tree, [])
        stream.write( [tbl.length].pack('v') )
        stream.write( tbl.pack('v*') )
        #write replace dict equals to chars
        cbuf = []
        desc = [0x80] # count of chars
        for i in 0..0x7F
            desc += [i*2] # char ofs = i*2
            cbuf += [0x80+i]
        end
        desc += [0x80*2] #size of cbuf
        stream.write(desc.pack('v*'))
        stream.write(cbuf.pack('v*'))
        #write data
        for i in 0..@segcnt-1
            stream.write( @segments[i]['buf'] )
        end
    end

end

class ExeConfigCommand < Resedit::AppCommand


    def initialize()
        super(['config'])
        addParam("action","config action objects/reloc/strings")
        addParam("exefile","exe file")
        addParam("p1","action parameter 1","")
        addParam("p2","action parameter 2","")
    end

    def mapObjects(exefile, ofs, cnt)
        cfg = Resedit::Config.new(CONFIG, [File.basename(exefile),"objects"])
        ofs = cfg['ofs'] if ofs.length==0
        wofs = []
        c = 0
        objs = File.join(File.dirname(exefile), "OBJECT.DAT")
        ObjectConvert.new(nil,nil).mktext(open(objs), 'txt', nil).lines.each{|l|
            wofs+=[c]
            c+=l.length+1
        }
        wofs = wofs.map.with_index{|o,i| [o, [i,0]]}.to_h
        cfg['ofs'] = ofs
        le = Resedit::Multiexe.new(exefile)
        pos = le.env.s2i(ofs)
        logd("pos = #{pos.to_s(16)}")
        i=0
        cnt = cnt.length ? le.env.s2i(cnt) : -1
        cfg['words']={}
        while true
            val = le.readRelocated(pos, 5).unpack("CV")
            pos += 5
            break if val[0]<0 || val[0]>5
            break if i==cnt
            pofs = le.body.getData(le.body.addr2raw(val[1]),8).unpack("V*")
            ad = val[1]-4
            pofs.each{|o|
                ad+=4
                next if o==0
                o-=1
                raise "Word not found #{o}" if !wofs[o]
                cfg['words'][ad.to_s(16)] = wofs[o][0]
                wofs[o][1]+=1
            }
            i+=1
        end
        wofs.each{|k,v|
            puts "Word #{v[0]} used #{v[1]} times" if v[1]!=1
        }
        log("#{i} objects found")

        cfg.save()
    end

    def findReloc(exe, val)
        le = Resedit::Multiexe.new(exe)
        out = le.relocfind(val, "z")
        return if !out
        out.each{|k,v|
            puts "#{val} @ #{k.to_s(16)} <= #{v.map{|v| v.to_s(16)}}"
        }
    end

    def findStrings(exe, minsz)
        le = Resedit::Multiexe.new(exe)
        out = le.stringfind(minsz)
        esc = Resedit::StdEscaper.new()
        cfg = Resedit::Config.new(CONFIG, File.basename(exe))
        lst = []
        out.each{|s|
            str = esc.escape(s[0]) + " \t " + s[1].to_s(16)
            str += " \t " + s[2].map{|v| v.to_s(16)}.join(",")
            lst += [str]
        }
        cfg["exestrings"] = lst
        cfg.save()
    end

    def extendExe(exe)
        FileUtils.cp(exe, exe + '.bak') if !File.exist?(exe + '.bak')
        le = Resedit::Multiexe.new(exe+".bak")

        #cseg01:00021B71 E8 1A 37 06 00                    call    FOPEN
        #cseg01:00021B76 89 C6                             mov     esi, eax
        #change to
        #cseg01:00021B71 BE 04 03 02 01                          mov     esi, 1020304h
        #cseg01:00021B76 FF D6                                   call    esi
        #----
        #cseg01:00021B60 READ_OBJECT_DAT proc near

        ofs = le.append("9090CCBE12345678FFD689C6C39090")  #nop nop int3; mov esi,12345678; call esi; mov esi,eax; ret; nop; nop
        le.change(":00021B71", "BE04030201FFD6")
        le.reloc(":00021B72",":"+(ofs[0]+2).to_s(16))  #mov esi, myfunc (int3)
        le.reloc(":"+(ofs[0]+4).to_s(16), ":00085290")  #call FOPEN instead of 12345678 in myfunc

        le.header.print("changes")
        le.print("header")
        le.print("tables")

        puts "Inserted at #{ofs.map{|v| v.to_s(16)}}"
        le.hex("0x"+(ofs[1]-10).to_s(16), "21", "r")
        le.dump("test.exe","[3,4]")
        le.save(exe,"final")
    end

    def job(params)
        cmd = params['action']
        if cmd=="objects"
            mapObjects(params['exefile'], params['p1'], params['p2'])
        elsif cmd=="reloc"
            findReloc(params['exefile'], params['p1'])
        elsif cmd=="strings"
            findStrings(params['exefile'], params['p1'])
        else
            raise "Unknown action #{cmd}"
        end
    end
end

class App < Resedit::App
    def initialize()
        super('slh_pack','1.4',
            [
                FontConvertCommand.new(),
                TextConvertCommand.new(),
                ExeConfigCommand.new()
            ],
            false,
            "by bjfn (c) old-games.ru, 2016")
    end
end


if __FILE__ == $0
    App.new().run()
end
