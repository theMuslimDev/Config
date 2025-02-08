# Setting Up SwiftFormat

1. **Install [swift-format for xcode](https://github.com/nicklockwood/SwiftFormat?tab=readme-ov-file#xcode-source-editor-extension)**:
   - Install via homebrew: `$ brew install --cask swiftformat-for-xcode`
   - This will install `SwiftFormat for Xcode` in your Applications folder. Double-click the app to launch it, and then follow the on-screen instructions. Ensure the checkbox next to `SwiftFormat` is checked in `System Preferences -> Privacy & Security -> Extensions -> Xcode Source Editor`

2. **Configure Xcode Shortcut**:
   - Go to `System Settings`.
   - Navigate to the `Keyboard -> Keyboard Shortcuts -> App Shortcuts` section.
   - Create a new shortcut for formatting by clicking the "+" button.
   - Set the command to **Editor->SwiftFormat->Format File**. You can choose any shortcut you prefer (e.g., `Command-S`) to trigger the formatting action.

3. **Import `.swiftformat` Configuration File**:
   - Open `swift format for xcode app`.
   - Select menu `File -> Open`
   - Select the `.swiftformat` in the root directory of the ios project.
   - Relaunch Xcode

Now, whenever you press your chosen hotkey (e.g., Command-S), Xcode will format the current file using the rules defined in imported `.swiftformat` configuration. This will apply to all iOS projects. If we want to update the swift format rules just make a pr change to the .swiftformat and reimport it to the `swift format for xcode app`
