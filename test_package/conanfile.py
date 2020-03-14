from conans import ConanFile, CMake, tools
import os, subprocess

class HelloTestConan(ConanFile):
    settings = "os", "compiler", "build_type", "arch"
    generators = "cmake", "virtualrunenv"
    requires =   "bison/3.3.2@bincrafters/stable", "flex/2.6.4@bincrafters/stable"

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()

    def imports(self):
        self.copy("*.dll", dst="bin", src="bin")
        self.copy("*.dylib*", dst="bin", src="lib")
        self.copy('*.so*', dst='bin', src='lib')

    def test(self):
        if not tools.cross_building(self.settings):
            os.chdir("bin")
            subprocess.run(['.%sexample' % os.sep], stdout=subprocess.PIPE,input='1+b',encoding='utf-8')
