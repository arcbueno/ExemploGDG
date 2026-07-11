import 'package:flutter/material.dart';
import 'package:noventa_8_food/formulario_v1/formulario_state.dart';
import 'package:noventa_8_food/formulario_v1/models/restaurante.dart';
import 'package:noventa_8_food/formulario_v1/repositories/restaurante_respository.dart';

class FormularioViewmodel {
  final repository = RestauranteRespository();

  final ValueNotifier<FormularioState> state = ValueNotifier<FormularioState>(
    FormularioState(),
  );

  FormularioViewmodel() {
    _loadCategorias();
  }

  Future<void> _loadCategorias() async {
    state.value = FormularioState(isLoading: true);

    final categorias = await repository.getCategorias();

    state.value = FormularioState(categoriasDisponiveis: categorias);
  }

  void submit(Restaurante restaurante) async {
    if (state.value.isReadOnly ||
        state.value.isLoading ||
        state.value.isLoadingWithForm) {
      return;
    }

    state.value = FormularioState(
      isReadOnly: true,
      categoriasDisponiveis: state.value.categoriasDisponiveis,
      dadosRestaurante: restaurante,
    );
  }

  void editForm() {
    if (!state.value.isReadOnly ||
        state.value.isLoading ||
        state.value.isLoadingWithForm) {
      return;
    }

    state.value = FormularioState(
      isReadOnly: false,
      categoriasDisponiveis: state.value.categoriasDisponiveis,
      dadosRestaurante: state.value.dadosRestaurante,
    );
  }

  Future<String?> confirmSubmit() async {
    if (state.value.dadosRestaurante == null) {
      return 'Não há dados para enviar';
    }
    if (!state.value.isReadOnly) {
      return 'O formulário não está em modo de leitura';
    }
    if (state.value.isLoadingWithForm || state.value.isLoading) {
      return 'O formulário está carregando, aguarde';
    }

    state.value = FormularioState(
      isReadOnly: true,
      isLoadingWithForm: true,
      categoriasDisponiveis: state.value.categoriasDisponiveis,
      dadosRestaurante: state.value.dadosRestaurante,
    );

    final result = await repository.submit(state.value.dadosRestaurante!);

    if (result == null) {
      state.value = FormularioState(isSuccess: true);
    }

    return result;
  }
}
