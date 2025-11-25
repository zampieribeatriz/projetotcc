<?php
/**
 * Arquivo: conexao.php
 * Descrição: Script para estabelecer a conexão com o banco de dados MySQL
 * usando a extensão MySQLi.
 */

// 1. Definição das constantes de conexão
// Por favor, altere estes valores para os dados do seu ambiente
define('DB_SERVER', 'localhost'); // Geralmente 'localhost'
define('DB_USERNAME', 'root'); // Seu nome de usuário do banco de dados (ex: root)
define('DB_PASSWORD', '2025&dev'); // Sua senha do banco de dados
define('DB_NAME', 'saude_app'); // ALTERADO: Novo nome do banco de dados

// 2. Cria a conexão
$conexao = new mysqli(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_NAME);

// 3. Verifica a conexão
if ($conexao->connect_error) {
    // Se houver erro, exibe uma mensagem e interrompe a execução
    die("Erro de conexão com o banco de dados: " . $conexao->connect_error);
}

// 4. Define o conjunto de caracteres para UTF-8 (importante para acentos)
if (!$conexao->set_charset("utf8")) {
    printf("Erro ao carregar conjunto de caracteres utf8: %s\n", $conexao->error);
    exit();
}

// Se a conexão for bem-sucedida, a variável $conexao estará disponível para outros scripts.
?>
