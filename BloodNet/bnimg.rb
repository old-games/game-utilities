#!/usr/bin/env ruby
# encoding: utf-8

require 'bundler/setup'
require 'resedit'
require 'pathname'

class Palette
    class NoColorError < StandardError; end

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

    attr_reader :name

    def initialize()
        default()
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

    def packCol(col)
        r = (col>>16) & 0xFF
        g = (col>>8) & 0xFF
        b = col & 0xFF
        r >>= 2
        g >>= 2
        b >>= 2
        return [r,g,b].pack("CCC")
    end


    def default()
        @rev = nil
        @name = nil
        @cols = COLS.map{|c| cconv(c)}
    end

    def load(buf, name)
        @rev = nil
        @name = name.downcase
        @cols = [0]*(buf.length/3)
        (buf.length/3).times{|i|
            @cols[i] = cconv(('X'+buf[i*3,3]).unpack('N')[0])
        }
    end

    def repack(transpIdx, nucols)
        tcol = col(transpIdx)
        out = ''
        i = 0
        nucols.each{|c|
            next if c==tcol
            out += packCol(tcol) if i==transpIdx
            out += packCol(c)
            i += 1
        }
        while i<=transpIdx
            out += packCol(tcol)
            i+=1
        end
        load(out, @name)
        return out
    end

    def col(idx)
        ret = @cols[idx]
        raise "Wrong palette index #{idx}" if !ret
        ret
    end

    def idx(col)
        if @rev==nil
            @rev = {}
            @cols.each.with_index{|c,i|
                @rev[c] = i if !@rev[c]
            }
        end
        #        @rev = Hash[@cols.map.with_index{|x,i| [x,i]}] if @rev==nil
        ret = @rev[col]
        raise NoColorError, "Wrong palette color: #{col.to_s(16)}" if ret==nil
        ret
    end

    def self.col(idx); instance.col(idx) end
    def self.idx(col); instance.idx(col) end
    def self.load(buf, name); instance.load(buf, name) end
    def self.default; instance.default end
    def self.name; instance.name end
    def self.repack(transpId, cols); instance.repack(transpId, cols) end
end


class PLFile
    PALS = {/chargen.*/=>"chargen.face0"}
    PK_START = -10
    PK_VAL = -1
    PK_RPT = -2


    class PLImage
        attr_reader :pal, :width, :height

        def initialize(path, ofs)
            @reidx=nil
            @pal = nil
            File.open(path, "rb") {|fp|
                fp.seek(ofs)
                @hdr = fp.read(0x1C).unpack("C20v4")
                @width = @hdr[-2]
                @height = @hdr[-3]
                @flags = @hdr[0]
                @packed = fp.read(@hdr[-1])
                @pal = fp.read((@hdr[2]+1)*3) if (@flags & 1)!=0
                @reidx = fp.read(@hdr[1]+1) if (@flags & 2)!=0
            }
        end

        def trans; @hdr[3] end

        def setCols(cols)
            raise "No Palette in image" if (@flags & 1)==0
            @pal = cols
            clen = cols.length/3
            @hdr[2] = clen-1
            if @reidx.length<clen
                @reidx = (0..clen-1).to_a.pack("C*")
                @hdr[1] = clen-1
            end
        end

        def mkindices(imgdata)
            idx = [0]*256
            imgdata.each{|b| idx[b] += 1 }
            out = []
            for i in 0..255
                out += [i] if idx[i]>0
            end
            @ridx = out.pack("C*")
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
            op+=1 if out[op][1]==PK_RPT
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
            data = analyze(data)
            #TODO: calc unpacked tail
            tail = ''
            # unp = data.length-1
            # while data[unp][1]==-1
            #     tail = data[unp][0].chr+tail
            #     unp-=1
            # end
            # data = data[0..-tail.length] if tail.length>0
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
                    bs.write(v[2] & 0xFF)	#lo byte or 1-byte length
                elsif v[1]==PK_VAL
                    #unmapped
                    bs.write(0x0F, 4)
                    bs.write(v[0])
                else
                    #mapped
                    bs.write(v[1], 4)
                end
            }
            return [bs.finish() + tail, tail.length]
        end

        def pack(imgdata=nil)
            data = @packed
            loop do
                break if !imgdata
                ctype = @hdr[4]
                if ctype==0x10
                    data = imgdata.pack("C*")
                    break
                end
                if @reidx
                    ridx = Hash[mkindices(imgdata).map.with_index{|x,i| [x,i]}]
                    data = imgdata.map{|i| ridx[i]}
                end
                data, unp = packData(data)
                @hdr[-4] = unp
                @hdr[-1] = data.length
                puts "#{@hdr}"
                break
            end
            ret = @hdr.pack("C20v4")
            ret += data
            ret += @pal if (@flags & 1)!=0
            ret += @reidx if (@flags & 2)!=0
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
                puts "#{@hdr}"
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


    attr_reader :path, :tbl

    def initialize(path)
        @path = Pathname.new(path)
        @tbl = readTbl()
        @bodys = {}
    end

    def name; @path.basename(".PL").to_s end
    def imgname(name)
        name.downcase!
        @tbl.each{|nm,ofs|
            return nm if nm.downcase==name
        }
        return nil
    end

    def loadPalette(inm, set=true)
        f = PLImage.new(@path, @tbl[inm])
        return f.pal if !set
        if f.pal
            Palette.load(f.pal, "#{name}.#{inm}")
        else
            findPalette(inm)
        end
        return f
    end

    def findPalette(inm)
        nm = "#{name}.#{inm}".downcase
        pname = nil
        PALS.each{|k,v|
            next if (k=~nm).nil?
            pname = v
            break
        }
        if !pname
            nid = inm =~ /\d*$/
            pname = nid==inm.length ? nil : "#{name}.#{inm[0..nid-1]}0".downcase
        end
        return if Palette.name == pname
        return Palette.default() if !pname
        pl,im = pname.split('.')
        lib = pl==name ? self : PLFile.new(@path.dirname.join(pl.upcase+".PL"))
        im = lib.imgname(im)
        return Palette.default() if !im
        pal = lib.loadPalette(im, false)
        return Palette.default() if !pal
        Palette.load(pal, pname)
    end

    def loadImage(inm)
        f = loadPalette(inm)

        img = Resedit::createImage(f.width, f.height)
        buf = f.unpack()
        i = 0
        f.height.times{|y|
            f.width.times{|x|
                img.setPixel(x, y, Palette.col(buf[i]))
                i+=1
            }
        }
        return img
    end

    def saveImage(inm, img=nil)
        f = loadPalette(inm)
        imgdata = nil
        if img
            raise "Wrong image size #{img.width}x#{img.height}. Expected #{f.width}x#{f.height}" if f.width!=img.width || f.height!=img.height
            imgdata = [0]*img.width*img.height
            pset = false
            begin
                i=0
                img.height.times{|y|
                    img.width.times{|x|
                        col = img.getPixel(x, y)
                        imgdata[i] = Palette.idx(col)
                        i += 1
                    }
                }
            rescue Palette::NoColorError
                raise if !f.pal || pset
                cols = Set.new
                img.height.times{|y|
                    img.width.times{|x|
                        cols.add(img.getPixel(x, y))
                }}
                puts "!!!WARNING: Updating palette of #{inm}"
                f.setCols(Palette.repack(f.trans, cols))
                pset = true
                retry
            end
        end
        @bodys[inm] = f.pack(imgdata)
    end

    def readTbl(nosort=false)
        t = {}
        File.open(@path, "rb") {|f|
            cnt, ftbl = f.read(6).unpack("vV")
            f.seek(ftbl)
            cnt.times {
                ofs,nm = f.read(12).unpack("VA*")
                t[nm] = ofs
            }
        }
        return t if nosort
        t.sort_by{|k,_| k.downcase}.to_h
    end

    def save(fname)
        t = readTbl(true)
        buf = ''
        t.each{|nm,ofs|
            t[nm] = buf.length+6
            buf+=@bodys[nm]
        }
        File.open(fname,"wb"){|f|
            f.write([t.length, buf.length+6].pack("vV"))
            f.write(buf)
            t.each{|nm, ofs|
                f.write([ofs,nm].pack("VA*"))
                f.write("\x00"*(8-nm.length)) if nm.length<8
            }
        }
    end
end


class PlCommand < Resedit::ConvertCommand

    def initialize()
        super("pl","*.pl")
    end

    def import(infile)
        logd("importing pl #{@resname} from #{infile}")
        dname = "#{infile}_pl"
        f = PLFile.new(backup())
        f.tbl.each{|nm,ofs|
            fname = File.join(dname,"#{nm}.png")
            img = File.exist?(fname) ? Resedit::loadImage(fname) : nil
            puts "Packing file #{fname}" if img
            f.saveImage(nm, img)
        }
        puts "Saving resource #{@resname}"
        f.save(@resname)
    end

    def export(outfile)
        logd("exporting pl #{@resname} to #{outfile}")
        dname = "#{outfile}_pl"
        Dir.mkdir(dname) unless File.directory?(dname)
        f = PLFile.new(@resname)
        f.tbl.each{|nm,ofs|
            puts "Unpaking #{nm} @ #{ofs.to_s(16)}"
            img = f.loadImage(nm)
            img.save(File.join(dname,"#{nm}.png"))
        }
    end
end

class ReadPaletteCommand < Resedit::AppCommand
    def initialize
        super('readpal')
        addParam('file', 'palette bitmap')
    end

    def job(params)
        require 'free-image'
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
