;.dsection spc_code
;.section spc_code
;.binary "spc700/kcity-audio.sfc", $1000, $8000

; sections for each of these so they show up in the .map?

.dsection sound_bank
.section sound_bank
the_sound_bank .binary "../music/build/kcity.smbank", 0, $8000
.endsection