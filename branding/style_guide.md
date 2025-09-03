# 🎨 HealPray Brand Style Guide
## Visual Identity & Design System

---

## 🎯 **Brand Overview**

**HealPray** represents the intersection of spiritual healing and modern technology. Our visual identity reflects compassion, hope, and divine connection through contemporary design aesthetics.

### **Brand Personality**
- **Compassionate**: Warm, understanding, supportive
- **Spiritual**: Sacred, divine, transcendent
- **Modern**: Clean, tech-forward, accessible
- **Healing**: Restorative, peaceful, therapeutic
- **Trustworthy**: Reliable, secure, professional

---

## 🌈 **Color System**

### **Primary Colors**
```css
/* Sunrise Gold - Hope & New Beginnings */
--sunrise-gold: #FFD700;
--sunrise-orange: #FFA500;
--sunrise-coral: #FF6B6B;

/* Healing Green - Peace & Renewal */
--healing-teal: #4ECDC4;
--healing-blue: #45B7B8;
--healing-dark: #3D9970;

/* Midnight Blue - Depth & Reflection */
--midnight-blue: #2C3E50;
--midnight-mid: #34495E;
--midnight-light: #5D6D7E;

/* Pure Colors */
--pure-white: #FFFFFF;
--off-white: #F8F9FA;
--light-gray: #E9ECEF;
```

### **Gradient Combinations**
```css
/* Morning Gradient */
background: linear-gradient(135deg, #FFD700 0%, #FFA500 50%, #FF6B6B 100%);

/* Midday Gradient */
background: linear-gradient(135deg, #4ECDC4 0%, #45B7B8 50%, #3D9970 100%);

/* Night Gradient */
background: linear-gradient(135deg, #2C3E50 0%, #34495E 50%, #5D6D7E 100%);

/* Healing Glow */
background: radial-gradient(circle, rgba(255,215,0,0.3) 0%, rgba(78,205,196,0.1) 100%);
```

### **Color Usage Guidelines**

#### **Primary Applications**
- **Sunrise Gold**: Call-to-action buttons, highlights, positive emotions
- **Healing Green**: Success states, wellness indicators, calm sections
- **Midnight Blue**: Headers, navigation, professional content

#### **Emotional Color Mapping**
- **Joy/Hope (8-10)**: Sunrise gradients, warm golds
- **Neutral/Balanced (5-7)**: Healing greens, soft teals  
- **Struggle/Low (1-4)**: Gentle blues, supportive purples
- **Crisis (<3)**: Soft corals, warm support colors

#### **Accessibility Standards**
- All color combinations meet WCAG 2.1 AA standards
- Minimum contrast ratio: 4.5:1 for normal text
- Minimum contrast ratio: 3:1 for large text
- Color is never the sole indicator of information

---

## 📝 **Typography System**

### **Primary Typeface: Poppins**
```css
font-family: 'Poppins', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;

/* Weight Scale */
--font-light: 300;
--font-regular: 400;
--font-medium: 500;
--font-semibold: 600;
--font-bold: 700;
```

### **Secondary Typeface: Nunito Sans**
```css
font-family: 'Nunito Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;

/* Usage: Body text, captions, supporting content */
```

### **Type Scale**
```css
/* Display */
--font-display: clamp(2.5rem, 5vw, 4rem); /* 40-64px */
--line-height-display: 1.1;
--font-weight-display: 700;

/* Heading 1 */
--font-h1: clamp(2rem, 4vw, 3rem); /* 32-48px */
--line-height-h1: 1.2;
--font-weight-h1: 700;

/* Heading 2 */
--font-h2: clamp(1.5rem, 3vw, 2.25rem); /* 24-36px */
--line-height-h2: 1.3;
--font-weight-h2: 600;

/* Heading 3 */
--font-h3: clamp(1.25rem, 2.5vw, 1.75rem); /* 20-28px */
--line-height-h3: 1.4;
--font-weight-h3: 600;

/* Body Large */
--font-body-large: 1.125rem; /* 18px */
--line-height-body-large: 1.6;
--font-weight-body-large: 400;

/* Body */
--font-body: 1rem; /* 16px */
--line-height-body: 1.6;
--font-weight-body: 400;

/* Body Small */
--font-body-small: 0.875rem; /* 14px */
--line-height-body-small: 1.5;
--font-weight-body-small: 400;

/* Caption */
--font-caption: 0.75rem; /* 12px */
--line-height-caption: 1.4;
--font-weight-caption: 300;
```

---

## 🎭 **Logo Usage Guidelines**

### **Logo Variations**

#### **Primary Logo** (`healpray-logo-primary.svg`)
- Full logo with symbol and wordmark
- Use when space allows
- Minimum width: 200px
- Maximum width: 600px

#### **Icon Only** (`healpray-icon.svg`)
- App icons, favicons, small spaces
- Square format (1:1 ratio)
- Minimum size: 16px
- Maximum size: 512px

#### **Wordmark Only**
- Text-only version
- Long horizontal layouts
- When symbol is used separately

### **Clear Space Requirements**
- Maintain clear space equal to the height of the "H" in HealPray
- No other elements within this zone
- Applies to all sides of the logo

### **Logo Don'ts**
❌ Don't stretch or distort the logo  
❌ Don't change colors arbitrarily  
❌ Don't add effects or shadows  
❌ Don't use on busy backgrounds without proper contrast  
❌ Don't use below minimum size requirements  

---

## 📱 **App Icon Specifications**

### **iOS App Icon Sizes**
```
iPhone:
- 180x180px (@3x) - iPhone 6s Plus, 7 Plus, 8 Plus, X, XS, XS Max, 11 Pro Max
- 120x120px (@2x) - iPhone 6, 6s, 7, 8, XR, 11
- 60x60px (@1x) - iPhone 4, 4s, 5, 5s, SE

iPad:
- 167x167px (@2x) - iPad Pro
- 152x152px (@2x) - iPad, iPad mini
- 76x76px (@1x) - iPad

App Store:
- 1024x1024px - App Store listing
```

### **Android App Icon Sizes**
```
- 192x192px (xxxhdpi)
- 144x144px (xxhdpi) 
- 96x96px (xhdpi)
- 72x72px (hdpi)
- 48x48px (mdpi)

Play Store:
- 512x512px - Play Store listing
```

### **Icon Design Principles**
- Recognizable at all sizes
- Simple, memorable shape
- Consistent with brand colors
- Works in light and dark themes
- Follows platform guidelines

---

## 🎨 **UI Component Guidelines**

### **Buttons**

#### **Primary Button**
```css
background: linear-gradient(135deg, #FFD700 0%, #FFA500 100%);
border-radius: 12px;
padding: 16px 24px;
font-weight: 600;
color: #FFFFFF;
box-shadow: 0 4px 12px rgba(255, 215, 0, 0.3);
```

#### **Secondary Button**
```css
background: transparent;
border: 2px solid #4ECDC4;
border-radius: 12px;
padding: 14px 22px;
font-weight: 600;
color: #4ECDC4;
```

#### **Tertiary Button**
```css
background: transparent;
border: none;
padding: 8px 16px;
font-weight: 500;
color: #2C3E50;
text-decoration: underline;
```

### **Cards**
```css
background: #FFFFFF;
border-radius: 16px;
padding: 24px;
box-shadow: 0 8px 32px rgba(44, 62, 80, 0.1);
border: 1px solid rgba(78, 205, 196, 0.1);
```

### **Input Fields**
```css
background: #F8F9FA;
border: 2px solid transparent;
border-radius: 12px;
padding: 16px;
font-size: 16px;
transition: all 0.3s ease;

/* Focus State */
border-color: #4ECDC4;
background: #FFFFFF;
box-shadow: 0 0 0 4px rgba(78, 205, 196, 0.1);
```

---

## 🌙 **Dark Mode Specifications**

### **Dark Theme Colors**
```css
/* Backgrounds */
--bg-primary-dark: #1A1A1A;
--bg-secondary-dark: #2D2D2D;
--bg-tertiary-dark: #3D3D3D;

/* Text */
--text-primary-dark: #FFFFFF;
--text-secondary-dark: #B0B0B0;
--text-tertiary-dark: #808080;

/* Accents */
--accent-gold-dark: #FFE55C;
--accent-teal-dark: #5EDCD4;
--accent-blue-dark: #4A90E2;
```

---

## ✨ **Animation Guidelines**

### **Motion Principles**
- **Easing**: `cubic-bezier(0.4, 0.0, 0.2, 1)` - Material easing
- **Duration**: 200-300ms for micro-interactions, 400-600ms for transitions
- **Spiritual Feel**: Gentle, flowing, organic movements

### **Common Animations**
```css
/* Fade In */
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

/* Prayer Card Entrance */
@keyframes prayerCardIn {
  from { 
    opacity: 0; 
    transform: scale(0.9) translateY(30px); 
  }
  to { 
    opacity: 1; 
    transform: scale(1) translateY(0); 
  }
}

/* Healing Glow */
@keyframes healingGlow {
  0%, 100% { box-shadow: 0 0 20px rgba(78, 205, 196, 0.3); }
  50% { box-shadow: 0 0 40px rgba(78, 205, 196, 0.6); }
}
```

---

## 📷 **Photography & Imagery Style**

### **Photography Guidelines**
- Soft, natural lighting
- Warm, inviting tones
- Peaceful, serene environments
- Diverse, inclusive representation
- Avoid religious imagery that's denomination-specific

### **Illustration Style**
- Minimalist, geometric approach
- Gradient overlays
- Spiritual symbolism (abstract)
- Consistent line weights
- Rounded, friendly shapes

---

## 📋 **Brand Voice & Tone**

### **Voice Characteristics**
- **Compassionate**: Understanding and empathetic
- **Wise**: Knowledgeable without being preachy
- **Gentle**: Soft, supportive, non-judgmental
- **Hopeful**: Optimistic, uplifting, encouraging
- **Inclusive**: Welcoming to all backgrounds

### **Tone Variations by Context**

#### **Morning (Hope)**
- Warm, energetic, optimistic
- "Good morning! Ready to embrace today's blessings?"

#### **Midday (Strength)**  
- Supportive, empowering, steady
- "You're stronger than you know. Let's find that inner peace."

#### **Evening (Reflection)**
- Calm, grateful, reflective
- "As the day closes, let's reflect on the grace we've received."

#### **Crisis Support**
- Immediate, caring, professional
- "You're not alone. Let's find comfort together."

---

## 🔧 **Implementation Guidelines**

### **CSS Custom Properties Setup**
```css
:root {
  /* Colors */
  --color-sunrise-gold: #FFD700;
  --color-healing-teal: #4ECDC4;
  --color-midnight-blue: #2C3E50;
  --color-white: #FFFFFF;
  
  /* Typography */
  --font-primary: 'Poppins', sans-serif;
  --font-secondary: 'Nunito Sans', sans-serif;
  
  /* Spacing */
  --space-xs: 0.5rem;
  --space-sm: 1rem;
  --space-md: 1.5rem;
  --space-lg: 2rem;
  --space-xl: 3rem;
  
  /* Border Radius */
  --radius-sm: 8px;
  --radius-md: 12px;
  --radius-lg: 16px;
  --radius-xl: 24px;
}
```

### **Design System Integration**
- Use design tokens consistently
- Maintain component library
- Regular brand compliance audits
- Cross-platform consistency

---

**Brand Guidelines Version**: 1.0  
**Last Updated**: January 2024  
**Approved By**: Jeff Ronos, Brand Lead
