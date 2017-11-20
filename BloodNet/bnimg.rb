#!/usr/bin/env ruby
# encoding: utf-8

require 'bundler/setup'
require 'resedit'
require 'free-image'

class Palette
    include Singleton
    COLS = [0x030202, 0x040101, 0x010103, 0x030304, 0x050404, 0x050406, 0x050606, 0x070606, 0x080706, 0x080807, 0x090808, 0x0A0908, 0x0B0A09, 0x0D0C0A, 0x0E0D0B, 0x0F0E0C,
            0x100F0D, 0x11100E, 0x12110F, 0x111010, 0x131210, 0x131312, 0x141414, 0x161512, 0x181410, 0x1A140E, 0x1A120D, 0x18120D, 0x16110C, 0x15100B, 0x170F0A, 0x170E08,
            0x140D08, 0x130C07, 0x100B08, 0x0E0A07, 0x0C0906, 0x0B0805, 0x0C0704, 0x0A0704, 0x0A0502, 0x090504, 0x080604, 0x080302, 0x060200, 0x060202, 0x090805, 0x0A0706,
            0x0C0908, 0x0E0A0A, 0x0C0C0C, 0x0E0E0E, 0x110C0C, 0x110C0A, 0x120D09, 0x110E0A, 0x130E0A, 0x120E0D, 0x150F0F, 0x161210, 0x171212, 0x1B1314, 0x1A1815, 0x1B1916,
            0x1C1A18, 0x1B1A1A, 0x1D1C1B, 0x1F1C18, 0x1F1A16, 0x211814, 0x221912, 0x221A11, 0x221A13, 0x231914, 0x241A13, 0x251910, 0x24180F, 0x241A0F, 0x23190C, 0x23160B,
            0x23140A, 0x21160C, 0x1F140C, 0x1D130C, 0x1D120A, 0x1A120A, 0x18110A, 0x1D160A, 0x1F180A, 0x1F150E, 0x20160F, 0x1F1710, 0x1E1712, 0x1D1813, 0x1C1611, 0x1C150F,
            0x20180F, 0x22170F, 0x211811, 0x231B14, 0x251C14, 0x261B12, 0x291B11, 0x2B1D13, 0x2A1F14, 0x281E15, 0x261E16, 0x241D16, 0x261F18, 0x281F17, 0x2A2018, 0x2A221A,
            0x28211B, 0x24221E, 0x23201C, 0x211E1B, 0x1E1E1E, 0x212020, 0x242323, 0x272420, 0x2A2722, 0x2C2824, 0x2E2A26, 0x2F2A24, 0x302821, 0x2E271E, 0x2C251F, 0x2E241C,
            0x2D221A, 0x2E2016, 0x302116, 0x322317, 0x362418, 0x35251A, 0x38271B, 0x3E2A1C, 0x3E2C1F, 0x3F2F20, 0x3F3019, 0x3D371A, 0x3B3126, 0x3B3229, 0x38352C, 0x36322D,
            0x35302A, 0x322E29, 0x302C28, 0x2E2D2D, 0x2A2929, 0x272626, 0x2A1E20, 0x291C1C, 0x271A1C, 0x251A1C, 0x241819, 0x211619, 0x1F1418, 0x181818, 0x171617, 0x181614,
            0x171A1F, 0x191D24, 0x2F2121, 0x31281D, 0x352B20, 0x332B22, 0x352C23, 0x382F25, 0x3F362A, 0x3F382C, 0x3F3A2F, 0x3F3D31, 0x3F3A33, 0x3F3B35, 0x3C3A35, 0x3B3B39,
            0x3F3F3A, 0x3F3F3D, 0x3F3F36, 0x3B3731, 0x383530, 0x363535, 0x323131, 0x382B10, 0x2B220E, 0x29210D, 0x281E0B, 0x241D0E, 0x2D1E14, 0x281108, 0x250D06, 0x1F0C06,
            0x190A06, 0x150905, 0x110805, 0x0E0604, 0x0E0501, 0x070708, 0x000000, 0x3F3F3F, 0x000000, 0x250500, 0x300200, 0x3B1500, 0x3F2700, 0x3F3100, 0x3F3B00, 0x191205,
            0x201709, 0x281B0E, 0x302115, 0x33261A, 0x372C21, 0x3B3228, 0x0D0014, 0x11001B, 0x160122, 0x1A0329, 0x1F0630, 0x240937, 0x290D3F, 0x000000, 0x020202, 0x050505,
            0x080808, 0x0B0B0B, 0x0E0E0E, 0x111111, 0x010F01, 0x011401, 0x021A02, 0x031F03, 0x042504, 0x052A05, 0x063007, 0x141100, 0x181501, 0x1D1903, 0x221D05, 0x262109,
            0x2B250D, 0x302A12, 0x140000, 0x1D0000, 0x270202, 0x310505, 0x330B0D, 0x361216, 0x391A1F, 0x000000, 0x111111, 0x1A1A1A, 0x232323, 0x2C2C2C, 0x363636, 0x3F3F3F]

    attr_accessor :trans

    def initialize()
        clear()
    end

    def cconv(col)
        r = (col>>16) & 0xFF
        g = (col>>8) & 0xFF
        b = col & 0xFF
        r = (r<<2) | (r>>4)
        g = (g<<2) | (g>>4)
        b = (b<<2) | (b>>4)
        return 0xFF000000 | ((r & 0xFF) << 16) | ((g&0xFF) << 8) | (b & 0xFF)
    end


    def clear()
        @cols = COLS.map{|c| cconv(c)}
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

    def col(idx)
        id = @idx[idx]
        return 0x00FFFFFF if @trans==id
        raise "Wrong palette index #{idx}" if !@cols[id]
        @cols[id]
    end

    def rcol(idx); @cols[idx] end

    def self.reidx(buf); instance.reidx(buf) end
    def self.clear(); instance.clear() end
    def self.setColors(buf); instance.setColors(buf) end
    def self.col(idx); instance.col(idx) end
    def self.rcol(idx); instance.rcol(idx) end

end

class ImgUnpacker
    def initialize()
        #Palette.clear()
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
        raise "Unknown compression type #{@ctype}" if @ctype!=1 && @ctype!=2
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
