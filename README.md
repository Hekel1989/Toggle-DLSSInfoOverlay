# DLSS Indicator Toggle Tool

A simple utility to toggle the NVIDIA DLSS indicator overlay on and off with a single click.

## Overview

This tool allows you to quickly toggle the DLSS indicator overlay while gaming without having to manually edit the Windows registry. The DLSS indicator shows which DLSS mode is currently active in supported games, and which resolution is DLSS upscaling from and to.

## Features

- **One-Click Toggle**: Instantly enable or disable the DLSS indicator
- **No Installation Required**: Portable executable, just download and run
- **Minimal UI**: Shows a brief notification that automatically closes
- **Game-Friendly**: Can be alt-tabbed to from any fullscreen game

## Technical Details

This tool toggles the `ShowDlssIndicator` DWORD (32-bit) value in the registry at:
`HKEY_LOCAL_MACHINE\SOFTWARE\NVIDIA Corporation\Global\NGXCore`

When enabled, the value is set to 1024 (decimal).

## Requirements

- Windows 10/11
- NVIDIA GPU with DLSS support
- Administrator privileges (required to modify registry)

## Usage

1. Download the executable from the releases section
2. Run the executable (administrator privileges will be requested automatically)
3. A notification will appear indicating whether the DLSS indicator has been enabled or disabled
4. The notification will automatically close after 2 seconds

## Notes

- This tool requires administrator privileges to modify registry settings
- Changes take effect immediately in supported games
- Created for gamers who want to quickly toggle the DLSS indicator without interrupting gameplay

## License

MIT License
