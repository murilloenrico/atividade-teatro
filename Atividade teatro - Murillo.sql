Create Schema Teatro;
use teatro;

create table pecas_teatro(
id_peca int auto_increment,
nome_peca varchar(60),
descricao varchar(80),
duracao int,
data_estreia date,
preco decimal(10,2),
constraint id_pecapk primary key (id_peca));


insert into pecas_teatro(nome_peca,descricao,duracao,data_estreia,preco)
Values("Os 3 Veados","Peça para maiores de 14 anos",60,20241020,80);

select * from pecas_teatro;




DELIMITER $$

CREATE FUNCTION calcular_duracao_peca(
    p_id_peca INT
)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_duracao INT;

    -- Seleciona a duração da peça com base no id_peca fornecido
    SELECT duracao INTO v_duracao
    FROM pecas_teatro
    WHERE id_peca = p_id_peca;

    -- Retorna a duração da peça
    RETURN v_duracao;
END$$

DELIMITER ;
SELECT calcular_duracao_peca(2);


DELIMITER $$

CREATE FUNCTION calcular_media_duracao()
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_media_duracao DECIMAL(10,2);

    -- Calcula a média da duração de todas as peças na tabela
    SELECT AVG(duracao) INTO v_media_duracao
    FROM pecas_teatro;

    -- Retorna a média da duração
    RETURN v_media_duracao;
END$$

DELIMITER ;
SELECT calcular_media_duracao();








DELIMITER $$

CREATE FUNCTION verificar_disponibilidade(
    p_data DATE
)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_existe INT;

    -- Conta o número de peças que têm a mesma data de estreia fornecida
    SELECT COUNT(*)
    INTO v_existe
    FROM pecas_teatro
    WHERE DATE(data_estreia) = p_data;

    -- Retorna 0 se houver pelo menos uma peça para a data fornecida, caso contrário, retorna 1
    RETURN CASE
        WHEN v_existe > 0 THEN 0
        ELSE 1
    END;
END$$

DELIMITER ;

SELECT verificar_disponibilidade('2024-10-24');




DELIMITER $$

CREATE PROCEDURE agendar_peca(
    IN p_nome_peca VARCHAR(60),
    IN p_descricao VARCHAR(80),
    IN p_duracao INT,
    IN p_data_estreia DATE,
    IN p_preco DECIMAL(10,2)
)
BEGIN
    DECLARE v_disponibilidade BOOLEAN;
    DECLARE v_media_duracao DECIMAL(10,2);

    -- Verifica a disponibilidade da data
    SET v_disponibilidade = verificar_disponibilidade(p_data_estreia);

    -- Se a data não estiver disponível, interrompe a procedure
    IF v_disponibilidade = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A data fornecida já está ocupada por outra peça.';
    END IF;

    -- Insere a nova peça na tabela pecas_teatro
    INSERT INTO pecas_teatro (nome_peca, descricao, duracao, data_estreia, preco)
    VALUES (p_nome_peca, p_descricao, p_duracao, p_data_estreia, p_preco);

    -- Calcula a média de duração das peças
    SET v_media_duracao = calcular_media_duracao();

    -- Imprime informações sobre a peça agendada e a média de duração
    SELECT 
        CONCAT('Peça agendada com sucesso: ', p_nome_peca) AS Mensagem,
        CONCAT('Média de duração das peças: ', v_media_duracao, ' minutos') AS Media_Duracao;
END$$

DELIMITER ;

CALL agendar_peca(
    'Os 5 bixos do mato',
    'Maiores de 18',
    240,                  -- duração em minutos
    '2024-10-24',         -- data de estreia
    100.00                -- preço
);