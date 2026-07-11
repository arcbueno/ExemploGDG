import 'package:noventa_8_food/formulario_v2/models/categoria.dart';
import 'package:noventa_8_food/formulario_v2/models/restaurante.dart';

sealed class FormularioState {}

class FormularioInitialState extends FormularioState {}

class FormularioLoadingState extends FormularioState {}

class FormularioEditingState extends FormularioState {
  final List<Categoria> categoriasDisponiveis;
  FormularioEditingState({required this.categoriasDisponiveis});
}

class FormularioReadOnlyState extends FormularioState {
  final Restaurante dadosRestaurante;
  final List<Categoria> categoriasDisponiveis;
  FormularioReadOnlyState({
    required this.categoriasDisponiveis,
    required this.dadosRestaurante,
  });
}

class FormularioConfirmLoadingState extends FormularioState {
  final Restaurante dadosRestaurante;
  FormularioConfirmLoadingState({required this.dadosRestaurante});
}

class FormularioSuccessState extends FormularioState {}
