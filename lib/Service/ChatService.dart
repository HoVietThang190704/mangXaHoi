import '../Repository/ChatRepository.dart';
import '../Model/ChatModels.dart';

class ChatService {
  final ChatRepository _repo = ChatRepository();

  Future<ChatGroupResult> createGroup({required String name, List<String>? memberIds, String? avatar}) async {
    return _repo.createGroup(name: name, memberIds: memberIds, avatar: avatar);
  }

  Future<List<ChatGroupResult>> fetchGroups({int page = 1, int limit = 20}) async {
    return _repo.fetchGroups(page: page, limit: limit);
  }

  Future<ChatGroupResult?> getGroup(String groupId) async {
    return _repo.getGroup(groupId);
  }
}
