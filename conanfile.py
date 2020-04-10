from conans import ConanFile,python_requires, tools
import os

class BnfcConan(ConanFile):
    python_requires("ghc-build-helper/0.1@haskell/testing")
    name = "bnfc"
    version = "2.8.3"
    license = "GPL"
    requires = "semigroups/0.19.1"
    build_requires = "ghc/8.10.1@haskell/testing"
    author = "Michael Tsukerman <miketsukerman@gmail.com>"
    url = "https://github.com/miketsukerman/conan-bnfc"
    description = "Compiler front-end generator based on Labelled BNF"
    topics = ("bnfc", "lbnf", "parser")
    settings = "os", "compiler", "build_type", "arch"
    generators = "virtualenv"
    scm = {
         "type": "git",
         "subfolder": "bnfc",
         "url": "https://github.com/BNFC/bnfc",
         "revision": "master"
    }

    def build(self):
        with tools.chdir("bnfc/source"):
            ghc = self.python_requires["ghc-build-helper"].module.GHCBuild(self)
            ghc.setup()
            ghc.configure()
            ghc.build()
            ghc.install()
            # self.run("ghc -threaded --make Setup", run_environment=True)
            # self.run(".{}Setup configure --user --prefix={}".format(os.sep,self.package_folder), run_environment=True)
            # self.run(".{}Setup build".format(os.sep), run_environment=True)
            # self.run(".{}Setup install".format(os.sep), run_environment=True)

    def package(self):
        self.copy("*.dll", dst="bin", keep_path=False)
        self.copy("*.so", dst="lib", keep_path=False)
        self.copy("*.dylib", dst="lib", keep_path=False)
        self.copy("*.a", dst="lib", keep_path=False)
