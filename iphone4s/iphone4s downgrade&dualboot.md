> When I got an old iPhone 4s with an activation lock, I wanted to both bypass it and downgrade to iOS 6.1.3.
> Here is the method I used.

## 1. Prepare the Raspberry Pi Pico
- Get a Raspberry Pi Pico and copy the 8940 (See the end of page) file to the Pico drive.
- Press the **BOOTSEL** button on the Pico and connect it to your Mac.
- A drive will appear. Copy the file to the drive.
- The drive will disappear instantly — this means the file has been flashed to the Pico.
- The LED on the Pico should now flash once per second.

## 2. Enter PwnDFU Mode
- Put the iPhone 4s into DFU mode. Connect to Mac and press home+top 8s and release top, keep press home 8s.
- Connect the power cable to the Pico and connect the iPhone once the LED is flashing.
- The LED will blink quickly at first, then slow down to two flashes per second. If it keeps blinking quickly, please run from the start again.
- At this point the iPhone should be in pwnDFU mode. It may be enter an error state of DFU, you can check the Finder or i4tools, there is no any ID of the device. So you may need to run the process again.

## 3. Bypass Activation and Dualboot
Use

[Legacy iOS Kit]: https://github.com/LukeZGD/Legacy-iOS-Kit	"Legacy iOS Kit"

 to downgrade the device or bypass the activation lock.

iOS 9 Activation Lock Bypass

Useful tool --> SSH Ramdisk and Run the following commands:

```
./mount.sh
mv /mnt2/Applications/Setup.app /mnt2/Applications/Setup.app.bak
reboot
```
iOS 6 Activation Lock Bypass Run:

- Make sure the target device has an untethered jailbreak.

- Enter pwnDFU mode, Useful tool --> SSH Ramdisk , and mount the system partition.

- This can all be done using Legacy iOS Kit, which is a powerful tool for legacy iDevices.

```
./mount.sh
```



If you are working with a CoolBooter partition, run:
```shell
mount_hfs /dev/disk0s1s3 /mnt1 ## instead of mount.sh
```

Replace the original file with the patched version:
```shell
scp -P 6414 -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedKeyTypes=+ssh-rsa "source_file" "destination_file"

destination_file：/mnt1/usr/libexec/lockdownd
```
Set permissions:
```
chmod 0755 /mnt1/usr/libexec/lockdownd
```
Reboot the device.

```
reboot_bak
```



## 4. Some tips for Setup

iOS 9 is very slow in running. So be patient.

The first thing we need to do is Jailbreak. You can use 

[Carbon]: https://ios.cfw.guide/using-carbon/	"Carbon"

 or 

[everpwnage]: https://ios.cfw.guide/installing-everpwnage	"everpwnage"

- Keep the network connected to github or YouTube normally. Especially you are in China.

- Attention, you will not be able to install IPA file via this method which bypass the activation lock. So carbon seems the only way to jailbreak.

- After Jailbroken, please delete the useless repos in Cydia without WiFi, I recommend to reserve the saurik one. The LukeZGD will be a built-in repo which comes from Legacy-iOS-kit. If you don't get anyting from this repo, please update the software first and install the cert (which you can find in Carbon). P

- I recommend to install iocaste untether for untethered jailbreak (forever jailbreak with reboot) openSSH, coolbooter for dual boot. Attention here, you need to install the coolbooter 1.4.1 to get the dual boot done. 1.6 is not available. Also available in coolbootercli.

- Until now you are in the main iOS9 and you can download any iOS version from 6 to 9. It 's better than install iOS 6 from new start.

  

  PS: Chip model(correspond to Pico firmware):

S5L8940

- iPad 2 (iPad2,1; iPad2,2; iPad2,3)
- iPhone 4S
- S5L8942

S5L9842

- Apple TV (3rd generation) (AppleTV3,1);one core disabled
- iPad 2 (iPad2,4)
- iPad mini
- iPod touch (5th generation)

S5L9847

- Apple TV (3rd generation) (AppleTV3,2)

[A5-Apple Wiki]: https://theapplewiki.com/wiki/A5	"A5-Apple Wiki"

