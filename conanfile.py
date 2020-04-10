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
    scm = {
         "type": "git",
         "subfolder": "bnfc",
         "url": "https://github.com/BNFC/bnfc",
         "revision": "master"
    }

    def build(self):
        with tools.chdir("bnfc/source"):
            self.run("ghc -threaded --make Setup", run_environment=True)
            self.run(".{}Setup configure --user --prefix={}".format(os.sep,self.package_folder), run_environment=True)
            self.run(".{}Setup build".format(os.sep), run_environment=True)
            self.run(".{}Setup install".format(os.sep), run_environment=True)

    def package(self):
        self.copy("*.dll", dst="bin", keep_path=False)
        self.copy("*.so", dst="lib", keep_path=False)
        self.copy("*.dylib", dst="lib", keep_path=False)
        self.copy("*.a", dst="lib", keep_path=False)
