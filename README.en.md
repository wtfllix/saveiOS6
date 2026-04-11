# saveiOS6

Give old devices a little more time.

This is a small Cydia repo project for `iOS 6` and older jailbroken devices.  
It provides a lightweight web entry, certificate download resources, and a basic repo structure.

## What Is Included

- A simple homepage
- Root certificates and `mobileconfig` resources
- `Packages` / `Packages.gz`
- A `debs/` package directory

## Why This Exists

Many old devices are not broken. They just no longer fit the modern web.

Certificates age out, TLS changes, pages get heavier, and devices that still work slowly lose the ability to connect.  
This project exists to keep them alive in the simplest, most maintainable way possible.

## Principles

- Keep it simple
- Stay friendly to old devices
- Fewer scripts, fewer dependencies
- No unnecessary design complexity

## Notes

- This project cannot guarantee access to every modern website
- Even with newer root certificates, some sites may still fail because of newer TLS requirements
- Certificate resources and repo contents will need ongoing maintenance

If you are still keeping old devices alive, this repo is for people like you.
