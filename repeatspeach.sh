#!/bin/bash
#El presente script es un auxiliar para Tutor, que permite repetir el discurso generado
#puede modificar la velocidad de reproducción 
#Autor: Francisco Javier José Angeles  bocho_zic@hotmail.com
#Fecha de creación: dom 07 dic 2025 20:23:37 CST
#


# Acelerar 1.5x (mantiene tono):
#sox speach.wav output_fast.wav tempo 1.3

#aplay output_fast.wav



# Reproduce directamente (sin archivo intermedio):
#ffmpeg -i speach.wav -filter:a "atempo=1.6" -f wav - | aplay


ffmpeg -loglevel quiet -i speach.wav -filter:a "atempo=1.60" -f wav - | aplay >/dev/null 2>&1 &


#nohup bash -c 'ffmpeg -i speech.wav -filter:a "atempo=2.0" -f wav - | aplay' </dev/null >/dev/null 2>&1 &
