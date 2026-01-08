import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mangxahoi/Components/PostCardComponent.dart';
import 'package:mangxahoi/Model/PostModel.dart';
import 'package:mangxahoi/Model/AuthUserModel.dart';

void main(){
  testWidgets('PostCard displays author and content', (WidgetTester tester) async {
    final post = PostModel(
      id: 1,
      author: AuthUserModel(id: '1', email: 'a@a.com', userName: 'Alice'),
      content: 'Hello world',
      createdAt: DateTime.now(),
      likes: 2,
      comments: 1,
    );

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: PostCardComponent(post: post))));

    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Hello world'), findsOneWidget);
  });
}
