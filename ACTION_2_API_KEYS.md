# 🔑 Action 2: API Keys Setup (15 minutes)

## ✅ **Opened for You:**
- [x] OpenAI API Keys page: https://platform.openai.com/api-keys
- [x] Google AI Studio (Gemini): https://makersuite.google.com/app/apikey
- [x] Environment template created: `healpray_mobile/.env.template`

---

## 🎯 **Get Your API Keys:**

### **Step 1: OpenAI API Key (5 minutes)**

**In the OpenAI page (already opened):**

1. Sign in to your OpenAI account (or create one)
2. Click "Create new secret key"
3. Name it: `HealPray Development`
4. **Copy the key immediately** (you won't see it again!)
5. **Recommended**: Add $20-50 credit to your account for development

**Expected format**: `sk-...` (starts with sk-)

### **Step 2: Google Gemini API Key (5 minutes)**

**In the Google AI Studio (already opened):**

1. Sign in with your Google account
2. Click "Create API Key"
3. Select "Create API key in new project" or use existing
4. **Copy the API key**
5. **Note**: Gemini has generous free tier (perfect for development)

**Expected format**: `AI...` (starts with AI)

### **Step 3: Configure Environment File (5 minutes)**

```bash
# Navigate to Flutter app directory
cd /Users/ronos/Workspace/Projects/Active/HealPray/healpray_mobile

# Copy template to actual .env file
cp .env.template .env

# Open .env file for editing
open -a TextEdit .env

# Or use nano if you prefer terminal
# nano .env
```

**Replace these values in your `.env` file:**
```bash
# Replace with your actual OpenAI key
OPENAI_API_KEY=sk-your-actual-openai-key-here

# Replace with your actual Gemini key  
GOOGLE_GEMINI_API_KEY=AI-your-actual-gemini-key-here

# Update Firebase project ID to match what you created
FIREBASE_PROJECT_ID=healpray-dev
# (or healpray-dev-xyz if you had to use a suffix)
```

---

## ✅ **Verification Commands:**

After updating your `.env` file, verify it's working:

```bash
# Check that .env file exists and has content
cat .env | head -5

# Test that Flutter can load environment variables
cd healpray_mobile
flutter pub get

# Install flutter_dotenv if not already done
flutter pub add flutter_dotenv
```

---

## 🎯 **What Each API Key Does:**

### **OpenAI API Key**
- **Purpose**: Generates personalized prayers using GPT-4
- **Cost**: ~$0.01-0.03 per prayer generation
- **Usage**: Primary AI engine for prayer content
- **Free Tier**: $5 credit for new accounts

### **Google Gemini API Key**  
- **Purpose**: Backup AI provider, conversation features
- **Cost**: Very generous free tier (60 requests/minute)
- **Usage**: Fallback when OpenAI is unavailable
- **Free Tier**: 1 million tokens per month

---

## 🔒 **Security Notes:**

1. **Never commit `.env` to Git** (already in .gitignore)
2. **Use different keys for production**  
3. **Monitor API usage regularly**
4. **Set up billing alerts**

---

## 🚨 **Troubleshooting:**

**Issue**: OpenAI key doesn't work
- **Solution**: Check billing account has credit
- **Solution**: Verify key wasn't deactivated

**Issue**: Gemini key fails
- **Solution**: Enable Gemini API in Google Cloud Console
- **Solution**: Check API quotas and limits

**Issue**: `.env` file not loading
- **Solution**: Restart Flutter app (`flutter run`)
- **Solution**: Verify `.env` is in `healpray_mobile/` directory

---

## 🎯 **Ready for Action 3 After This:**

Once your API keys are configured:

**Action 3: Test Flutter Setup**
- Verify app builds successfully  
- Test on iOS simulator
- Test on Android emulator
- Confirm hot reload works

---

## 💰 **Cost Monitoring:**

### **OpenAI Usage Estimates**
- Development: ~$20-50/month
- 1000 prayer generations ≈ $10-30
- Set billing alerts at $25, $50

### **Gemini Usage Estimates**  
- Development: FREE (within limits)
- 1000 conversations ≈ FREE
- Monitor quota usage in console

---

**Status**: 🔄 **READY TO EXECUTE**  
**Prerequisites**: Complete Firebase setup (Action 1) first  
**Next**: Action 3 - Test Flutter Setup
