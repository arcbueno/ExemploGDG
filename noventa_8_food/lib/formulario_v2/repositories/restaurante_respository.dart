import 'package:noventa_8_food/formulario_v2/models/categoria.dart';
import 'package:noventa_8_food/formulario_v2/models/restaurante.dart';

class RestauranteRespository {
  Future<List<Categoria>> getCategorias() async {
    await Future.delayed(const Duration(seconds: 2));
    return [
      Categoria(id: '1', nome: 'Comida Brasileira'),
      Categoria(id: '2', nome: 'Comida Japonesa'),
      Categoria(id: '3', nome: 'Comida Italiana'),
      Categoria(id: '4', nome: 'Comida Mexicana'),
    ];
  }

  Future<String?> submit(Restaurante restaurante) async {
    await Future.delayed(const Duration(seconds: 2));
    return null;
  }
}
