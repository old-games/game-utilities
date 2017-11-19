#!/usr/bin/env ruby
# encoding: utf-8

require 'bundler/setup'
require 'resedit'
require 'free-image'

class Palette
    include Singleton
    COLS = [0xc0808,0x100c0c,0x181010,0x1c0c08,0x200c00,0x280c00,0x301004,0x301c10,0x28140c,0x201410,0x201818,0x141418,0x181c20,0x1c2028,0x242830,0x283038,
            0x30282c,0x302420,0x241c20,0x412418,0x3c2824,0x3c2c30,0x493438,0x513830,0x5d382c,0x613420,0x5d2c1c,0x5d2810,0x592008,0x69280c,0x713418,0x7d3418,
            0x7d3c20,0x753c2c,0x6d3824,0x693c30,0x6d4934,0x694945,0x614549,0x614d51,0x553c3c,0x5d4141,0x4d4d4d,0x515159,0x495161,0x4d5969,0x556175,0x61656d,
            0x696d71,0x6d6569,0x6d5165,0x715559,0x6d4d51,0x754149,0x753838,0x824130,0x8e4130,0x924d34,0xa6513c,0x9e6138,0xa26145,0xaa6941,0xb27141,0xae7551,
            0xa26d51,0x8e6551,0x8e6965,0x825969,0x795961,0x7d5151,0x8e4d55,0x8a454d,0x8a3c41,0x8e2c34,0xa63438,0xa23c45,0xb63441,0xc73045,0xcf283c,0xd72030,
            0xc7242c,0xba282c,0xa6242c,0xa6181c,0xb61418,0xcf1820,0xe31824,0xe31018,0xeb080c,0xf70408,0xcf0c0c,0xdf2441,0xc73859,0xcb4171,0xb24d71,0x9e516d,
            0x8e5165,0x9a4959,0xaa4159,0x925d3c,0x82553c,0x7d4d30,0x8e4d28,0x8e3c1c,0x9e411c,0xa64d24,0xc36118,0xe77528,0xbe7541,0xc37d55,0xbe826d,0xd38e61,
            0xe39261,0xef9e6d,0xf3ae75,0xfbdfba,0xe7e7e3,0xd3d7db,0xcbcbd3,0xbec3cf,0xb6b6be,0xa6aab6,0x9ea2ae,0x969aa2,0xa29a9a,0x9e9692,0x8a8a92,0x7d828a,
            0x6d798e,0x65758a,0x5d6d7d,0x71757d,0x827979,0x826179,0x795d71,0x715571,0x71597d,0x8a6586,0x8e6592,0x82618a,0x92699a,0x926daa,0x9a71aa,0x9a6da2,
            0x9e71b2,0x9a75c3,0xa671ba,0xae65b2,0xb25da2,0xba518a,0xa25d8a,0x9e6d8e,0x8e5d79,0xa27169,0x797561,0x615d5d,0x614d5d,0x414959,0x3c414d,0x413c41,
            0x493845,0x303845,0x3c3c6d,0x554d7d,0x343092,0x18109e,0x281ccb,0x1818df,0x2c2cdf,0x3c3cd7,0x4941cb,0x5151be,0x5555db,0x6d6ddb,0x655daa,0x753ca2,
            0x8645a6,0x7d869e,0x9a9acf,0x969ae3,0xb282ef,0xbe86ef,0xb67de3,0xaa7de3,0xa279d3,0xba82ff,0xb28aff,0xbe8eff,0xffffff,0x921c20,0x513020,0x4d281c,
            0x4d2410,0x491c08,0x411808,0x180800,0xc0c30,0x181461,0x0,0xffffff,0x0,0x961400,0xc30800,0xef5500,0xff9e00,0xffc700,0xffef00,0x654914,
            0x825d24,0xa26d38,0xc38655,0xcf9a69,0xdfb286,0xefcba2,0x340051,0x45006d,0x59048a,0x690ca6,0x7d18c3,0x9224df,0xa634ff,0x0,0x80808,0x141414,
            0x202020,0x2c2c2c,0x383838,0x454545,0x43c04,0x45104,0x86908,0xc7d0c,0x109610,0x14aa14,0x18c31c,0x514500,0x615504,0x75650c,0x8a7514,0x9a8624,
            0xae9634,0xc3aa49,0x510000,0x750000,0x9e0808,0xc71414,0xcf2c34,0xdb4959,0xe7697d,0x0,0x454545,0x696969,0x8e8e8e,0xb2b2b2,0xdbdbdb,0xffffff]

    attr_accessor :trans

    def initialize()
        clear()
    end

    def cconv(col)
        r = (col>>16) & 0xFF
        g = (col>>8) & 0xFF
        b = col & 0xFF
        r = (r<<2)+(r>>4)
        g = (g<<2)+(g>>4)
        b = (b<<2)+(b>>4)
        return 0xFF000000 | ((r & 0xFF) << 16) | ((g&0xFF) << 8) | (b & 0xFF)
    end


    def clear()
        @cols = VGA.map{|c| 0xFF000000 | c}
        @idx = Array(0..255)
        @trans = nil
    end

    def setColors(buf)
        @cols = [0]*(buf.length/3)
        (buf.length/3).times{|i|
            @cols[i] = cconv(('X'+buf[i*3,3]).unpack('N')[0])
        }
    end

    def reidx(buf)
        @idx = buf.unpack("C*")
    end

    def col(idx);
        id = @idx[idx]
        return 0x00FFFFFF if @trans==id
        raise "Wrong palette index #{idx}" if !@cols[id]
        @cols[id]
    end

    def self.reidx(buf); instance.reidx(buf) end
    def self.clear(); instance.clear() end
    def self.setColors(buf); instance.setColors(buf) end
    def self.col(idx); instance.col(idx) end

end

class ImgUnpacker
    def initialize()
        Palette.clear()
    end

    def buildImg(buf)
        Palette.instance.trans = @hdr[3]
        i = 0
        img = Resedit::createImage(@width, @height)
        @height.times{|y|
            @width.times{|x|
                img.setPixel(x, y, Palette.col(buf[i]))
                i+=1
            }
        }
        return img
    end

    def _unpack(buf, out)
        map = @hdr[5,15]
        puts "#{@hdr}"
        len = @hdr[1]+1
        bs = Resedit::BitStream.new(buf)
        out[0] = bs.read(8);
        prev = out[0]
        op = 1
        while !bs.eof?
            b = bs.read(4)
            if @ctype == 2 && b == 0x0E
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
    end

    def unpack(fp)
        @hdr = fp.read(0x1C).unpack("C20v4")
        @width = @hdr[-2]
        @height = @hdr[-3]
        @flags = @hdr[0]
        @ctype = @hdr[4]
        raise "Unknown compression type #{ctype}" if @ctype!=1 && @ctype!=2
        unp = @hdr[-4]
        packed = fp.read(@hdr[-1] - unp)
        data = [0] * (@width*@height - unp)
        data += fp.read(unp).unpack("C*") if unp>0
        _unpack(packed, data)
        Palette.setColors(fp.read((@hdr[2]+1)*3)) if (@flags & 1)!=0
        Palette.reidx(fp.read(@hdr[1]+1)) if (@flags & 2)!=0
        return buildImg(data)
    end

    def self.unpack(fp, pos=nil)
        if pos
            prev = fp.tell()
            fp.seek(pos)
        end
        ret = ImgUnpacker.new().unpack(fp)
        fp.seek(prev) if pos
        return ret
    end
end


class PlCommand < Resedit::ConvertCommand

    def initialize()
        super("pl","*.pl")
    end

    def import(infile)
        raise 'Not implemented'
    end

    def export(outfile)
        logd("exporting pl #{@resname} to #{outfile}")
        dname = "#{outfile}_pl"
        Dir.mkdir(dname) unless File.directory?(dname)
        File.open(@resname, "rb"){|f|
            cnt, ftbl = f.read(6).unpack("vV")
            f.seek(ftbl)
            for i in 0..cnt-1
                ofs,nm = f.read(12).unpack("VA*")
                puts "Unpaking #{nm} @ #{ofs.to_s(16)}"
                img = ImgUnpacker::unpack(f, ofs)
                img.save(File.join(dname,"#{nm}.png"))
            end
        }
    end
end

class ReadPaletteCommand < Resedit::AppCommand
    def initialize
        super('readpal')
        addParam('file', 'palette bitmap')
    end

    def job(params)
        FreeImage::Bitmap.open(params['file']){|img|
            img.width.times{|i|
                puts if i%16==0
                col=img.pixel_color(i, 0)
                v = (col[:red] << 16) | (col[:green] << 8) | col[:blue]
                print "0x#{v.to_s(16)},"
            }
        }
        puts
    end
end

class App < Resedit::App
    def initialize()
        super('bnimg','0.1',
            [
                PlCommand.new(),
                ReadPaletteCommand.new()
            ],
            false,
            "by bjfn (c) old-games.ru, 2017")
    end
end

if __FILE__ == $0
    App.new().run()
end
