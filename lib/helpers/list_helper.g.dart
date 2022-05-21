// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_helper.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$ListHelperState on ListHelper, Store {
  final _$onlineusersAtom = Atom(name: 'ListHelper.onlineusers');

  @override
  ObservableList<String> get onlineusers {
    _$onlineusersAtom.reportRead();
    return super.onlineusers;
  }

  @override
  set onlineusers(ObservableList<String> value) {
    _$onlineusersAtom.reportWrite(value, super.onlineusers, () {
      super.onlineusers = value;
    });
  }

  final _$writingusersAtom = Atom(name: 'ListHelper.writingusers');

  @override
  ObservableList<String> get writingusers {
    _$writingusersAtom.reportRead();
    return super.writingusers;
  }

  @override
  set writingusers(ObservableList<String> value) {
    _$writingusersAtom.reportWrite(value, super.writingusers, () {
      super.writingusers = value;
    });
  }

  final _$ListHelperActionController = ActionController(name: 'ListHelper');

  @override
  dynamic setOnlineUsers(List<String> users) {
    final _$actionInfo = _$ListHelperActionController.startAction(
        name: 'ListHelper.setOnlineUsers');
    try {
      return super.setOnlineUsers(users);
    } finally {
      _$ListHelperActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic setWritingUsers(List<String> writing) {
    final _$actionInfo = _$ListHelperActionController.startAction(
        name: 'ListHelper.setWritingUsers');
    try {
      return super.setWritingUsers(writing);
    } finally {
      _$ListHelperActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
onlineusers: ${onlineusers},
writingusers: ${writingusers}
    ''';
  }
}
