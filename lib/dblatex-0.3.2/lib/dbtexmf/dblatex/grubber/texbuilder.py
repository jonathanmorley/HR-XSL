# This file is part of Rubber and thus covered by the GPL
# (c) Emmanuel Beffara, 2002--2006
"""
LaTeX document building system for Grubber.

This module is specific to Grubber and provides a class that encapsulates some of
the rubber internals.
"""
import subprocess
import os
from msg import _, msg
from maker import Maker
from latex import Latex


class LatexBuilder:
    """
    Main (g)rubber wrapper hiding all the internals and compiling the
    required tex file.
    """
    def __init__(self):
        # The actual workers
        self.maker = Maker()
        self.tex = Latex(self.maker)
        self.maker.dep_append(self.tex)

        # What to do
        self.backend = "pdftex"
        self.format = "pdf"
        self.index_style = ""
        self.batch = 1
        self.encoding = "latin-1"
        self.texpost = ""

    def set_format(self, format):
        # Just record it
        self.format = format

    def set_backend(self, backend):
        self.backend = backend

    def set_index_style(self, index_style):
        self.index_style = index_style

    def compile(self, source):
        self.tex.batch = self.batch
        self.tex.encoding = self.encoding
        self.tex.set_source(source)

        # Load the modules needed to produce the expected output format
        if (self.format == "pdf"):
            if (self.backend == "pdftex"):
                self.tex.modules.register("pdftex")
            elif (self.backend == "xetex"):
                self.tex.modules.register("xetex")
            else:
                self.tex.modules.register("dvips")
                self.tex.modules.register("ps2pdf")
        elif (self.format == "ps"):
            self.tex.modules.register("dvips")

        # Now load other the modules required to compile this file
        self.tex.prepare()

        # Set the index style
        if self.index_style and self.tex.modules.has_key("makeidx"):
            idx = self.tex.modules["makeidx"]
            idx.style = self.index_style

        # Let's go...
        rc = self.maker.make()
        if rc != 0:
            raise OSError("%s compilation failed" % self.tex.program)

        # Post process script to call?
        if not(self.texpost):
            return

        os.environ["LATEX"] = self.tex.program
        rc = subprocess.call([self.texpost, source], stdout=msg.stdout)
        if rc == 1:
            return
        if rc != 0:
            raise OSError("%s texpost failed" % self.texpost)

        rc = self.maker.make(force=1)
        if rc != 0:
            raise OSError("%s post compilation failed" % self.tex.program)

    def clean(self):
        self.tex.clean()
        self.reinit()

    def reinit(self):
        self.tex.reinit()
        self.maker.reinit()
        self.maker.dep_append(self.tex)

    def print_errors(self):
        msg.display_all(self.tex.get_errors(), writer=msg.write_stderr)

