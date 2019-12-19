# Bombardier
A Mac utility that downloads and extracts [Boot Camp](https://support.apple.com/en-au/boot-camp) drivers with a single click:

|                | **Light** | **Dark** |
| :------------: | :-------: | :------: |
| **Mac Models** | ![Mac Models](Readme%20Resources/Mac%20Models%20-%20Light.png) | ![Mac Models](Readme%20Resources/Mac%20Models%20-%20Dark.png) |
| **Boot Camp Packages** | ![Boot Camp Packages](Readme%20Resources/Boot%20Camp%20Packages%20-%20Light.png) | ![Boot Camp Packages](Readme%20Resources/Boot%20Camp%20Packages%20-%20Dark.png) |

Bombardier is my homage to [brigadier](https://github.com/timsutton/brigadier), a command-line utility that has saved me countless hours troubleshooting Boot Camp driver packages.

## Features
*   [x] One click download of Boot Camp drivers
    *   The Boot Camp driver disk image (**DMG**) is automatically extracted from the downloaded Package (**PKG**)
    *   Boot Camp drivers are downloaded to `~/Downloads/Bombardier`
    *   You can toggle between the **Mac Models** and **Boot Camp Packages** view layouts
    *   You can search just about anything to help filter down Packages
    *   You can also double-click on a Package row to initiate a download (or **Show in Finder** if already downloaded)
*   [x] Launching Bombardier will automatically update:
    *   The list of Mac Models
    *   The Apple Software Update Catalog (**SUCatalog**), used to determine Boot Camp drivers

        **Note:** The catalog can be overridden via **Preferences**:

        | **Light** | **Dark** |
        | :-------: | :------: |
        | ![Preferences](Readme%20Resources/Preferences%20-%20Light.png) | ![Preferences](Readme%20Resources/Preferences%20-%20Dark.png) |


## Build Requirements
*   Written in Swift 5.1.
*   Built using Xcode 11.3.
*   Builds run on OS X El Capitan 10.11 or later.
*   Bombardier has been tested on macOS Catalina 10.15.

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
    Copyright © 2020 Nindi Gill

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
