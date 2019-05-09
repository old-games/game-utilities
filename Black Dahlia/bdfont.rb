#!/usr/bin/env ruby
# encoding: utf-8

require 'bundler/setup'
require 'resedit'


class PLImage
    attr_reader :pal, :width, :height

    def initialize(fp)
        @reidx=nil
        @pal = nil
        @hdr = fp.read(0x1C).unpack("C20v4")
        @width = @hdr[-2]
        @height = @hdr[-3]
        @flags = @hdr[0]
        @packed = fp.read(@hdr[-1])
        @pal = fp.read((@hdr[2]+1)*3) if (@flags & 1)!=0
        @reidx = fp.read(@hdr[1]+1) if (@flags & 2)!=0
    end

    def trans; @hdr[3] end

    def mkindices(imgdata)
        idx = [0]*256
        imgdata.each{|b| idx[b] += 1 }
        out = []
        for i in 0..255
            out += [i] if idx[i]>0
        end
        @reidx = out.pack("C*")
        @hdr[1] = out.length-1
        return out
    end

    def analyze(data)
        # returns array of packdescr [ [byte, packtype(map/val/rpt), rptval], ...]
        len = @hdr[1]+1
        anal = {}
        ctype = @hdr[4]
        out = [[0, 0]] * data.length
        prev = data[0]
        out[0]=[prev, PK_START]
        op = 1
        for i in 1..data.length-1
            f = data[i]
            if out[op][1]==PK_RPT
                if f==out[op][0]
                    out[op][2]+=1
                    next
                end
                op+=1
            end
            s = i<data.length-2 ? data[i+1] : -1
            if f==prev && s==prev && ctype==2
                out[op] = [f, PK_RPT, -1]
                next
            end
            #val delta 4 map
            d = f<prev ? f+len-prev : f-prev
            out[op] = [f, d]
            prev = f
            op+=1
            anal[d] = 0 if !anal[d]
            anal[d] += 1
        end
        op+=1 if op<out.length && out[op][1]==PK_RPT
        out = out[0, op]
        #build pack map
        anal = anal.sort_by {|_, v| v}.reverse[0, 15].map{|v,_| v}
        @hdr=@hdr[0, 5] + anal + [0]*(15-anal.length) + @hdr[20..-1]
        anal = anal[0, 14] if ctype==2
        anal = Hash[anal.map.with_index{|v,i| [v,i]}]
        for i in 1..out.length-1
            d = out[i][1]
            next if d<0
            out[i][1] = anal[d] ? anal[d] : PK_VAL
        end
        return out
    end

    def packData(data)
        #return [data.pack("C*"), data.length-1]
        data = analyze(data)
        #TODO: calc unpacked tail
        tail = ''
        # unp = data.length-1
        # while data[unp][1]!=PK_RPT
        #     tail = data[unp][0].chr+tail
        #     unp-=1
        # end
        # data = data[0..-tail.length-1] if tail.length>0
        bs = Resedit::BitStream.new()
        data.each{|v|
            if v[1]==PK_START
                #first
                bs.write(v[0])
            elsif v[1]==PK_RPT
                #repeat prev
                bs.write(0x0E, 4)
                bs.write(0xFF) if v[2]>0xFE  #2-bytes length
                bs.write(v[2]>>8) if v[2]>0xFE #hi byte
                bs.write(v[2] & 0xFF)   #lo byte or 1-byte length
            elsif v[1]==PK_VAL
                #unmapped
                bs.write(0x0F, 4)
                bs.write(v[0])
            else
                #mapped
                bs.write(v[1], 4)
            end
        }
        ln = bs.bytes.length
        out = bs.finish()
        out+='\0' if ln==out.length
        return [out + tail, tail.length]
    end

    def getpal(data)
        pal={}
        data.each{|b|
            pal[b]=1 if not pal[b]
        }
        return pal.keys().sort()
    end

    def pack(imgdata=nil)
        data = @packed
        loop do
            break if !imgdata
            #puts "#{@hdr}\n#{getpal(unpack())}"
            ctype = @hdr[4]
            if ctype==0x10
                data = imgdata.pack("C*")
                break
            end
            if @reidx
                #puts "#{@reidx.unpack('C*')}"
                ridx = Hash[mkindices(imgdata).map.with_index{|x,i| [x,i]}]
                data = imgdata.map{|i| ridx[i]}
                #puts "#{@reidx.unpack('C*')}"
            end
            data, unp = packData(data)
            @hdr[-4] = unp
            @hdr[-1] = data.length
            puts "#{@hdr}"
            #puts "#{getpal(imgdata)}"
            break
        end
        ret = @hdr.pack("C20v4")
        ret += data
        ret += @pal if (@flags & 1)!=0
        ret += @reidx if (@flags & 2)!=0

        return ret if !imgdata

        # tst = imgdata
        # @packed = data
        # res = unpack()
        # for i in 0..tst.length
        #     if tst[i]!=res[i]
        #         puts "wrong #{i} #{tst[i]} #{res[i]}"
        #     end
        # end
        return ret
    end

    def unpack()
        ctype = @hdr[4]
        return @packed if ctype==0x10
        raise "Unknown compression #{ctype}" if !ctype.between?(1,2)
        unp = @hdr[-4]
        out = [0] * (@width*@height - unp)
        out += @packed[-unp..-1].unpack("C*") if unp>0
        if unp < @width*@height
            sz = @width*@height-unp
            len = @hdr[1]+1
            map = @hdr[5,15]
            bs = Resedit::BitStream.new( @packed[0.. -unp-1] )
            out[0] = bs.read(8)
            prev = out[0]
            op = 1
            while op<sz
                b = bs.read(4)
                if ctype == 2 && b == 0x0E
                    c = bs.read(8)
                    c = (bs.read(8) << 8 | bs.read(8)) if c==0xFF
                    (c+2).times{
                        out[op] = prev
                        op += 1
                    }
                    next
                end
                if b == 0x0F
                    b = bs.read(8)
                else
                    b = map[b] + prev
                    b = (b&0xFF) - len if b>0xFF || b>=len
                end
                prev = b & 0xFF
                out[op] = prev
                op+=1
            end
            raise "Wrong unpacked length #{op} #{@width*@height} #{unp}" if op != sz
        end
        if @reidx
            ridx = @reidx.unpack("C*")
            out = out.map{|i|
                raise "No index #{i} in reindex_map #{ridx}" if !ridx[i]
                ridx[i]
            }
        end
        return out
    end

end



class FontCommand < Resedit::FontConvertCommand

    MAGIC = "NF2T"

    def initialize()
        super("*.fnt")
    end

    def mkfont(file)
        @hdr = file.read(0x0C).unpack("a4C8")
        raise "Wrong file type" if @hdr[0]!=MAGIC
        @first = @hdr[1]
        @count = @hdr[2]
        @map = []
        @wdt = 0
        @hgt = 0
        @count.times{
            prm = file.read(8).unpack("VC4")
            @map << prm
            @wdt = prm[1]+prm[3] if prm[1]+prm[3]>@wdt
            @hgt = prm[2]+prm[4] if prm[2]+prm[4]>@hgt
        }
        @img = PLImage.new(file).unpack()
        return Resedit::Font.new(@wdt, @hgt, bpp: 8)
    end

    def pack(file, outstream)
        raise "Not implemented."
    end

    def mkchar(prm)
        buf = @img[prm[0], prm[1]*prm[2]]
        res = ("\x00"*(@wdt*@hgt)).bytes
        id = 0
        prm[2].times{|j|
            k = j+prm[4]
            prm[1].times{|i|
                res[k*@wdt+i+prm[3]] = buf[id] == 0 ? 0xFF : 0
                id+=1
            }
        }
        res
    end

    def unpack(file)
        log('extracting '+@resname)
        i = 0
        while i < @count
            prm = @map[i]
            @font.setChar(i+@first, mkchar(prm), prm[1])
            i += 1
        end
    end
end


class App < Resedit::App
    def initialize()
        super('bdfont','0.1',
            [
                FontCommand.new(),
            ],
            false,
            "by bjfn (c) old-games.ru, 2019")
    end
end

if __FILE__ == $0
    App.new().run()
end
