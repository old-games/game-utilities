#!/usr/bin/env ruby

begin
    require 'resedit'
rescue LoadError
    open("./Gemfile", "w") {|f|
        f.write('source "http://rubygems.org"')
        f.write("\ngem 'resedit', '~>1.3'\n")
        f.write("gem 'builder', '~>3.2.2'\n")
    }
    system("bundle install")
    abort
end

class FontConvertCommand < Resedit::FontConvertCommand
    def initialize()
        super('*.fnt')
    end

    def mkfont(file)
        @head = file.read(10).bytes
        @bts = @head[2]
        @strt = @head[3]
        @cnt = @head[4]+1
        @hgt = @head[6]
        @wdt = @head[7]
        @xwds = @head[8]
        @wds = nil
        if @wdt == 0xff
            @wdt = 0
            @wds = file.read(@xwds==0xFF ? 256 : @cnt).bytes
            @wds.each { |w|
                @wdt = w if w > @wdt && w < 0x10
            }
        end
        logd("reading font #{@resname} #{@strt} #{@cnt} #{@hgt} #{@wdt}")
        return Resedit::Font.new(@wdt, @hgt)
    end


    def pack(file, stream)
        log('packing '+@resname)
        @strt = @font.minChar if @font.minChar<@strt
        @cnt = @font.maxChar+1 if @font.maxChar+1>@cnt
        @head[3] = @strt
        @head[4] = @cnt-1
        stream.write(@head.pack("C*"))
        if @head[7] == 0xff
            while @wds.length<@cnt
                @wds << 0
            end
            i=@strt
            while i<@cnt
                w=@font.charWidth(i)
                if w
                    @wds[i] = w
                end
                i += 1
            end
            stream.write(@wds.pack("C*"))
        end
        empty=[]
        for i in 0..@bts*@hgt-1
            empty << 0
        end
        i=@strt
        while i < @cnt
            buf = @font.getChar(i)
            res = buf ? Resedit::BitConverter.bytes2Bits(buf,@wdt,@bts) : empty
            stream.write(res.pack("C*"))
            i += 1
        end
    end


    def unpack(file)
        log('unpacking '+@resname)
        i=@strt
        while i < @cnt
            buf = file.read(@hgt*@bts).bytes
            res = Resedit::BitConverter.bits2Bytes(buf, @wdt)
            w=@wds[i] if @wds
            @font.setChar(i, res, w)
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

    def isTextStart(ln)
        return false if ln[2]!=':'
        return false if ln[6]!=':'
        return false if ln[7]!=' '
        return false if ln[8]!='<'
        return false if ln[0]<'0' || ln[0]>'9'
        return false if ln[1]<'0' || ln[1]>'9'
        return false if ln[3]<'0' || ln[3]>'9'
        return false if ln[4]<'0' || ln[4]>'9'
        return false if ln[5]<'0' || ln[5]>'9'
        return true
    end

    def loadLines(fname)
        lns=[]
        buf=nil
        open(fname+".txt", "r:cp866:utf-8").each_line {|l|
            if isTextStart(l)
                if buf
                    buf = buf[0..-3] if buf[-2..-1] == ">\n"
                    lns += [buf]
                end
                buf = l[9..-1]
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


class TextConvertCommand < Resedit::TextConvertCommand

    def initialize()
        super('hobostr.dat')
    end


    def linesCount()
        @segments.map{|s| s['count']}.reduce(0, :+)
    end

    def readHuff(node,tbl,pos)
        v = tbl[pos]
        n = node.addLeft( (v & 0x8000) != 0 ? v^0xFFFF : nil)
        readHuff(n,tbl,v) if !n.value
        v = tbl[pos+1]
        n = node.addRight( (v & 0x8000) != 0 ? v^0xFFFF : nil)
        readHuff(n,tbl,v) if !n.value
    end

    def mktext(file, format, encoding)
        txt=Resedit::Text.new(format,'cp866')
        if !format
            txt.formatter = TextFormatter.new('cp866')
            txt.escaper = nil
        end
        @segcnt=file.read(2).unpack('v')[0]
        @segments=[]
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
        res=''
        line.each_byte{|b|
            if (b>=0x80)
                res+=@dict[b-0x80]
            else
                res+=b.chr
            end
        }
        return res
    end

    def unpack(file)
        log('unpacking '+@resname)
        for i in 0..@segcnt-1
            @segments[i]['sztbl'].each.with_index{|sz,j|
                meta={'addr'=>sprintf("%02d:%03d", i,j)}
                line=@huff.decode(file.read(sz))
                line=dictReplace(line)
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
        bal=@huff.balancer()
        for i in 0..@text.lines.length-1
            bal.addData(@text.getLine(i)+"\0")
        end
        bal.balanceValues()

        #make segments buffers
        curln=0
        for i in 0..@segcnt-1
            @segments[i]['buf'] = ''
            @segments[i]['sztbl'] = []
            for j in 0..@segments[i]['count']-1
                ln=@text.getLine(curln)
                curln += 1
                enc=@huff.encode(ln)
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


class App < Resedit::App
    def initialize()
        super('slh_pack','1.2',
            [
                FontConvertCommand.new(),
                TextConvertCommand.new()
            ],
            false,
            "by bjfn (c) old-games.ru, 2016")
    end
end


if __FILE__ == $0
    App.new().run()
end
