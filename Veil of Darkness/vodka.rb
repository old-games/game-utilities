#!/usr/bin/env ruby
# encoding: utf-8

require 'bundler/setup'
require 'resedit'
require 'pathname'


class PatchCommand < Resedit::AppCommand
    def initialize()
        super(['patch'])
        addParam('file', 'code file to patch (path to code.1 / code.2)')
        addOption('rebuild', 'r', false, 'rebuild asm')
    end

    def patchCode2(fname)
        FileUtils.cp(fname, fname + '.bak') if ! File.exist?(fname + '.bak')
        patch = Resedit::CodePatch.loadPatch("ruinp.bin")
        mz = Resedit::MZ.new(fname+".bak")
        add = mz.replace(patch[0].hexdata())
        addr = add[1]

        puts "readkey -> ru_input..."
        mz.change("122E:113A:fix", patch[1].value(0, 10, patch[0].addr(0,addr)))
        mz.reloc("122E:1140:fix")

        puts "peekkey -> ru_input..."
        mz.change("122E:1162:fix", patch[1].value(1, 10, patch[0].addr(0,addr)))
        mz.reloc("122E:1168:fix")

        puts "max sym compare..."
        mz.change("0050:9AD7:fix", patch[1].value(3, 9))
        mz.change("0050:A704:fix", patch[1].value(4, 4))

        puts "to_lower -> ru_lower..."
        mz.change("19E3:0026:fix", patch[1].value(5, 5, patch[0].addr(1,addr)))
        mz.reloc("19E3:0029:fix")

        puts "Bye bye..."
        mz.change("19EB:0B87:fix", mz.hexify("log\x00Пока\x00пока\x00".encode("cp866")))
        mz.change("0050:9715:fix", "8B0B")
        mz.change("0050:997A:fix", "900B")

        puts "y/n fixes..."
        mz.change("122E:23EF:fix", "3D8D00")
        mz.change("122E:23F4:fix", "3D8400")
        mz.change("122E:2404:fix", mz.hexify("Д".encode("cp866")))
        mz.change("122E:2514:fix", mz.hexify("Д".encode("cp866")))
        mz.change("0050:006C:fix", mz.hexify("Д".encode("cp866")))

        puts "hotkey fixes..." # 11 dwords in jump table at 0050:054E + 9dw
        mz.change("0050:0560:fix", "94009100820098009C009900870085008C0095009A00")


        puts "strincmp -> ru_stricmp..."
        mz.change("19DD:0025:fix", patch[1].value(5, 21, patch[0].addr(2,addr)))
        mz.reloc("19DD:0028:fix")


        mz.print("changes")
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
