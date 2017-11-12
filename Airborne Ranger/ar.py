from dosbox import *
import os
import logging
import struct
logger = logging.getLogger("dosbox.AR")


class Ar(Program):
    """ Airborne ranger """

    def __init__(self):
        sym = os.path.join(os.path.dirname(__file__), "ar_sym.json")
        Program.__init__(self, "ar.exe", sym)
        self.files = None
        self.lastFileId = None

    def readFiles(self):
        fls = struct.unpack("<61H", self.mem("FILE_TABLE", 2*61))
        self.files = []
        for x in fls:
            f = struct.unpack("<13sB5H", self.dmem(x, 24))
            f = [f[0].rstrip("\x00"), f[1], [hex(f[2]), hex(f[3])], f[4], [hex(f[5]), hex(f[6])], 0]
            self.files += [f]
        logger.debug("Ar files: %s", str(self.files))

    def loaded(self):
        logger.info("AR loaded at %04X", self.base)
        self.readFiles()
        Breaks().add("FILE_UNPACK", self.unpack)
        Breaks().add(self.rebase("0000:0826"), self.unpacked)
        Dosbox().cont()

    def unpack(self, **kwargs):
        fid = self.wvar(0x18e)  # read file id
        logger.info("unpacking file %d (%s)", fid, self.files[fid])
        # Dosbox().cont()

    def unpacked(self, **kwargs):
        self.lastFileId = self.wvar(0x18e)  # read file id
        f = self.files[self.lastFileId]
        f[5] = self.ctx.di - int(f[4][1][2:], 16)
        logger.info("unpacked file %d (%s) @ %s len %d", self.lastFileId, f[0], f[4], f[5])
        logger.info("You can dump file with ar.prog.dumpLastFile()")

    def dumpLastFile(self):
        f = self.files[self.lastFileId]
        path = os.path.join("qemu/ar/res", f[0])
        logger.info("Saving file %s", path)
        mem = self.mem(f[4], f[5])
        with open(path, "wb") as f:
            f.write(mem)


prog = Ar()
