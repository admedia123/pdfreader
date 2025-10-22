# 🎯 Ads Setup Guide - Firebase Remote Config + AdMob + AppLovin

## 📋 Overview

This guide will help you set up a complete ads management system using:
- **Firebase Remote Config** - Control ads on/off remotely
- **AdMob** - Google's ad network
- **AppLovin** - Alternative ad network
- **Network Analysis** - Monitor ad performance

---

## 🔧 Step 1: Firebase Remote Config Setup

### **1.1 Create Remote Config Parameters**

Go to Firebase Console → Remote Config → Add parameters:

```json
{
  "ads_enabled": true,
  "ads_network_priority": "admob,applovin",
  "admob_enabled": true,
  "applovin_enabled": true,
  "banner_frequency": 30,
  "interstitial_frequency": 60,
  "rewarded_cooldown": 300,
  "app_open_delay": 5
}
```

### **1.2 AdMob Configuration**

```json
{
  "admob_banner_id": "ca-app-pub-3940256099942544/6300978111",
  "admob_interstitial_id": "ca-app-pub-3940256099942544/1033173712",
  "admob_rewarded_id": "ca-app-pub-3940256099942544/5224354917",
  "admob_app_open_id": "ca-app-pub-3940256099942544/3419835294"
}
```

### **1.3 AppLovin Configuration**

```json
{
  "applovin_sdk_key": "YOUR_APPLOVIN_SDK_KEY",
  "applovin_banner_id": "YOUR_APPLOVIN_BANNER_ID",
  "applovin_interstitial_id": "YOUR_APPLOVIN_INTERSTITIAL_ID",
  "applovin_rewarded_id": "YOUR_APPLOVIN_REWARDED_ID",
  "applovin_app_open_id": "YOUR_APPLOVIN_APP_OPEN_ID"
}
```

---

## 🎯 Step 2: AdMob Setup

### **2.1 Create AdMob Account**
1. Go to [AdMob Console](https://admob.google.com/)
2. Create new app: "High PDF Reader"
3. Get App ID: `ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX`

### **2.2 Create Ad Units**

#### **Banner Ad**
- Ad Unit ID: `ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX`
- Size: 320x50

#### **Interstitial Ad**
- Ad Unit ID: `ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX`
- Type: Interstitial

#### **Rewarded Ad**
- Ad Unit ID: `ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX`
- Type: Rewarded

#### **App Open Ad**
- Ad Unit ID: `ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX`
- Type: App Open

### **2.3 Update Configuration**

Update `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX" />
```

Update `lib/services/remote_config_service.dart`:
```dart
'admob_banner_id': 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX',
'admob_interstitial_id': 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX',
'admob_rewarded_id': 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX',
'admob_app_open_id': 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX',
```

---

## 🚀 Step 3: AppLovin Setup

### **3.1 Create AppLovin Account**
1. Go to [AppLovin Console](https://www.applovin.com/)
2. Create new app: "High PDF Reader"
3. Get SDK Key: `YOUR_APPLOVIN_SDK_KEY`

### **3.2 Create Ad Units**

#### **Banner Ad**
- Ad Unit ID: `YOUR_APPLOVIN_BANNER_ID`
- Size: 320x50

#### **Interstitial Ad**
- Ad Unit ID: `YOUR_APPLOVIN_INTERSTITIAL_ID`
- Type: Interstitial

#### **Rewarded Ad**
- Ad Unit ID: `YOUR_APPLOVIN_REWARDED_ID`
- Type: Rewarded

#### **App Open Ad**
- Ad Unit ID: `YOUR_APPLOVIN_APP_OPEN_ID`
- Type: App Open

### **3.3 Update Configuration**

Update `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="applovin.sdk.key"
    android:value="YOUR_APPLOVIN_SDK_KEY" />
```

Update `lib/services/remote_config_service.dart`:
```dart
'applovin_sdk_key': 'YOUR_APPLOVIN_SDK_KEY',
'applovin_banner_id': 'YOUR_APPLOVIN_BANNER_ID',
'applovin_interstitial_id': 'YOUR_APPLOVIN_INTERSTITIAL_ID',
'applovin_rewarded_id': 'YOUR_APPLOVIN_REWARDED_ID',
'applovin_app_open_id': 'YOUR_APPLOVIN_APP_OPEN_ID',
```

---

## 📊 Step 4: Network Analysis Setup

### **4.1 Firebase Analytics Events**

The system automatically tracks:
- `ad_loaded` - When ad loads successfully
- `ad_failed` - When ad fails to load
- `ad_shown` - When ad is displayed
- `ad_clicked` - When user clicks ad
- `rewarded_completed` - When user earns reward

### **4.2 Network Performance Monitoring**

```dart
// Get network analysis
final analysis = AdsManager.instance.getNetworkAnalysis();
print('Network Status: ${analysis['network_status']}');
print('Network Failures: ${analysis['network_failures']}');
```

---

## 🧪 Step 5: Testing

### **5.1 Test Ads Screen**

1. Open app → Tab "Ads"
2. Check Remote Config values
3. Test each ad type:
   - Banner (automatic)
   - Interstitial (button)
   - Rewarded (button)
   - App Open (button)

### **5.2 Test Scenarios**

#### **Scenario 1: AdMob Primary**
```json
{
  "ads_enabled": true,
  "ads_network_priority": "admob,applovin",
  "admob_enabled": true,
  "applovin_enabled": true
}
```

#### **Scenario 2: AppLovin Primary**
```json
{
  "ads_enabled": true,
  "ads_network_priority": "applovin,admob",
  "admob_enabled": true,
  "applovin_enabled": true
}
```

#### **Scenario 3: Ads Disabled**
```json
{
  "ads_enabled": false,
  "ads_network_priority": "admob,applovin",
  "admob_enabled": true,
  "applovin_enabled": true
}
```

---

## 🔄 Step 6: Remote Control

### **6.1 Enable/Disable Ads**
```json
{
  "ads_enabled": false  // Disable all ads
}
```

### **6.2 Change Network Priority**
```json
{
  "ads_network_priority": "applovin,admob"  // AppLovin first
}
```

### **6.3 Adjust Frequency**
```json
{
  "banner_frequency": 60,        // 60 seconds
  "interstitial_frequency": 120, // 2 minutes
  "rewarded_cooldown": 600,      // 10 minutes
  "app_open_delay": 10          // 10 seconds
}
```

---

## 📱 Step 7: Production Setup

### **7.1 Replace Test IDs**

**AdMob Test IDs (Development):**
```
ca-app-pub-3940256099942544/6300978111  // Banner
ca-app-pub-3940256099942544/1033173712  // Interstitial
ca-app-pub-3940256099942544/5224354917  // Rewarded
ca-app-pub-3940256099942544/3419835294  // App Open
```

**Production IDs:**
```
ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX  // Your real IDs
```

### **7.2 AppLovin Production**

Replace test IDs with your real AppLovin ad unit IDs.

### **7.3 Firebase Remote Config**

1. Set up production values
2. Publish configuration
3. Monitor performance

---

## 🚨 Troubleshooting

### **Common Issues:**

#### **1. Ads Not Showing**
- Check `ads_enabled` in Remote Config
- Verify ad unit IDs are correct
- Check network connectivity
- Review Firebase Analytics events

#### **2. Network Failures**
- Check network status in Ads Test screen
- Verify SDK keys are correct
- Check ad unit IDs format
- Review error logs

#### **3. Remote Config Not Updating**
- Check Firebase Console
- Verify app is connected to internet
- Check cache expiration settings
- Force refresh config

### **Debug Commands:**

```bash
# Check logs
flutter logs

# Test specific network
# Update Remote Config to test single network

# Force refresh
# Use "Refresh Config" button in Ads Test screen
```

---

## 📈 Monitoring & Analytics

### **Firebase Analytics Events:**
- `ad_loaded` - Ad loaded successfully
- `ad_failed` - Ad failed to load
- `ad_shown` - Ad displayed to user
- `ad_clicked` - User clicked ad
- `rewarded_completed` - User earned reward

### **Key Metrics:**
- Ad load success rate
- Ad click-through rate
- Revenue per user
- Network performance
- Fallback usage

---

## 🎯 Next Steps

1. **Set up AdMob account and get real IDs**
2. **Set up AppLovin account and get real IDs**
3. **Update Remote Config with production values**
4. **Test all ad types in development**
5. **Deploy to production**
6. **Monitor performance and optimize**

---

**💡 Pro Tips:**
- Always test with test IDs first
- Monitor network performance regularly
- Use Remote Config to A/B test different settings
- Keep fallback networks enabled
- Monitor user experience impact
