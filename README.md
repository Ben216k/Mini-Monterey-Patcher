# Mini Monterey Patcher

**Mini Monterey is reaching End of Life. On December 11th 2021, this repo will be archived and no further support will be provided.**

A mini patcher for macOS Monterey by Ben Sova.

Full support for **Mid 2013 and later**. Some support for **Early 2012 and later**.

## Wait, where's the UI?!
**This in no way is the sequel to Patched Sur.** This will only be a terminal-based patcher.

**I have this so I can play with Monterey without building a full UI patcher.** Which will come out before the full release of Monterey with many previews and betas along the way.

Also, no Patched Monterey will not be exclusive to Mid-2013 and later Macs, I've already got a fix, but for various reasons, I can't use it in this patch.

So yeah... that's what this will be. Monterey, here we come!

# Credits
- [BarryKN](https://github.com/barrykn) for the patching method and the micropatcher.
- EduCovas, [Jackluke](https://github.com/jacklukem), [DhinakG](https://github.com/DhinakG) and [MykolaG](https://github.com/khronokernel) from [Dortania](https://github.com/dortania) for HD4000 Acceleration.
- [ASentientBot](https://github.com/ASentientBot) and [MykolaG](https://github.com/khronokernel) for pre-802.11ac WiFi patches (and EduCovas for alerting me of them).
- [Monkiey](https://github.com/Monkiey), [riiveraluis](https://github.com/riiveraluis) and [Finder352](https://www.youtube.com/channel/UC1ANuAzvOToCVizzck3JjPg) for testing out the patcher. 

## Supported Unsupported Macs
### Mid 2013 to 2015:
If you have one of these first make sure you need the patcher, since some of these Macs don't need it. If you do proceed, then you'll be technically done at Step 7, but the rest will help to allow NVRAM Resets

### Early 2012 to Early 2013:
These Macs require patching the kexts (it's simple with PatchSystem.sh) to get WiFi, Graphics Acceleration, and Sleep/Wake. However, Bluetooth doesn't work even if you patch the kexts (and therefore continuity features won't work). That's a pretty big trade off so make sure you understand that before upgrading to Monterey. This may change later on, but as of right now, that's how it is.

\*There's a chance the WiFi patch won't work, so run `ioreg -rn ARPT | grep IOName` in Terminal and open an issue with the output of that.

### Late 2011 and Below:
These Macs are currently unsupported because they need Legacy Graphics Acceleration with OpenGL and not Metal which will be a some time from now. Without it they would run like literal snails (imagine waiting for 14 seconds just for Safari to close).

## Instructions
1. Download and extract "Source Code (zip)" from the latest release.
2. Open Disk Utility and format your drive as MacOS Extended (Journaled) with a GUID Partition Map.
3. Get the latest copy of the macOS Monterey InstallAssistant which you can find on [this page](https://mrmacintosh.com/macos-12-monterey-full-installer-database-download-directly-from-apple/) (or use this [Beta 2 link](http://swcdn.apple.com/content/downloads/54/23/071-59953-A_U9D4NB05NR/nqzt71pnylsuux326a4vqexb33oz0auhas/InstallAssistant.pkg)).
4. Install the package, then open Terminal and type in `sudo /Applications/"Install macOS Monterey beta.app"/Contents/Resources/createinstallmedia --volume ` (make sure there's a space after `--volume`) then drag in your USB from your Desktop. Press enter and wait for it to finish.
5. Drag in PatchUSB.sh then press enter and wait for it to finish.
6. Reboot your Mac and hold option until you see the boot screen. There, select EFI Boot (your Mac will immediately turn off afterwards, that is normal)
7. Turn on your Mac holding option like before, then select Install macOS 12 Beta.
8. After it boots, open Install macOS 12 Beta and follow through the prompts.
9. Once the install finishes, you'll have to do one of two things:
    • If you have a Mid 2013 or Later Mac, you're pretty much done.
    • If you have an Early 2013 or Older Mac, you have to continue through to get WiFi and Acceleration.
10. Turn your Mac off, then boot into Install macOS 12 Beta again.
11. Click Utilities in the menu bar then click Terminal.
12. Type in `/Volumes/Image\ Volume/PatchSystem.sh /Volumes/"Your Drive"` replacing Your Drive with the name of the drive you selected to install Monterey on (Keep the quotes), then press enter.
13. After that finishes, reboot, read the FAQ then enjoy Monterey!

## FAQ
#### Can I erase the Installer USB after I'm done?
Technically yes, but don't. Your installer is your only hope at recovering your Mac if something goes wrong after patching. Just because you can do it doesn't mean you should do it.

#### Does this patcher support SIP and FileVault?
PatchSystem.sh requires both to be off while running it, but at least for SIP's case, you can turn it off after it has been ran. FileVault probably is the same way, but unless you want to lose the ability to update and turn it off, I'd keep it off for now.

#### Software Update doesn't show the latest beta.
That's perfectly normal. Your Mac is still unsupported, so it still won't show the update, just like how it was when you were still on Big Sur.

As of right now the only way to update is to just follow the instructions again, but sooner or later I'll release an Update Assistant (similar to the Patched Sur Updater) that'll help update your Mac with only a click (and of course you'll have to run PatchSystem.sh again).

#### Recovery Mode Doesn't Boot
There's not much I can say here other than "Yeah, that's normal". You can use the Installer USB as recovery mode. I'll add a patch for this soon, but it won't be full recovery, just basic stuff.

#### Can I do an NVRAM/PRAM reset?
Yes, but only if you ran `PatchSystem.sh`. Afterwards you should boot into the EFI Boot on the installer USB that you held on to because you read a different question in the FAQ. If you didn't run `PatchSystem.sh` then your Mac won't boot at all without using the EFI Boot.

#### Bluetooth/Continuity doesn't work.

Did you read Supported Unsupported Macs details before upgrading? No? Okay.

## Support

If you need help with the patcher, just go to one of these places:

- [Mini Monterey / Patched Sur Discord](https://discord.gg/2DxVn4HDX6) (live chat about all things Mini Monterey and Patched Sur, you can also come here to get notified for patcher updates).
- [The Issues Page](https://github.com/Ursinia/Mini-Monterey-Patcher/issues) (*only* for if it's a patcher bug)
- [Unsupported Macs Discord](https://discord.gg/XbbWAsE) (live chat for everything about Unsupported Macs)
- [r/PatchedMonterey](https://reddit.com/r/PatchedMonterey) (subreddit for Mini Monterey and the soon to be Patched Monterey)
- [r/MontereyPatcher](https://reddit.com/r/MontereyPatcher) (subreddit for all Monterey patchers)
