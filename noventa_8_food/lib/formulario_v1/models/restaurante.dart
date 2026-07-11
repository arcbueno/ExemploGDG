import 'categoria.dart';

class Restaurante {
  final String id;
  final String nome;
  final String descricao;
  final Categoria categoria;

  Restaurante({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.categoria,
  });
}
