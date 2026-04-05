# 🎨 SentimentPro Animated Components Guide

This guide shows how to use the new Figma-inspired animated components in your Flutter app.

## 📦 Available Components

### 1. **FlowButton** - Circular Animated Button
Beautiful gradient circular buttons with smooth scale animations.

#### Basic Usage
```dart
FlowButton(
  icon: Icons.delete_outline_rounded,
  size: 40,
  tooltip: 'Delete analysis',
  onPressed: () {
    // Action
  },
)
```

#### With Custom Gradient
```dart
FlowButton(
  icon: Icons.share_rounded,
  size: 48,
  gradientColors: [
    const Color(0xFF3B82F6).withOpacity(0.7),
    const Color(0xFF1D4ED8),
  ],
  onPressed: () {},
  isLoading: false,
)
```

#### Available Gradient Presets
- **Blue**: `[Color(0xFF3B82F6), Color(0xFF1D4ED8)]` - For share/view actions
- **Red**: `[Color(0xFFEF4444), Color(0xFFDC2626)]` - For delete actions
- **Green**: `[Color(0xFF10B981), Color(0xFF059669)]` - For approve/save actions
- **Purple**: `[Color(0xFF667EEA), Color(0xFF764BA2)]` - For primary actions

---

### 2. **AnimatedFlowButton** - Full-width Animated Button
Gradient button with label and icon, perfect for primary actions.

#### Usage
```dart
AnimatedFlowButton(
  icon: Icons.analyze_rounded,
  label: 'Analyze Sentiment',
  onPressed: () {
    // Analyze action
  },
  gradientColors: [
    const Color(0xFF667EEA),
    const Color(0xFF764BA2),
  ],
)
```

---

### 3. **GradientHeader** - Animated Header Component
Enhanced header with fade-in and slide-up animations plus rotating background circle.

#### Usage
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
  actions: [
    IconButton(icon: Icon(Icons.settings), onPressed: () {})
  ],
)
```

---

### 4. **ActionButton** - Compact Action Button
Small animated button with icon and label for inline actions.

#### Usage
```dart
ActionButton(
  icon: Icons.edit_rounded,
  label: 'Edit',
  onPressed: () {},
  backgroundColor: const Color(0xFFF3F4F6),
  iconColor: const Color(0xFF4B5563),
)
```

---

### 5. **ModernCard** - Elevated Card with Hover Effect
Smooth hover animations and elevation changes.

#### Basic Usage
```dart
ModernCard(
  onTap: () => Navigator.push(...),
  child: Column(
    children: [
      Text('Analysis #1'),
      // Card content
    ],
  ),
)
```

#### With Custom Styling
```dart
ModernCard(
  padding: const EdgeInsets.all(24),
  margin: const EdgeInsets.only(bottom: 16),
  borderRadius: 24,
  elevation: 4,
  backgroundColor: Colors.white,
  enableHoverEffect: true,
  onTap: () {},
  child: Text('Your content here'),
)
```

---

### 6. **ShimmerCard** - Skeleton Loading
Animated shimmer effect for loading states.

#### Usage
```dart
Column(
  children: [
    ShimmerCard(height: 120, borderRadius: 24),
    ShimmerCard(height: 120, borderRadius: 24),
    ShimmerCard(height: 120, borderRadius: 24),
  ],
)
```

---

### 7. **AnimatedCounter** - Animated Statistics
Smooth counting animation for displaying numbers.

#### Usage
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceAround,
  children: [
    AnimatedCounter(
      value: 42,
      label: 'Reviews',
      color: const Color(0xFF10B981),
    ),
    AnimatedCounter(
      value: 28,
      label: 'Positive',
      color: const Color(0xFF3B82F6),
    ),
  ],
)
```

---

## 🎯 Color Scheme

### Primary Colors
- **Primary Purple**: `#667EEA` to `#764BA2`
- **Secondary Blue**: `#3B82F6` to `#1D4ED8`
- **Success Green**: `#10B981` to `#059669`
- **Danger Red**: `#EF4444` to `#DC2626`

### Neutral Colors
- **Dark BG**: `#1E293B` (Dark mode)
- **Light BG**: `#FFFFFF` (Light mode)
- **Gray 500**: `#717182`
- **Gray 400**: `#E5E7EB`

---

## 📱 Implementation Examples

### History Screen with Flow Buttons
```dart
Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    FlowButton(
      icon: Icons.share_rounded,
      size: 40,
      tooltip: 'Share analysis',
      gradientColors: [
        const Color(0xFF3B82F6).withOpacity(0.7),
        const Color(0xFF1D4ED8),
      ],
      onPressed: () {
        // Share action
      },
    ),
    const SizedBox(width: 8),
    FlowButton(
      icon: Icons.delete_outline_rounded,
      size: 40,
      tooltip: 'Delete analysis',
      gradientColors: [
        const Color(0xFFEF4444).withOpacity(0.7),
        const Color(0xFFDC2626),
      ],
      onPressed: () {
        // Delete action
      },
    ),
  ],
)
```

### Loading State
```dart
if (isLoading) {
  Column(
    children: [
      ShimmerCard(),
      ShimmerCard(),
      ShimmerCard(),
    ],
  )
} else {
  // Content
}
```

### Statistics Display
```dart
Container(
  padding: const EdgeInsets.all(24),
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.05),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: Colors.grey.withOpacity(0.1)),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      AnimatedCounter(value: 156, label: 'Total Reviews', color: Colors.grey),
      AnimatedCounter(value: 98, label: 'Positive', color: const Color(0xFF10B981)),
      AnimatedCounter(value: 35, label: 'Negative', color: const Color(0xFFEF4444)),
    ],
  ),
)
```

---

## ⚙️ Animation Properties

### FlowButton
- **Scale**: 1.0 → 0.85 (300ms)
- **Curve**: `Curves.easeInOut`
- **Shadow**: Dynamic based on gradient color

### GradientHeader
- **Fade**: 0 → 1 (800ms)
- **Slide**: Offset(0, 0.3) → (0, 0) (800ms)
- **Rotate**: Continuous 360° rotation of background circle

### ModernCard
- **Scale**: 1.0 → 0.98 on hover
- **Shadow**: Increases on hover
- **Duration**: 300ms

### AnimatedCounter
- **Duration**: Configurable (default 800ms)
- **Curve**: `Curves.easeOut`
- **Effect**: Smooth number increment

---

## 🎨 Customization Tips

1. **Change colors**: Pass custom `gradientColors` list
2. **Adjust size**: Use `size` parameter (default: 48)
3. **Add tooltips**: Use `tooltip` parameter
4. **Loading state**: Set `isLoading: true` to show spinner
5. **Disable hover**: Set `enableHoverEffect: false` in ModernCard

---

## 📝 File Locations

- `lib/widgets/flow_button.dart` - Circular gradient buttons
- `lib/widgets/action_button.dart` - Compact action buttons & counters
- `lib/widgets/gradient_header.dart` - Animated header component
- `lib/widgets/modern_card.dart` - Card with hover effects
- `lib/screens/history_screen.dart` - Implementation example

---

## 🚀 Next Steps

1. Import the components in your screens
2. Replace existing buttons with FlowButton
3. Add animations to loading states with ShimmerCard
4. Display statistics with AnimatedCounter
5. Use ModernCard for all interactive cards

Enjoy building beautiful, animated UIs! ✨
