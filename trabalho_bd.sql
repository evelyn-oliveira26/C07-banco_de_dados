-- =====================================================================
-- C07 - Banco de Dados | Sistema de Gerenciamento Industrial
-- Parte 2: implementação do modelo da parte 1
--
-- Integrantes: Evelyn Maria de Oliveira Silva  (686)
-- 				João Vitor Custódio             (764)
--
--   1. Criação do banco e das tabelas
--   2. Inserção dos dados
--   3. Manipulação de dados (DML)
--   4. Consultas com JOIN (1:N, 1:1 e N:M)
--   5. Function
--   6. Views
--   7. Triggers
--   8. Procedure
--   9. Usuários e ROLE
-- =====================================================================

-- 1. CRIAÇÃO DO BANCO E DAS TABELAS
DROP DATABASE IF EXISTS trabalho_bd;
CREATE DATABASE trabalho_bd;
USE trabalho_bd;

CREATE TABLE Empresa (
    codigo_empresa INT          NOT NULL AUTO_INCREMENT,
    nome           VARCHAR(100) NOT NULL,
    cnpj           CHAR(14)     NOT NULL UNIQUE,
    endereco       VARCHAR(150) NOT NULL,
    telefone       VARCHAR(15),
    PRIMARY KEY (codigo_empresa)
);

CREATE TABLE Setor (
    codigo_setor   INT          NOT NULL AUTO_INCREMENT,
    nome           VARCHAR(100) NOT NULL,
    localizacao    VARCHAR(100) NOT NULL,
    descricao      TEXT,
    codigo_empresa INT          NOT NULL,
    PRIMARY KEY (codigo_setor),
    CONSTRAINT fk_setor_empresa
        FOREIGN KEY (codigo_empresa) REFERENCES Empresa (codigo_empresa)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE Empregado (
    codigo_empregado   INT           NOT NULL AUTO_INCREMENT,
    nome               VARCHAR(100)  NOT NULL,
    cpf                CHAR(11)      NOT NULL UNIQUE,
    data_nascimento    DATE          NOT NULL,
    cargo              VARCHAR(60)   NOT NULL,
    salario            DECIMAL(10,2) NOT NULL,
    codigo_setor       INT           NOT NULL,
    codigo_responsavel INT,
    PRIMARY KEY (codigo_empregado),
    CONSTRAINT fk_empregado_setor
        FOREIGN KEY (codigo_setor) REFERENCES Setor (codigo_setor),
    CONSTRAINT fk_empregado_responsavel
        FOREIGN KEY (codigo_responsavel) REFERENCES Empregado (codigo_empregado)
        ON DELETE SET NULL
);

CREATE TABLE Produto (
    codigo_produto INT           NOT NULL AUTO_INCREMENT,
    nome           VARCHAR(100)  NOT NULL,
    descricao      TEXT,
    categoria      VARCHAR(60)   NOT NULL,
    valor          DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (codigo_produto)
);

CREATE TABLE Producao (
    codigo_producao      INT         NOT NULL AUTO_INCREMENT,
    data                 DATE        NOT NULL,
    quantidade_produzida INT         NOT NULL,
    turno                VARCHAR(30) NOT NULL,
    codigo_setor         INT         NOT NULL,
    PRIMARY KEY (codigo_producao),
    CONSTRAINT fk_producao_setor
        FOREIGN KEY (codigo_setor) REFERENCES Setor (codigo_setor)
        ON DELETE RESTRICT
);

CREATE TABLE Detalhe_Producao (
    codigo_producao    INT NOT NULL,
    codigo_produto     INT NOT NULL,
    quantidade_produto INT NOT NULL,
    PRIMARY KEY (codigo_producao, codigo_produto),
    CONSTRAINT fk_detalhe_producao
        FOREIGN KEY (codigo_producao) REFERENCES Producao (codigo_producao),
    CONSTRAINT fk_detalhe_produto
        FOREIGN KEY (codigo_produto) REFERENCES Produto (codigo_produto)
);

CREATE TABLE Projeto (
    codigo_projeto INT           NOT NULL AUTO_INCREMENT,
    nome           VARCHAR(100)  NOT NULL,
    descricao      TEXT,
    data_inicio    DATE          NOT NULL,
    data_termino   DATE          NOT NULL,
    orcamento      DECIMAL(12,2) NOT NULL,
    codigo_empresa INT           NOT NULL,
    codigo_produto INT           NOT NULL UNIQUE,
    PRIMARY KEY (codigo_projeto),
    CONSTRAINT fk_empresa_projeto
        FOREIGN KEY (codigo_empresa) REFERENCES Empresa (codigo_empresa),
    CONSTRAINT fk_produto_projeto
        FOREIGN KEY (codigo_produto) REFERENCES Produto (codigo_produto)
);

CREATE TABLE Participacao_Projeto (
    codigo_empregado INT NOT NULL,
    codigo_projeto   INT NOT NULL,
    PRIMARY KEY (codigo_empregado, codigo_projeto),
    CONSTRAINT fk_projeto_empregado
        FOREIGN KEY (codigo_empregado) REFERENCES Empregado (codigo_empregado),
    CONSTRAINT fk_empregado_projeto
        FOREIGN KEY (codigo_projeto) REFERENCES Projeto (codigo_projeto)
);

-- 2. INSERÇÃO DOS DADOS
INSERT INTO Empresa (nome, cnpj, endereco, telefone) VALUES
    ('Metalúrgica Vale do Sapucaí Ltda',      '12345678000195', 'Av. João de Camargo, 510 - Santa Rita do Sapucaí/MG', '(35) 3471-1000'), -- 1
    ('Indústria Mineira de Componentes S.A.', '23456789000186', 'Rod. Fernão Dias, km 862 - Pouso Alegre/MG',          '(35) 3422-2000'), -- 2
    ('Sul Minas Polímeros Ltda',              '34567890000177', 'Rua das Indústrias, 88 - Itajubá/MG',                 '(35) 3622-3000'), -- 3
    ('Eletro Serra Equipamentos Ltda',        '45678901000168', 'Av. Brasil, 1500 - Varginha/MG',                      '(35) 3221-4000'), -- 4
    ('TecnoForja Indústria e Comércio Ltda',  '56789012000159', 'Distrito Industrial, Lote 12 - Extrema/MG',           NULL);             -- 5

INSERT INTO Setor (nome, localizacao, descricao, codigo_empresa) VALUES
    ('Usinagem',              'Galpão A',             'Torneamento e fresamento CNC de peças metálicas',     1), -- 1
    ('Montagem',              'Galpão B',             'Montagem mecânica e elétrica dos produtos finais',    1), -- 2
    ('Controle de Qualidade', 'Bloco Administrativo', 'Inspeção dimensional e ensaios das peças produzidas', 1), -- 3
    ('Engenharia de Produto', 'Bloco Técnico',        'Desenvolvimento e melhoria dos produtos da empresa',  1), -- 4
    ('Injeção Plástica',      'Galpão 1',             'Injeção de peças em polímero',                        3), -- 5
    ('Estamparia',            'Unidade Pouso Alegre', 'Corte e estampagem de chapas de aço',                 2), -- 6
    ('Logística e Expedição', 'Doca 2',               NULL,                                                  4); -- 7

INSERT INTO Empregado (nome, cpf, data_nascimento, cargo, salario, codigo_setor, codigo_responsavel) VALUES
    ('Helena Duarte Ribeiro',   '11122233344', '1978-03-14', 'Gerente Industrial',      14500.00, 4, NULL), -- 1
    ('Marcos Vinícius Antunes', '22233344455', '1984-07-22', 'Supervisor de Usinagem',   7800.00, 1, 1),    -- 2
    ('Patrícia Lemos Barbosa',  '33344455566', '1986-11-05', 'Supervisora de Montagem',  7600.00, 2, 1),    -- 3
    ('Rafael Souza Lima',       '44455566677', '1995-01-30', 'Operador de CNC',          3900.00, 1, 2),    -- 4
    ('Juliana Costa Pereira',   '55566677788', '1992-09-18', 'Operadora de CNC',         4100.00, 1, 2),    -- 5
    ('Bruno Carvalho Dias',     '66677788899', '1998-05-09', 'Montador',                 3200.00, 2, 3),    -- 6
    ('Camila Ferreira Rocha',   '77788899900', '1997-12-27', 'Montadora',                3350.00, 2, 3),    -- 7
    ('Diego Martins Teixeira',  '88899900011', '1990-04-03', 'Inspetor de Qualidade',    4800.00, 3, 1),    -- 8
    ('Larissa Almeida Prado',   '99900011122', '1988-08-16', 'Engenheira de Produto',    9200.00, 4, 1),    -- 9
    ('Thiago Nogueira Reis',    '10120230340', '1993-06-21', 'Projetista Mecânico',      6100.00, 4, 9),    -- 10
    ('Sérgio Pacheco Moura',    '20230340450', '1981-02-11', 'Supervisor de Injeção',    7200.00, 5, NULL), -- 11
    ('Aline Barros Figueiredo', '30340450560', '1999-10-02', 'Operadora de Injetora',    3400.00, 5, 11);   -- 12

INSERT INTO Produto (nome, descricao, categoria, valor) VALUES
    ('Eixo de Transmissão ET-200',  'Eixo usinado em aço SAE 4140 para redutores',     'Componentes Mecânicos',  480.00), -- 1
    ('Flange de Aço Inox FI-50',    'Flange de 2 polegadas em aço inox 304',           'Componentes Mecânicos',  135.50), -- 2
    ('Painel de Controle PC-10',    'Painel elétrico com CLP para linhas de produção', 'Eletroeletrônicos',     2150.00), -- 3
    ('Carcaça Plástica CP-7',       'Carcaça injetada em ABS para motores pequenos',   'Polímeros',               42.90), -- 4
    ('Engrenagem Helicoidal EH-32', 'Engrenagem de 32 dentes com tratamento térmico',  'Componentes Mecânicos',  310.00), -- 5
    ('Suporte Estampado SE-12',     NULL,                                              'Estampados',              18.75), -- 6
    ('Válvula Pneumática VP-3',     'Válvula 5/2 vias com acionamento por solenoide',  'Pneumática',             265.00); -- 7

INSERT INTO Producao (data, quantidade_produzida, turno, codigo_setor) VALUES
    ('2026-09-01',  200, 'Manhã', 1), -- 1
    ('2026-09-01',  360, 'Tarde', 1), -- 2
    ('2026-09-02',   25, 'Manhã', 2), -- 3
    ('2026-09-02', 1500, 'Noite', 5), -- 4
    ('2026-09-03', 2400, 'Manhã', 6), -- 5
    ('2026-09-03',  120, 'Tarde', 2), -- 6
    ('2026-09-04',  350, 'Manhã', 1); -- 7

INSERT INTO Detalhe_Producao (codigo_producao, codigo_produto, quantidade_produto) VALUES
    (1, 1,  120),
    (1, 5,   80),
    (2, 2,  300),
    (2, 5,   60),
    (3, 3,   25),
    (4, 4, 1500),
    (5, 6, 2400),
    (6, 3,   30),
    (6, 7,   90),
    (7, 1,  150),
    (7, 2,  200);

INSERT INTO Projeto (nome, descricao, data_inicio, data_termino, orcamento, codigo_empresa, codigo_produto) VALUES
    ('Linha ET-200 de Alta Precisão',       'Reduzir a tolerância de usinagem do eixo ET-200',    '2025-02-03', '2025-11-28',  850000.00, 1, 1), -- 1
    ('Painel PC-10 Conectado',              'Incluir comunicação em rede e telemetria no painel', '2025-06-02', '2026-05-29', 1200000.00, 1, 3), -- 2
    ('Carcaça CP-7 em Polímero Reciclado',  'Trocar o ABS virgem por material reciclado',         '2025-03-10', '2025-12-19',  320000.00, 3, 4), -- 3
    ('Engrenagem EH-32 Silenciosa',         'Novo perfil de dente para reduzir ruído',            '2026-01-12', '2026-12-18',  540000.00, 1, 5), -- 4
    ('Flange FI-50 para Setor Alimentício', NULL,                                                 '2025-08-04', '2026-03-27',  275000.00, 1, 2); -- 5

INSERT INTO Participacao_Projeto (codigo_empregado, codigo_projeto) VALUES
    (1, 1), (2, 1), (4, 1), (10, 1),
    (1, 2), (8, 2), (9, 2), (10, 2),
    (11, 3), (12, 3),
    (5, 4), (9, 4), (10, 4),
    (8, 5), (9, 5);

-- 3. MANIPULAÇÃO DE DADOS (DML)
UPDATE Empresa
SET telefone = '(35) 3435-5000'
WHERE codigo_empresa = 5;

UPDATE Empregado
SET cargo   = 'Operador de CNC Pleno',
    salario = salario * 1.08
WHERE codigo_empregado = 4;

UPDATE Empregado
SET salario = salario * 1.05
WHERE codigo_setor = 2;

SELECT nome, cargo, salario
FROM Empregado
WHERE salario > 5000
ORDER BY salario DESC;

DELETE FROM Participacao_Projeto
WHERE codigo_empregado = 8
  AND codigo_projeto = 5;

-- 4. CONSULTAS COM JOIN (1:N, 1:1 e N:M)
SELECT e.nome   AS empregado,
       e.cargo,
       s.nome   AS setor,
       emp.nome AS empresa,
       r.nome   AS responsavel
FROM Empregado e
INNER JOIN Setor s     ON s.codigo_setor = e.codigo_setor
INNER JOIN Empresa emp ON emp.codigo_empresa = s.codigo_empresa
LEFT JOIN Empregado r  ON r.codigo_empregado = e.codigo_responsavel
ORDER BY emp.nome, s.nome, e.nome;

SELECT p.nome  AS produto,
       p.categoria,
       p.valor,
       pj.nome AS projeto,
       pj.orcamento
FROM Produto p
LEFT JOIN Projeto pj ON pj.codigo_produto = p.codigo_produto
ORDER BY p.nome;

SELECT pj.nome AS projeto,
       e.nome  AS empregado,
       e.cargo
FROM Participacao_Projeto pp
INNER JOIN Projeto pj  ON pj.codigo_projeto = pp.codigo_projeto
INNER JOIN Empregado e ON e.codigo_empregado = pp.codigo_empregado
ORDER BY pj.nome, e.nome;

SELECT p.nome                              AS produto,
       COUNT(pr.codigo_producao)           AS qtd_producoes,
       SUM(d.quantidade_produto)           AS total_fabricado,
       SUM(d.quantidade_produto * p.valor) AS valor_produzido
FROM Produto p
INNER JOIN Detalhe_Producao d ON d.codigo_produto = p.codigo_produto
INNER JOIN Producao pr        ON pr.codigo_producao = d.codigo_producao
GROUP BY p.codigo_produto, p.nome
ORDER BY valor_produzido DESC;

-- 5. FUNCTION
DELIMITER $$

CREATE FUNCTION valor_producao (p_codigo_producao INT)
RETURNS DECIMAL(14,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(14,2);

    SET total = (SELECT SUM(d.quantidade_produto * p.valor)
                 FROM Detalhe_Producao d
                 INNER JOIN Produto p ON p.codigo_produto = d.codigo_produto
                 WHERE d.codigo_producao = p_codigo_producao);

    RETURN total;
END$$

DELIMITER ;

SELECT codigo_producao,
       data,
       turno,
       valor_producao(codigo_producao) AS valor_total
FROM Producao;

-- 6. VIEWS
CREATE VIEW resumo_producao AS
SELECT pr.codigo_producao,
       pr.data,
       pr.turno,
       s.nome   AS setor,
       emp.nome AS empresa,
       pr.quantidade_produzida,
       valor_producao(pr.codigo_producao) AS valor_total
FROM Producao pr
INNER JOIN Setor s     ON s.codigo_setor = pr.codigo_setor
INNER JOIN Empresa emp ON emp.codigo_empresa = s.codigo_empresa;

CREATE VIEW empregado_publico AS
SELECT e.codigo_empregado,
       e.nome,
       e.cargo,
       s.nome   AS setor,
       emp.nome AS empresa
FROM Empregado e
INNER JOIN Setor s     ON s.codigo_setor = e.codigo_setor
INNER JOIN Empresa emp ON emp.codigo_empresa = s.codigo_empresa;

SELECT * FROM resumo_producao;
SELECT * FROM empregado_publico;

-- 7. TRIGGERS
DELIMITER $$

CREATE TRIGGER detalhe_producao_insert
AFTER INSERT ON Detalhe_Producao
FOR EACH ROW
BEGIN
    UPDATE Producao
    SET quantidade_produzida = (SELECT SUM(quantidade_produto)
                                FROM Detalhe_Producao
                                WHERE codigo_producao = NEW.codigo_producao)
    WHERE codigo_producao = NEW.codigo_producao;
END$$

CREATE TRIGGER detalhe_producao_update
AFTER UPDATE ON Detalhe_Producao
FOR EACH ROW
BEGIN
    UPDATE Producao
    SET quantidade_produzida = (SELECT SUM(quantidade_produto)
                                FROM Detalhe_Producao
                                WHERE codigo_producao = NEW.codigo_producao)
    WHERE codigo_producao = NEW.codigo_producao;
END$$

CREATE TRIGGER detalhe_producao_delete
AFTER DELETE ON Detalhe_Producao
FOR EACH ROW
BEGIN
    UPDATE Producao
    SET quantidade_produzida = (SELECT IFNULL(SUM(quantidade_produto), 0)
                                FROM Detalhe_Producao
                                WHERE codigo_producao = OLD.codigo_producao)
    WHERE codigo_producao = OLD.codigo_producao;
END$$

DELIMITER ;

INSERT INTO Detalhe_Producao (codigo_producao, codigo_produto, quantidade_produto) VALUES (3, 7, 40);

SELECT codigo_producao, quantidade_produzida FROM Producao WHERE codigo_producao = 3;

UPDATE Detalhe_Producao
SET quantidade_produto = 50
WHERE codigo_producao = 3
  AND codigo_produto = 7;

SELECT codigo_producao, quantidade_produzida FROM Producao WHERE codigo_producao = 3;

DELETE FROM Detalhe_Producao
WHERE codigo_producao = 3
  AND codigo_produto = 7;

SELECT codigo_producao, quantidade_produzida FROM Producao WHERE codigo_producao = 3;

-- 8. PROCEDURE
DELIMITER $$

CREATE PROCEDURE registrar_producao (
    IN p_data           DATE,
    IN p_turno          VARCHAR(30),
    IN p_codigo_setor   INT,
    IN p_codigo_produto INT,
    IN p_quantidade     INT
)
BEGIN
    INSERT INTO Producao (data, quantidade_produzida, turno, codigo_setor)
    VALUES (p_data, 0, p_turno, p_codigo_setor);

    INSERT INTO Detalhe_Producao (codigo_producao, codigo_produto, quantidade_produto)
    VALUES (LAST_INSERT_ID(), p_codigo_produto, p_quantidade);
END$$

DELIMITER ;

CALL registrar_producao('2026-09-05', 'Manhã', 1, 1, 100);

SELECT * FROM resumo_producao WHERE data = '2026-09-05';

-- 9. USUÁRIOS E ROLE
DROP USER IF EXISTS'carlos'@'localhost';
DROP USER IF EXISTS 'marina'@'localhost';
DROP ROLE IF EXISTS 'analista_producao';

CREATE ROLE 'analista_producao';

GRANT SELECT ON trabalho_bd.Setor   TO 'analista_producao';
GRANT SELECT ON trabalho_bd.Produto TO 'analista_producao';
GRANT SELECT, INSERT, UPDATE ON trabalho_bd.Producao         TO 'analista_producao';
GRANT SELECT, INSERT, UPDATE ON trabalho_bd.Detalhe_Producao TO 'analista_producao';
GRANT SELECT ON trabalho_bd.resumo_producao   TO 'analista_producao';
GRANT SELECT ON trabalho_bd.empregado_publico TO 'analista_producao';
GRANT EXECUTE ON PROCEDURE trabalho_bd.registrar_producao TO 'analista_producao';

CREATE USER 'carlos'@'localhost' IDENTIFIED BY 'Carlos@2026';
CREATE USER 'marina'@'localhost' IDENTIFIED BY 'Marina@2026';

GRANT 'analista_producao' TO 'carlos'@'localhost', 'marina'@'localhost';

SET DEFAULT ROLE 'analista_producao' TO 'carlos'@'localhost', 'marina'@'localhost';

SHOW GRANTS FOR 'analista_producao';
SHOW GRANTS FOR 'carlos'@'localhost';
SHOW GRANTS FOR 'marina'@'localhost';

-- Para testar, conecte como carlos (senha Carlos@2026) e executar:
SELECT * FROM trabalho_bd.resumo_producao;      -- permitido
SELECT * FROM trabalho_bd.empregado_publico;    -- permitido
SELECT nome, salario FROM trabalho_bd.Empregado;   -- negado