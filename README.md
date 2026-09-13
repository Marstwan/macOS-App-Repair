# RepairApp.command

A macOS command-line tool that fixes the most common warnings you get when opening apps downloaded outside the App Store:

- *"'X' can't be opened because it is from an unidentified developer."*

- *"'X' is damaged and can't be opened. You should move it to the Trash."*

  It removes the quarantine attributes macOS adds to downloaded files and, if needed, re-signs the app locally so the system stops blocking it.

> ⚠️ Only use this with software from sources you trust. This tool doesn't check whether an app is safe — it just tells macOS to stop treating it as something downloaded from the internet.

## Requirements

- macOS (any recent version, Apple Silicon or Intel).
- Terminal (included by default, in Applications → Utilities → Terminal).

## Installation

1. Download [`RepairApp.command`](./RepairApp.command) by clicking the file and then **Download raw file** (or clone the repo).

2. Open **Terminal**.

3. Give the script execute permission. Type this and press Enter (adjust the path if you saved it somewhere other than Downloads):

   ```bash
   chmod +x ~/Downloads/RepairApp.command
   ```

   This step is necessary because browsers usually strip the execute permission from downloaded files, even though the script already has it in the GitHub repo.

## First run (step by step)

The first time, macOS will push back twice, separately. This is normal and only happens once:

### 1. "Unidentified developer" warning

If you double-click it and macOS says it can't be opened because it's from an unidentified developer:

- Go to Finder and find `RepairApp.command`.

- **Right-click (or Control-click) the file → Open**.

- The same warning will appear, but this time with an **Open** button. Click it.

  *(You won't need to repeat this on future runs.)*

### 2. "You don't have appropriate access privileges" warning

If instead you get a warning saying it couldn't run because you don't have adequate access privileges, the file lost its execute permission during download (that's what the `chmod +x` step above is for). Run that command again and try once more.

### 3. Privacy & Security permission

If macOS is still blocking it:

1. Go to **System Settings → Privacy & Security**.
2. Scroll down to the **Security** section, where you should see a message mentioning `RepairApp.command`.
3. Click **Open Anyway**.
4. Enter your administrator password if prompted.
5. Try opening the file again (double-click, or right-click → Open).

## Usage

Running it shows a menu with these options:

```
1) Repair app (remove quarantine attributes)   <- most common fix
2) Self-sign app (fixes 'app is damaged')
3) Show Gatekeeper status
4) Quit
```

- **Option 1 — Repair app**: asks you to drag the application (the `.app`) into the Terminal window and press Enter. Removes the quarantine attributes. This fixes most cases.

- **Option 2 — Self-sign app**: if the app still says it's "damaged" after using option 1, use this to re-sign it locally.

- **Option 3 — Show Gatekeeper status**: checks whether Gatekeeper (macOS's app verification system) is active. Informational only, doesn't change anything.

- **Option 4 — Quit**: closes the script.

  The script will ask for your administrator password (`sudo`) so it can modify the application's attributes.

## How to drag the app in correctly

When the script asks for the application's path, the easiest way is:

1. Open a Finder window and locate the `.app` (usually in `/Applications`).

2. Drag it directly onto the Terminal window where the script is waiting for input.

3. Press Enter.

   You can also type the full path by hand, for example:

```
/Applications/AppName.app
```

## FAQ

**Does this disable my Mac's security?**
No. It only acts on the specific application you point it to. Gatekeeper stays active and keeps protecting the rest of the system.

**Is it safe to enter my administrator password?**
The script only uses `sudo` for operations on the `.app` you specify (`xattr` and `codesign`). You can review the full code in [`RepairApp.command`](./RepairApp.command) before running it — it's plain text, nothing hidden.

**Why does it ask for `chmod +x` if it was already uploaded that way to GitHub?**
Browsers typically reset the execute bit when downloading files, as a general security measure. It has nothing to do with this specific script.

## License

MIT — use it, modify it, and share it freely.
