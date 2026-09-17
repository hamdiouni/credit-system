# Restart Server to Apply Changes

## What Was Fixed

Updated MongoDB schema to support `BALANCE_CREDIT` transaction type.

**Files Updated**:
- `server.js` - Added `'balance_credit'` to enum
- `server.cjs` - Added `'balance_credit'` to enum

## How to Restart Server

### Option 1: If server is running in a terminal
1. Go to the terminal running the server
2. Press `Ctrl+C` to stop it
3. Run: `node server.js` or `node server.cjs`

### Option 2: If you don't know where it's running
1. Open Task Manager (Ctrl+Shift+Esc)
2. Find "Node.js" process
3. End the process
4. Open new terminal in project folder
5. Run: `node server.js`

### Option 3: Quick restart command
```bash
# Stop any running node processes (Windows)
taskkill /F /IM node.exe

# Start server
node server.js
```

## Verify Server is Running

You should see:
```
MongoDB connected successfully
Server running on port 3000
```

## Test the Fix

1. **Restart the server** (see above)
2. **Refresh the Flutter app** (press `R` in terminal or refresh browser)
3. **Try overpayment again**:
   - Add payment with "Allow Overpayment" checked
   - Should work now! ✅

## What Changed

**Before**:
```javascript
enum: ['credit', 'payment']  // ❌ balance_credit not allowed
```

**After**:
```javascript
enum: ['credit', 'payment', 'balance_credit']  // ✅ Now allowed
```

## Expected Result

After restarting server, overpayment should work:
- ✅ Payment splits into PAYMENT + BALANCE_CREDIT
- ✅ Balance credit saves to database
- ✅ Balance credit displays in UI
- ✅ No more validation errors

## If Still Not Working

Check console for:
- Server connection errors
- Database errors
- Make sure MongoDB is running

The error message should change from:
```
❌ ValidationError: `balance_credit` is not a valid enum value
```

To:
```
✅ Payment added. Balance credit: XX.XXX TND
```
