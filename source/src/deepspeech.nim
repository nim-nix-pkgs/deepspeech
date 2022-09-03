
#Nim Bindings for Mozilla's deepspeech model  version - 0.7.0
#Note version is important as no backward/forward Compatibility would be there.

import os,times
const DllName = "libdeepspeech.so"

type 
    ModelStateObj {.incompleteStruct.}  = object
    ModelState*  = ptr ModelStateObj
    StreamingStateObj {.incompleteStruct.} = object
    StreamingState* = ptr StreamingStateObj

#Stores text of an individual token, along with its timing information
#TO TEST
type
    TokenMetadata = object 
        #text corresponding to this token
        text: cstring
        #Position of the token in units of 20ms
        timestep: cuint
        #position of the token in seconds
        start_time: cfloat
#TO TEST
type 
    CandidateTranscript = object
        #array of tokenMetadata objects
        tokens: ptr TokenMetadata
        num_tokens: cuint
        confidence: cdouble
#TO TEST
type 
    Metadata = object
        transcripts: ptr CandidateTranscript
        num_transcripts: cuint
#TO TEST
type
    DeepSpeechErrorCodes{.size:sizeof(cshort).} = enum
        #OK
        DS_ERR_OK                 = 0x0000,

        #Missing informations
        DS_ERR_NO_MODEL           = 0x1000,

        #Invalid parameters
        DS_ERR_INVALID_ALPHABET   = 0x2000,
        DS_ERR_INVALID_SHAPE      = 0x2001,
        DS_ERR_INVALID_SCORER     = 0x2002,
        DS_ERR_MODEL_INCOMPATIBLE = 0x2003,
        DS_ERR_SCORER_NOT_ENABLED = 0x2004,

        #Runtime failures
        DS_ERR_FAIL_INIT_MMAP     = 0x3000,
        DS_ERR_FAIL_INIT_SESS     = 0x3001,
        DS_ERR_FAIL_INTERPRETER   = 0x3002,
        DS_ERR_FAIL_RUN_SESS      = 0x3003,
        DS_ERR_FAIL_CREATE_STREAM = 0x3004,
        DS_ERR_FAIL_READ_PROTOBUF = 0x3005,
        DS_ERR_FAIL_CREATE_SESS   = 0x3006,
        DS_ERR_FAIL_CREATE_MODEL  = 0x3007,


proc createModel*(modelPath: cstring,obj: ptr ModelState): cint {.importc: "DS_CreateModel",cdecl,dynlib: DllName.}
#get default Beam Width used by the Compiled model...as decoder graph run dynamically based on the beamWidth
proc getBeamWidth*(aCtx: ModelState): cuint {.importc: "DS_GetModelBeamWidth",cdecl,dynlib: DllName.}
proc setBeamWidth*(aCtx: ModelState,beamWidth: cuint): cint {.importc: "DS_SetBeamWidth",cdecl,dynlib: Dllname.}
proc getModelSampleRate*(aCtx: ModelState): cint {.importc: "DS_GetModelSampleRate",cdecl,dynlib: DllName.}
proc enableExternalScorer*(aCtx: ModelState, scorerPath: cstring ): cint {.importc: "DS_EnableExternalScorer",cdecl,dynlib: DllName.}
proc DisableExternalScorer*(aCtx: ModelState): cint {.importc: "DS_DisableExternalScorer",cdecl,dynlib: DllName.}
#setting scoreAlphaBeta..for now hardCoding..based on deepspeech_0.7.0 model's values
#useful..when creating your own LanguageModel...or  training on Your dataset...is generally find on a dev dataset.
proc setScorerAlphaBeta*(aCtx: ModelState,alpha: cfloat = 0.93128  ,beta: cfloat = 1.18341 ): cint {.importc: "DS_SetScorerAlphaBeta",cdecl,dynlib: DllName.}

#stream
proc speechToText(actx: ModelState, aBuffer: ptr cshort,aBufferSize: cuint): cstring {.importc: "DS_SpeechToText",cdecl,dynlib: DllName.}
#creating the stream.
proc createStream*(actx: ModelState,obj: ptr StreamingState): cint {.importc: "DS_CreateStream",cdecl,dynlib: DllName.}
#feed the audio-Content to the stream..This also run the acoustic model when enough audio data has been collected( I think 320ms)
proc feedAudioContent*(astx: StreamingState,aBuffer: ptr cshort,aBufferSize: cuint) {.importc: "DS_FeedAudioContent",cdecl,dynlib: DllName.}
proc finishStream*(astx: StreamingState): cstring {.importc: "DS_FinishStream",cdecl,dynlib: DllName.}
#Should Call it very carefully...either call finishStream or this...this frees all the resources without CTC decoding.
proc freeStream(astx: StreamingState) {.importc: "DS_FreeStream",cdecl,dynlib: DllName.}

#Can be used to Free String data in memory...store the string data locally. and free data allocated by C for string using this.
proc freeString*(str: cstring) {.importc: "DS_FreeString",cdecl,dynlib: DllName.}

#TODO  3 OR MORE FUNCTIONS nim definitions... For more see "include/deepspeech_0.7.h"


