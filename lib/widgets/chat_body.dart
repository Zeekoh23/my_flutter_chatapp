import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './card_skelton.dart';

class ChatBody extends StatelessWidget {
  ChatBody(
      {Key? key,
      required this.refresh,
      required this.itemBuilder,
      required this.isLoading,
      required this.length})
      : super(key: key);
  RefreshCallback refresh;
  bool isLoading;
  int? length;
  IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refresh,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          isLoading
              ? Expanded(
                  child: ListView.separated(
                    itemBuilder: (ctx, index) => CardSkelton(),
                    separatorBuilder: (ctx, index) =>
                        const SizedBox(height: 16),
                    itemCount: 9,
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                      itemCount: length, itemBuilder: itemBuilder),
                ),
        ],
      ),
    );
  }
}
