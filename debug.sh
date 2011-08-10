#!/bin/bash
sdlmess -debug -joystick_deadzone 1.100000 -joystick_saturation 0.550000 -skip_gameinfo -ramsize 524288 -frameskip 0 -rompath /home/david/roms -video opengl -numscreens -1 -nomaximize coco3p -quickload /home/david/projects/6809/chip09/bin/chip09.bin -floppydisk1 /home/david/projects/6809/chip09/disks/chip09.dsk 2>&1 | cat > /dev/null
