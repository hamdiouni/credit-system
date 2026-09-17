# Test Overpayment Feature

## Quick Test Steps

### 1. Run the App
```bash
flutter run -d chrome
```

### 2. Create Test Customer
- Add customer: "Test Customer"
- Phone: "1234567890"

### 3. Add Initial Credit
- Click on customer
- Add Credit: 50 TND
- Items: Rice, Sugar
- Save

### 4. Test Normal Payment (Should Work)
- Click "Add Payment"
- Amount: 30 TND
- DON'T check "Allow Overpayment"
- Save
- ✅ Should work - Debt becomes 20 TND

### 5. Test Overpayment Blocked (Should Show Error)
- Click "Add Payment"
- Amount: 50 TND (more than 20 TND debt)
- DON'T check "Allow Overpayment"
- Save
- ✅ Should show error: "Payment (50.000 TND) exceeds current debt (20.000 TND). Enable 'Allow Overpayment' to continue."

### 6. Test Overpayment Allowed (Should Work)
- Click "Add Payment"
- Amount: 50 TND
- CHECK "Allow Overpayment" ✅
- Save
- ✅ Should show: "Payment added. Balance credit: 30.000 TND"
- ✅ Debt becomes: 0 TND
- ✅ Blue box appears: "Balance Credit: 30.00"

### 7. Test Balance Credit Reduces Future Debt
- Add new Credit: 100 TND
- ✅ Debt should be: 70 TND (100 - 30 balance credit)
- ✅ Balance credit box disappears (used up)

## What to Check

### In Customer Detail Screen
- [ ] Debt shows correctly
- [ ] Balance credit shows in blue box when > 0
- [ ] Balance credit has wallet icon
- [ ] Balance credit disappears when used

### In Payment Screen
- [ ] "Allow Overpayment" checkbox works
- [ ] Error message shows when overpayment not allowed
- [ ] Success message shows balance credit amount
- [ ] Payment splits correctly into PAYMENT + BALANCE_CREDIT

### In Transaction List
- [ ] PAYMENT transactions show
- [ ] BALANCE_CREDIT transactions show
- [ ] All amounts are correct

## Console Output to Check

Look for these messages:
```
✅ Payment added. Balance credit: XX.XXX TND
```

Or error:
```
❌ [AddPaymentScreen] Error: ...
```

## If You See Errors

Check console for:
- Type errors (int vs String)
- Null errors
- Database errors

The error should now show in a SnackBar with full details!
