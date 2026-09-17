# Modelagem de Banco de Dados — Sistema de Gerenciamento Industrial

## Integrantes

**- Nome:** Evelyn Maria de Oliveira Silva

**- Matrícula:** 686

**- Nome:** João Vitor Custódio

**- Matrícula:** 764

## Tema escolhido

**Sistema de Gerenciamento para Empresa do Setor Industrial**

O projeto consiste na modelagem de um banco de dados para uma empresa do setor industrial, contemplando o controle de informações relacionadas a empregados, setores, produtos, produções e projetos desenvolvidos pela empresa. O objetivo é permitir o gerenciamento organizado das atividades da empresa, desde a estrutura hierárquica dos setores e empregados até o acompanhamento da produção de produtos e da execução de projetos.

## a) Modelo conceitual

O modelo conceitual representa as principais entidades envolvidas no sistema e os relacionamentos entre elas. Foram definidas as entidades Empresa, Setor, Empregado, Produto, Produção e Projeto, além das entidades associativas necessárias para os relacionamentos N:M. Cada entidade possui atributos que representam suas principais informações, como códigos, nomes, datas e valores. Os relacionamentos representam, por exemplo, a ligação entre empresa e setores, setores e empregados, produtos e produções, e empregados e projetos.

## b) Modelo lógico

O modelo lógico transforma as entidades e relacionamentos em tabelas que podem ser implementadas no banco de dados MySQL. Cada tabela possui uma chave primária (PK) para identificar seus registros de forma única. As chaves estrangeiras (FKs) são utilizadas para estabelecer as relações entre as tabelas. Foram utilizadas as tabelas Empresa, Setor, Empregado, Produto, Producao, Projeto, Detalhe_Producao e Participacao_Projeto, cada uma contendo suas respectivas PKs e FKs.

## c) Cardinalidades dos relacionamentos

As cardinalidades foram definidas de acordo com as regras de negócio do sistema. Empresa e Setor possuem relação 1:N, assim como Setor e Empregado, Setor e Produção e Empresa e Projeto. O relacionamento entre Empregado e Empregado é recursivo 1:N, representando a hierarquia entre responsáveis e subordinados. Produto e Produção possuem relacionamento N:M, assim como Empregado e Projeto. Já Projeto e Produto possuem relacionamento 1:1, pois cada projeto possui um único produto principal e um produto pode ser principal de, no máximo, um projeto.

## d) Justificativa das tabelas intermediárias

As tabelas intermediárias são necessárias para representar corretamente os relacionamentos N:M no modelo relacional. Como um registro de uma tabela pode estar relacionado a vários registros da outra tabela, e vice-versa, é criada uma terceira tabela contendo as chaves estrangeiras das duas entidades. Dessa forma, é possível registrar cada associação individualmente sem duplicar informações ou limitar a quantidade de relacionamentos.

## e) Tabelas dos relacionamentos N:M

A tabela **Detalhe_Producao** representa o relacionamento N:M entre Produto e Produção, permitindo registrar quais produtos fazem parte de cada produção e a quantidade produzida de cada produto. O nome foi escolhido porque a tabela contém os detalhes relacionados a uma determinada produção.

A tabela **Participacao_Projeto** representa o relacionamento N:M entre Empregado e Projeto, registrando quais empregados participam de cada projeto. O nome foi escolhido por representar diretamente a participação dos empregados nos projetos, sendo mais descritivo do que simplesmente unir os nomes das duas entidades.

## Arquivos do repositório

- `trabalho_bd.mwb` — arquivo do modelo gerado pelo MySQL Workbench.
