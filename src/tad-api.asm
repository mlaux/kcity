; LoadAudioData             01AC3C RLF    TAD_IO_VERSION            00000E REA    
; Tad_AudioDriver_Bin       018074 RLA    Tad_AudioDriver_SIZE      000642 REA    
; Tad_BlankSong_Bin         0186B6 RLA    Tad_BlankSong_SIZE        000025 REZ    
; Tad_FinishLoadingData     00F228  LF    Tad_GetSong               00F282  LA    
; Tad_GetStereoFlag         00F298  LA    Tad_Init                  00F0BD  LF    
; Tad_IsLoaderActive        00F2BE  LA    Tad_IsSongLoaded          00F2C6  LA    
; Tad_IsSongPlaying         00F2CC  LA    Tad_LoadSong              00F260  LA    
; Tad_LoadSongIfChanged     00F276  LA    Tad_Loader_Bin            018000 RLA    
; Tad_Loader_SIZE           000074 REZ    Tad_Process               00F13B  LF    
; Tad_QueueCommand          00F238  LA    Tad_QueueCommandOverride  00F23D  LA    
; Tad_QueuePannedSoundEffect 00F24A  LA    Tad_QueueSoundEffect      00F254  LA    
; Tad_ReloadCommonAudioData 00F286  LA    Tad_SetMono               00F28C  LA    
; Tad_SetStereo             00F292  LA    Tad_SetTransferSize       00F2AA  LA    
; Tad_SongsStartImmediately 00F29E  LA    Tad_SongsStartPaused      00F2A4  LA    

Tad_Init = $f0bd
Tad_LoadSong = $f260
Tad_Process = $f13b