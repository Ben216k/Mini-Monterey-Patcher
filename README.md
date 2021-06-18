# Mini Monterey Patcher
A mini patcher for macOS Monterey by Ben Sova.

**Only supports Mid-2013 and later Macs (with exceptions) for now.**

## Wait, where's the UI?!
**This in no way is the squal to Patched Sur.** This will only be a terminal-based patcher.

**I have this so I can play with Monterey without building a full UI patcher.** Which will come out before the full release of Monterey with many previews and betas along the way.

Also, no Patched Monterey will not be exclusive to Mid-2013 and later Macs, I've already got a fix, but for various reasons, I can't use it in this patch.

So yeah... that's what this will be. Monterey, here we come!

# Credits
- [BarryKN](https://github.com/barrykn) for the patching method and the micropatcher.
- EduCovas, [Jackluke](https://github.com/jacklukem), [DhinakG](https://github.com/DhinakG) and [MykolaG](https://github.com/khronokernel) from [Dortania](https://github.com/dortania) for HD4000 Acceleration.
- [Monkiey](https://github.com/Monkiey), [riiveraluis](https://github.com/riiveraluis) and [Finder352](https://www.youtube.com/channel/UC1ANuAzvOToCVizzck3JjPg) for testing out the patcher. 

## Supported Unsupported Macs
### Mid 2013 to 2015:
If you have one of these first make sure you need the patcher, since some of these Macs don't need it. If you do proceed, then you'll be technically done at Step 7, but the rest will help to allow NVRAM Resets

### Early 2012 to Early 2013:
If you have one of these Macs, you must have a 80211ac WiFi card (or if you have a constant and forever Ethernet connection, that works too) because the WiFi patch is borked. I may or may not be able to fix this in the future, but for now it's going to be that way. 

Unlike the Mid-2013 and later Macs, you do have to do all the steps, otherwise you would suffer the lack of graphics acceleration and sleep/wake.

### Late 2011 and Below:
These Macs are currently unsupported because they need Legacy Graphics Acceleration with OpenGL and not Metal which will be a some time from now. Without it they would run like literal snails (imagine waiting for 14 seconds just for Safari to close).

## Instructions
1. Download and extract "Source Code (zip)" from the latest release.
2. Open Terminal and drag in CreateUSB.sh and your usb then press enter then wait for it to finish.
    • You can also create the installer yourself with createinstallmedia.
3. Drag in PatchUSB.sh then press enter and wait for it to finish
4. Reboot your Mac and hold option until you see the boot screen. There, select EFI Boot (your Mac will immediately turn off afterwards, that is normal)
5. Turn on your Mac holding option like before, then select Install macOS 12 Beta.
6. After it boots, open Install macOS 12 Beta and follow through the prompts.
7. Once the install finishes, you'll have to do one of two things:
    • If you have a Mid 2013 or Later Mac, you're pretty much done.
    • If you have an Early 2013 or Older Mac, you have to continue through to get WiFi and Acceleration.
8. Turn your Mac off, then boot into Install macOS 12 Beta again.
9. Click Utilities in the menu bar then click Terminal.
10. Type in `/Volumes/Image\ Volume/PatchSystem.sh /Volumes/"Your Drive"` replacing Your Drive with the name of the drive you selected to install Monterey on (Keep the quotes), then press enter.
11. After that finishes, reboot, read the FAQ then enjoy Monterey!

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

#### WiFi doesn't work.

Did you read the second sentence? No? Okay.

## Support

If you need help with the patcher, just go to one of these places:

- [Mini Monterey / Patched Sur Discord](https://discord.gg/2DxVn4HDX6) (live chat about all things Mini Monterey and Patched Sur, you can also come here to get notified for patcher updates).
- [The Issues Page](https://github.com/Ursinia/Mini-Monterey-Patcher/issues) (*only* for if it's a patcher bug)
- [Unsupported Macs Discord](https://discord.gg/XbbWAsE) (live chat for everything about Unsupported Macs)
- [r/PatchedMonterey](https://reddit.com/r/PatchedMonterey) (subreddit for Mini Monterey and the soon to be Patched Monterey)
- [r/MontereyPatcher](https://reddit.com/r/MontereyPatcher) (subreddit for all Monterey patchers)
