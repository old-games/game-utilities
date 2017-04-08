#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'resedit'


class PatchCommand < Resedit::AppCommand
    def initialize()
        super(['patch'])
        addParam('file', nil, 'code file to patch (path to code.1 / code.2)')
        addOption('rebuild', 'r', false, 'rebuild asm')
    end

    def job(params)
        if params['rebuild']
            raise "Rebuild failed" if !system("nasm ruinp.asm -o ruinp.bin")
        end

        fname = params['file']
        log("Patching %s.", fname)
        FileUtils.cp(fname, fname + '.bak') if ! File.exist?(fname + '.bak')

        mz = Resedit::MZ.new(fname)
        mz.replace("./ruinp.bin")
        mz.print("header")
        puts
        mz.dasm("append")
        mz.save(fname)
        mz.close()

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
