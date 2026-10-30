import 'package:flutter/material.dart';

enum _TaskPriority { high, medium, low }

enum _TaskFilter { all, active, completed }

class _Task {
  _Task({
    required this.title,
    required this.note,
    required this.priority,
  });

  final String title;
  final String note;
  final _TaskPriority priority;
  bool isCompleted = false;
}

class _NewTask {
  const _NewTask(this.title, this.note, this.priority);

  final String title;
  final String note;
  final _TaskPriority priority;
}

class UIUpdatesDemo extends StatefulWidget {
  const UIUpdatesDemo({super.key});

  @override
  State<UIUpdatesDemo> createState() => _UIUpdatesDemoState();
}

class _UIUpdatesDemoState extends State<UIUpdatesDemo> {
  static const _ink = Color(0xFF202C27);
  static const _mutedInk = Color(0xFF78817B);
  static const _green = Color(0xFF426B55);
  static const _paper = Color(0xFFF6F6F1);

  final List<_Task> _tasks = [
    _Task(
      title: 'Plan the week',
      note: 'Pick the three things that matter most',
      priority: _TaskPriority.high,
    ),
    _Task(
      title: 'Send project update',
      note: 'Share progress with the team',
      priority: _TaskPriority.medium,
    ),
    _Task(
      title: 'Take a proper lunch break',
      note: 'Step away from the screen',
      priority: _TaskPriority.low,
    ),
  ];

  _TaskFilter _filter = _TaskFilter.all;

  List<_Task> get _visibleTasks {
    switch (_filter) {
      case _TaskFilter.active:
        return _tasks.where((task) => !task.isCompleted).toList();
      case _TaskFilter.completed:
        return _tasks.where((task) => task.isCompleted).toList();
      case _TaskFilter.all:
        return _tasks;
    }
  }

  int get _completedCount => _tasks.where((task) => task.isCompleted).length;

  Future<void> _addTask() async {
    final task = await showDialog<_NewTask>(
      context: context,
      builder: (context) => const _AddTaskDialog(),
    );

    if (task == null || !mounted) return;

    setState(() {
      _tasks.insert(
        0,
        _Task(
          title: task.title,
          note: task.note,
          priority: task.priority,
        ),
      );
      _filter = _TaskFilter.all;
    });
  }

  void _toggleTask(_Task task) {
    setState(() => task.isCompleted = !task.isCompleted);
  }

  void _removeTask(_Task task) {
    final index = _tasks.indexOf(task);
    setState(() => _tasks.remove(task));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Task deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              setState(() => _tasks.insert(index, task));
            },
          ),
        ),
      );
  }

  String _dateLabel(DateTime date) {
    const weekdays = [
      'MONDAY',
      'TUESDAY',
      'WEDNESDAY',
      'THURSDAY',
      'FRIDAY',
      'SATURDAY',
      'SUNDAY',
    ];
    const months = [
      'JANUARY',
      'FEBRUARY',
      'MARCH',
      'APRIL',
      'MAY',
      'JUNE',
      'JULY',
      'AUGUST',
      'SEPTEMBER',
      'OCTOBER',
      'NOVEMBER',
      'DECEMBER',
    ];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final completed = _completedCount;
    final total = _tasks.length;
    final progress = total == 0 ? 0.0 : completed / total;

    return Scaffold(
      backgroundColor: _paper,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTask,
        backgroundColor: _green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New task'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5EDE5),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: _green,
                            ),
                          ),
                          const SizedBox(width: 11),
                          const Text(
                            'daylight',
                            style: TextStyle(
                              color: _ink,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            tooltip: 'Add a task',
                            onPressed: _addTask,
                            icon: const Icon(Icons.add_rounded),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: _ink,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text(
                        _dateLabel(DateTime.now()),
                        style: const TextStyle(
                          color: _mutedInk,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const SizedBox(height: 9),
                      const Text(
                        'Make today\ncount.',
                        style: TextStyle(
                          color: _ink,
                          fontSize: 38,
                          height: 1.12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.6,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _ProgressCard(
                        completed: completed,
                        total: total,
                        progress: progress,
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          const Text(
                            'Your tasks',
                            style: TextStyle(
                              color: _ink,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 9),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE9EBE5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$total',
                              style: const TextStyle(
                                color: _mutedInk,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _FilterBar(
                        selected: _filter,
                        onChanged: (filter) => setState(() => _filter = filter),
                      ),
                      const SizedBox(height: 14),
                      if (_visibleTasks.isEmpty)
                        _EmptyTasks(filter: _filter)
                      else
                        ..._visibleTasks.map(
                          (task) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Dismissible(
                              key: ObjectKey(task),
                              direction: DismissDirection.endToStart,
                              onDismissed: (_) => _removeTask(task),
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1DFDB),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Color(0xFF9B5147),
                                ),
                              ),
                              child: _TaskTile(
                                task: task,
                                onToggle: () => _toggleTask(task),
                                onDelete: () => _removeTask(task),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 64),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.completed,
    required this.total,
    required this.progress,
  });

  final int completed;
  final int total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF304B3D),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'A little progress adds up.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$completed / $total',
                style: const TextStyle(
                  color: Color(0xFFD8E4D9),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: const Color(0x2EFFFFFF),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFFB8D5B6)),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onChanged});

  final _TaskFilter selected;
  final ValueChanged<_TaskFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    const labels = {
      _TaskFilter.all: 'All',
      _TaskFilter.active: 'To do',
      _TaskFilter.completed: 'Done',
    };

    return Wrap(
      spacing: 8,
      children: _TaskFilter.values.map((filter) {
        final isSelected = filter == selected;
        return ChoiceChip(
          label: Text(labels[filter]!),
          selected: isSelected,
          onSelected: (_) => onChanged(filter),
          showCheckmark: false,
          backgroundColor: Colors.transparent,
          selectedColor: const Color(0xFF304B3D),
          side: BorderSide(
            color:
                isSelected ? const Color(0xFF304B3D) : const Color(0xFFE2E5DE),
          ),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF657069),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        );
      }).toList(),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  final _Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    late final Color priorityColor;
    late final Color priorityBackground;
    late final String priorityLabel;
    switch (task.priority) {
      case _TaskPriority.high:
        priorityColor = const Color(0xFFB76A55);
        priorityBackground = const Color(0x1AB76A55);
        priorityLabel = 'HIGH';
        break;
      case _TaskPriority.medium:
        priorityColor = const Color(0xFFB58B43);
        priorityBackground = const Color(0x1AB58B43);
        priorityLabel = 'MED';
        break;
      case _TaskPriority.low:
        priorityColor = const Color(0xFF6D8B75);
        priorityBackground = const Color(0x1A6D8B75);
        priorityLabel = 'LOW';
        break;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEBECE7)),
      ),
      child: Row(
        children: [
          Checkbox(
            value: task.isCompleted,
            onChanged: (_) => onToggle(),
            shape: const CircleBorder(),
            activeColor: const Color(0xFF426B55),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        color: task.isCompleted
                            ? const Color(0xFF9BA19C)
                            : const Color(0xFF202C27),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (task.note.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.note,
                        style: const TextStyle(
                          color: Color(0xFF89918B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: priorityBackground,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              priorityLabel,
              style: TextStyle(
                color: priorityColor,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Delete ${task.title}',
            onPressed: onDelete,
            icon: const Icon(Icons.close_rounded, size: 18),
            color: const Color(0xFFA3AAA4),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _EmptyTasks extends StatelessWidget {
  const _EmptyTasks({required this.filter});

  final _TaskFilter filter;

  @override
  Widget build(BuildContext context) {
    late final String message;
    switch (filter) {
      case _TaskFilter.completed:
        message = 'Nothing completed just yet.';
        break;
      case _TaskFilter.active:
        message = "You're all caught up. Enjoy the breathing room.";
        break;
      case _TaskFilter.all:
        message = 'A fresh start. Add your first task.';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEBECE7)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.spa_outlined,
            size: 28,
            color: Color(0xFF6D8B75),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF78817B),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddTaskDialog extends StatefulWidget {
  const _AddTaskDialog();

  @override
  State<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<_AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  _TaskPriority _priority = _TaskPriority.medium;

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      _NewTask(
        _titleController.text.trim(),
        _noteController.text.trim(),
        _priority,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create a task'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Task',
                  hintText: 'What needs to get done?',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Give your task a name.';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _save(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  hintText: 'Add a little detail (optional)',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<_TaskPriority>(
                initialValue: _priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: const [
                  DropdownMenuItem(
                    value: _TaskPriority.high,
                    child: Text('High'),
                  ),
                  DropdownMenuItem(
                    value: _TaskPriority.medium,
                    child: Text('Medium'),
                  ),
                  DropdownMenuItem(
                    value: _TaskPriority.low,
                    child: Text('Low'),
                  ),
                ],
                onChanged: (priority) {
                  if (priority != null) {
                    setState(() => _priority = priority);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Add task'),
        ),
      ],
    );
  }
}
