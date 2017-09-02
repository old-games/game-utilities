#!/usr/bin/env ruby

require 'bundler/setup'
require 'resedit'
require 'pathname'
require 'roo-xls'


class PatchCommand < Resedit::AppCommand
    def initialize()
        super(['patch'])
        addParam('file', 'code file to patch (path to code.1 / code.2)')
    end

    def swap16(word)
        return ((word & 0xFF) << 8) | ((word>>8) & 0xFF)
    end

    def readXls(fname)
        xlsname = Pathname.new(fname).parent().join("A.xls").to_s
        puts "reading table from #{xlsname}"
        xls = Roo::Spreadsheet.open(xlsname, extension: :xls)
        sht = xls.sheet(0)
        rid = 1
        map = {}
        while true
            rw = sht.row(rid)
            rid+=1
            break if rw[0]=="===="
            next if !rw[0] || !rw[1]
            map[rid-3] = rw[1].downcase()
        end
        map = Hash[map.invert().sort()]
        puts map
        ret = ""
        map.each{ |k,v|
            ret += sprintf("%04X", swap16(v))
        }
        #puts "TABLE = "+ret
        return ret
    end

    def job(params)
        fname = params['file']
        log("Patching #{fname}.")
        FileUtils.cp(fname, fname + '.bak') if ! File.exist?(fname + '.bak')

        mz = Resedit::MZ.new(fname)
        table = readXls(fname)
        puts "adding translate table code..."
        code = "bb100001c001c32e8b07f7d805feffcb" + table
        addr = mz.replace(code)[-1]
        #mz.dasm("append", "16")
        puts sprintf("inserting call to %04X:%04X...", addr[1], addr[0])
        mz.change("0050:AD07", "9A"+sprintf("%04X%04X", swap16(addr[0]), swap16(addr[1])))
        #mz.dasm("0050:AD04", "14")
        puts "Adding relocation..."
        mz.reloc("0050:AD0A")

        #mz.print("header")
        mz.print("changes")
        mz.save(fname)
        mz.close()

        log("File %s patched.", fname)
    end
end

class ExploreCommand < Resedit::AppCommand
    def initialize()
        super(['explore'])
    end

    def job(params)
    end
end


class App < Resedit::App
    def initialize()
        super('VoD key adjust','0.1',
            [
                PatchCommand.new(),
                ExploreCommand.new(),
            ],
            false,
            "by bjfn (c) old-games.ru, 2017")
    end
end

if __FILE__ == $0
    App.new().run()
end
