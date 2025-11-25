<?php
// salvar_agendamento.php
include 'conexao.php';

$nome_paciente = $_POST['nome_paciente'];
$especialidade = $_POST['especialidade'];
$data_consulta = $_POST['data_consulta'];
$medico = $_POST['medico'];

$sql = "INSERT INTO agendamentos (nome_paciente, especialidade, data_consulta, medico)
VALUES ('$nome_paciente', '$especialidade', '$data_consulta', '$medico')";

if ($conn->query($sql) === TRUE) {
    echo "Agendamento realizado com sucesso.";
} else {
    echo "Erro: " . $conn->error;
}

$conn->close();
?>
