# MEDMOS

MIDI Emphasized Deterministic Monotasking Operating System

## Overview

The goal of this project is to recreate the MIDI features of the Atari ST, on x86 hardware.

For some reason, I am fascinated by the Atari ST and how it is capable of solid, tight MIDI timing.
Some consider it to be the "gold standard" for MIDI timing.

I have always been frustrated by modern computers with USB becoming the dominant interface for music.

Adding to that frustration are modern operating systems that become slower and slower over time,
optimizing for throughput rather than latency.

So this project is intended to be a single tasking operating system along the lines of an Atari ST
or a Commodore 64, with a focus on MIDI and audio in general, where the audio hardware is accessed
directly, with nothing getting in the way.

I have never actually used an Atari ST before. I don't even think I have ever seen one in person.
During that era, I had a Commodore Amiga, and before that, a Commodore 64. I did not realize at the
time that the Atari ST is more of a successor to the Commodore 64, and the Commodore Amiga is more
of a successor to the Atari 800. The Atari ST has MIDI, while the Commodore 64 has the SID chip.

## Requirements

Ensoniq AudioPCI 1371 (ES1371)

# 2022-06-16

![Screenshot 2022-06-16](Screenshots/medmos-20220616.png)

I followed the Bare Bones tutorial at OSDev.org, and was able to get a basic system up and running.

It uses GRUB to boot a multiboot kernel into 640x480x32. GRUB and the way it selects a graphics mode
does not work consistently on my hardware, I've had the most luck with Nvidia. Long term, I am leaning
towards not using GRUB and simply using VGA mode 12h (640x480x4), since that should be good enough and
more compatible across my hardware.

I was able to get the Objective-C runtime up and running, as well as most of the code from HOTDOG.
This makes it easy to draw text using different fonts and so on. At the moment I am using the
Commodore 64 font and colors.

I am able to read input from the keyboard and mouse.

I am able to detect the ES1371, enable the UART, send MIDI data, as well as receive MIDI data and
indicate which notes are being played on the piano. I am currently polling, so the receive code is
hacky and very ugly. I really need to implement interrupts.

