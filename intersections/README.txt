FOR USE WITH SC 3.7 running on MacOS

Assumes SC 3.7 is installed at /Applications/SuperCollider/SuperCollider.app
with extensions at ~/Library/Application\ Support/SuperCollider/Extensions

This software is written in SuperCollider and depends on Nick Collins' SCMIR and BBCut2 libraries for music information retrieval and beat tracking.

Thanks to Michael Casey and Nick Collins for their great MIR work that this project depended upon. This code draws upon SC examples by Nick Collins and Fredrik Olofsson in the BBCut2 help files.

The code creates music in three sections that all depend on the several audio sections extracted from a single source file.

To run with a specific WAV audio file:

bash RunMe.sh '/absolute/path/to/file.wav'

Otherwise,

bash RunMe.sh (a default file will be used: an instrumental track from Moderat's new album III)