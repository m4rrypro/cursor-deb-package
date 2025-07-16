# Desktop Integration Fix for Cursor .deb Package

## Problem
The Cursor application would not launch from the desktop icon/menu, but worked when run from command line with:
```bash
/usr/share/cursor/cursor --no-sandbox
```

## Root Causes Identified

1. **Missing `--no-sandbox` flag in desktop file**: The desktop entry was calling `/usr/bin/cursor %F` without the required `--no-sandbox` flag that Electron apps need for GUI launches.

2. **Missing environment variables**: Electron applications often require specific environment variables to run properly in GUI mode.

3. **Inadequate wrapper script**: The original wrapper script had logic issues and didn't consistently apply the `--no-sandbox` flag.

4. **Missing dependencies**: Some GUI-related dependencies were missing from the package.

## Fixes Applied

### 1. Fixed Desktop File (`cursor.desktop`)
**Before:**
```ini
Exec=/usr/bin/cursor %F
```

**After:**
```ini
Exec=env ELECTRON_IS_DEV=0 /usr/bin/cursor --no-sandbox %F
```

**Changes:**
- Added `env ELECTRON_IS_DEV=0` to set proper environment
- Added `--no-sandbox` flag to the Exec line
- Applied same fix to the "New Empty Window" action

### 2. Enhanced Wrapper Script (`/usr/bin/cursor`)
**Improvements:**
- Always creates a wrapper script instead of sometimes using symlinks
- Sets proper environment variables:
  - `ELECTRON_IS_DEV=0`
  - `ELECTRON_DISABLE_SECURITY_WARNINGS=true`
- Robust executable finding logic with multiple fallback paths
- Always applies `--no-sandbox` flag
- Better error handling and user feedback

### 3. Added Missing Dependencies
**Added to package dependencies:**
- `libgconf-2-4` - Configuration system
- `libxfixes3` - X11 fixes extension
- `libxinerama1` - Multi-monitor support
- `libxcursor1` - Cursor theme support
- `libxi6` - X11 input extension

### 4. Environment Variable Handling
The wrapper script now properly sets:
- `ELECTRON_IS_DEV=0` - Ensures production mode
- `ELECTRON_DISABLE_SECURITY_WARNINGS=true` - Reduces console noise

## Testing the Fix

After installing the fixed package:

1. **Desktop Icon**: Should launch properly from application menu
2. **Command Line**: Still works as before
3. **File Associations**: Should work with file opening
4. **New Window Action**: Right-click menu option should work

## Technical Details

### Why `--no-sandbox` is Required
Electron applications use Chromium's sandboxing by default, which can conflict with certain Linux desktop environments and security policies. The `--no-sandbox` flag disables this sandboxing, allowing the application to run in GUI mode.

### Environment Variables
- `ELECTRON_IS_DEV=0`: Tells Electron this is a production build, not development
- `ELECTRON_DISABLE_SECURITY_WARNINGS`: Prevents security warnings in console

### Wrapper Script Benefits
- Consistent flag application regardless of how Cursor is launched
- Robust executable finding (handles different installation layouts)
- Proper environment setup
- Better error messages for troubleshooting

## Files Modified
- `scripts/convert-to-deb.sh` - Main conversion script
- Desktop file creation logic
- Wrapper script creation logic
- Package dependencies

## Verification Commands

After installing the fixed package, you can verify:

```bash
# Check wrapper script
cat /usr/bin/cursor

# Check desktop file
cat /usr/share/applications/cursor.desktop

# Test wrapper directly
/usr/bin/cursor --version

# Test desktop integration
desktop-file-validate /usr/share/applications/cursor.desktop
```

This fix ensures that Cursor will launch properly from both GUI and command line interfaces.
