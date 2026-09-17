# Quick Test Guide 🧪

## How to Test All New Features

### 🌍 Test 1: Language Switching (2 minutes)

**What to test**: All UI text changes language

**Steps**:
1. Open app (should be in English)
2. Click Settings icon (top right)
3. Select "العربية" (Arabic)
4. ✅ Verify: All text is now in Arabic, reading right-to-left
5. Go back, click Settings again
6. Select "Français" (French)
7. ✅ Verify: All text is now in French
8. Go back, click Settings again
9. Select "English"
10. ✅ Verify: All text is back in English

**Expected Result**: No mixed languages, smooth transitions

---

### 💰 Test 2: Balance Credit Feature (3 minutes)

**What to test**: Overpayment creates balance credit

**Steps**:
1. Click + button to add customer
2. Enter name: "Test User", phone: "123456789"
3. Click Save
4. ✅ Verify: Green success message with checkmark
5. Click on "Test User"
6. Click "Add Credit"
7. Enter amount: 100, click Save
8. ✅ Verify: Green success message
9. Click "Add Payment"
10. Enter amount: 150
11. Check "Allow Overpayment" checkbox
12. Click Save
13. ✅ Verify: Success message shows "Balance credit: 50.000 TND"
14. ✅ Verify: Blue box shows "Balance Credit: 50.00"
15. Go back to customer list
16. ✅ Verify: Customer shows balance credit with wallet icon

**Expected Result**: Balance credit = 50 TND everywhere

---

### 📄 Test 3: PDF Export (2 minutes per language)

**What to test**: PDF exports correctly in all languages

**Steps**:
1. Open customer with transactions
2. Click "Export PDF" button
3. ✅ Verify: Button shows "Exporting..." while loading
4. ✅ Verify: PDF opens in new tab (web) or downloads
5. ✅ Verify: Currency shows "TND" (not DNT)
6. ✅ Verify: Dates are formatted correctly
7. Switch to Arabic (Settings)
8. Export PDF again
9. ✅ Verify: Arabic text reads right-to-left
10. ✅ Verify: Arabic letters are joined (not separated)
11. Switch to French
12. Export PDF again
13. ✅ Verify: French text displays correctly

**Expected Result**: PDFs look professional in all languages

---

### 📅 Test 4: Date Formatting (1 minute)

**What to test**: Dates display consistently

**Steps**:
1. Open customer detail screen
2. ✅ Verify: "Created" date shows in format: MM/DD/YYYY
3. ✅ Verify: Transaction dates show: MM/DD/YYYY HH:MM
4. Switch to Arabic
5. ✅ Verify: Dates use Arabic numerals if locale supports it
6. Export PDF
7. ✅ Verify: PDF dates match screen dates

**Expected Result**: Consistent date formatting everywhere

---

### 🎨 Test 5: Empty States (1 minute)

**What to test**: Empty states look good

**Steps**:
1. Open app with no customers
2. ✅ Verify: Large icon with "No customers yet" message
3. Add a customer with no transactions
4. Open customer detail
5. ✅ Verify: Receipt icon with "No transactions yet" message
6. Go back to customer list
7. Search for "xyz123"
8. ✅ Verify: Search icon with appropriate message

**Expected Result**: Friendly, helpful empty states

---

### ✅ Test 6: Success/Error Messages (2 minutes)

**What to test**: Feedback messages look good

**Steps**:
1. Add a customer
2. ✅ Verify: Green floating message with checkmark icon
3. Try to add customer with same phone number
4. ✅ Verify: Red floating message with error icon
5. Add credit to customer
6. ✅ Verify: Green floating message with checkmark
7. Try to pay more than debt without overpayment
8. ✅ Verify: Orange floating message with warning icon
9. Enable overpayment and pay
10. ✅ Verify: Green floating message with balance info

**Expected Result**: Consistent, visually appealing feedback

---

## 🐛 Common Issues & Solutions

### Issue: Mixed languages in UI
**Solution**: Make sure you're using latest code. Run `flutter clean` then `flutter run`

### Issue: PDF not exporting
**Solution**: Check browser console for errors. Make sure MongoDB server is running.

### Issue: Balance credit not showing
**Solution**: Make sure you checked "Allow Overpayment" and payment exceeds debt

### Issue: Dates look wrong
**Solution**: This is expected - dates format according to device locale

---

## ✅ Quick Checklist

Use this checklist to verify everything works:

- [ ] Language switches to Arabic correctly
- [ ] Language switches to French correctly
- [ ] Language switches back to English correctly
- [ ] Overpayment creates balance credit
- [ ] Balance credit shows on detail screen
- [ ] Balance credit shows on list screen
- [ ] PDF exports in English
- [ ] PDF exports in Arabic (RTL, joined letters)
- [ ] PDF exports in French
- [ ] All PDFs show "TND" currency
- [ ] Dates are consistent across UI and PDF
- [ ] Empty state shows when no customers
- [ ] Empty state shows when no transactions
- [ ] Success messages are green with checkmark
- [ ] Error messages are red with error icon
- [ ] Warning messages are orange with warning icon

---

## 🚀 Ready for Production?

If all checkboxes above are checked ✅, the app is ready for production!

**Next Steps**:
1. Test on Android device (if targeting Android)
2. Test on Windows desktop (if targeting Windows)
3. Load test with many customers
4. Deploy to production

---

**Happy Testing! 🎉**
