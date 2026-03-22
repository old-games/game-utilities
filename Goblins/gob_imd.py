# gob imd to/from wav v0.3 by FullSpektr and Dimouse

import fs
import glob
import os
import sys
import math

def addchunk(f, wav, sound_chunk_size):
    f.write(b'\x00')
    f.write(b'\xFF')
	
    buffer = wav.read(sound_chunk_size)
    f.write(buffer)
    print('Add sound data', len(buffer), 'bytes')

    if len(buffer) < sound_chunk_size:
      extra = b'\x80' * (sound_chunk_size - len(buffer))
      f.write(extra)
      print('Extra sound data', len(extra), 'bytes')


def export(imd_name):
    wav_name = fs.filename_wo_ext(imd_name) + '.wav'
    wav = fs.File(open(wav_name, 'wb'), 'le')

    # RIFF chunk
    wav.write(b'RIFF')
    wav.write_u32(0)  # chunk size (write later)
    wav.write(b'WAVE') # RIFF type

    # fmt chunk
    wav.write(b'fmt ')
    wav.write_u32(16)    # chunk size
    wav.write_u16(1)     # format tag
    wav.write_u16(1)     # channels
    wav.write_u32(22050) # freq
    wav.write_u32(22050) # bytes per sec (freq * channels * block align)
    wav.write_u16(1)     # block align
    wav.write_u16(8)     # bits

    # data chunk
    wav.write(b'data')
    wav.write_u32(0)  # chunk size (write later)
    data_size = 0

    with open(imd_name, 'rb') as f:
        f = fs.File(f, 'le')
        # header
        placeholder = f.read_u16()
        version = f.read_u16()
        frames = f.read_u16()
        y = f.read_u16()
        x = f.read_u16()
        width = f.read_u16()
        height = f.read_u16()
        flags = f.read_u16()
        data_offset = f.read_u16()

        print('version', hex(version), 'frames', frames)

        # palette
        palette = list(f.read(256*3))

        if version & 0xFF >= 3:
            quads = f.read_u16()
            f.seek(quads * 4 * 2, os.SEEK_CUR)

        seek_table_offset = 0
        if version & 0xFF >= 4:
            seek_table_offset = f.read_u32()

        if version & 0x8000:
            frame_coords_offset = f.read_u32()
            # print('file position of frame coordinates table', frame_coords_offset)

        sound_chunk_size = 0
        sound_chunks = 0
        if version & 0x4000:
            freq = f.read_u16()
            sound_chunk_size = f.read_u16()
            sound_chunks = f.read_s16()
            #print('raw sound_chunks', sound_chunks)
            if sound_chunks < 0: sound_chunks = -sound_chunks - 1
            # print('freq', freq,
            #     'sound_chunk_size', sound_chunk_size,
            #     'count', sound_chunks)

        if version & 0x2000:
            frame_chunk_size = f.read_u16()
            #print('frame_chunk_size', frame_chunk_size)

        # get file size
        f.seek(0, os.SEEK_END)
        file_size = f.tell()

        # read data
        f.seek(data_offset)

        frame = 0
        while frame < frames:

            if seek_table_offset > 0 and f.tell() >= seek_table_offset:
                break

            # сначала идет звук
            code = f.read_u16()
            #print(hex(code), 'pos', f.tell())
            if code == 0xFF01: # несколько чанков (обычно вначале?)
                print('audio frames', frame, code)
                buffer = f.read(sound_chunk_size * sound_chunks)
                data_size += wav.write(buffer)
            elif code == 0xFF00: # один чанк
                print('audio frame', frame, code)           
                buffer = f.read(sound_chunk_size)
                data_size += wav.write(buffer)
            elif code == 0xFFF0: # один чанк
                f.read(2) # ???
            elif code > 0: # видео данные?
                video_type = f.read_u16() # ???
                print('video frame', frame, code, video_type)
                f.seek(code, os.SEEK_CUR)
                frame += 1
                #print('video frame', frame, code, video_type)
            else: # если код 0, то это пустой кадр?
                print('empty frame', frame, code)
                frame += 1

        if frame < frames:
            print('processed only', frame, '? seek_table_offset', seek_table_offset, 'ftell', f.tell())
            print('WARNING! Perhaps the file is not fully parsed')
            

    # data chunk size
    wav.seek(40) # 12 + 24 + 4 = 36 + 4
    wav.write_u32(data_size)

    # RIFF chunk size
    data_size += 36
    wav.seek(4) # 40 - 36
    wav.write_u32(data_size)

    wav.close()

def inject(imd_name: str, wav_name: str):
    wav = fs.File(open(wav_name, 'rb'), 'le')
    wav.seek(40)
    data_size = wav.read_u32()
    print('wav data size', data_size)

    new_name = imd_name.split("\\")
    f2 = open(new_name[0]+"\\new\\"+new_name[1], 'w+b')
    with open(imd_name, 'r+b') as f:
        f = fs.File(f, 'le')
        # header
        placeholder = f.read_u16()
        version = f.read_u16()
        frames = f.read_u16()
        y = f.read_u16()
        x = f.read_u16()
        width = f.read_u16()
        height = f.read_u16()
        flags = f.read_u16()
        data_offset = f.read_u16()

        # palette
        palette = list(f.read(256*3))

        if version & 0xFF >= 3:
            quads = f.read_u16()
            f.seek(quads * 4 * 2, os.SEEK_CUR)

        seek_table_offset = 0
        if version & 0xFF >= 4:
            seek_table_offset = f.read_u32()

        if version & 0x8000:
            frame_coords_offset = f.read_u32()

        sound_chunk_size = 0
        sound_chunks = 0
        if version & 0x4000:
            freq = f.read_u16()
            sound_chunk_size = f.read_u16()
            sound_chunks = f.read_s16()
            if sound_chunks < 0: sound_chunks = -sound_chunks - 1

        if version & 0x2000:
            frame_chunk_size = f.read_u16()

        print('sound_chunk_size', sound_chunk_size)

        # get file size
        f.seek(0, os.SEEK_END)
        file_size = f.tell()

        f.seek(seek_table_offset)
        buffer3 = f.read(4*frames)

        f.seek(0, os.SEEK_SET)
        buffer1 = f.read(data_offset)
        f2.write(buffer1)
	
        # read data
        f.seek(data_offset)

        print(frames)

        add_offsets = []

        frame = 0
        buffer2 = 0
        code2 = 0
        frames2 = frames
        prevaudio = 0
        chunks = 0

        while frame < frames2:   #if need to cut out blank frames at the end
            if seek_table_offset > 0 and f.tell() >= seek_table_offset:
                break

            code = f.read_u16()

            if code == 0xFF01: # несколько чанков (обычно вначале?)
                f2.write(code.to_bytes(2, 'little'))
                prevaudio = 1
                print('audio frames', frame, code)
                sound_buffer_size = sound_chunk_size * sound_chunks
                buffer = wav.read(sound_buffer_size)
                f.read(sound_buffer_size)
                f2.write(buffer)
                chunks+=1
                if len(buffer) < sound_buffer_size:
                    extra = b'\x80' * (sound_buffer_size - len(buffer))
                    f2.write(extra)
                    print('Extra sound data', len(extra), 'bytes')
            elif code == 0xFF00: # один чанк
                f2.write(code.to_bytes(2, 'little'))
                prevaudio = 1
                print('audio frame', frame, code)           
                buffer = wav.read(sound_chunk_size)
                f.read(sound_chunk_size)

                f2.write(buffer)
                chunks+=1
                if len(buffer) < sound_chunk_size:
                    extra = b'\x80' * (sound_chunk_size - len(buffer))
                    f2.write(extra)
                    print('Extra sound data', len(extra), 'bytes')
                
                #data_size += wav.write(buffer)
            elif code == 0xFFF0: # один чанк
                f2.write(code.to_bytes(2, 'little'))
                unkn = f.read(2) # ???
                f2.write(unkn.to_bytes(2, 'little'))
                print('unknown frame', frame, code, unkn)
            elif code > 0: # видео данные?
                video_type = f.read_u16() # ???

                if prevaudio == 0:
                  addchunk(f2, wav, sound_chunk_size)
                  chunks+=1
                print('video frame', frame, code, video_type)

                f2.write(code.to_bytes(2, 'little'))
                f2.write(video_type.to_bytes(2, 'little'))
                
                buffer2 = f.read(code)
                code2 = code
                f2.write(buffer2)

                frame += 1
                prevaudio = 0

            else: # если код 0, то это пустой кадр?
                if prevaudio == 0:
                   addchunk(f2, wav, sound_chunk_size)
                   chunks+=1

                f2.write(code.to_bytes(2, 'little'))
                print('empty frame', frame, code)
                frame += 1
                prevaudio = 0
                
# if needed to add extra chunks
        print('wav data size', data_size)
        print('wav tell', wav.tell())
        max = (data_size) / sound_chunk_size - chunks
        max = math.ceil(max)
        print('add chunks', max)

        code2=0
        for i in range(0,max):
          add_offset = f2.tell()
          add_offsets.append(add_offset)
          addchunk(f2, wav, sound_chunk_size)
          f2.write(code2.to_bytes(2, 'little')) #empty chunk
          frames2+=1
        
        f2.seek(4)
        f2.write((frames2).to_bytes(2, 'little'))

        f2.seek(data_offset)
        f2.seek(0, os.SEEK_END)
        
        seek_table_offset2 = f2.tell()
        print('seek_table_offset', seek_table_offset, 'ftell', seek_table_offset2)

        f2.write(buffer3)
        for o in add_offsets:
          f2.write(o.to_bytes(4, 'little'))

        f2.seek(0x31c)
        f2.write(seek_table_offset2.to_bytes(4, 'little'))

        print('wav tell', wav.tell())
    #
    wav.close()
    

def print_help_and_exit():
    print('using: gob_imd.py export path/to/imds/')
    print('       gob_imd.py import path/to/in.imd path/to/import.wav')
    exit()

if len(sys.argv) < 3: print_help_and_exit()

action = sys.argv[1]
if action == 'export':
    c = 0
    for filepath in glob.iglob(sys.argv[2] + '*.IMD'):
        c += 1
        print(c, filepath)
        export(filepath)
    print('Done. Processed', c, 'files.')
elif action == 'import':
    if len(sys.argv) < 4: print_help_and_exit()
    inject(sys.argv[2], sys.argv[3])
    print('Done')
else:
    print_help_and_exit()
