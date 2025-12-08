# Dashboard Color Guide

## 🎨 Official Color Palette

### Primary Colors
- **Primary Purple**: `#7C3AED`
  - RGB: (124, 58, 237)
  - Used for: AppBar, Primary buttons, stat card accents
  
- **Accent Sky Blue**: `#0EA5E9`
  - RGB: (14, 165, 233)
  - Used for: Secondary accents, progress bars, task status

### Light Variants
- **Light Purple**: `#F3E8FF`
  - RGB: (243, 232, 255)
  - Used for: Card backgrounds, subtle backgrounds
  
- **Light Sky Blue**: `#E0F2FE`
  - RGB: (224, 242, 254)
  - Used for: Alternative backgrounds, hover states

### Supporting Colors
- **White**: `#FFFFFF` - Text on colored backgrounds, cards
- **Black/Dark Gray**: `#000000` / `#1F2937` - Primary text
- **Light Gray**: `#9CA3AF` - Secondary text, borders
- **Success Green**: `#10B981` - Completed tasks, earnings
- **Amber/Gold**: `#FBBF24` - Star ratings, highlights
- **Red**: `#EF4444` - Danger, sign out button

## 📍 Where Colors Are Used

### Welcome Section (Banner)
```
Background: Gradient (Purple → Sky Blue)
Text: White
Buttons: White background with Purple text / Red for SignOut
Avatar: White with border
Rating Badge: Amber background
```

### Statistics Section
```
Active Jobs Card: Purple accent
Completed Tasks Card: Sky Blue accent
Earnings Card: Green accent
Icons: Matching accent color
Text Value: Accent color (bold)
Label: Gray
Background: Light variant of accent color
```

### Job Cards
```
Container: White with light gray border
Icon Box: Gradient (Purple light → Sky Blue light)
Icon: Purple
Text: Dark gray/black
Location: Medium gray
Rating: Amber star
Pay: Green (bold)
Apply Button: Purple background, white text
```

### Active Tasks
```
Container: White with light gray border
Title: Dark gray/black (bold)
Status Badge: Light sky blue background, sky blue text
Progress Bar: Sky blue (animated)
Client Text: Gray
```

### Service Cards (Carousel)
```
Container: Light variant of service color
Icon Box: Service color with opacity
Icon: Service color
Text: Dark gray/black
Hover: Slightly darker shade
```

### Bottom Navigation
```
Active Item: Purple icon
Inactive Item: Gray icon
Label: Gray text
Selected Label: Purple text
```

## 🎯 Design Principles

1. **Purple Dominance**: Use as primary color for main actions
2. **Sky Blue Accent**: Use to draw attention to secondary elements
3. **Contrast**: Ensure good contrast for readability
4. **Consistency**: Use same colors for similar elements
5. **Meaning**: 
   - Purple = Primary action/main theme
   - Sky Blue = Progress/secondary action
   - Green = Success/earnings
   - Amber = Rating/quality
   - Red = Logout/danger

## 💻 Color Usage Code

```dart
// Primary Colors
const Color primaryPurple = Color(0xFF7C3AED);
const Color accentSkyBlue = Color(0xFF0EA5E9);

// Light Variants
const Color lightPurple = Color(0xFFF3E8FF);
const Color lightSkyBlue = Color(0xFFE0F2FE);

// Usage Examples:
Container(
  color: primaryPurple.withOpacity(0.15), // Light background
  child: Icon(icon, color: primaryPurple), // Icon
)

ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: primaryPurple,
    foregroundColor: Colors.white,
  ),
  child: Text('Action'),
)

LinearProgressIndicator(
  valueColor: AlwaysStoppedAnimation<Color>(accentSkyBlue),
)
```

## 🎨 Gradient Combinations

### Welcome Banner
```
From: Primary Purple (#7C3AED)
To: Accent Sky Blue (#0EA5E9)
Direction: Top-left to bottom-right
```

### Job Card Icons
```
From: primaryPurple.withOpacity(0.2)
To: accentSkyBlue.withOpacity(0.2)
Direction: Variable
```

## ✨ Color Psychology

- **Purple**: Creativity, professionalism, trust, ambition
- **Sky Blue**: Calm, reliability, trustworthiness, clarity
- **Green**: Success, growth, money, achievement
- **Amber**: Quality, attention, premium feeling

Perfect combination for a marketplace app!

## 📱 Color Testing

Test colors on:
- Light backgrounds ✓
- Dark backgrounds ✓
- Different screen brightness ✓
- Colorblind modes ✓
- Print versions ✓

## 🔄 Future Color Customization

To change colors globally, update these values in `dashboard.dart`:

```dart
const Color primaryPurple = Color(0xFF7C3AED); // Change here
const Color accentSkyBlue = Color(0xFF0EA5E9); // Change here
const Color lightSkyBlue = Color(0xFFE0F2FE);  // Change here
const Color lightPurple = Color(0xFFF3E8FF);   // Change here
```

---

**Color Guide Version**: 1.0  
**Last Updated**: December 7, 2025
