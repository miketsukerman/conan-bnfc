from conans import ConanFile, tools
import os

class BnfcConan(ConanFile):
    name = "bnfc"
    version = "2.8.3"
    license = "GPL"
    author = "Michael Tsukerman <miketsukerman@gmail.com>"
    url = "https://github.com/miketsukerman/conan-bnfc"
    description = "Compiler front-end generator based on Labelled BNF"
    topics = ("bnfc", "lbnf", "parser")
    settings = "os", "compiler", "build_type", "arch"
    options = {"shared": [True, False]}
    default_options = {"shared": False}
    generators = "cmake"

    def source(self):
        self.run("git clone https://github.com/BNFC/bnfc")

    def build(self):
        with tools.chdir("bnfc/source"):
            self.run("cabal install --bindir={} --libdir={}".format(os.path.join(self.package_folder, "bin"), os.path.join(self.package_folder, "lib")))

    def package(self):
        self.copy("*.h", dst="include", src="hello")
        self.copy("*.dll", dst="bin", keep_path=False)
        self.copy("*.so", dst="lib", keep_path=False)
        self.copy("*.dylib", dst="lib", keep_path=False)
        self.copy("*.a", dst="lib", keep_path=False)
