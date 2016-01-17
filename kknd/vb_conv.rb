#!/usr/bin/env ruby

require 'wavefile'

class Wave

    def initialize(file)
        @file = file
    end

    def write(channels, bps, rate, data)
        sz = data.size
        sz += 36
        block = bps/8*channels;
        bytePs = block*rate
        open(@file, "wb") {|f|
            f.write("RIFF"+[sz].pack('V')+"WAVEfmt ")
            f.write([16,1,channels,rate,bytePs,block,bps].pack('VvvVVvv'))
            f.write("data"+[data.size].pack('V'))
            f.write(data)
        }
    end

end

class Siff
    attr_accessor(:width, :height, :frames, :bps, :rate)

    def initialize(file)
        @file = file
    end


    def readVb(fname, nuData=nil)
        _data = ''
        open(fname,'rb') {|f|
            _name = f.read(4)
            _sz = f.read(4).unpack('N')[0]
            _ver = f.read(4)
            raise "Wrong vb format" if (_name!='SIFF' || _sz!=f.size-8 || _ver!="VBV1")
            _name = f.read(4)
            _sz = f.read(4).unpack('N')
            f.read(2)
            @width,@height = f.read(4).unpack('vv')
            f.read(4)
            @frames,@bps,@rate = f.read(6).unpack('v3')
            f.read(16)
            raise "Wrong vb format" if (_name!='VBHD')
            _name = f.read(4)
            _sz = f.read(4).unpack('N')[0]
            raise "Wrong vb format" if (_name!='BODY')
            _pos = 0
            _bid = 0
            while _pos<_sz
                _ps = f.pos
                _bsz,_fl = f.read(6).unpack('Vv')
                _pos+=_bsz
                _bid+=1
                _flags = ''
                if (_fl & 1)!=0 
                    _mot = f.read(4).unpack('s2<')
                    _flags+=' motion='+_mot.to_s 
                end
                if (_fl & 4)!=0
                    _asz = f.read(4).unpack('V')[0]
                    _flags+=' audio(%d)' % _asz
                    _data += f.read(_asz-4)
                end
                if (_fl & 8)!=0
                    _vsz = f.read(4).unpack('V')[0]
                    _flags+=' video(%d)' % _vsz
                    f.read(_vsz-4) 
                end
                if (_fl & 16)!=0
                    _psz,_from,_count = f.read(6).unpack('VCC')
                    _flags+=' palette(%d:%d:%d)' % [_psz,_from,_count]
                    f.read(3*_count)
                end
                if (_fl & 32)!=0
                    _fdur = f.read(2).unpack('v')[0]
                    _flags+=' frame_dur='+_fdur.to_s
                end
                if (_fl & 64)!=0
                    _ssz = f.read(4).unpack('V')[0]
                    _flags+=' something(%d)' % _ssz
                    f.read(_ssz-4)
                end
                #print "Block_%d @0x%08X %d %d: %s\n" % [_bid, _ps, _bsz, _fl, _flags]
            end
            raise "Bad file data" if (_pos != _sz)
        }
        return _data
    end

    def pack
        return 1
    end

    def unpack
        _data = readVb(@file)
        wav = Wave.new(File.join(File.dirname(@file), File.basename(@file, '.*')+".wav"))
        wav.write(1, @bps, @rate, _data)
        return 0
    end

end



def usage()
print <<EOF
vb_conv version 1.0
usage:
    vb_conv.rb unpack <file> - unpack vb to wav
    vb_conv.rb pack <file> - pack wav to vb
EOF
return 1
end

if __FILE__ == $0
    cmd = ARGV[0]
    file = ARGV[1]
    if (!file || !cmd)
        exit(usage())
    end
    case cmd
    when 'pack'
        exit(Siff.new(file).pack())
    when 'unpack'
        exit(Siff.new(file).unpack())
    else
        puts "Error: unknown command "+cmd
        exit(usage())
    end
end