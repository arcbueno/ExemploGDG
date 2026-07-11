import 'package:flutter/material.dart';
import 'package:noventa_8_food/formulario_v2/formulario_state.dart';
import 'package:noventa_8_food/formulario_v2/models/restaurante.dart';
import 'package:noventa_8_food/formulario_v2/repositories/restaurante_respository.dart';

class FormularioViewmodel {
  final repository = RestauranteRespository();

  final ValueNotifier<FormularioState> state = ValueNotifier<FormularioState>(
    FormularioInitialState(),
  );

  FormularioViewmodel() {
    _loadCategorias();
  }

  Future<void> _loadCategorias() async {
    state.value = FormularioLoadingState();

    final categorias = await repository.getCategorias();

    state.value = FormularioEditingState(categoriasDisponiveis: categorias);
  }

  void submit(Restaurante restaurante) async {
    if (state.value is! FormularioEditingState) {
      return;
    }

    final categorias =
        (state.value as FormularioEditingState).categoriasDisponiveis;

    state.value = FormularioReadOnlyState(
      categoriasDisponiveis: categorias,
      dadosRestaurante: restaurante,
    );
  }

  void editForm() {
    if (state.value is! FormularioReadOnlyState) {
      return;
    }

    final categorias =
        (state.value as FormularioReadOnlyState).categoriasDisponiveis;

    state.value = FormularioEditingState(categoriasDisponiveis: categorias);
  }

  Future<String?> confirmSubmit() async {
    if (state.value is! FormularioReadOnlyState) {
      return 'Estado inválido para submissão';
    }

    final dadosRestaurante =
        (state.value as FormularioReadOnlyState).dadosRestaurante;

    state.value = FormularioConfirmLoadingState(
      dadosRestaurante: dadosRestaurante,
    );

    final result = await repository.submit(dadosRestaurante);

    if (result == null) {
      state.value = FormularioSuccessState();
    }

    return result;
  }
}
