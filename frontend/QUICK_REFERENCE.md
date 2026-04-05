# 🎨 Quick Reference: Animated Components

## Copy-Paste Ready Code Snippets

### 1️⃣ Delete Button (Red)
```dart
FlowButton(
  icon: Icons.delete_outline_rounded,
  size: 40,
  tooltip: 'Delete',
  gradientColors: [
    const Color(0xFFEF4444).withOpacity(0.7),
    const Color(0xFFDC2626),
  ],
  onPressed: () {
    // Delete action
  },
)
```

### 2️⃣ Share Button (Blue)
```dart
FlowButton(
  icon: Icons.share_rounded,
  size: 40,
  tooltip: 'Share',
  gradientColors: [
    const Color(0xFF3B82F6).withOpacity(0.7),
    const Color(0xFF1D4ED8),
  ],
  onPressed: () {
    // Share action
  },
)
```

### 3️⃣ Primary Action Button (Purple)
```dart
SizedBox(
  width: double.infinity,
  child: AnimatedFlowButton(
    icon: Icons.analytics_rounded,
    label: 'Analyze Sentiment',
    gradientColors: [
      const Color(0xFF667EEA),
      const Color(0xFF764BA2),
    ],
    onPressed: () {
      // Analyze action
    },
  ),
)
```

### 4️⃣ Confirm Button (Green)
```dart
AnimatedFlowButton(
  icon: Icons.check_rounded,
  label: 'Confirm',
  gradientColors: [
    const Color(0xFF10B981),
    const Color(0xFF059669),
  ],
  onPressed: () {
    // Confirm action
  },
)
```

### 5️⃣ Interactive Card
```dart
ModernCard(
  onTap: () => Navigator.push(...),
  child: Column(
    children: [
      // Card content
      Text('Your content here'),
    ],
  ),
)
```

### 6️⃣ Action Row (Multiple Buttons)
```dart
Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    FlowButton(
      icon: Icons.share_rounded,
      size: 40,
      onPressed: () {},
      gradientColors: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    ),
    const SizedBox(width: 8),
    FlowButton(
      icon: Icons.delete_outline_rounded,
      size: 40,
      onPressed: () {},
      gradientColors: const [Color(0xFFEF4444), Color(0xFFDC2626)],
    ),
  ],
)
```

### 7️⃣ Animated Statistics
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceAround,
  children: [
    AnimatedCounter(
      value: 156,
      label: 'Total Reviews',
      color: Colors.grey,
    ),
    AnimatedCounter(
      value: 98,
      label: 'Positive',
      color: const Color(0xFF10B981),
    ),
    AnimatedCounter(
      value: 35,
      label: 'Negative',
      color: const Color(0xFFEF4444),
    ),
  ],
)
```

### 8️⃣ Loading State (Shimmer)
```dart
Column(
  children: [
    ShimmerCard(height: 120, borderRadius: 24),
    ShimmerCard(height: 120, borderRadius: 24),
    ShimmerCard(height: 120, borderRadius: 24),
  ],
)
```

### 9️⃣ Settings/Compact Button
```dart
ActionButton(
  icon: Icons.edit_rounded,
  label: 'Edit',
  onPressed: () {},
)
```

### 🔟 Animated Header
```dart
GradientHeader(
  title: const Text(
    'Analysis History',
    style: TextStyle(
      color: Colors.white,
      fontSize: 26,
      fontWeight: FontWeight.bold,
    ),
  ),
  subtitle: Text(
    '${history.length} analyses found',
    style: const TextStyle(color: Colors.white70),
  ),
)
```

---

## Color Palette (Copy-Paste)

```dart
// Blue (Share/View)
const Color _blue1 = Color(0xFF3B82F6);
const Color _blue2 = Color(0xFF1D4ED8);

// Green (Success/Save/Approve)
const Color _green1 = Color(0xFF10B981);
const Color _green2 = Color(0xFF059669);

// Red (Delete/Cancel)
const Color _red1 = Color(0xFFEF4444);
const Color _red2 = Color(0xFFDC2626);

// Purple (Primary/Analyze)
const Color _purple1 = Color(0xFF667EEA);
const Color _purple2 = Color(0xFF764BA2);

// Indigo (Settings/Options)
const Color _indigo1 = Color(0xFF8B5CF6);
const Color _indigo2 = Color(0xFF6D28D9);

// Amber (Download/Export)
const Color _amber1 = Color(0xFFF59E0B);
const Color _amber2 = Color(0xFFD97706);

// Usage
gradientColors: [_blue1.withOpacity(0.7), _blue2]
```

---

## Size Guidelines

```dart
// Full-width button (primary actions)
AnimatedFlowButton(...)  // Default full width

// Large circular button (important actions)
FlowButton(size: 50, ...)  // 50x50 dp

// Medium circular button (normal actions)
FlowButton(size: 40, ...)  // 40x40 dp (default)

// Small compact button (inline actions)
ActionButton(...)  // Auto size-fit

// Card spacing
ModernCard(
  padding: const EdgeInsets.all(20),
  margin: const EdgeInsets.only(bottom: 16),
)
```

---

## Common Patterns

### Pattern 1: Header with Actions
```dart
GradientHeader(
  title: Text('Title'),
  actions: [
    IconButton(icon: Icon(Icons.settings), onPressed: () {}),
  ],
)
```

### Pattern 2: Card with Footer Actions
```dart
ModernCard(
  child: Column(
    children: [
      // Content
      Text('Card content'),
      SizedBox(height: 16),
      // Actions row
      Row(
        children: [
          ActionButton(icon: Icons.edit, label: 'Edit', onPressed: () {}),
          SizedBox(width: 8),
          ActionButton(icon: Icons.delete, label: 'Delete', onPressed: () {}),
        ],
      ),
    ],
  ),
)
```

### Pattern 3: Statistics Row
```dart
Container(
  padding: const EdgeInsets.all(24),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      AnimatedCounter(value: total, label: 'Total', color: Colors.grey),
      AnimatedCounter(value: positive, label: 'Positive', color: _green1),
      AnimatedCounter(value: negative, label: 'Negative', color: _red1),
    ],
  ),
)
```

### Pattern 4: Action Row (Share + Delete)
```dart
Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    FlowButton(
      icon: Icons.share_rounded,
      size: 40,
      gradientColors: const [_blue1, _blue2],
      onPressed: share,
    ),
    SizedBox(width: 8),
    FlowButton(
      icon: Icons.delete_outline_rounded,
      size: 40,
      gradientColors: const [_red1, _red2],
      onPressed: delete,
    ),
  ],
)
```

---

## Props Reference

### FlowButton
```dart
FlowButton(
  icon: Icons.delete_rounded,        // Required: Icon to display
  onPressed: () {},                   // Required: Callback
  size: 40,                           // Optional: Button size (40)
  tooltip: 'Delete',                  // Optional: Hover tooltip
  gradientColors: colors,             // Optional: Custom gradient
  isLoading: false,                   // Optional: Show spinner
)
```

### AnimatedFlowButton
```dart
AnimatedFlowButton(
  icon: Icons.analyze,                // Required
  label: 'Analyze',                   // Required
  onPressed: () {},                   // Required
  gradientColors: colors,             // Optional
  isLoading: false,                   // Optional
)
```

### ModernCard
```dart
ModernCard(
  child: widget,                      // Required: Content
  onTap: () {},                       // Optional: Tap callback
  padding: EdgeInsets.all(20),        // Optional
  margin: EdgeInsets.all(16),         // Optional
  borderRadius: 24,                   // Optional
  enableHoverEffect: true,            // Optional
)
```

### AnimatedCounter
```dart
AnimatedCounter(
  value: 42,                          // Required: Number to animate
  label: 'Reviews',                   // Required: Label text
  color: Colors.blue,                 // Required: Text color
  duration: Duration(milliseconds: 800), // Optional: Animation duration
)
```

---

## Animation Timings

```dart
// Button press
Duration: 600ms
Curve: Curves.easeInOut
Scale: 1.0 → 0.85 → 1.0

// Header entrance  
Duration: 800ms
Curve: Curves.easeOut

// Card hover
Duration: 300ms
Curve: Curves.easeInOut

// Counter animation
Duration: 800ms (default)
Curve: Curves.easeOut

// Shimmer
Duration: 1500ms
Repeat: Infinite
```

---

## Imports Needed

```dart
// For FlowButton and AnimatedFlowButton
import '../widgets/flow_button.dart';

// For ActionButton and AnimatedCounter
import '../widgets/action_button.dart';

// For ModernCard and ShimmerCard
import '../widgets/modern_card.dart';

// For GradientHeader
import '../widgets/gradient_header.dart';
```

---

## Troubleshooting

**Button not animating?**
- Make sure it's a `FlowButton`, not `IconButton`
- Check that `onPressed` is implemented

**Colors not matching?**
- Double-check hex codes (copy from palette above)
- Add `.withOpacity(0.7)` for optional transparency

**Card hover not working?**
- Hover effects only work on desktop with mouse
- Set `enableHoverEffect: true` (default)

**Counter not animating?**
- Make sure using `AnimatedCounter` widget
- Check value changes are being detected

**Header animation missing?**
- GradientHeader now includes animations automatically
- No additional setup needed

---

## 📞 Need Help?

Refer to:
- `COMPONENTS_GUIDE.md` - Detailed documentation
- `components_showcase_screen.dart` - Live examples
- `lib/screens/history_screen.dart` - Working implementation

Happy coding! ✨
