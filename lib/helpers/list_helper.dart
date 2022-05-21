import 'package:mobx/mobx.dart';

part 'list_helper.g.dart';

class ListHelperState = ListHelper with _$ListHelperState;

abstract class ListHelper with Store {
  @observable
  ObservableList<String> onlineusers = ObservableList<String>();

  @observable
  ObservableList<String> writingusers = ObservableList<String>();

  @action
  setOnlineUsers(List<String> users) {
    onlineusers = ObservableList.of(users);
  }

  @action
  setWritingUsers(List<String> writing) {
    writingusers = ObservableList.of(writing);
  }
}
