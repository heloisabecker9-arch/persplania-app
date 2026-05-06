import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];

  final List<String> _categories = [
    'Todas',
    'Trabalho',
    'Estudo',
    'Pessoal',
    'Saúde',
    'Outros',
  ];
  final List<String> _statuses = ['Todas', 'Pendentes', 'Concluídas'];

  String _selectedCategory = 'Todas';
  String _selectedStatus = 'Todas';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _applyFilters() {
    setState(() {
      _filteredTasks = _tasks.where((task) {
        if (_selectedCategory != 'Todas' && task.category != _selectedCategory) {
          return false;
        }
        if (_selectedStatus == 'Pendentes' && task.completed) {
          return false;
        }
        if (_selectedStatus == 'Concluídas' && !task.completed) {
          return false;
        }
        if (_selectedDate != null) {
          final selectedDate = _selectedDate!;
          final dueDate = task.dueDate?.toLocal();
          if (dueDate == null ||
              dueDate.year != selectedDate.year ||
              dueDate.month != selectedDate.month ||
              dueDate.day != selectedDate.day) {
            return false;
          }
        }
        return true;
      }).toList();
      // Ordenar tarefas fixadas no topo
      _filteredTasks.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return 0;
      });
    });
  }

  Future<void> _loadTasks() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await supabase
          .from('tasks')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .execute();

      final data = response.data as List<dynamic>?;
      final List<Task> tasks = data == null
          ? []
          : data.map((item) => Task.fromMap(item as Map<String, dynamic>)).toList();

      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
      _applyFilters();
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar tarefas: $error')),
      );
    }
  }

  Future<void> _toggleCompleted(Task task) async {
    try {
      await supabase
          .from('tasks')
          .update({'completed': !task.completed})
          .eq('id', task.id)
          .execute();
      _loadTasks();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar tarefa: $error')),
      );
    }
  }

  Future<void> _togglePinned(Task task) async {
    try {
      await supabase
          .from('tasks')
          .update({'is_pinned': !task.isPinned})
          .eq('id', task.id)
          .execute();
      _loadTasks();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao fixar tarefa: $error')),
      );
    }
  }

  Future<void> _deleteTask(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir tarefa'),
          content: const Text('Tem certeza que deseja excluir esta tarefa?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await supabase.from('tasks').delete().eq('id', task.id).execute();
      _loadTasks();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir tarefa: $error')),
      );
    }
  }

  Future<void> _signOut() async {
    await supabase.auth.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Widget _buildFilterChips() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.filter_list_rounded, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Filtros rápidos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                      _applyFilters();
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _statuses.map((status) {
                final selected = _selectedStatus == status;
                return ChoiceChip(
                  label: Text(status),
                  selected: selected,
                  selectedColor: Theme.of(context).colorScheme.secondary.withOpacity(0.18),
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  labelStyle: TextStyle(
                    color: selected ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.onSurface,
                  ),
                  onSelected: (_) {
                    setState(() {
                      _selectedStatus = status;
                      _applyFilters();
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarFilter() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.12),
            Theme.of(context).colorScheme.secondary.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Filtrar por data',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (_selectedDate != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedDate = null;
                        _applyFilters();
                      });
                    },
                    child: const Text('Limpar'),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () async {
                final selected = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (selected != null) {
                  setState(() {
                    _selectedDate = selected;
                    _applyFilters();
                  });
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate == null
                          ? 'Selecione uma data'
                          : '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskTile(Task task) {
    final dueLabel = task.dueDate == null
        ? 'Sem prazo'
        : '${task.dueDate!.toLocal().day.toString().padLeft(2, '0')}/${task.dueDate!.toLocal().month.toString().padLeft(2, '0')}/${task.dueDate!.toLocal().year} ${task.dueDate!.toLocal().hour.toString().padLeft(2, '0')}:${task.dueDate!.toLocal().minute.toString().padLeft(2, '0')}';
    final statusColor = task.completed ? Colors.green : task.isOverdue ? Colors.redAccent : Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: () async {
        await Navigator.pushNamed(context, '/create', arguments: task);
        _loadTasks();
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: statusColor.withOpacity(0.16),
                  child: Icon(
                    task.completed ? Icons.check : task.isOverdue ? Icons.schedule : Icons.lightbulb,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (task.isPinned)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(Icons.push_pin, size: 16, color: Theme.of(context).colorScheme.primary),
                            ),
                          Expanded(
                            child: Text(
                              task.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (task.description.isNotEmpty)
                        Text(
                          task.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75),
                              ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                PopupMenuButton<String>(
                  onSelected: (String result) {
                    if (result == 'delete') {
                      _deleteTask(task);
                    } else if (result == 'toggle_pin') {
                      _togglePinned(task);
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'toggle_pin',
                      child: Row(
                        children: [
                          Icon(
                            task.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                            color: task.isPinned ? Theme.of(context).colorScheme.primary : null,
                          ),
                          const SizedBox(width: 8),
                          Text(task.isPinned ? 'Desfixar' : 'Fixar no topo'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: const [
                          Icon(Icons.delete_outline, color: Colors.redAccent),
                          SizedBox(width: 8),
                          Text('Excluir'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildStatusBadge(task.category.isEmpty ? 'Sem categoria' : task.category, Theme.of(context).colorScheme.primary.withOpacity(0.15), Theme.of(context).colorScheme.primary),
                _buildStatusBadge(task.completed ? 'Concluída' : 'Pendente', statusColor.withOpacity(0.12), statusColor),
                _buildStatusBadge(dueLabel, Theme.of(context).colorScheme.surfaceVariant, Theme.of(context).colorScheme.onSurface),
                if (task.isOverdue)
                  _buildStatusBadge('Atrasada', Colors.redAccent.withOpacity(0.16), Colors.redAccent),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _toggleCompleted(task),
                    icon: Icon(task.completed ? Icons.undo : Icons.check_circle_outline),
                    label: Text(task.completed ? 'Marcar pendente' : 'Concluir'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: statusColor,
                      side: BorderSide(color: statusColor.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final totalTasks = _tasks.length;
    final pendingTasks = _tasks.where((task) => !task.completed).length;
    final overdueTasks = _tasks.where((task) => task.isOverdue).length;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onBackground,
        title: Text('Minha agenda', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: _signOut,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTasks,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 18),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      gradient: LinearGradient(
                        colors: [colorScheme.primary.withOpacity(0.2), colorScheme.secondary.withOpacity(0.12)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bom dia!',
                                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Aqui estão suas tarefas mais importantes.',
                                    style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onBackground.withOpacity(0.75)),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12),
                                ],
                              ),
                              padding: const EdgeInsets.all(14),
                              child: Icon(Icons.calendar_today, color: colorScheme.primary, size: 28),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            _buildSummaryBadge('Total', totalTasks.toString(), colorScheme.primary),
                            const SizedBox(width: 12),
                            _buildSummaryBadge('Pendentes', pendingTasks.toString(), colorScheme.secondary),
                            const SizedBox(width: 12),
                            _buildSummaryBadge('Atrasadas', overdueTasks.toString(), Colors.redAccent),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildFilterChips(),
                  _buildCalendarFilter(),
                  if (_filteredTasks.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        children: [
                          Icon(Icons.inbox, size: 72, color: colorScheme.onBackground.withOpacity(0.28)),
                          const SizedBox(height: 18),
                          Text(
                            'Nenhuma tarefa aqui',
                            style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onBackground.withOpacity(0.78)),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Adicione uma tarefa e veja seu dia ganhar ritmo.',
                            style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onBackground.withOpacity(0.72)),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    ..._filteredTasks.map(_buildTaskTile).toList(),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, '/create');
          _loadTasks();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova tarefa'),
      ),
    );
  }

  Widget _buildSummaryBadge(String label, String value, Color badgeColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: badgeColor.withOpacity(0.14),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: badgeColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: badgeColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
