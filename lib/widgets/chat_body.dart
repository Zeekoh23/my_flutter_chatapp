import 'package:flutter/material.dart';

import './primary_button.dart';
import './card_skelton.dart';
import '../pages/contact_page.dart';
import '../constants.dart';

class ChatBody extends StatelessWidget {
  ChatBody(
      {Key? key,
      required this.refresh,
      required this.itemBuilder,
      required this.isLoading,
      required this.length,
      required this.isEmpty1})
      : super(key: key);
  RefreshCallback refresh;
  bool isLoading;
  int? length;
  IndexedWidgetBuilder itemBuilder;
  List isEmpty1;

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
                  child: isEmpty1.isEmpty
                      ? Padding(
                          padding:
                              EdgeInsets.only(top: 15, left: 80, right: 80),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline, size: 40),
                              const SizedBox(height: 2),
                              Text('Please create a new chat'),
                              const SizedBox(height: 20),
                              PrimaryButton(
                                  text: 'Click here',
                                  press: () {
                                    Navigator.of(context)
                                        .pushNamed(ContactPage.routename);
                                  },
                                  padding: EdgeInsets.all(kDefaultPadding / 2)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: length, itemBuilder: itemBuilder),
                ),
        ],
      ),
    );
  }
}
