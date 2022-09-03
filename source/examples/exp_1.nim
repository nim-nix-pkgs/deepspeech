
#This is a simple example to run inference on a  .wav file using deepspeech lib.
#Note:  Raw audio data being used for inference must be   PCM, Int16 format and sampled at 16Khz. Make sure to convert to this format if not already so.


#read the raw audio data.

import deepspeech, wav,tables,parseopt

var SCORER = false
#provide model key and scorer key[optional]
var args = initTable[string, string]()
for kind,key,value in getopt():
    if key == "scorer":
        SCORER  = true
    args.add(key,value)

assert len(args) <= 3

let
    modelPtr: ModelState = nil  #deepSpeech model  
    deepStreamPtr: StreamingState = nil  #deepSpeech model stream
    modelPath = args["model"]
    audioPath = args["audio"]
var scorerPath : string
if  SCORER:
    scorerPath = args["scorer"]

var 
    codeD: cint
    text : cstring 

#DeepSpeech model initialization...only once.
codeD = createModel(modelPath,unsafeaddr(modelPtr))
if codeD == 0'i32:
    echo("Model Created Successfully")
let beamWidth = getBeamWidth(modelPtr)
echo("Default Beam Width is : ",int(beamWidth))
#enable External Scorer.
if SCORER:
    codeD = enableExternalScorer(modelPtr, scorerPath)
    if codeD == 0'i32:
        echo("External Scorer Enabled.")


#read/get audio  data
let (f,sampleRate,channels) = wavRead(audioPath)
var buff : seq[int16] = f.readChunk(sampleRate*3,channels)  #3 seconds of audio  
f.close()


echo()
#start/create stream.
codeD = createStream(modelPtr,unsafeAddr(deepStreamPtr))

#feed the whole audio data.
feedAudioContent(deepStreamPtr,cast[ptr cshort](addr(buff[0])),cuint(len(buff)))

#finish stream[will release the memory also]..create stream again if needed.
#copy the data at text pointer if want to use in Nim main code.
text = finishStream(deepStreamPtr)
echo("Transcript: ",text)
freeString(text)
