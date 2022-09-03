# Package

#version Same as of corresponding DeepSpeech model.
version       = "0.7.0"
author        = "Anubhav (eagledot)"
description   = "DeepSpeech (Mozilla) bindings for Nim"
license       = "MIT"
srcDir        = "src"


# Dependencies
requires "nim >= 1.0.0"

skipDirs = @["examples","lib"]
