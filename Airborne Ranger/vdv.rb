#!/usr/bin/env ruby
# encoding: utf-8

require 'bundler/setup'
require 'resedit'
require 'pathname'

class Packer
    TBL_LEN = 0x800

    def initialize(data)
        @data = data
        clearTbl()
    end

    def clearTbl()
        @sz = 9
        @mpos = 1 << @sz
        @ofs = [-1] * 0x800
        @vls = (0..0xFF).to_a + [0]*0x700
        @pos = 0x100
    end

    def unpack()
        ret = ''
        b = Resedit::BitStream.new(@data, 2)
        maxsz = b.read(8)
        prev = 0
        while !b.eof?
            i = b.read(@sz)
            ri = i
            @ofs[@pos] = prev
            a = nil
            if i >= @pos
                i = prev
                prev = @pos
                a = @vls[@pos-1].chr
            else
                prev = i
            end

            v = @vls[i].chr
            pi = i
            while @ofs[i]>=0
                i = @ofs[i]
                v = @vls[i].chr + v
            end
            v += a if a
            ret += v
            #puts "#{ri} #{pi} (#{@pos} #{@ofs[@pos-2]} #{@ofs[@pos-1]} #{@ofs[@pos]} #{@ofs[@pos+1]}) - "+v.each_byte.map { |b| sprintf("%02X",b) }.join if @pos>=670
            @vls[@pos] = v[0]

            @pos += 1
            if @pos >= @mpos
                @sz += 1
                @mpos = 1 << @sz
                #puts "--- #{@sz} #{@mpos} #{@pos}"
                clearTbl() if @sz > maxsz
            end
        end
        return ret
    end

    def pack()
    end

    def self.unpack(data); Packer.new(data).unpack() end
    def self.pack(data); Packer.new(data).pack() end
end


class DtxCommand < Resedit::ConvertCommand
    def initialize()
        super('dtx', "*.dtx")
    end

    def import(inname)
        logd("importing dtx #{inname} to #{@resname}")
        back = backup()
    end

    def export(outname)
        logd("exporting dtx #{@resname} to #{outname}")
        data = File.open(@resname, "rb").read
        File.open(outname+".bin", "wb"){|f|
            f.write(Packer.unpack(data))
        }
    end

end

class MzUnpackCommand < Resedit::AppCommand
    def initialize()
        super(['mzunpack'])
        addParam('file', 'file to unpack')
    end

    def adr(seg, ofs); (seg<<4)+ofs end

    def job(params)
        fname = params['file']
        FileUtils.cp(fname, fname + '.bak') if !File.exist?(fname + '.bak')
        log("Unpacking #{fname}.")
        mz = Resedit::MZ.new(fname+".bak")
        cs = mz.header.info[:CS]
        data = mz.body.bytes
        descr = data[cs<<4, 16].unpack("v*")
        rel = adr(cs, 0x125)
        relocs = {}
        rcnt = 0
        for i in 0..0x0f
            cnt = data[rel,2].unpack('v')[0]
            rel += 2
            r = data[rel, cnt*2].unpack('v*')
            relocs[i * 0x1000] = r
            rcnt += r.length
            rel += cnt*2
        end
        wpos = descr[6]<<4
        data += "\x00" * (wpos - data.length)
        rpos = (cs << 4) - 1
        rpos -= 1 while data[rpos].ord() == 0xFF
        #unpack
        while true
            op = data[rpos].ord()
            sz = data[rpos-2, 2].unpack("v")[0]
            wpos -= sz
            if op & 0xFE == 0xb0
                rpos-=4
                c = data[rpos+1]
                data = data[0, wpos] + c*sz + data[wpos+sz .. -1]
            elsif op & 0xFE == 0xb2
                rpos -= sz+3
                data = data[0, wpos] + data[rpos+1, sz] + data[wpos+sz .. -1]
            else
                raise "Unpack failed - unknown op"
            end
            break if op & 1!=0
        end
        data = data[0, 0x1b510]
        mz.body.setData(data)
        mz.header.setBodySize(data.length)
        #relocs restore
        mz.header.setSpaceForRelocs(rcnt)
        idx=0
        relocs.each{|seg, ofs|
            ofs.each{|o|
                mz.header.setRelocation(idx, [o, seg])
                idx += 1
            }
        }
        #ss:sp, cs:ip restore
        mz.header.setInfo(:IP, descr[0])
        mz.header.setInfo(:CS, descr[1])
        mz.header.setInfo(:SP, descr[4])
        mz.header.setInfo(:SS, descr[5])

        mz.print('header')
        mz.save(fname, "final")
    end
end

class App < Resedit::App
    def initialize()
        super('VDV','0.1',
            [
                MzUnpackCommand.new(),
                DtxCommand.new(),
            ],
            false,
            "by bjfn (c) old-games.ru, 2017")
    end
end

if __FILE__ == $0
    App.new().run()
end
