import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';

/// 10 / 20 / 50 questions, or a custom number typed by the user.
class QuestionCountPicker extends StatefulWidget {
  const QuestionCountPicker({super.key, required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  static const presets = [10, 20, 50];
  static const maxCustom = 200;

  @override
  State<QuestionCountPicker> createState() => _QuestionCountPickerState();
}

class _QuestionCountPickerState extends State<QuestionCountPicker> {
  late bool _custom = !QuestionCountPicker.presets.contains(widget.value);
  late final TextEditingController _controller = TextEditingController(
    text: _custom ? '${widget.value}' : '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _typed(String text) {
    final number = int.tryParse(text);
    if (number != null && number >= 1) {
      widget.onChanged(number.clamp(1, QuestionCountPicker.maxCustom));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          children: [
            for (final count in QuestionCountPicker.presets)
              ChoiceChip(
                label: Text('$count'),
                selected: !_custom && widget.value == count,
                onSelected: (_) {
                  setState(() => _custom = false);
                  widget.onChanged(count);
                },
              ),
            ChoiceChip(
              label: Text(l10n.practiceCustom),
              selected: _custom,
              onSelected: (_) => setState(() => _custom = true),
            ),
          ],
        ),
        if (_custom)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: SizedBox(
              width: 160,
              child: TextField(
                controller: _controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: l10n.practiceCustomLabel(QuestionCountPicker.maxCustom),
                  border: const OutlineInputBorder(),
                ),
                onChanged: _typed,
              ),
            ),
          ),
      ],
    );
  }
}
