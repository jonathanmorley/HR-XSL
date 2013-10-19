# 
# Slow interface to fontconfig for Dblatex, that only parses some commmand line
# output to store the fonts available on the system and their characteristics.
#
# An efficient solution should use some python bindings to directly call the
# C fontconfig library.
#
from subprocess import Popen, PIPE

def execute(cmd):
    p = Popen(cmd, shell=True, stdout=PIPE)
    data = p.communicate()[0]
    rc = p.wait()
    if rc != 0:
        raise OSError("'%s' failed (%d)" % (cmd, rc))
    return data


class FcFont:
    """
    Font Object with properties filled with the fc-match command output.
    """
    def __init__(self, fontnames, partial=False):
        self.name = fontnames[0]
        self.aliases = fontnames[1:]
        self._completed = False
        if not(partial):
            self.complete()

    def complete(self):
        if not(self._completed):
            d = execute("fc-match --verbose '%s'" % self.name)
            d = d.strip()
            self._build_attr_from(d)
            self._completed = True

    def _build_attr_from(self, data):
        ninfos = self._splitinfos(data)

        # Remove the first line
        ninfos[0] = ninfos[0].split("\n")[1]
        for i in ninfos:
            if i: self._buildattr(i)
        
        # Check the consistency
        if self.family != self.name.replace("\-", "-"):
            raise ValueError("Unknown font '%s' vs '%s'" % (self.name,
            self.family))

    def _splitinfos(self, data):
        ninfos = [data]
        for sep in ("(s)", "(w)", "(=)"):
            infos = ninfos
            ninfos = []
            for i in infos:
                ni = i.split(sep)
                ninfos += ni
        return ninfos

    def _buildattr(self, infos):
        """
        Parse things like:
           'fullname: "Mukti"(s)
            fullnamelang: "en"(s)
            slant: 0(i)(s)
            weight: 80(i)(s)
            width: 100(i)(s)
            size: 12(f)(s)'
        """
        try:
            attrname, attrdata = infos.split(":", 1)
        except:
            # Skip this row
            print "Wrong data? '%s'" % infos
            return
        
        #print infos
        attrname = attrname.strip() # Remove \t
        attrdata = attrdata.strip() # Remove space

        # Specific case
        if attrname == "charset":
            self._build_charset(attrdata)
            return

        # Get the data type
        if (not(attrdata) or (attrdata[0] == '"' and attrdata[-1] == '"')):
            setattr(self, attrname, attrdata.strip('"'))
            return
        
        if (attrdata.endswith("(i)")):
            setattr(self, attrname, int(attrdata.strip("(i)")))
            return

        if (attrdata.endswith("(f)")):
            setattr(self, attrname, float(attrdata.strip("(f)")))
            return

        if (attrdata == "FcTrue"):
            setattr(self, attrname, True)
            return

        if (attrdata == "FcFalse"):
            setattr(self, attrname, False)
            return

    def _build_charset(self, charset):
        """
        Parse something like:
           '0000: 00000000 ffffffff ffffffff 7fffffff 00000000 00002001 00800000 00800000
            0009: 00000000 00000000 00000000 00000030 fff99fee f3c5fdff b080399f 07ffffcf
            0020: 30003000 00000000 00000010 00000000 00000000 00001000 00000000 00000000
            0025: 00000000 00000000 00000000 00000000 00000000 00000000 00001000 00000000'
        """
        self.charsetstr = charset
        self.charset = []
        lines = charset.split("\n")
        for l in lines:
            umajor, row = l.strip().split(":", 1)
            int32s = row.split()
            p = 0
            for w in int32s:
                #print "=> %s" % w
                v = int(w, 16)
                for i in range(0, 32):
                    m = 1 << i
                    #m = 0x80000000 >> i
                    if (m & v):
                        uchar = umajor + "%02X" % (p + i)
                        #print uchar
                        self.charset.append(int(uchar, 16))
                p += 32

    def remove_char(self, char):
        try:
            self.charset.remove(char)
        except:
            pass

    def has_char(self, char):
        #print self.family, char, self.charset
        return (ord(char) in self.charset)


class FcManager:
    """
    Collect all the fonts available in the system. The building can be partial,
    i.e. the font objects can be partially created, and updated later (when
    used).
    """
    def __init__(self):
        self.fonts = {}

    def get_font(self, fontname):
        font = self.fonts.get(fontname)
        if font:
            font.complete()
        return font

    def get_font_handling(self, char, all=False):
        fonts = []
        # Brutal method to get something...
        for f in self.fonts.values():
            f.complete()
            if f.has_char(char):
                if all:
                    fonts.append(f)
                else:
                    return f
        return fonts

    def build_fonts(self, partial=False):
        d = execute("fc-list")
        fonts = d.strip().split("\n")
        for f in fonts:
            fontnames = f.split(":")[0].split(",")
            mainname = fontnames[0]
            if self.fonts.get(mainname):
                print "'%s': duplicated" % mainname
                continue

            #print fontnames
            font = FcFont(fontnames, partial=partial)
            self.fonts[mainname] = font


