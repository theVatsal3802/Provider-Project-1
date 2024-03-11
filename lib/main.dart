import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BreadCrumbProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(),
        home: const HomeScreen(),
        routes: {
          "/new": (context) => const NewBreadCrumbScreen(),
        },
      ),
    );
  }
}

class BreadCrumb {
  bool isActive;
  final String name;
  final String uuid;
  BreadCrumb({
    required this.isActive,
    required this.name,
  }) : uuid = const Uuid().v4();

  void activate() {
    isActive = true;
  }

  @override
  bool operator ==(covariant BreadCrumb other) => uuid == other.uuid;

  @override
  int get hashCode => uuid.hashCode;

  String get title => name + (isActive ? " > " : "");
}

class BreadCrumbProvider extends ChangeNotifier {
  final List<BreadCrumb> _items = [];

  UnmodifiableListView<BreadCrumb> get item => UnmodifiableListView(_items);

  void add(BreadCrumb breadCrumb) {
    for (final item in _items) {
      item.activate();
    }
    _items.add(breadCrumb);
    notifyListeners();
  }

  void reset() {
    _items.clear();
    notifyListeners();
  }
}

class BreadCrumbWidget extends StatelessWidget {
  final UnmodifiableListView<BreadCrumb> breadCrumbs;
  const BreadCrumbWidget({
    super.key,
    required this.breadCrumbs,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: breadCrumbs.map(
        (breadCrumb) {
          return Text(
            breadCrumb.title,
            textScaler: TextScaler.noScaling,
            style: TextStyle(
              color: breadCrumb.isActive ? Colors.blue : Colors.black,
            ),
          );
        },
      ).toList(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          textScaler: TextScaler.noScaling,
        ),
      ),
      body: Column(
        children: [
          Consumer<BreadCrumbProvider>(
            builder: (context, value, child) {
              return BreadCrumbWidget(
                breadCrumbs: value.item,
              );
            },
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed("/new");
            },
            child: const Text(
              "Add new bread crumb",
              textScaler: TextScaler.noScaling,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<BreadCrumbProvider>().reset();
            },
            child: const Text(
              "Reset",
              textScaler: TextScaler.noScaling,
            ),
          ),
        ],
      ),
    );
  }
}

class NewBreadCrumbScreen extends StatefulWidget {
  const NewBreadCrumbScreen({super.key});

  @override
  State<NewBreadCrumbScreen> createState() => _NewBreadCrumbScreenState();
}

class _NewBreadCrumbScreenState extends State<NewBreadCrumbScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add new bread crumb",
          textScaler: TextScaler.noScaling,
        ),
      ),
      body: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: "Enter the name of the new breadcrumb",
            ),
            controller: _controller,
          ),
          TextButton(
            onPressed: () {
              final text = _controller.text;
              if (text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Please enter some name",
                      textScaler: TextScaler.noScaling,
                    ),
                  ),
                );
                return;
              }
              context.read<BreadCrumbProvider>().add(
                    BreadCrumb(
                      isActive: false,
                      name: text.trim(),
                    ),
                  );
              Navigator.of(context).pop();
            },
            child: const Text(
              "Add",
              textScaler: TextScaler.noScaling,
            ),
          ),
        ],
      ),
    );
  }
}
