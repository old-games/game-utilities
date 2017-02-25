#!/usr/bin/env ruby
open("./Gemfile", "w") {|f|
    f.write('source "http://rubygems.org"')
    f.write("\ngem 'resedit', '>=1.0.3', :github => 'mypasswordisqwerty/gemresedit', :branch => 'master' \n")
}
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
    system("bundle install --quiet")
    require 'resedit'
rescue LoadError
    puts "Dependencies not loaded. Try to rerun this script again."
    exit(1)
end


class FontConvertCommand < Resedit::FontConvertCommand
    def initialize()
        super('fnt')
    end

    def mkfont(file)
        @head = file.read(10).bytes
        @bts=@head[2]
        @strt = @head[3]
        @cnt = @head[4]+1
        @hgt = @head[6]
        @wdt = @head[7]
        @xwds = @head[8]
        @wds = nil
        if @wdt==0xff
            @wdt=0
            @wds = file.read(@xwds==0xFF ? 256 : @cnt).bytes
            @wds.each { |w|
                @wdt=w if w>@wdt && w<0x10
            }
        end
        logd("reading font #{@resname} #{@strt} #{@cnt} #{@hgt} #{@wdt}")
        return Resedit::Font.new(@wdt, @hgt)
    end


    def pack(file, stream)
        log('packing '+@resname)
        @strt=@font.minChar if @font.minChar<@strt
        @cnt=@font.maxChar+1 if @font.maxChar+1>@cnt
        @head[3]=@strt
        @head[4]=@cnt-1
        stream.write(@head.pack("C*"))
        if @head[7] == 0xff
            while @wds.length<@cnt
                @wds << 0
            end
            i=@strt
            while i<@cnt
                w=@font.charWidth(i)
                if w
                    @wds[i]=w
                end
                i+=1
            end
            stream.write(@wds.pack("C*"))
        end
        empty=[]
        for i in 0..@bts*@hgt-1
            empty << 0
        end
        i=@strt
        while i < @cnt
            buf=@font.getChar(i)
            res=Resedit::BitConverter.bytes2Bits(buf,@wdt,@bts) if buf
            res=empty if !buf
            stream.write(res.pack("C*"))
            i += 1
        end
    end


    def unpack(file)
        log('unpacking '+@resname)
        i=@strt
        while i < @cnt
            buf = file.read(@hgt*@bts).bytes
            res = Resedit::BitConverter.bits2Bytes(buf, @wdt)
            w=@wds[i] if @wds
            @font.setChar(i, res, w)
            i += 1
        end
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
        super('slh_pack','1.1',
            [FontConvertCommand.new()],
            false,
            "by bjfn (c) old-games.ru, 2016")
    end
end


if __FILE__ == $0
    App.new().run()
end
