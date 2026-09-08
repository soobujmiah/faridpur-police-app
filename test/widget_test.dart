import 'package:flutter_test/flutter_test.dart';

import 'package:faridpurpolice/main.dart';

void main() {
  testWidgets('Splash screen shows Bangla title and subtitle', (tester) async {
    await tester.pumpWidget(const FaridpurPoliceApp());

    expect(find.text('ফরিদপুর জেলা পুলিশ'), findsOneWidget);
    expect(find.text('Powered by Onskill-iT'), findsOneWidget);
  });
}
