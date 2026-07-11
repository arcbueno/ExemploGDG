# Exemplo GDG João Pessoa — State Pattern no Flutter

Este repositório reúne um exemplo em Flutter usado como apoio para uma palestra do Google Developers Group em João Pessoa, no formato Google I/O Extended.

O foco da apresentação é o **State Pattern**, um padrão comportamental que ajuda a organizar objetos que mudam de comportamento conforme o seu estado interno.

[Apresentação base da palestra](https://docs.google.com/presentation/d/1L6kq9nMf3MkN-wV0sP8OhA8H8qBFmPR4aE9EMwZZ0As/edit?usp=sharing)

## Objetivo

Demonstrar, na prática, por que estados modelados como classes explícitas deixam o código:

- mais legível
- mais fácil de manter
- mais previsível durante transições
- menos sujeito a condicionais espalhadas pela aplicação

## Tema da palestra

A palestra parte de um problema comum em telas Flutter:

- carregamento de dados
- modo de edição
- modo somente leitura
- confirmação de envio
- sucesso e falha

Quando tudo isso é representado apenas por flags booleanas e condicionais, a tela fica difícil de evoluir. A proposta é mostrar como o State Pattern ajuda a transformar esse cenário em um fluxo mais claro e extensível.

## O que este exemplo mostra

O projeto contém duas abordagens para o mesmo fluxo de formulário:

### `formulario_v1`

Versão inicial, com o estado representado por uma classe única e vários campos booleanos.

Essa versão serve para evidenciar os problemas mais comuns:

- combinações inválidas de estado
- leitura mais difícil
- validações repetidas
- transições menos explícitas

### `formulario_v2`

Versão refatorada com estados explícitos usando uma hierarquia de classes.

Essa versão mostra os benefícios do State Pattern:

- cada estado tem sua própria responsabilidade
- as transições ficam mais claras
- o comportamento do formulário depende do estado atual
- a evolução do fluxo fica mais simples

## Conceito central

O State Pattern é útil quando um objeto altera seu comportamento conforme o estado interno muda. Em vez de acumular `if` e `switch` espalhados pelo código, o comportamento é delegado para objetos que representam cada estado.

Em termos práticos, isso ajuda a tratar a interface como uma máquina de estados finitos:

- estado inicial
- carregando
- editando
- somente leitura
- confirmando envio
- sucesso

## Estrutura do projeto

```text
noventa_8_food/
  lib/
    formulario_v1/
    formulario_v2/
```

A ideia é comparar as duas versões lado a lado e observar como o design muda quando os estados deixam de ser apenas flags e passam a ser classes de domínio.

## Como executar

Dentro da pasta do projeto Flutter:

```bash
flutter pub get
flutter run
```

Se quiser rodar em uma plataforma específica, use o device disponível no seu ambiente Flutter.

## Para acompanhar a palestra

Durante a apresentação, observe especialmente:

1. como o estado está modelado em cada versão
2. como as transições são feitas
3. quais problemas aparecem quando há muitos campos booleanos
4. como o State Pattern reduz complexidade

## Referências

- [State Pattern — Refactoring.Guru](https://refactoring.guru/design-patterns/state)
- [Entendendo e aplicando o State pattern no Flutter — Parte 1](https://medium.com/cuscuzcomcodigo/entendendo-e-aplicando-o-state-pattern-no-flutter-parte-1-fda8d2e23701)

## Contexto

Projeto de exemplo preparado para fins didáticos, com foco em arquitetura, legibilidade e ensino do padrão State em Flutter.
