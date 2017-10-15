#!/usr/bin/env ruby

require 'bundler/setup'
require 'resedit'
require 'pathname'


class PatchCommand < Resedit::AppCommand
    def initialize()
        super(['patch'])
        addParam('file', 'code file to patch (path to code.1 / code.2)')
        addOption('rebuild', 'r', false, 'rebuild asm')
    end

    def swap16(word)
        return ((word & 0xFF) << 8) | ((word>>8) & 0xFF)
    end

    def patchCode2(fname)
        FileUtils.cp(fname, fname + '.bak') if ! File.exist?(fname + '.bak')
        patch = Resedit::CodePatch.loadPatch("ruinp.bin")
        mz = Resedit::MZ.new(fname+".bak")
        add = mz.replace(patch[0].hexdata())
        addr = add[1]

        r122e = (0x122e + add[2]).to_s(16)
        r50 = (0x50 + add[2]).to_s(16)
        r19e3 = (0x19E3 + add[2]).to_s(16)
        puts "Patching readkey func -> ru_input"
        mz.change(r122e+":113A", patch[1].value(0, 10, patch[0].addr(0,addr)))
        mz.reloc(r122e+":1140")

        puts "Patching peekkey func -> ru_inpu"
        mz.change(r122e+":1162", patch[1].value(1, 10, patch[0].addr(0,addr)))
        mz.reloc(r122e+":1168")

        puts "Patch max key compare"
        mz.change(r50+":9AD7", patch[1].value(3, 9))
        mz.change(r50+":A704", patch[1].value(4, 4))

        puts "To lower change -> ru_lower"
        mz.change(r19e3+":0026", patch[1].value(5, 5, patch[0].addr(1,addr)))
        mz.reloc(r19e3+":0029")



        #mz.print("changes")
        mz.print("header")
        mz.save(fname,"final")
        mz.close()
    end

    def job(params)
        if params['rebuild']
            puts "rebuilding asm"
            raise "Rebuild failed" if !system("nasm ruinp.asm -o ruinp.bin")
        end

        fname = params['file']
        log("Patching #{fname}.")
        if fname.downcase.end_with?("code.2")
            patchCode2(fname)
        else
            raise "Don't know how to patch "+fname
        end


        log("File %s patched.", fname)
    end
end

class App < Resedit::App
    def initialize()
        super('VoD key adjust','0.1',
            [
                PatchCommand.new(),
            ],
            false,
            "by bjfn (c) old-games.ru, 2017")
    end
end

if __FILE__ == $0
    App.new().run()
end
