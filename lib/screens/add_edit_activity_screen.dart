import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../models/activity_entry.dart';
import '../providers/activity_provider.dart';
import '../utils/formatters.dart';

Future<void> openActivityForm(BuildContext context, {ActivityEntry? entry}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => AddEditActivityScreen(entry: entry),
    ),
  );
}

class AddEditActivityScreen extends StatefulWidget {
  const AddEditActivityScreen({super.key, this.entry});

  final ActivityEntry? entry;

  @override
  State<AddEditActivityScreen> createState() => _AddEditActivityScreenState();
}

class _AddEditActivityScreenState extends State<AddEditActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  late ActivityType _type;
  late DateTime _date;
  late final TextEditingController _duration;
  late final TextEditingController _calories;
  late final TextEditingController _steps;
  late final TextEditingController _note;
  bool _saving = false;

  bool get _isEdit => widget.entry != null;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _type = e?.type ?? ActivityType.walking;
    _date = e?.date ?? DateTime.now();
    _duration = TextEditingController(text: e == null ? '' : '${e.durationMin}');
    _calories = TextEditingController(text: e == null ? '' : '${e.calories}');
    _steps = TextEditingController(
      text: (e == null || e.steps == 0) ? '' : '${e.steps}',
    );
    _note = TextEditingController(text: e?.note ?? '');
  }

  @override
  void dispose() {
    _duration.dispose();
    _calories.dispose();
    _steps.dispose();
    _note.dispose();
    super.dispose();
  }

  String? _validateInt(
    String? value, {
    required String label,
    required int min,
    required int max,
    bool required = true,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return required ? 'Enter $label' : null;
    final n = int.tryParse(text);
    if (n == null) return 'Numbers only';
    if (n < min || n > max) return 'Enter $min–$max';
    return null;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(now) ? now : _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year, now.month, now.day, 23, 59),
    );
    if (picked != null) {
      setState(() {
        _date = DateTime(picked.year, picked.month, picked.day, _date.hour, _date.minute);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    final provider = context.read<ActivityProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final entry = ActivityEntry(
      id: widget.entry?.id,
      type: _type,
      durationMin: int.parse(_duration.text.trim()),
      calories: int.parse(_calories.text.trim()),
      steps: int.tryParse(_steps.text.trim()) ?? 0,
      date: _date,
      note: _note.text.trim(),
    );

    try {
      if (_isEdit) {
        await provider.updateEntry(entry);
      } else {
        await provider.addEntry(entry);
      }
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text(_isEdit ? 'Activity updated' : 'Activity logged')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('Something went wrong. Please try again.')),
      );
    }
  }

  Future<void> _delete() async {
    final id = widget.entry?.id;
    if (id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete activity?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await context.read<ActivityProvider>().deleteEntry(id);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit activity' : 'Log activity'),
        actions: [
          if (_isEdit)
            IconButton(
              tooltip: 'Delete',
              onPressed: _delete,
              icon: Icon(Icons.delete_outline_rounded, color: scheme.error),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            _label('Activity type'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in ActivityType.values)
                  ChoiceChip(
                    avatar: Icon(
                      t.icon,
                      size: 18,
                      color: _type == t ? Colors.white : t.color,
                    ),
                    label: Text(t.label),
                    selected: _type == t,
                    selectedColor: t.color,
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _type == t ? Colors.white : scheme.onSurface,
                    ),
                    onSelected: (_) => setState(() => _type = t),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            _label('Date'),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(14),
              child: InputDecorator(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.calendar_today_rounded),
                ),
                child: Text(friendlyDate(_date)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _duration,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Duration',
                      suffixText: 'min',
                    ),
                    validator: (v) =>
                        _validateInt(v, label: 'duration', min: 1, max: 1440),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _calories,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Calories',
                      suffixText: 'kcal',
                    ),
                    validator: (v) =>
                        _validateInt(v, label: 'calories', min: 0, max: 10000),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _steps,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Steps (optional)',
                helperText: 'Steps taken during this activity',
                prefixIcon: Icon(Icons.directions_walk_rounded),
              ),
              validator: (v) => _validateInt(
                v,
                label: 'steps',
                min: 0,
                max: 100000,
                required: false,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _note,
              maxLength: 120,
              maxLines: 3,
              minLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(_isEdit ? 'Save changes' : 'Save activity'),
            ),
          ],
        ),
      ),
    );
  }
}