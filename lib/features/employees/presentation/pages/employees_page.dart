import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../notifiers/employees_notifier.dart';
import '../states/employee_state.dart';

class EmployeesPage extends StatelessWidget {
  final EmployeesNotifier notifier;

  const EmployeesPage({
    super.key,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: notifier,
      child: const _EmployeesPage(),
    );
  }
}

class _EmployeesPage extends StatefulWidget {
  const _EmployeesPage();

  @override
  State<_EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<_EmployeesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeesNotifier>().loadEmployees();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Funcionários')),
        body: Consumer<EmployeesNotifier>(
          builder: (context, notifier, _) {
            final state = notifier.state;

            return switch (state) {
              EmployeesInitial() || EmployeesLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              EmployeesError(:final message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: notifier.loadEmployees,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
              EmployeesLoaded(:final employees) =>
                employees.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum funcionário cadastrado',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Adicione funcionários para começar',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: notifier.loadEmployees,
                        child: ListView.builder(
                          itemCount: employees.length,
                          itemBuilder: (context, index) {
                            final employee = employees[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: employee.avatarUrl != null
                                      ? NetworkImage(employee.avatarUrl!)
                                      : null,
                                  child: employee.avatarUrl == null
                                      ? Text(
                                          employee.nome[0].toUpperCase(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : null,
                                ),
                                title: Text(employee.nome),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(employee.email),
                                    if (employee.roles != null)
                                      Text(
                                        employee.roles!.nome,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      employee.isActive
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      color: employee.isActive
                                          ? Colors.green
                                          : Colors.red,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.chevron_right),
                                  ],
                                ),
                                onTap: () {
                                  context.push(
                                    '/establishment/profile/employees/${employee.id}/edit',
                                    extra: employee,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
            };
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            context.push('/establishment/profile/employees/add');
          },
          icon: const Icon(Icons.add),
          label: const Text('Adicionar'),
        ),
      );
  }
}
