#!/usr/bin/env ruby
# encoding: utf-8

require 'bundler/setup'
require 'resedit'
require 'pathname'


class UnpackCommand < Resedit::AppCommand
    def initialize()
        super(['unpack'])
        addParam('file', 'file to unpack')
    end

    def adr(seg, ofs); (seg<<4)+ofs end

    def job(params)
        fname = params['file']
        FileUtils.cp(fname, fname + '.bak') if ! File.exist?(fname + '.bak')
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
                UnpackCommand.new(),
            ],
            false,
            "by bjfn (c) old-games.ru, 2017")
    end
end

if __FILE__ == $0
    App.new().run()
end
