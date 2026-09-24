**Web App Version + Detection Backend: **https://github.com/ashwinraonc-oss/Guitar_Buddy_Web

G**uitar Buddy Overview:**

Guitar Buddy is an iOS app for guitarists and songwriters to aid in music production. Guitar Buddy combines real-time audio analysis with music theory by listening to a live guitar signal, detecting the chord being played, displaying interactive fretboard diagrams and letting you play back the detected voicing through a custom MIDI synthesizer built on AVAudioEngine/AVAudioUnitSampler. 

**Detect: **

Listens to a live guitar signal through the mic and identifies the chord being played in real time, then displays the matching fretboard diagram for that voicing. Tap to play back the detected chord through a custom MIDI synthesizer built on AVAudioEngine/AVAudioUnitSampler, so you can compare what you played against how it should sound.

**Create: **

A chord progression builder that suggests musically valid next chords based on what you've already picked, using a diatonic scale-degree lookup table (including 7th-chord qualities) rather than a fixed preset list — so every suggestion stays in key with the progression you're building.

**Tune: **

A chromatic tuner with a YIN pitch-detection algorithm implemented from scratch and SIMD-accelerated via Accelerate for fast, precise readings. Supports standard tuning plus alternates (Drop D, DADGAD, Eb, and custom tunings), comparing your live pitch against each string's target frequency in cents.

**Record: **

Capture guitar takes directly in the app with a built-in recorder that shows a live animated bar-graph visualizer reacting to input level in real time. Play back any recording with the same visualizer driven by the audio's live playback levels, browse and manage a running list of past takes, and delete ones you don't need — laying the groundwork for an upcoming feature that will automatically detect the chord progression played in a recording using an on-device model.

**Screenshots of App:**

<img src="Guitar%20Buddy/App%20Screenshots/IMG_7519.jpeg" width="200"> <img src="Guitar%20Buddy/App%20Screenshots/IMG_7520.jpeg" width="200"> <img src="Guitar%20Buddy/App%20Screenshots/IMG_7521.jpeg" width="200"> <img src="Guitar%20Buddy/App%20Screenshots/IMG_7522.jpeg" width="200">

