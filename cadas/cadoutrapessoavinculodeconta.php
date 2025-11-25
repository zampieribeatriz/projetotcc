<?php
// Define que o script deve parar se houver um erro de execução
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// =================================================================
// 1. CONFIGURAÇÃO DO BANCO DE DADOS
// =================================================================

// ATENÇÃO: Substitua os placeholders abaixo pelas suas credenciais reais do banco de dados!
$servername = "localhost"; // Geralmente 'localhost'
$username = "seu_usuario_db"; // Ex: root
$password = "sua_senha_db"; // Sua senha
$dbname = "nome_do_seu_banco"; // Ex: sus_agendamento

// Nome da tabela que armazenará os dados de vínculo
$table_name = "vinculos_usuario";

// =================================================================
// 2. VERIFICAÇÃO DO MÉTODO E RECEBIMENTO DOS DADOS
// =================================================================

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Coleta e sanitiza os dados recebidos do formulário
    $idcartao = filter_input(INPUT_POST, 'idcartao', FILTER_SANITIZE_NUMBER_INT);
    $nome = filter_input(INPUT_POST, 'nome', FILTER_SANITIZE_STRING);
    $cpf = filter_input(INPUT_POST, 'cpf', FILTER_SANITIZE_STRING);

    // =============================================================
    // 3. VALIDAÇÃO DOS DADOS (Verifica se os campos obrigatórios estão preenchidos)
    // =============================================================

    if (empty($idcartao) || empty($nome) || empty($cpf)) {
        // Redireciona de volta para a página do formulário com uma mensagem de erro
        header("Location: index.html?status=erro_campos");
        exit();
    }

    // Opcional: Aqui você pode adicionar uma validação de CPF mais robusta.

    // Remove formatação do CPF para armazenamento
    $cpf_limpo = preg_replace('/[^0-9]/', '', $cpf);
    
    // Conexão com o banco de dados
    $conn = new mysqli($servername, $username, $password, $dbname);

    // Verifica a conexão
    if ($conn->connect_error) {
        // Em um ambiente real, você não deve mostrar o erro para o usuário
        die("Falha na conexão: " . $conn->connect_error);
    }
    
    // =============================================================
    // 4. PREPARAÇÃO E EXECUÇÃO DA INSERÇÃO (Usando Prepared Statements)
    // =============================================================
    
    // O Prepared Statement previne ataques de SQL Injection
    $stmt = $conn->prepare("INSERT INTO $table_name (id_cartao_sus, nome_completo, cpf) VALUES (?, ?, ?)");
    
    // 's' para string, 'i' para integer. Aqui usamos 'i', 's', 's'
    // Se o ID do Cartão SUS for muito grande e a coluna no DB for VARCHAR, use 's'
    $stmt->bind_param("iss", $idcartao, $nome, $cpf_limpo);
    
    if ($stmt->execute()) {
        // Redireciona em caso de sucesso
        // Você pode redirecionar para uma página de sucesso ou para o painel do usuário
        header("Location: sucesso.html?status=vinculo_ok");
        exit();
    } else {
        // Redireciona em caso de falha na execução
        // Loga o erro, mas não o exibe diretamente para o usuário
        error_log("Erro ao inserir dados: " . $stmt->error);
        header("Location: index.html?status=erro_db");
        exit();
    }

    // Fecha o statement e a conexão
    $stmt->close();
    $conn->close();

} else {
    // Se o acesso não for via POST (ex: alguém tentar acessar o arquivo diretamente pelo navegador)
    header("Location: index.html");
    exit();
}

?>