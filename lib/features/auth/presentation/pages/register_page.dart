import 'package:flutter/material.dart';
import 'package:mobile_flutter/app/utils/formatters.dart';
import 'package:mobile_flutter/features/auth/presentation/states/register_state.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_flutter/core/di/service_locator.dart';
import 'package:mobile_flutter/features/auth/data/models/auth_models.dart';
import 'package:mobile_flutter/features/auth/presentation/notifiers/register_notifier.dart';
import 'package:mobile_flutter/widgets/app_text_form_field.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RegisterNotifier(ServiceLocator().authRepository),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _clientFormKey = GlobalKey<FormState>();
  final _establishmentFormKey = GlobalKey<FormState>();

  // Client Controllers
  final _clientNameController = TextEditingController();
  final _clientEmailController = TextEditingController();
  final _clientPasswordController = TextEditingController();
  final _clientConfirmPasswordController = TextEditingController();
  final _clientCpfController = TextEditingController();
  final _clientPhoneController = TextEditingController();

  // Establishment Controllers
  final _estNameController = TextEditingController(); // Nome do responsável
  final _estEmailController = TextEditingController();
  final _estCnpjController = TextEditingController();
  final _estPasswordController = TextEditingController();
  final _estConfirmPasswordController = TextEditingController();
  final _estEstablishmentNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        context.read<RegisterNotifier>().toggleType(
          _tabController.index == 0
              ? 0
              : 1,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _clientNameController.dispose();
    _clientEmailController.dispose();
    _clientPasswordController.dispose();
    _clientCpfController.dispose();
    _estNameController.dispose();
    _estEmailController.dispose();
    _estPasswordController.dispose();
    _estEstablishmentNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta'),
        /*
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Sou Cliente'),
            Tab(text: 'Sou Estabelecimento'),
          ],
        ),
        */
      ),
      body: Consumer<RegisterNotifier>(
        builder: (context, notifier, child) {
          // Show messages when status changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            switch (notifier.status) {
              case Success():
                notifier.reset();
                context.go('/home');
              case Error(message: final msg):
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(msg),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
                notifier.reset();
              default:
                break;
            }
          });

          final isLoading = notifier.status is Loading;
          return _buildClientForm(isLoading);
          /*
          return TabBarView(
            controller: _tabController,
            children: [
              _buildClientForm(isLoading),
              _buildEstablishmentForm(isLoading),
            ],
          );
          */
        },
      ),
    );
  }

  Widget _buildClientForm(bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _clientFormKey,
        child: Column(
          children: [
            AppTextFormField(
              controller: _clientNameController,
              label: 'Nome',
              labelStyle: AppTextFormFieldLabelStyle.fixed,
              hint: 'Nome Completo',
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              controller: _clientEmailController,
              label: 'E-mail',
              labelStyle: AppTextFormFieldLabelStyle.fixed,
              hint: 'nome@email.com',
              keyboardType: TextInputType.emailAddress,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppTextFormField(
                    controller: _clientCpfController,
                    label: 'CPF',
                    labelStyle: AppTextFormFieldLabelStyle.fixed,
                    hint: '000.000.000-00',
                    keyboardType: TextInputType.number,
                    inputFormatters: [cpfFormatter],
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Campo obrigatório' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppTextFormField(
                    controller: _clientPhoneController,
                    label: 'Telefone',
                    labelStyle: AppTextFormFieldLabelStyle.fixed,
                    hint: '(00) 00000-0000',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [telefoneFormatter],
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Campo obrigatório' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              controller: _clientPasswordController,
              label: 'Senha',
              labelStyle: AppTextFormFieldLabelStyle.fixed,
              hint: 'Crie uma senha',
              obscureText: true,
              validator: (value) =>
                  (value?.length ?? 0) < 6 ? 'Mínimo 6 caracteres' : null,
            ),
            const SizedBox(height: 16,),
            AppTextFormField(
              controller: _clientConfirmPasswordController,
              hint: 'Confirme a senha',
              obscureText: true,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Campo obrigatório';
                }
                if (value != _clientPasswordController.text) {
                  return 'Senhas não são iguais';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: isLoading
                    ? null
                    : () {
                        if (_clientFormKey.currentState?.validate() ?? false) {
                          final dto = RegisterClientDto(
                            nome: _clientNameController.text,
                            email: _clientEmailController.text,
                            cpf: _clientCpfController.text,
                            password: _clientPasswordController.text,
                          );
                          context.read<RegisterNotifier>().registerClient(dto);
                        }
                      },
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('CRIAR CONTA CLIENTE'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstablishmentForm(bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _establishmentFormKey,
        child: Column(
          children: [
            AppTextFormField(
              controller: _estNameController,
              label: 'Nome do Responsável',
              labelStyle: AppTextFormFieldLabelStyle.fixed,
              hint: 'Nome completo',
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              controller: _estCnpjController,
              label: 'CNPJ',
              labelStyle: AppTextFormFieldLabelStyle.fixed,
              hint: 'AB.123.456/1000.12',
              inputFormatters: [cnpjFormatter],
              validator: (value) =>
                value?.isEmpty ?? true ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16,),
            AppTextFormField(
              controller: _estEstablishmentNameController,
              label: 'Nome do Estabelecimento',
              labelStyle: AppTextFormFieldLabelStyle.fixed,
              hint: 'Nome Fantasia',
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              controller: _estEmailController,
              label: 'E-mail',
              labelStyle: AppTextFormFieldLabelStyle.fixed,
              hint: 'nome@email.com',
              keyboardType: TextInputType.emailAddress,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              controller: _estPasswordController,
              label: 'Senha',
              labelStyle: AppTextFormFieldLabelStyle.fixed,
              hint: 'Crie uma senha',
              obscureText: true,
              validator: (value) =>
                  (value?.length ?? 0) < 6 ? 'Mínimo 6 caracteres' : null,
            ),
            const SizedBox(height: 16,),
            AppTextFormField(
              controller: _estConfirmPasswordController,
              hint: 'Confirme a senha',
              obscureText: true,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Campo obrigatório';
                }
                if (value != _estPasswordController.text) {
                  return 'Senhas não são iguais';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: isLoading
                    ? null
                    : () {
                        if (_establishmentFormKey.currentState?.validate() ??
                            false) {
                          final dto = RegisterEstablishmentDto(
                            nome: _estNameController.text,
                            email: _estEmailController.text,
                            nomeEstabelecimento:
                                _estEstablishmentNameController.text,
                            password: _estPasswordController.text,
                            cnpj: _estCnpjController.text,
                          );
                          context.read<RegisterNotifier>().registerEstablishment(
                            dto,
                          );
                        }
                      },
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('CRIAR CONTA ESTABELECIMENTO'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
