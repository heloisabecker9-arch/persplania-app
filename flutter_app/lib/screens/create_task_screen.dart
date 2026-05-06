import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/task.dart';

class CreateTaskScreen extends StatefulWidget {
  final Task? task;

  const CreateTaskScreen({super.key, this.task});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSaving = false;
  bool _isPinned = false;

  final List<String> _categories = [
    'Trabalho',
    'Estudo',
    'Pessoal',
    'Saúde',
    'Outros',
  ];
  late String _selectedCategory;
  DateTime? _selectedDueDate;
  late String _repeatType;
  late int _repeatInterval;

  final List<String> _repeatTypes = ['none', 'daily', 'weekly', 'monthly', 'yearly'];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.task?.category.isNotEmpty == true ? widget.task!.category : _categories.first;
    _selectedDueDate = widget.task?.dueDate;
    _isPinned = widget.task?.isPinned ?? false;
    _repeatType = widget.task?.repeatType ?? 'none';
    _repeatInterval = widget.task?.repeatInterval ?? 1;
    _titleController.text = widget.task?.title ?? '';
    _descriptionController.text = widget.task?.description ?? '';
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDueDate ?? now),
    );
    if (time == null) return;

    setState(() {
      _selectedDueDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _saveTask() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuário não autenticado.')));
      }
      return;
    }

    if (_titleController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe o título da tarefa.')));
      }
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final values = {
        'user_id': user.id,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'completed': widget.task?.completed ?? false,
        'is_pinned': _isPinned,
        'repeat_type': _repeatType,
        'repeat_interval': _repeatInterval,
      };
      if (_selectedDueDate != null) {
        values['due_date'] = _selectedDueDate!.toUtc().toIso8601String();
      }

      if (widget.task == null) {
        await supabase.from('tasks').insert(values).execute();
      } else {
        await supabase.from('tasks').update(values).eq('id', widget.task!.id).execute();
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      final message = error is PostgrestException && error.message.contains('is_pinned')
          ? 'Coluna "is_pinned" não existe em tasks. Execute o SQL de atualização no Supabase.'
          : 'Erro ao salvar tarefa: $error';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.task == null ? 'Criar tarefa' : 'Editar tarefa';
    final dueText = _selectedDueDate == null
        ? 'Escolher prazo (data e hora)'
        : 'Prazo: ${_selectedDueDate!.toLocal().day.toString().padLeft(2, '0')}/${_selectedDueDate!.toLocal().month.toString().padLeft(2, '0')}/${_selectedDueDate!.toLocal().year} ${_selectedDueDate!.toLocal().hour.toString().padLeft(2, '0')}:${_selectedDueDate!.toLocal().minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Descreva sua tarefa com clareza para manter seu fluxo produtivo.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75)),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Título',
                      prefixIcon: const Icon(Icons.task_alt_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Descrição',
                      prefixIcon: const Icon(Icons.sticky_note_2_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Categoria',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _categories.map((category) {
                      final selected = _selectedCategory == category;
                      return ChoiceChip(
                        label: Text(category),
                        selected: selected,
                        selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.18),
                        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                        labelStyle: TextStyle(
                          color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                        ),
                        onSelected: (_) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Repetição',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _repeatType,
                          decoration: InputDecoration(
                            labelText: 'Tipo',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                          items: [
                            const DropdownMenuItem(value: 'none', child: Text('Não repetir')),
                            const DropdownMenuItem(value: 'daily', child: Text('Diariamente')),
                            const DropdownMenuItem(value: 'weekly', child: Text('Semanalmente')),
                            const DropdownMenuItem(value: 'monthly', child: Text('Mensalmente')),
                            const DropdownMenuItem(value: 'yearly', child: Text('Anualmente')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _repeatType = value;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (_repeatType != 'none')
                        Expanded(
                          child: TextFormField(
                            initialValue: _repeatInterval.toString(),
                            decoration: InputDecoration(
                              labelText: 'Intervalo',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final intValue = int.tryParse(value) ?? 1;
                              setState(() {
                                _repeatInterval = intValue.clamp(1, 365);
                              });
                            },
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_selectedDueDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedDueDate = null;
                          });
                        },
                        icon: const Icon(Icons.clear),
                        label: const Text('Remover prazo'),
                      ),
                    ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: _pickDueDate,
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text(dueText),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: _isPinned ? Theme.of(context).colorScheme.primary.withOpacity(0.12) : Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.push_pin_outlined,
                          color: _isPinned ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Fixar esta tarefa no topo',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Switch(
                          value: _isPinned,
                          onChanged: (value) {
                            setState(() {
                              _isPinned = value;
                            });
                          },
                          activeColor: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveTask,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(widget.task == null ? 'Salvar tarefa' : 'Atualizar tarefa'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
