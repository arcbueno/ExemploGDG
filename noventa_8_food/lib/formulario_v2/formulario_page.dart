import 'package:flutter/material.dart';
import 'package:noventa_8_food/formulario_v2/formulario_state.dart';
import 'package:noventa_8_food/formulario_v2/formulario_viewmodel.dart';
import 'package:noventa_8_food/formulario_v2/models/categoria.dart';
import 'package:noventa_8_food/formulario_v2/models/restaurante.dart';

class FormularioPageV2 extends StatefulWidget {
  const FormularioPageV2({super.key});

  @override
  State<FormularioPageV2> createState() => _FormularioPageState();
}

class _FormularioPageState extends State<FormularioPageV2> {
  late final FormularioViewmodel _viewModel;
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();

  Categoria? _categoriaSelecionada;

  @override
  void initState() {
    super.initState();
    _viewModel = FormularioViewmodel();
    _viewModel.state.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _viewModel.state.removeListener(_onStateChanged);
    _viewModel.state.dispose();
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    final state = _viewModel.state.value;

    if (state is FormularioReadOnlyState) {
      _categoriaSelecionada = state.dadosRestaurante.categoria;
    } else if (state is FormularioEditingState &&
        state.categoriasDisponiveis.isNotEmpty &&
        _categoriaSelecionada != null) {
      _categoriaSelecionada = _resolveCategoria(
        state.categoriasDisponiveis,
        _categoriaSelecionada!.id,
      );
    } else if (state is FormularioConfirmLoadingState) {
      _categoriaSelecionada = state.dadosRestaurante.categoria;
    }

    if (mounted) {
      setState(() {});
    }
  }

  Categoria? _resolveCategoria(List<Categoria> categorias, String id) {
    for (final categoria in categorias) {
      if (categoria.id == id) {
        return categoria;
      }
    }
    return null;
  }

  void _handleSubmit(FormularioEditingState state) {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final categoria = _categoriaSelecionada;
    if (categoria == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione uma categoria')));
      return;
    }

    final restaurante = Restaurante(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nome: _nomeController.text.trim(),
      descricao: _descricaoController.text.trim(),
      categoria: categoria,
    );

    _viewModel.submit(restaurante);
  }

  Future<void> _handleConfirmSubmit() async {
    final result = await _viewModel.confirmSubmit();
    if (!mounted) {
      return;
    }

    if (result != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Formulário de restaurante')),
      body: ValueListenableBuilder<FormularioState>(
        valueListenable: _viewModel.state,
        builder: (context, state, _) {
          return switch (state) {
            FormularioLoadingState() => _LoadingView(),
            FormularioEditingState(:final categoriasDisponiveis) => _FormView(
              title: 'Novo restaurante',
              formKey: _formKey,
              nomeController: _nomeController,
              descricaoController: _descricaoController,
              categorias: categoriasDisponiveis,
              categoriaSelecionada: _categoriaSelecionada,
              onCategoriaChanged: (categoria) {
                setState(() {
                  _categoriaSelecionada = categoria;
                });
              },
              onSubmit: () => _handleSubmit(state),
              submitLabel: 'Revisar formulário',
              submitIcon: Icons.check,
              isFormEnabled: true,
            ),
            FormularioReadOnlyState(
              :final categoriasDisponiveis,
              :final dadosRestaurante,
            ) =>
              _ReviewView(
                title: 'Revisar dados',
                formKey: _formKey,
                nomeController: _nomeController,
                descricaoController: _descricaoController,
                categorias: categoriasDisponiveis,
                categoriaSelecionada:
                    _categoriaSelecionada ?? dadosRestaurante.categoria,
                onEdit: _viewModel.editForm,
                onConfirm: _handleConfirmSubmit,
              ),
            FormularioConfirmLoadingState(:final dadosRestaurante) =>
              _ConfirmLoadingView(
                dadosRestaurante: dadosRestaurante,
                nomeController: _nomeController,
                descricaoController: _descricaoController,
              ),
            FormularioSuccessState() => _SuccessView(),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}

Categoria? _resolveCategoria(List<Categoria> categorias, String id) {
  for (final categoria in categorias) {
    if (categoria.id == id) {
      return categoria;
    }
  }
  return null;
}

class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Carregando categorias...'),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  const _FormView({
    required this.title,
    required this.formKey,
    required this.nomeController,
    required this.descricaoController,
    required this.categorias,
    required this.categoriaSelecionada,
    required this.onCategoriaChanged,
    required this.onSubmit,
    required this.submitLabel,
    required this.submitIcon,
    required this.isFormEnabled,
  });

  final String title;
  final GlobalKey<FormState> formKey;
  final TextEditingController nomeController;
  final TextEditingController descricaoController;
  final List<Categoria> categorias;
  final Categoria? categoriaSelecionada;
  final ValueChanged<Categoria?> onCategoriaChanged;
  final VoidCallback onSubmit;
  final String submitLabel;
  final IconData submitIcon;
  final bool isFormEnabled;

  @override
  Widget build(BuildContext context) {
    final dropdownValue = categoriaSelecionada == null
        ? null
        : _resolveCategoria(categorias, categoriaSelecionada!.id) ??
              categoriaSelecionada;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nomeController,
                  enabled: isFormEnabled,
                  decoration: const InputDecoration(
                    labelText: 'Nome do restaurante',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o nome do restaurante';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descricaoController,
                  enabled: isFormEnabled,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe a descrição do restaurante';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Categoria>(
                  initialValue: dropdownValue,
                  items: categorias
                      .map(
                        (categoria) => DropdownMenuItem<Categoria>(
                          value: categoria,
                          child: Text(categoria.nome),
                        ),
                      )
                      .toList(),
                  onChanged: isFormEnabled ? onCategoriaChanged : null,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null) {
                      return 'Selecione uma categoria';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: onSubmit,
                  icon: Icon(submitIcon),
                  label: Text(submitLabel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewView extends StatelessWidget {
  const _ReviewView({
    required this.title,
    required this.formKey,
    required this.nomeController,
    required this.descricaoController,
    required this.categorias,
    required this.categoriaSelecionada,
    required this.onEdit,
    required this.onConfirm,
  });

  final String title;
  final GlobalKey<FormState> formKey;
  final TextEditingController nomeController;
  final TextEditingController descricaoController;
  final List<Categoria> categorias;
  final Categoria categoriaSelecionada;
  final VoidCallback onEdit;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final categoria =
        _resolveCategoria(categorias, categoriaSelecionada.id) ??
        categoriaSelecionada;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              _SummaryTile(title: 'Nome', value: nomeController.text),
              const SizedBox(height: 12),
              _SummaryTile(title: 'Descrição', value: descricaoController.text),
              const SizedBox(height: 12),
              _SummaryTile(title: 'Categoria', value: categoria.nome),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onEdit,
                      child: const Text('Editar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onConfirm,
                      icon: const Icon(Icons.send),
                      label: const Text('Confirmar envio'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfirmLoadingView extends StatelessWidget {
  const _ConfirmLoadingView({
    required this.dadosRestaurante,
    required this.nomeController,
    required this.descricaoController,
  });

  final Restaurante dadosRestaurante;
  final TextEditingController nomeController;
  final TextEditingController descricaoController;

  @override
  Widget build(BuildContext context) {
    nomeController.text = dadosRestaurante.nome;
    descricaoController.text = dadosRestaurante.descricao;

    return const Center(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Confirmando envio...'),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Restaurante enviado com sucesso',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'O formulário foi concluído e os dados foram confirmados.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            Text(value),
          ],
        ),
      ),
    );
  }
}
