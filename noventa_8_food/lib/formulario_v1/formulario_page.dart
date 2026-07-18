import 'package:flutter/material.dart';
import 'package:noventa_8_food/formulario_v1/formulario_state.dart';
import 'package:noventa_8_food/formulario_v1/formulario_viewmodel.dart';
import 'package:noventa_8_food/formulario_v1/models/categoria.dart';
import 'package:noventa_8_food/formulario_v1/models/restaurante.dart';

class FormularioPage extends StatefulWidget {
  const FormularioPage({super.key});

  @override
  State<FormularioPage> createState() => _FormularioPageState();
}

class _FormularioPageState extends State<FormularioPage> {
  late final FormularioViewmodel _viewModel;
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();

  Categoria? _categoriaSelecionada;

  @override
  void initState() {
    super.initState();
    _viewModel = FormularioViewmodel();
    _viewModel.state.addListener(_syncFromState);
  }

  @override
  void dispose() {
    _viewModel.state.removeListener(_syncFromState);
    _viewModel.state.dispose();
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  void _syncFromState() {
    final state = _viewModel.state.value;
    final restaurante = state.dadosRestaurante;

    if (restaurante != null) {
      if (_nomeController.text != restaurante.nome) {
        _nomeController.text = restaurante.nome;
      }
      if (_descricaoController.text != restaurante.descricao) {
        _descricaoController.text = restaurante.descricao;
      }

      _categoriaSelecionada =
          _findCategoriaById(
            state.categoriasDisponiveis,
            restaurante.categoria.id,
          ) ??
          restaurante.categoria;
    }
  }

  Categoria? _findCategoriaById(List<Categoria> categorias, String id) {
    try {
      return categorias.firstWhere((categoria) => categoria.id == id);
    } catch (e) {
      return null;
    }
  }

  void _handleSubmit(FormularioState state) {
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
      id:
          state.dadosRestaurante?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
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
          final categoriaDropdownValue = _categoriaSelecionada == null
              ? null
              : _findCategoriaById(
                  state.categoriasDisponiveis,
                  _categoriaSelecionada!.id,
                );

          if (state.isSuccess) {
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

          final loadingCategorias =
              state.isLoading && state.categoriasDisponiveis.isEmpty;
          if (loadingCategorias) {
            return const Positioned.fill(
              child: ColoredBox(
                color: Color(0x66FFFFFF),
                child: Center(
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
                ),
              ),
            );
          }

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                state.isReadOnly
                                    ? 'Revisar dados'
                                    : 'Novo restaurante',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _nomeController,
                                enabled: !state.isReadOnly,
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
                                controller: _descricaoController,
                                enabled: !state.isReadOnly,
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
                                initialValue: categoriaDropdownValue,
                                items: state.categoriasDisponiveis
                                    .map(
                                      (categoria) =>
                                          DropdownMenuItem<Categoria>(
                                            value: categoria,
                                            child: Text(categoria.nome),
                                          ),
                                    )
                                    .toList(),
                                onChanged: state.isReadOnly
                                    ? null
                                    : (categoria) {
                                        setState(() {
                                          _categoriaSelecionada = categoria;
                                        });
                                      },
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
                              if (state.isReadOnly) ...[
                                const SizedBox(height: 16),
                                _SummaryTile(
                                  title: 'Categoria selecionada',
                                  value: _categoriaSelecionada?.nome ?? '-',
                                ),
                              ],
                              const SizedBox(height: 24),
                              if (!state.isReadOnly)
                                ElevatedButton.icon(
                                  onPressed: state.isLoadingWithForm
                                      ? null
                                      : () => _handleSubmit(state),
                                  icon: const Icon(Icons.check),
                                  label: const Text('Revisar formulário'),
                                )
                              else
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: state.isLoadingWithForm
                                            ? null
                                            : _viewModel.editForm,
                                        child: const Text('Editar'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: state.isLoadingWithForm
                                            ? null
                                            : _handleConfirmSubmit,
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
                      if (state.isReadOnly) ...[
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Pré-visualização',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 12),
                                _SummaryTile(
                                  title: 'Nome',
                                  value: _nomeController.text,
                                ),
                                const SizedBox(height: 12),
                                _SummaryTile(
                                  title: 'Descrição',
                                  value: _descricaoController.text,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              if (state.isLoadingWithForm)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x33FFFFFF),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          );
        },
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
