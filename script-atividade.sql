CREATE TABLE motorista(
	codMot integer PRIMARY KEY,
	cpf numeric(11),
	cnh numeric(10),
	nome varchar(50),
	endereco varchar(100)
);

INSERT INTO motorista (codMot, cpf, cnh, nome, endereco) VALUES
(1, 12345678901, 4321000000, 'João', 'Guarabira'),
(2, 98765000000, 9675300000, 'Roberto', 'Pirpirituba'),
(3, 13569000000, 9128300000, 'Pedro', 'Belem');

CREATE TABLE veiculo(
	placa char(7) PRIMARY KEY,
	capacidade integer
);

INSERT INTO veiculo (placa, capacidade) VALUES
('AAA0001', 40),
('BBB0002', 20),
('CCC0003', 15);

CREATE TABLE vendedor(
	codVdd integer PRIMARY KEY,
	cpf numeric(11),
	v_comissao numeric(4,2),
	nome varchar(50),
	endereco varchar(100)
);

INSERT INTO vendedor (codVdd, cpf, v_comissao, nome, endereco) VALUES
(1, 10223456734, 13.00, 'José', 'Aracagi'),
(2, 55552021555, 13.20, 'Maria', 'Mari'),
(3, 55484811514, 22.00, 'Marcos', 'Aracagi');

CREATE TABLE cliente(
	codCli integer PRIMARY KEY,
	nome varchar(50),
	tel char(10),
	endereco varchar(100),
	cpf numeric(11),
	email varchar(50)
);

INSERT INTO cliente (codCli, nome, tel, endereco, cpf, email) VALUES
(12367, 'Aldo', '96543211', 'Contendas', 53200011111, 'santosoliveira@gmail.com'),
(90843, 'José', '91872000', 'Contendas', 53200022222, 'jose.silva@gmail.com'),
(90840, 'Mario', '91918270', 'Guarabira', 19172633333, 'mario@gmail.com');

CREATE TABLE venda(
	numVend integer PRIMARY KEY,
	valor_total numeric(11,2),
	codVdd integer,
	codCli integer,
	FOREIGN KEY (codVdd) REFERENCES vendedor(codVdd),
	FOREIGN KEY (codCli) REFERENCES cliente(codCli)
);

INSERT INTO venda (numVend, valor_total, codVdd, codCli) VALUES
(4565, 960.00, 1, 12367),
(2222, 5678.00, 2, 90843),
(5082, 5778, 3, 90840);

CREATE TABLE produto(
	codPro integer PRIMARY KEY,
	custo numeric(11,2),
	descricao text,
	preco numeric(11,2),
	nome varchar(50)
);

INSERT INTO produto (codPro, custo, descricao, preco, nome) VALUES
(9053, 500.00, 'Descrição do produto 1', 600.00, 'Nome do Produto 1'),
(9054, 350.50, 'Descrição do produto 2', 450.00, 'Nome do Produto 2'),
(9055, 720.75, 'Descrição do produto 3', 850.00, 'Nome do Produto 3');

CREATE TABLE item_venda(
	codPro INTEGER,
	numVen INTEGER,
	vUnitario NUMERIC(11,2),
	qtd INTEGER,
	PRIMARY KEY (codPro, numVen),
	FOREIGN KEY (codPro) REFERENCES produto(codPro),
	FOREIGN KEY (numVen) REFERENCES venda(numVend)
);

INSERT INTO item_venda (codPro, numVen, vUnitario, qtd) VALUES 
(9053, 4565, 10.50, 5),
(9054, 5082, 20.75, 3),
(9055, 2222, 15.20, 8);

CREATE TABLE entrega(
	horaEntrega time,
	dataEntrega date,
	numVen integer,
	placa char(7),
	codMot integer,
	PRIMARY KEY (horaEntrega, dataEntrega),
	FOREIGN KEY (numVen) REFERENCES venda(numVend),
	FOREIGN KEY (placa) REFERENCES veiculo(placa),
	FOREIGN KEY (codMot) REFERENCES motorista(codMot)
);

INSERT INTO entrega (horaEntrega, dataEntrega, numVen, placa, codMot) VALUES
('07:00:00', '2023-02-04', 2222, 'AAA0001', 1),
('05:45:32', '2023-04-15', 4565, 'BBB0002', 2),
('06:30:00', '2023-12-09', 5082, 'CCC0003', 3);

UPDATE produto SET descricao = 'Nova descrição para produto 1' WHERE codPro = 9053;

SELECT * FROM cliente;
SELECT * FROM venda;

SELECT v.nome AS vendedor_nome, c.nome AS cliente_nome, venda.valor_total
FROM venda
JOIN vendedor v ON venda.codVdd = v.codVdd
JOIN cliente c ON venda.codCli = c.codCli;

DELETE FROM item_venda WHERE codPro = 9055;
DELETE FROM produto WHERE codPro = 9055;

CREATE VIEW vendas_clientes AS
SELECT v.numVend, v.valor_total, c.nome AS cliente_nome, c.endereco AS cliente_endereco
FROM venda v
JOIN cliente c ON v.codCli = c.codCli;

SELECT * FROM vendas_clientes;

CREATE OR REPLACE FUNCTION add_cliente(_nome varchar, _tel char(10), _endereco varchar, _cpf numeric(11), _email varchar)
RETURNS void AS $$
BEGIN
    INSERT INTO cliente (nome, tel, endereco, cpf, email) VALUES (_nome, _tel, _endereco, _cpf, _email);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION atualizar_comissao()
RETURNS trigger AS $$
BEGIN
    UPDATE vendedor SET v_comissao = v_comissao + NEW.valor_total * 0.05 WHERE codVdd = NEW.codVdd;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_atualizar_comissao
AFTER INSERT ON venda
FOR EACH ROW EXECUTE FUNCTION atualizar_comissao();
