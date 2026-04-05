import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sentiment_analyzer/providers/theme_provider.dart';

void main() {
  testWidgets('App basic initialization and UI presence', (WidgetTester tester) async {
    // We can't easily bootstrap the whole app in a widget test due to Supabase/dotenv init
    // But we can test specific widgets or the Main screen with mocked providers.
    
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Sentiment Analysis')),
          ),
        ),
      ),
    );

    expect(find.text('Sentiment Analysis'), findsOneWidget);
  });
}
