import 'package:flutter_test/flutter_test.dart';
import 'package:mangxahoi/Model/PostModel.dart';

void main(){
  test('PostModel parses an empty list', () async {
    final list = PostModel.listFromJsonString('[]');
    expect(list.length, 0);
  });

  test('PostModel parses a simple payload', () async {
    final raw = '[{"id":1,"author":{"id":"1","email":"a@a.com","userName":"Alice"},"content":"Hi","createdAt":"2026-01-01T00:00:00Z","likes":1,"comments":0}]';
    final list = PostModel.listFromJsonString(raw);
    expect(list.length, 1);
    expect(list.first.content, 'Hi');
    expect(list.first.author.userName, 'Alice');
  });
}
