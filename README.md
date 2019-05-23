# Bombardier
A Mac utility that downloads and extracts [Boot Camp](https://support.apple.com/en-au/boot-camp) drivers with a single click:

<img src="https://github.com/ninxsoft/Bombardier/blob/master/Readme%20Resources/Bombardier.png" width="500">

Bombardier is my homage to [brigadier](https://github.com/timsutton/brigadier), a command-line utility that has saved me countless hours troubleshooting Boot Camp driver packages.

## Features
*   [x] One click download of Boot Camp drivers
    *   The Boot Camp driver disk image (**DMG**) is automatically extracted from the downloaded Package (**PKG**)
    *   Boot Camp drivers are downloaded to `~/Downloads/Bombardier`
*   [x] Launching Bombardier will automatically update:
    *   The list of Mac Models
    *   The Apple Software Update Server Catalog (**SUCatalog**), used to determine Boot Camp drivers


## Build Requirements
*   Written in Swift 5.0.1.
*   Built using Xcode 10.2.1.
*   Builds run on OS X El Capitan 10.11 or later.
*   App tested on macOS Mojave 10.14.

## Download
Grab the latest version of Bombardier from the [releases page](https://github.com/ninxsoft/Bombardier/releases).

## Credits / Thank You
*   Project created and maintained by Nindi Gill ([ninxsoft](https://github.com/ninxsoft)).
*   Tim Sutton ([timsutton](https://github.com/timsutton)) for his amazing work on [brigadier](https://github.com/timsutton/brigadier).
*   Adrien Le Mière ([@Moutok](https://macadmins.slack.com)) for the awesome app name.

## Version History
*   1.0
    *   Initial release

## License
    Copyright © 2019 Nindi Gill

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
