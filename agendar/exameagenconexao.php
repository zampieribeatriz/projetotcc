<?php
$host = "localhost"; // Servidor do banco de dados
$dbname = "sistema_sus"; // Nome do banco de dados
$username = "root"; // Usuário do banco de dados
$password = ""; // Senha do banco de dados

try {
    // Conexão com o banco de dados usando PDO
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    // Definindo o modo de erro do PDO para exceção
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    echo "Erro na conexão: " . $e->getMessage();
}
?>
