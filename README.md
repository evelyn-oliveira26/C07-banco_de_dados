# Banco de Dados - Sistema de Gerenciamento Industrial

## Integrantes

**- Nome:** Evelyn Maria de Oliveira Silva

**- Matrícula:** 686

**- Nome:** João Vitor Custódio

**- Matrícula:** 764

## Tema escolhido

**Sistema de Gerenciamento para Empresa do Setor Industrial**

Banco de dados para uma empresa do setor industrial, com o controle de empregados, setores, produtos, produções e projetos. O objetivo é organizar as atividades da empresa, desde a hierarquia dos setores e empregados até o acompanhamento da produção e dos projetos.

## Arquivos do repositório

- `trabalho_bd.mwb` - modelo gerado pelo MySQL Workbench (parte 1).
- `trabalho_bd_imagem.png` - imagem do diagrama (parte 1).
- `trabalho_bd.sql` - script SQL da implementação (parte 2).

---

# Parte 1 - Modelagem

## a) Modelo conceitual

Foram definidas as entidades Empresa, Setor, Empregado, Produto, Produção e Projeto, além das entidades associativas dos relacionamentos N:M. Cada entidade tem atributos com suas principais informações, como códigos, nomes, datas e valores. Os relacionamentos ligam empresa e setores, setores e empregados, produtos e produções, e empregados e projetos.

## b) Modelo lógico

O modelo lógico transforma as entidades e os relacionamentos em tabelas do MySQL: Empresa, Setor, Empregado, Produto, Producao, Projeto, Detalhe_Producao e Participacao_Projeto. Cada tabela tem uma chave primária (PK) que identifica seus registros, e as chaves estrangeiras (FKs) fazem a ligação entre as tabelas.

## c) Cardinalidades dos relacionamentos

| Relacionamento | Cardinalidade |
|---|---|
| Empresa - Setor | 1:N |
| Setor - Empregado | 1:N |
| Setor - Produção | 1:N |
| Empresa - Projeto | 1:N |
| Empregado - Empregado | 1:N recursivo (responsável e subordinados) |
| Produto - Produção | N:M |
| Empregado - Projeto | N:M |
| Projeto - Produto | 1:1 (cada projeto tem um produto principal, e um produto é principal de no máximo um projeto) |

## d) Justificativa das tabelas intermediárias

Em um relacionamento N:M, um registro de uma tabela pode estar ligado a vários da outra, e vice-versa. Para representar isso no modelo relacional é criada uma terceira tabela com as chaves estrangeiras das duas entidades. Assim cada associação é registrada individualmente, sem duplicar informações.

## e) Tabelas dos relacionamentos N:M

**Detalhe_Producao** representa o N:M entre Produto e Produção. Registra quais produtos fazem parte de cada produção e a quantidade de cada um. O nome foi escolhido porque a tabela guarda os detalhes de uma produção.

**Participacao_Projeto** representa o N:M entre Empregado e Projeto. Registra quais empregados participam de cada projeto. O nome descreve a participação dos empregados nos projetos, e é mais claro do que juntar os nomes das duas entidades.

---

# Parte 2 - Implementação

Toda a implementação está no arquivo [`trabalho_bd.sql`](trabalho_bd.sql), dividido em 9 seções. Para executar, abrir o arquivo no MySQL Workbench (MySQL 8) conectado como `root` e rodar o script inteiro. Ele apaga e recria o banco, a role e os usuários, então pode ser executado mais de uma vez.

| Requisito do enunciado | Seção do script |
|---|---|
| Banco e tabelas | 1 |
| Inserção de dados | 2 |
| Comandos DML | 3 |
| Buscas com JOIN (1:1, 1:N e N:M) | 4 |
| Function | 5 |
| View | 6 |
| Trigger | 7 |
| Procedure | 8 |
| Dois usuários e uma ROLE | 9 |

## 1. Banco e tabelas

O banco `trabalho_bd` tem as 8 tabelas do modelo da parte 1, com as mesmas colunas, tipos, PKs e FKs. As tabelas são criadas na ordem das dependências, porque uma FK só pode apontar para uma tabela que já existe.

- Os relacionamentos 1:N viraram uma FK na tabela do lado N.
- O 1:1 entre Projeto e Produto é uma FK em Projeto com `UNIQUE`, que impede o mesmo produto em dois projetos.
- Os N:M viraram as tabelas `Detalhe_Producao` e `Participacao_Projeto`, com PK composta pelas duas FKs.

## 2. Inserção dos dados

Os dados simulam um grupo de indústrias do Sul de Minas, com nomes, CNPJs e CPFs fictícios. Cada tabela tem pelo menos 5 registros: Empresa 5, Setor 7, Empregado 12, Produto 7, Producao 7, Detalhe_Producao 11, Projeto 5 e Participacao_Projeto 15.

## 3. Manipulação de dados (DML)

| Comando | O que faz | Por que foi usado |
|---|---|---|
| `INSERT` | Cadastra os dados iniciais | Popular as tabelas |
| `UPDATE` | Preenche o telefone da empresa 5 | O cadastro estava incompleto. Atualizar mantém o mesmo código da empresa |
| `UPDATE` | Promove o empregado 4: novo cargo e salário 8% maior | As duas colunas mudam no mesmo comando |
| `UPDATE` | Reajuste de 5% para o setor de Montagem | Um comando só atualiza várias linhas |
| `SELECT` | Lista quem ganha mais de R$ 5.000 | Conferir o resultado dos `UPDATE` |
| `DELETE` | Retira o empregado 8 do projeto 5 | Apaga só a linha da tabela intermediária; o empregado e o projeto continuam cadastrados |

## 4. Consultas com JOIN

| Consulta | Relacionamento | O que responde |
|---|---|---|
| 4.1 | **1:N** (Empresa → Setor → Empregado) | Cada empregado com seu setor, sua empresa e o nome do responsável |
| 4.2 | **1:1** (Produto - Projeto) | Cada produto com o projeto do qual é o produto principal |
| 4.3 | **N:M** (Empregado - Projeto) | Quem participa de cada projeto |
| 4.4 | **N:M** (Produto - Producao) | Quantidade de produções, total fabricado e valor produzido de cada produto |

Na 4.1 e na 4.2 foi usado `LEFT JOIN` para não perder quem não tem par: empregados sem responsável e produtos sem projeto aparecem com `NULL`. Na 4.3 e na 4.4 o `JOIN` passa pela tabela intermediária, e a 4.4 agrupa por produto com `GROUP BY`, `COUNT` e `SUM`.

## 5. Function

**`valor_producao`** recebe o código de uma produção e devolve o valor total em reais: a soma de quantidade × valor unitário de cada item.

**Por que foi criada:** o cálculo precisa de um `JOIN` com soma e é usado em mais de um lugar. Como function, fica escrito uma vez só e pode ser chamado dentro de um `SELECT`, como se fosse uma coluna.

## 6. Views

**`resumo_producao`** mostra uma linha por produção, com data, turno, setor, empresa, total de unidades e valor total.

**Por que foi criada:** o resumo junta três tabelas e chama a function. Com a view, basta um `SELECT` simples, sem reescrever os `JOIN`.

**`empregado_publico`** (extra) mostra os empregados sem CPF e sem salário.

**Por que foi criada:** os usuários da seção 9 têm permissão nesta view, e não na tabela Empregado. Assim consultam quem trabalha em cada setor sem ver os dados pessoais.

## 7. Triggers

**`detalhe_producao_insert`** é disparado depois de cada `INSERT` em `Detalhe_Producao` e recalcula a coluna `quantidade_produzida` da produção como a soma dos seus itens.

**Por que foi criado:** o total de uma produção aparece em dois lugares, na coluna de Producao e na soma dos itens. Com o trigger, o próprio banco mantém os dois iguais.

**`detalhe_producao_update`** e **`detalhe_producao_delete`** (extra) aplicam a mesma regra quando um item é alterado ou apagado.

No teste do script, a produção 3 começa com 25 unidades, vai para 65 com o `INSERT`, para 75 com o `UPDATE` e volta para 25 com o `DELETE`.

## 8. Procedure

**`registrar_producao`** recebe data, turno, setor, produto e quantidade, e registra uma produção já com o seu produto.

**Por que foi criada:** registrar uma produção exige dois `INSERT` em tabelas diferentes, e o segundo precisa do código gerado no primeiro. A procedure faz os dois em uma chamada só. O total começa em 0 e é preenchido pelo trigger.

## 9. Usuários e ROLE

Foram criados os usuários `carlos` e `marina`, relacionados pela role `analista_producao`.

**Por que usar uma role:** as permissões são dadas à role, e os usuários recebem a role. Os dois ficam com os mesmos acessos, e para mudar uma permissão de todos basta um comando.

A role pode consultar Setor e Produto, consultar, inserir e alterar em Producao e Detalhe_Producao, consultar as duas views e executar a procedure. Ela não tem acesso às tabelas Empresa, Empregado, Projeto e Participacao_Projeto.

## Implementações extras

1. View `empregado_publico`: acesso aos empregados sem expor CPF e salário.
2. Triggers de `UPDATE` e `DELETE` em `Detalhe_Producao`: o total da produção fica correto em qualquer alteração dos itens.
