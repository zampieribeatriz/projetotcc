
-- -----------------------------------------------------
-- SCRIPT SQL CORRIGIDO - SAUDE APP
-- Removidas as tabelas e referências de MEDICAMENTO e DISTRIBUICAO_MEDICAMENTOS.
-- Corrigido o bloco de inserção de ESPECIALIDADE e a restrição CHECK na tabela ENDERECO.
-- -----------------------------------------------------

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema saude_app
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `saude_app` DEFAULT CHARACTER SET utf8mb4 ;
USE `saude_app` ;

-- -----------------------------------------------------
-- Tabela USUARIO (Entidade de Autenticação)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `saude_app`.`USUARIO` (
  `idusuario` INT NOT NULL AUTO_INCREMENT,
  `login` VARCHAR(100) NOT NULL UNIQUE COMMENT 'Pode ser email ou CPF',
  `senha_hash` CHAR(60) NOT NULL COMMENT 'Armazenar hash da senha, nunca a senha em texto puro',
  `tipo_usuario` ENUM('PACIENTE', 'PROFISSIONAL') NOT NULL,
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`idusuario`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Tabela PACIENTE (Detalhes do Usuário Paciente)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `saude_app`.`PACIENTE` (
  `idpaciente` INT NOT NULL AUTO_INCREMENT,
  `idusuario` INT NOT NULL UNIQUE COMMENT 'FK 1:1 para USUARIO',
  `nome` VARCHAR(150) NOT NULL,
  `cpf` CHAR(11) UNIQUE NULL,
  `idcartao` CHAR(15) NULL COMMENT 'Número do Cartão de Saúde, se houver',
  `telefone` VARCHAR(20) NULL,
  `email` VARCHAR(100) NULL,
  PRIMARY KEY (`idpaciente`),
  INDEX `fk_paciente_usuario_idx` (`idusuario` ASC) VISIBLE,
  CONSTRAINT `fk_paciente_usuario`
    FOREIGN KEY (`idusuario`)
    REFERENCES `saude_app`.`USUARIO` (`idusuario`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


ALTER TABLE PACIENTE
ADD COLUMN logradouro VARCHAR(255) NULL,
ADD COLUMN numero VARCHAR(20) NULL,
ADD COLUMN complemento VARCHAR(100) NULL,
ADD COLUMN bairro VARCHAR(100) NULL,
ADD COLUMN cidade VARCHAR(100) NULL,
ADD COLUMN estado CHAR(2) NULL,
ADD COLUMN cep CHAR(8) NULL;


CREATE TABLE IF NOT EXISTS `saude_app`.`VINCULO_PACIENTE` (
  `idvinculo` INT NOT NULL AUTO_INCREMENT,
  `idpaciente_principal` INT NOT NULL COMMENT 'FK para o PACIENTE logado que gerencia a conta',
  `idpaciente_vinculado` INT NOT NULL UNIQUE COMMENT 'FK para o PACIENTE dependente/vinculado',
  `tipo_relacao` ENUM('FILHO', 'CONJUGE', 'PAI_MAE', 'OUTRO') NULL,
  `data_vinculo` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`idvinculo`),
  CONSTRAINT `fk_vinculo_paciente_principal`
    FOREIGN KEY (`idpaciente_principal`)
    REFERENCES `saude_app`.`PACIENTE` (`idpaciente`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_vinculo_paciente_vinculado`
    FOREIGN KEY (`idpaciente_vinculado`)
    REFERENCES `saude_app`.`PACIENTE` (`idpaciente`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) 
ENGINE = InnoDB;
select * from vinculo_paciente;

-- -----------------------------------------------------
-- Tabela PROFISSIONAL (Detalhes do Usuário Profissional)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `saude_app`.`PROFISSIONAL` (
  `idprofissional` INT NOT NULL AUTO_INCREMENT,
  `idusuario` INT NOT NULL UNIQUE COMMENT 'FK 1:1 para USUARIO',
  `nome` VARCHAR(150) NOT NULL,
  `registro_conselho` VARCHAR(45) UNIQUE NOT NULL COMMENT 'CRM, COREN, etc.',
  PRIMARY KEY (`idprofissional`),
  INDEX `fk_profissional_usuario_idx` (`idusuario` ASC) VISIBLE,
  CONSTRAINT `fk_profissional_usuario`
    FOREIGN KEY (`idusuario`)
    REFERENCES `saude_app`.`USUARIO` (`idusuario`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Tabela UNIDADE_SAUDE
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `saude_app`.`UNIDADE_SAUDE` (
  `idunidade` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(150) NOT NULL,
  `telefone` VARCHAR(20) NULL,
  PRIMARY KEY (`idunidade`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Tabela ENDERECO (Para Paciente ou Unidade de Saúde)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `saude_app`.`ENDERECO` (
  `idendereco` INT NOT NULL AUTO_INCREMENT,
  `idpaciente` INT NULL COMMENT 'FK para PACIENTE (se for endereço do paciente)',
  `idunidade` INT NULL COMMENT 'FK para UNIDADE_SAUDE (se for endereço da unidade)',
  `logradouro` VARCHAR(100) NOT NULL,
  `numero` VARCHAR(10) NOT NULL,
  `complemento` VARCHAR(50) NULL,
  `bairro` VARCHAR(50) NOT NULL,
  `cidade` VARCHAR(50) NOT NULL,
  `estado` CHAR(2) NOT NULL,
  `cep` CHAR(8) NOT NULL,
  PRIMARY KEY (`idendereco`),
  INDEX `fk_endereco_paciente1_idx` (`idpaciente` ASC) VISIBLE,
  INDEX `fk_endereco_unidade_saude1_idx` (`idunidade` ASC) VISIBLE,
  -- A restrição CHECK (ck_endereco_owner) foi removida devido ao erro 3823 do MySQL com ON DELETE CASCADE.
  -- A lógica de exclusividade deve ser aplicada no nível da aplicação.
  CONSTRAINT `fk_endereco_paciente1`
    FOREIGN KEY (`idpaciente`)
    REFERENCES `saude_app`.`PACIENTE` (`idpaciente`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_endereco_unidade_saude1`
    FOREIGN KEY (`idunidade`)
    REFERENCES `saude_app`.`UNIDADE_SAUDE` (`idunidade`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Tabela ESPECIALIDADE
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `saude_app`.`ESPECIALIDADE` (
  `idespecialidade` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(100) NOT NULL UNIQUE,
  PRIMARY KEY (`idespecialidade`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Tabela PROFISSIONAL_ESPECIALIDADE (N:N)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `saude_app`.`PROFISSIONAL_ESPECIALIDADE` (
  `idprofissional` INT NOT NULL,
  `idespecialidade` INT NOT NULL,
  PRIMARY KEY (`idprofissional`, `idespecialidade`),
  INDEX `fk_prof_has_esp_especialidade1_idx` (`idespecialidade` ASC) VISIBLE,
  CONSTRAINT `fk_prof_has_esp_profissional1`
    FOREIGN KEY (`idprofissional`)
    REFERENCES `saude_app`.`PROFISSIONAL` (`idprofissional`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_prof_has_esp_especialidade1`
    FOREIGN KEY (`idespecialidade`)
    REFERENCES `saude_app`.`ESPECIALIDADE` (`idespecialidade`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Tabela CONSULTA
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `saude_app`.`CONSULTA` (
  `idconsulta` INT NOT NULL AUTO_INCREMENT,
  `idpaciente` INT NOT NULL,
  `idprofissional` INT NULL COMMENT 'Pode ser NULL se a consulta ainda não foi atribuída',
  `data_hora_agendada` DATETIME NOT NULL,
  `motivo` VARCHAR(255) NULL,
  `observacoes` TEXT NULL COMMENT 'Registro do profissional sobre o atendimento',
  `status` ENUM('AGENDADA', 'REALIZADA', 'CANCELADA') NOT NULL DEFAULT 'AGENDADA',
  PRIMARY KEY (`idconsulta`),
  INDEX `fk_consulta_paciente1_idx` (`idpaciente` ASC) VISIBLE,
  INDEX `fk_consulta_profissional1_idx` (`idprofissional` ASC) VISIBLE,
  CONSTRAINT `fk_consulta_paciente1`
    FOREIGN KEY (`idpaciente`)
    REFERENCES `saude_app`.`PACIENTE` (`idpaciente`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_consulta_profissional1`
    FOREIGN KEY (`idprofissional`)
    REFERENCES `saude_app`.`PROFISSIONAL` (`idprofissional`)
    ON DELETE SET NULL
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Tabela CHAT
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `saude_app`.`CHAT` (
  `idmensagem` INT NOT NULL AUTO_INCREMENT,
  `idpaciente` INT NOT NULL,
  `idprofissional` INT NULL COMMENT 'Pode ser NULL se o chat for de suporte/chatbot',
  `idremetente` INT NOT NULL COMMENT 'FK para USUARIO, indicando quem enviou a mensagem',
  `mensagem` TEXT NOT NULL,
  `data_hora` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `consulta_idconsulta` INT NULL COMMENT 'Contexto: Se a mensagem se refere a uma consulta específica',
  PRIMARY KEY (`idmensagem`),
  INDEX `fk_chat_paciente1_idx` (`idpaciente` ASC) VISIBLE,
  INDEX `fk_chat_profissional1_idx` (`idprofissional` ASC) VISIBLE,
  INDEX `fk_chat_remetente1_idx` (`idremetente` ASC) VISIBLE,
  INDEX `fk_chat_consulta1_idx` (`consulta_idconsulta` ASC) VISIBLE,
  CONSTRAINT `fk_chat_paciente1`
    FOREIGN KEY (`idpaciente`)
    REFERENCES `saude_app`.`PACIENTE` (`idpaciente`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_chat_profissional1`
    FOREIGN KEY (`idprofissional`)
    REFERENCES `saude_app`.`PROFISSIONAL` (`idprofissional`)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT `fk_chat_remetente1`
    FOREIGN KEY (`idremetente`)
    REFERENCES `saude_app`.`USUARIO` (`idusuario`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_chat_consulta1`
    FOREIGN KEY (`consulta_idconsulta`)
    REFERENCES `saude_app`.`CONSULTA` (`idconsulta`)
    ON DELETE SET NULL
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Tabela VACINA
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `saude_app`.`VACINA` (
  `idvacina` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(100) NOT NULL UNIQUE,
  `fabricante` VARCHAR(100) NULL,
  PRIMARY KEY (`idvacina`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Tabela REGISTRO_VACINA
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `saude_app`.`REGISTRO_VACINA` (
  `idregistro_vacina` INT NOT NULL AUTO_INCREMENT,
  `idpaciente` INT NOT NULL,
  `idvacina` INT NOT NULL,
  `idprofissional_aplicacao` INT NULL COMMENT 'FK para PROFISSIONAL que aplicou a vacina',
  `data_aplicacao` DATE NOT NULL,
  `dose` VARCHAR(45) NULL COMMENT 'Ex: 1ª Dose, Reforço',
  `lote` VARCHAR(45) NULL,
  PRIMARY KEY (`idregistro_vacina`),
  INDEX `fk_registro_paciente1_idx` (`idpaciente` ASC) VISIBLE,
  INDEX `fk_registro_vacina1_idx` (`idvacina` ASC) VISIBLE,
  INDEX `fk_registro_profissional1_idx` (`idprofissional_aplicacao` ASC) VISIBLE,
  CONSTRAINT `fk_registro_paciente1`
    FOREIGN KEY (`idpaciente`)
    REFERENCES `saude_app`.`PACIENTE` (`idpaciente`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_registro_vacina1`
    FOREIGN KEY (`idvacina`)
    REFERENCES `saude_app`.`VACINA` (`idvacina`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_registro_profissional1`
    FOREIGN KEY (`idprofissional_aplicacao`)
    REFERENCES `saude_app`.`PROFISSIONAL` (`idprofissional`)
    ON DELETE SET NULL
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Tabela EXAME_PREVISTO
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `saude_app`.`EXAME_PREVISTO` (
  `idexame_prev` INT NOT NULL AUTO_INCREMENT,
  `idpaciente` INT NOT NULL,
  `tipo_exame` VARCHAR(100) NOT NULL,
  `data_prevista` DATE NOT NULL,
  `data_realizacao` DATE NULL,
  `local` VARCHAR(100) NULL,
  `status` ENUM('PENDENTE', 'REALIZADO', 'CANCELADO') NOT NULL DEFAULT 'PENDENTE',
  PRIMARY KEY (`idexame_prev`),
  INDEX `fk_exame_prev_paciente1_idx` (`idpaciente` ASC) VISIBLE,
  CONSTRAINT `fk_exame_prev_paciente1`
    FOREIGN KEY (`idpaciente`)
    REFERENCES `saude_app`.`PACIENTE` (`idpaciente`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Tabela ALERTA
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `saude_app`.`ALERTA` (
  `idalerta` INT NOT NULL AUTO_INCREMENT,
  `idpaciente` INT NOT NULL,
  `tipo_alerta` ENUM('EXAME', 'CONSULTA', 'GERAL') NOT NULL,
  `mensagem` VARCHAR(255) NOT NULL,
  `data_hora_agendada` DATETIME NOT NULL,
  `data_envio` DATETIME NULL,
  `meio_envio` ENUM('APP', 'EMAIL', 'SMS') NULL,
  `status` ENUM('AGENDADO', 'ENVIADO', 'FALHOU') NOT NULL DEFAULT 'AGENDADO',
  PRIMARY KEY (`idalerta`),
  INDEX `fk_alerta_paciente1_idx` (`idpaciente` ASC) VISIBLE,
  CONSTRAINT `fk_alerta_paciente1`
    FOREIGN KEY (`idpaciente`)
    REFERENCES `saude_app`.`PACIENTE` (`idpaciente`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Tabela ALERTA_EXAME (Mantida, para ligar ALERTA a EXAME_PREVISTO)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `saude_app`.`ALERTA_EXAME` (
  `idalerta` INT NOT NULL,
  `idexame_prev` INT NOT NULL,
  PRIMARY KEY (`idalerta`),
  UNIQUE INDEX `fk_alerta_exame_exame_prev1_idx` (`idexame_prev` ASC) VISIBLE,
  CONSTRAINT `fk_alerta_exame_alerta1`
    FOREIGN KEY (`idalerta`)
    REFERENCES `saude_app`.`ALERTA` (`idalerta`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_alerta_exame_exame_prev1`
    FOREIGN KEY (`idexame_prev`)
    REFERENCES `saude_app`.`EXAME_PREVISTO` (`idexame_prev`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;


-- -----------------------------------------------------
-- Script de Inserção de Dados Fictícios (DML) - Adaptado
-- -----------------------------------------------------

USE `saude_app`;

SET @PASSWORD_HASH = '$2a$10$wT8hP7yZ9hB1t2v3c4d5eF6gH7iJ0kL/mN.oPqR.sT.uV/wX.yZ.';

-- -----------------------------------------------------
-- 1. USUARIO
-- -----------------------------------------------------
INSERT INTO `USUARIO` (`login`, `senha_hash`, `tipo_usuario`) VALUES
('ana.silva@email.com', 12345, 'PACIENTE'),
('breno.souza@email.com', 154321, 'PACIENTE'),
('carlos.gomes@email.com', 54321, 'PACIENTE'),
('daniel.pereira@email.com', 54321, 'PACIENTE'),
('dra.maria@saudeapp.com', 12345, 'PROFISSIONAL'),
('dr.joao@saudeapp.com', 12345, 'PROFISSIONAL'),
('dr.rodrigo@saudeapp.com',12345, 'PROFISSIONAL'),
('dra.fernanda@saudeapp.com', 54321, 'PROFISSIONAL');

-- -----------------------------------------------------
-- 2. PACIENTE
-- -----------------------------------------------------
INSERT INTO `PACIENTE` (`idusuario`, `nome`, `cpf`, `idcartao`, `telefone`, `email`) VALUES
(1, 'Ana Clara Silva', '11122233344', '1001001001', '31998887777', 'ana.silva@email.com'), -- idpaciente = 1
(2, 'Breno Souza Lima', '55566677788', '1001001002', '11995554444', 'breno.souza@email.com'), -- idpaciente = 2
(3, 'Carlos Eduardo Gomes', '99988877766', NULL, '21991112222', 'carlos.gomes@email.com'), -- idpaciente = 3
(4, 'Daniela Ferreira Pereira', '33344455566', '1001001004', '61992223333', 'daniel.pereira@email.com'); -- idpaciente = 4

-- -----------------------------------------------------
-- 3. PROFISSIONAL
-- -----------------------------------------------------
INSERT INTO `PROFISSIONAL` (`idusuario`, `nome`, `registro_conselho`) VALUES
(5, 'Dra. Maria Fernanda Santos', 'CRM/SP 123456'), -- idprofissional = 1
(6, 'Dr. João Victor Almeida', 'CRM/RJ 789012'), -- idprofissional = 2
(7, 'Dr. Rodrigo Torres', 'CRM/MG 345678'), -- idprofissional = 3
(8, 'Dra. Fernanda Costa', 'CRM/PR 901234'); -- idprofissional = 4

-- -----------------------------------------------------
-- 4. ESPECIALIDADE (Alterado "Dermatologia" para "Dermatologista")
-- -----------------------------------------------------
INSERT INTO `ESPECIALIDADE` (`nome`) VALUES
('Clínica Médica'), -- idespecialidade = 1
('Cardiologia'),    -- idespecialidade = 2
('Dermatologista'), -- idespecialidade = 3
('Ginecologia e Obstetrícia'), -- idespecialidade = 4
('Pediatria'),      -- idespecialidade = 5
('Oftalmologia'),   -- idespecialidade = 6
('Ortopedia e Traumatologia'), -- idespecialidade = 7
('Neurologia'),     -- idespecialidade = 8
('Psiquiatria'),    -- idespecialidade = 9
('Urologia'),       -- idespecialidade = 10
('Gastroenterologia'), -- idespecialidade = 11
('Endocrinologia e Metabologia'), -- idespecialidade = 12
('Otorrinolaringologia'), -- idespecialidade = 13
('Pneumologia'),    -- idespecialidade = 14
('Nefrologia'),     -- idespecialidade = 15
('Reumatologia'),   -- idespecialidade = 16
('Cirurgia Geral'), -- idespecialidade = 17
('Anestesiologia'), -- idespecialidade = 18
('Oncologia'),      -- idespecialidade = 19
('Infectologia');   -- idespecialidade = 20

-- -----------------------------------------------------
-- 5. PROFISSIONAL_ESPECIALIDADE
-- -----------------------------------------------------
INSERT INTO `PROFISSIONAL_ESPECIALIDADE` (`idprofissional`, `idespecialidade`) VALUES
(1, 1), -- Dra. Maria -> Clínica Médica
(1, 2), -- Dra. Maria -> Cardiologia
(2, 5), -- Dr. João -> Pediatria
(2, 20), -- Dr. João -> Infectologia
(3, 11), -- Dr. Rodrigo -> Gastroenterologia
(4, 6); -- Dra. Fernanda -> Oftalmologia

-- -----------------------------------------------------
-- 6. UNIDADE_SAUDE
-- -----------------------------------------------------
INSERT INTO `UNIDADE_SAUDE` (`nome`, `telefone`) VALUES
('Hospital Central de SP', '1120001000'), -- idunidade = 1
('Clínica Integrada Zona Sul', '2130002000'), -- idunidade = 2
('UBS Jardim América - BH', '3135003000'), -- idunidade = 3
('Pronto Atendimento Leste - DF', '6140004000'); -- idunidade = 4

-- -----------------------------------------------------
-- 7. ENDERECO
-- -----------------------------------------------------
INSERT INTO `ENDERECO` (`idpaciente`, `idunidade`, `logradouro`, `numero`, `complemento`, `bairro`, `cidade`, `estado`, `cep`) VALUES
(1, NULL, 'Rua das Flores', '10', 'Apto 101', 'Centro', 'Belo Horizonte', 'MG', '30110001'),
(2, NULL, 'Rua da Consolação', '500', 'Bloco B', 'Consolação', 'São Paulo', 'SP', '01300002'),
(3, NULL, 'Rua Ipanema', '125', NULL, 'Botafogo', 'Rio de Janeiro', 'RJ', '22210003'),
(4, NULL, 'Avenida Brasil', '250', NULL, 'Asa Norte', 'Brasília', 'DF', '70070002'),
(NULL, 1, 'Praça da Sé', '50', 'Bloco A', 'Sé', 'São Paulo', 'SP', '01001003'),
(NULL, 2, 'Rua da Praia', '1200', NULL, 'Copacabana', 'Rio de Janeiro', 'RJ', '22021004'),
(NULL, 3, 'Rua Quinze de Novembro', '20', NULL, 'Jardim América', 'Belo Horizonte', 'MG', '30350005'),
(NULL, 4, 'Quadra 105 Sul', '15', 'Lote C', 'Asa Sul', 'Brasília', 'DF', '70070006');

-- -----------------------------------------------------
-- 8. VACINA
-- -----------------------------------------------------
INSERT INTO `VACINA` (`nome`, `fabricante`) VALUES
('COVID-19 - Bivalente', 'Pfizer'), -- idvacina = 1
('Influenza Quadrivalente', 'Sanofi'), -- idvacina = 2
('Sarampo, Caxumba, Rubéola (SCR)', 'MSD'), -- idvacina = 3
('Febre Amarela', 'Bio-Manguinhos'); -- idvacina = 4

-- -----------------------------------------------------
-- 9. REGISTRO_VACINA
-- -----------------------------------------------------
INSERT INTO `REGISTRO_VACINA` (`idpaciente`, `idvacina`, `idprofissional_aplicacao`, `data_aplicacao`, `dose`, `lote`) VALUES
(1, 1, 1, '2023-11-01', 'Reforço', 'LOTE2023X'), -- Ana - Aplicado por Dra. Maria
(1, 2, 4, '2024-03-15', 'Única', 'LOTE2024A'), -- Ana - Aplicado por Dra. Fernanda
(2, 3, 2, '2005-05-10', 'Dose Única', 'LOTE2005Z'), -- Breno - Aplicado por Dr. João
(3, 1, 3, '2023-01-20', 'Dose Inicial', 'LOTE2022C'), -- Carlos - Aplicado por Dr. Rodrigo
(4, 1, 1, '2023-10-20', 'Reforço', 'LOTE2023Y'), -- Daniela - Aplicado por Dra. Maria
(4, 4, 2, '2020-08-05', 'Dose Única', 'LOTE2020F'); -- Daniela - Aplicado por Dr. João

-- -----------------------------------------------------
-- 10. EXAME_PREVISTO
-- -----------------------------------------------------
INSERT INTO `EXAME_PREVISTO` (`idpaciente`, `tipo_exame`, `data_prevista`, `data_realizacao`, `local`, `status`) VALUES
(3, 'Hemograma Completo', '2024-12-10', NULL, 'Hospital Central de SP', 'PENDENTE'), -- idexame_prev = 1 (Carlos)
(1, 'Eletrocardiograma', '2024-01-20', '2024-01-20', 'Clínica Integrada Zona Sul', 'REALIZADO'), -- idexame_prev = 2 (Ana)
(2, 'Raio-X de Tórax', '2024-06-01', '2024-06-01', 'UBS Jardim América - BH', 'REALIZADO'), -- idexame_prev = 3 (Breno)
(4, 'Ultrassonografia Abdominal', '2024-11-25', NULL, 'Pronto Atendimento Leste - DF', 'PENDENTE'); -- idexame_prev = 4 (Daniela)

-- -----------------------------------------------------
-- 11. CONSULTA
-- -----------------------------------------------------
INSERT INTO `CONSULTA` (`idpaciente`, `idprofissional`, `data_hora_agendada`, `motivo`, `observacoes`, `status`) VALUES
(1, 1, NOW() + INTERVAL 1 DAY, 'Avaliação de check-up anual', 'Paciente com histórico de pressão controlada. Solicitar exames de rotina.', 'AGENDADA'), -- idconsulta = 1 (Ana com Dra. Maria)
(2, 2, NOW() - INTERVAL 1 WEEK, 'Febre e tosse persistente', 'Diagnóstico de virose. Prescrito repouso e sintomáticos.', 'REALIZADA'), -- idconsulta = 2 (Breno com Dr. João)
(3, NULL, NOW() + INTERVAL 2 DAY, 'Dor abdominal intensa', NULL, 'AGENDADA'), -- idconsulta = 3 (Carlos - triagem/sem médico atribuído)
(4, 3, NOW() + INTERVAL 5 DAY, 'Queixa de azia constante e má digestão', NULL, 'AGENDADA'); -- idconsulta = 4 (Daniela com Dr. Rodrigo)

-- -----------------------------------------------------
-- 12. ALERTA
-- -----------------------------------------------------
INSERT INTO `ALERTA` (`idpaciente`, `tipo_alerta`, `mensagem`, `data_hora_agendada`, `meio_envio`, `status`) VALUES
(3, 'EXAME', 'Lembrete: Você tem um Hemograma Completo agendado.', NOW() + INTERVAL 1 HOUR, 'APP', 'AGENDADO'), -- idalerta = 1 (Para Carlos - Exame 1)
(1, 'CONSULTA', 'Lembrete de consulta com Dra. Maria amanhã.', NOW() + INTERVAL 2 HOUR, 'EMAIL', 'AGENDADO'), -- idalerta = 2 (Para Ana - Consulta 1)
(4, 'CONSULTA', 'Lembrete: Consulta com Dr. Rodrigo em 5 dias.', NOW() + INTERVAL 3 HOUR, 'SMS', 'AGENDADO'), -- idalerta = 3 (Para Daniela - Consulta 4)
(4, 'EXAME', 'Lembrete: Ultrassonografia agendada para dia 25/11.', NOW() + INTERVAL 4 HOUR, 'APP', 'AGENDADO'); -- idalerta = 4 (Para Daniela - Exame 4)

-- -----------------------------------------------------
-- 13. ALERTA_EXAME
-- -----------------------------------------------------
INSERT INTO `ALERTA_EXAME` (`idalerta`, `idexame_prev`) VALUES
(1, 1), -- Liga Alerta 1 ao Exame Previsto 1 (Carlos)
(4, 4); -- Liga Alerta 4 ao Exame Previsto 4 (Daniela)


select * from paciente;
