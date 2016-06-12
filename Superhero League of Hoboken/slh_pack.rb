#!/usr/bin/env ruby
require 'rubygems'

begin
    require 'bundler/setup'
rescue LoadError
    puts "Bundler not found. Installing."
    if !system("gem install bundler || sudo gem install bundler")
        puts "Bundler installation failure.\nRun 'gem install bundler'."
        exit(1)
    end
end

begin
    require 'resedit'
rescue LoadError
    puts "Resedit not found. Installing."
    open("./Gemfile", "w") {|f|
        f.write('source "https://rubygems.org"')
        f.write("\ngem 'resedit', :github => 'mypasswordisqwerty/gemresedit', :branch => 'master'\n")
    }
    if system("bundle install")
        puts "Dependencies installed."
    end
    exit(1)
end


class FontConvertCommand < Resedit::FontConvertCommand
    def initialize()
        super('fnt')
    end 

    def pack(file, name)
    end

    def unpack(file, name)
        log('unpacking '+name)
        head = file.read(10).bytes
        bts=head[2]
        strt = head[3]
        cnt = head[4]+1
        hgt = head[6]
        wdt = head[7]
        xwds = head[8]
        wds = nil
        if (wdt==0xff)
            wdt=0
            wds = file.read(xwds==0xFF ? 256 : cnt).bytes
            wds.each { |w|
                wdt=w if w>wdt && w<0x10
            }
        end
        logd("reading font #{strt} #{cnt} #{hgt} #{wdt}")
        fnt = Resedit::Font.new(wdt, hgt)
        i=strt
        while i<cnt do
            w = wdt
            w = wds[i] if wds
            buf = file.read(hgt*bts).bytes
            res = Resedit::BitConverter.bits2Bytes(buf, wdt)
            fnt.setChar(i, res)
            i+=1
        end
        return fnt
    end
end

=begin
class TextConvertCommand < Resedit::TextConvertCommand
    def pack(file)
    end

    def unpack(file)
    end
end
=end

class App < Resedit::App
    def initialize()
        super('slh_pack','1.0',
            [FontConvertCommand.new()],
            false,
            "by bjfn (c) old-games.ru, 2016")
    end
end


if __FILE__ == $0
    App.new().run()
end