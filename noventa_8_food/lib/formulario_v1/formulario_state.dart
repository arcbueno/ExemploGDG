import 'package:noventa_8_food/formulario_v1/models/categoria.dart';
import 'package:noventa_8_food/formulario_v1/models/restaurante.dart';

class FormularioState {
  final bool isLoading;
  final bool isReadOnly;
  final bool isLoadingWithForm;
  final bool isSuccess;
  final Restaurante? dadosRestaurante;
  final List<Categoria> categoriasDisponiveis;

  FormularioState({
    this.isLoading = false,
    this.isReadOnly = false,
    this.isLoadingWithForm = false,
    this.categoriasDisponiveis = const [],
    this.isSuccess = false,
    this.dadosRestaurante,
  });
}
