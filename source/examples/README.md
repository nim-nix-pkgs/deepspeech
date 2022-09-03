
## Usage:
* Build the binary/executable .

    ```$ nim c -f -d:release ./exp_1.nim``` [-f option is optional ,only used to force recompilation]
    
* Run it 

    ```$ ./exp_1.exe --model:<path/to/pretrained-model/.pbmm>  --scorer:<path/to/.scorer> --audio<path/to/.wav file>```

