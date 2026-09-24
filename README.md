Web App Version + Backend: https://github.com/ashwinraonc-oss/Guitar_Buddy_Web

Description:
Guitar Buddy is an iOS app for guitarists that combines real-time audio analysis with music theory. It listens to a live guitar signal and detects the chord being played, displaying interactive fretboard diagrams and letting you play back the detected voicing through a custom MIDI synthesizer built on AVAudioEngine/AVAudioUnitSampler. A built-in chromatic tuner implements the YIN pitch-detection algorithm from scratch (SIMD-accelerated via Accelerate) and supports alternate tunings (Drop D, DADGAD, Eb, custom tunings) by comparing detected pitch against each string's target frequency in cents. A chord progression builder uses a diatonic scale-degree lookup table to recommend musically valid progressions based on the chords you've already picked, including 7th-chord qualities.

Screenshots of App:
<img src="Guitar%20Buddy/App%20Screenshots/IMG_7519.jpeg" width="200"> <img src="Guitar%20Buddy/App%20Screenshots/IMG_7520.jpeg" width="200"> <img src="Guitar%20Buddy/App%20Screenshots/IMG_7521.jpeg" width="200"> <img src="Guitar%20Buddy/App%20Screenshots/IMG_7522.jpeg" width="200">

