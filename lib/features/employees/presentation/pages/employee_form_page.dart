import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../../core/services/session_service.dart';
import '../../data/models/employee_model.dart';
import '../../data/repositories/employee_repository.dart';
import '../notifiers/employee_form_notifier.dart';
import '../states/employee_form_state.dart';

class EmployeeFormPage extends StatefulWidget {
  final EmployeeRepository repository;
  final SessionService sessionService;

  const EmployeeFormPage({
    super.key,
    required this.repository,
    required this.sessionService,
  });

  @override
  State<EmployeeFormPage> createState() => _EmployeeFormPageState();
}

class _EmployeeFormPageState extends State<EmployeeFormPage> {
  late final EmployeeFormNotifier _notifier;
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isActive = true;
  final Set<int> _selectedRoles = {};

  @override
  void initState() {
    super.initState();
    _notifier = EmployeeFormNotifier(
      widget.repository,
      widget.sessionService,
    );
    _notifier.loadAvailableRoles();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _notifier.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final dto = CreateEmployeeDto(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        passwordHash: _passwordController.text.isNotEmpty
            ? _passwordController.text
            : null,
        isActive: _isActive,
        rolesId: _selectedRoles.toList(),
      );

      _notifier.createEmployee(dto);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _notifier,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Novo Funcionário'),
        ),
        body: Consumer<EmployeeFormNotifier>(
          builder: (context, notifier, _) {
            // Listener para sucesso
            if (notifier.state is EmployeeFormSuccess) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Funcionário criado com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );
                context.pop();
              });
            }

            // Listener para erro
            if (notifier.state is EmployeeFormError) {
              final error = notifier.state as EmployeeFormError;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error.message),
                    backgroundColor: Colors.red,
                  ),
                );
                notifier.resetState();
              });
            }

            final isLoading = notifier.state is EmployeeFormLoading;
            final rolesState = notifier.rolesState;

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome*',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    enabled: !isLoading,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nome é obrigatório';
                      }
                      if (value.trim().length < 3) {
                        return 'Nome deve ter pelo menos 3 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email*',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    enabled: !isLoading,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email é obrigatório';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Email inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                      helperText: 'Deixe vazio para não definir senha',
                    ),
                    obscureText: true,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Ativo'),
                    subtitle: const Text('Funcionário pode acessar o sistema'),
                    value: _isActive,
                    onChanged: isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _isActive = value;
                            });
                          },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Papéis (Permissões)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  switch (rolesState) {
                    RolesLoading() => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    RolesError(:final message) => Center(
                        child: Text(
                          message,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    RolesLoaded(:final roles) => roles.isEmpty
                        ? const Text('Nenhum papel disponível')
                        : Column(
                            children: roles.map((role) {
                              return CheckboxListTile(
                                title: Text(role.nome),
                                subtitle: role.descricao != null
                                    ? Text(role.descricao!)
                                    : null,
                                value: _selectedRoles.contains(role.id),
                                enabled: !isLoading,
                                onChanged: (checked) {
                                  setState(() {
                                    if (checked == true) {
                                      _selectedRoles.add(role.id);
                                    } else {
                                      _selectedRoles.remove(role.id);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                    _ => const SizedBox.shrink(),
                  },
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading ? null : _handleSubmit,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Salvar'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
