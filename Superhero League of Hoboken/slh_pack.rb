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
    def pack(file)
    end

    def unpack(file)
    end
end

class TextConvertCommand < Resedit::TextConvertCommand
    def pack(file)
    end

    def unpack(file)
    end
end


class App < Resedit::App
    def initialize()
        super('slh_pack','1.0',[FontConvertCommand.new(), TextConvertCommand.new()])
    end
end


if __FILE__ == $0
    App.new().run()
end