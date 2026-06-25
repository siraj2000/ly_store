import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/profile_controller.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../widgets/common/app_header.dart';

class MeasurementsScreen extends StatefulWidget {
  const MeasurementsScreen({super.key});

  @override
  State<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends State<MeasurementsScreen> {
  final _fields = <String, TextEditingController>{
    'Height': TextEditingController(),
    'Weight': TextEditingController(),
    'Bust/Chest': TextEditingController(),
    'Waist': TextEditingController(),
    'Hips': TextEditingController(),
    'Shoe size': TextEditingController(),
    'Preferred fit': TextEditingController(),
  };

  @override
  void dispose() {
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'My Measurements'),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.xl),
        children: [
          ..._fields.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.lg),
              child: AppTextField(controller: entry.value, label: entry.key),
            ),
          ),
          AppButton(
            text: 'Save',
            onPressed: () {
              context.read<ProfileController>().saveMeasurements({
                for (final entry in _fields.entries)
                  entry.key: entry.value.text.trim(),
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
