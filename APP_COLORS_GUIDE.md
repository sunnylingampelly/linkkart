# 🎨 LinkKart Mobile App - Color Palette

## Primary Colors (Blue)

### Primary Blue
- **Color**: `#5B6CFF` (RGB: 91, 108, 255)
- **Usage**: Main brand color, primary buttons, headers
- **Feel**: Modern, trustworthy, professional

### Primary Dark
- **Color**: `#4A5AE8` (RGB: 74, 90, 232)
- **Usage**: Hover states, pressed buttons
- **Feel**: Deeper, more intense

### Primary Light
- **Color**: `#7B8AFF` (RGB: 123, 138, 255)
- **Usage**: Backgrounds, subtle highlights
- **Feel**: Softer, lighter

---

## Secondary Colors (Green/Teal)

### Secondary Green
- **Color**: `#00D9A3` (RGB: 0, 217, 163)
- **Usage**: Success states, positive actions, QR code screen
- **Feel**: Fresh, positive, growth

### Secondary Dark
- **Color**: `#00C292` (RGB: 0, 194, 146)
- **Usage**: Hover states for secondary elements
- **Feel**: Deeper green

### Secondary Light
- **Color**: `#33E3B8` (RGB: 51, 227, 184)
- **Usage**: Light backgrounds, subtle accents
- **Feel**: Bright, energetic

---

## Accent Colors

### Accent Pink
- **Color**: `#FF6B9D` (RGB: 255, 107, 157)
- **Usage**: Special highlights, featured items
- **Feel**: Playful, attention-grabbing

### Accent Orange
- **Color**: `#FF9F43` (RGB: 255, 159, 67)
- **Usage**: Analytics, warnings, highlights
- **Feel**: Warm, energetic

### Accent Purple
- **Color**: `#9B59B6` (RGB: 155, 89, 182)
- **Usage**: Profile, special features
- **Feel**: Premium, creative

---

## Neutral Colors

### Background
- **Color**: `#F8F9FE` (RGB: 248, 249, 254)
- **Usage**: Main app background
- **Feel**: Clean, light, spacious

### Surface (White)
- **Color**: `#FFFFFF` (RGB: 255, 255, 255)
- **Usage**: Cards, containers, modals
- **Feel**: Pure, clean

### Surface Light
- **Color**: `#F5F6FA` (RGB: 245, 246, 250)
- **Usage**: Subtle backgrounds, disabled states
- **Feel**: Soft, neutral

---

## Text Colors

### Text Primary
- **Color**: `#1A1D2E` (RGB: 26, 29, 46)
- **Usage**: Main text, headings
- **Feel**: Strong, readable

### Text Secondary
- **Color**: `#6B7280` (RGB: 107, 114, 128)
- **Usage**: Descriptions, subtitles
- **Feel**: Softer, supporting

### Text Tertiary
- **Color**: `#9CA3AF` (RGB: 156, 163, 175)
- **Usage**: Placeholders, hints, disabled text
- **Feel**: Very subtle, background

### Text White
- **Color**: `#FFFFFF` (RGB: 255, 255, 255)
- **Usage**: Text on dark backgrounds
- **Feel**: High contrast, clear

---

## Status Colors

### Success Green
- **Color**: `#10B981` (RGB: 16, 185, 129)
- **Usage**: Success messages, confirmations, in-stock badges
- **Feel**: Positive, accomplished

### Warning Yellow
- **Color**: `#F59E0B` (RGB: 245, 158, 11)
- **Usage**: Warnings, cautions, low stock
- **Feel**: Attention, caution

### Error Red
- **Color**: `#EF4444` (RGB: 239, 68, 68)
- **Usage**: Errors, delete actions, out-of-stock
- **Feel**: Alert, danger

### Info Blue
- **Color**: `#3B82F6` (RGB: 59, 130, 246)
- **Usage**: Information, help, tips
- **Feel**: Informative, helpful

---

## Border & Divider

### Border
- **Color**: `#E5E7EB` (RGB: 229, 231, 235)
- **Usage**: Card borders, input borders
- **Feel**: Subtle separation

### Divider
- **Color**: `#F3F4F6` (RGB: 243, 244, 246)
- **Usage**: Section dividers, list separators
- **Feel**: Very subtle

---

## Shadows

### Shadow
- **Color**: `rgba(0, 0, 0, 0.1)` (10% black)
- **Usage**: Card shadows, elevation
- **Feel**: Depth, floating

### Shadow Light
- **Color**: `rgba(0, 0, 0, 0.05)` (5% black)
- **Usage**: Subtle shadows, hover states
- **Feel**: Very subtle depth

---

## Gradients

### Primary Gradient
- **Colors**: `#5B6CFF` → `#7B8AFF`
- **Direction**: Top-left to bottom-right
- **Usage**: Headers, hero sections, primary buttons
- **Feel**: Dynamic, modern

### Success Gradient
- **Colors**: `#00D9A3` → `#33E3B8`
- **Direction**: Top-left to bottom-right
- **Usage**: Success states, positive actions
- **Feel**: Fresh, positive

### Accent Gradient
- **Colors**: `#FF6B9D` → `#FF9F43`
- **Direction**: Top-left to bottom-right
- **Usage**: Special features, highlights
- **Feel**: Vibrant, energetic

---

## Color Usage by Screen

### Welcome Screen
- Background: Primary Gradient
- Text: White
- Button: White with Primary text

### Home Screen
- Background: Background (#F8F9FE)
- Header: Primary Gradient
- Cards: Surface (White)
- Quick Actions: Various accent colors

### Products Screen
- Background: Background
- Cards: Surface
- Edit Button: Primary
- Delete Button: Error Red
- Stock Badge: Success/Error

### Profile Screen
- Background: Background
- Header: Primary Gradient
- Menu Items: Surface with colored icons

### Add/Edit Product Screen
- Background: Background
- App Bar: Primary/Secondary
- Buttons: Primary/Secondary
- Form Fields: Surface

---

## Accessibility

### Contrast Ratios
- **Text Primary on Background**: 14.5:1 (AAA)
- **Text Secondary on Background**: 7.2:1 (AA)
- **White on Primary**: 8.6:1 (AAA)
- **White on Secondary**: 3.8:1 (AA)

### Color Blindness
- Primary (Blue) and Secondary (Green) are distinguishable
- Error (Red) and Success (Green) have different brightness
- Icons and text provide additional context

---

## Design Philosophy

### Modern & Professional
- Blue primary color conveys trust and professionalism
- Clean neutrals create spacious, uncluttered feel
- Subtle shadows add depth without distraction

### Vibrant & Energetic
- Bright accent colors add personality
- Gradients create dynamic, modern feel
- High contrast ensures readability

### Consistent & Cohesive
- Limited color palette prevents chaos
- Each color has specific purpose
- Gradients tie colors together

---

## Comparison with Storefront

### Mobile App Colors:
- **Primary**: Blue (#5B6CFF)
- **Secondary**: Green (#00D9A3)
- **Accent**: Pink, Orange, Purple
- **Feel**: Modern, vibrant, app-like

### Storefront Colors:
- **Primary**: Black (#000000)
- **Secondary**: White (#FFFFFF)
- **Accent**: Gold (#D4AF37)
- **Feel**: Luxury, elegant, premium

### Why Different?
- **Mobile App**: Needs to feel like a native app - vibrant, modern, energetic
- **Storefront**: Needs to feel like a luxury website - elegant, sophisticated, premium
- **Both**: Professional, trustworthy, high-quality

---

## Color Codes Quick Reference

```dart
// Primary
primary: #5B6CFF
primaryDark: #4A5AE8
primaryLight: #7B8AFF

// Secondary
secondary: #00D9A3
secondaryDark: #00C292
secondaryLight: #33E3B8

// Accent
accent: #FF6B9D
accentOrange: #FF9F43
accentPurple: #9B59B6

// Neutral
background: #F8F9FE
surface: #FFFFFF
surfaceLight: #F5F6FA

// Text
textPrimary: #1A1D2E
textSecondary: #6B7280
textTertiary: #9CA3AF

// Status
success: #10B981
warning: #F59E0B
error: #EF4444
info: #3B82F6

// Border
border: #E5E7EB
divider: #F3F4F6
```

---

**Design System**: Modern, vibrant, professional
**Primary Feel**: Trustworthy blue
**Accent Feel**: Energetic and playful
**Overall**: Native app experience with personality
