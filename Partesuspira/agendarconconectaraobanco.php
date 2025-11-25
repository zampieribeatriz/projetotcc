<?php
// conexao.php
$host = 'localhost';
$user = 'root';
$pass = '2025&dev';
$dbname = 'agendamentos';

$conn = new mysqli($host, $user, $pass, $dbname);

if ($conn->connect_error) {
    die("Erro na conexão: " . $conn->connect_error);
}
?>
