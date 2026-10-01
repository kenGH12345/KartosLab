import 'package:flutter/material.dart';

import '../controller/bam_controller.dart';
import '../data/bam_molecule_catalog.dart';
import '../data/bam_strings.dart';
import '../model/bam_screen_configurations.dart';
import 'bam_screen_body.dart';

class SingleScreen extends StatefulWidget {
  const SingleScreen({super.key, this.controller, this.embedded = false});

  final BamController? controller;
  final bool embedded;

  @override
  State<SingleScreen> createState() => _SingleScreenState();
}

class _SingleScreenState extends State<SingleScreen> {
  BamController? _controller;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller;
      _loading = false;
    } else {
      _load();
    }
  }

  Future<void> _load() async {
    try {
      await BamMoleculeCatalog.ensureInitialLoaded();
      await BamMoleculeCatalog.getMainInstance();
      if (!BamStrings.isLoaded) await BamStrings.load();
      if (!mounted) return;
      setState(() {
        _controller = BamController(BamScreenConfigurations.createSingle());
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null || _controller == null) {
      return Center(child: Text('加载失败: $_error'));
    }
    return BamScreenBody(
      controller: _controller!,
      embedded: widget.embedded,
      title: '单分子',
      showCollection: true,
    );
  }
}
