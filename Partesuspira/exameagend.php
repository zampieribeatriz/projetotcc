<?php
// Configuração do Banco de Dados - **ATENÇÃO: SUBSTITUA COM SUAS CREDENCIAIS REAIS**
$servername = "localhost";
$username = "seu_usuario_db"; 
$password = "sua_senha_db"; 
$dbname = "sus_agendamento"; 

// Tabela que armazena o histórico de agendamentos
$table_name = "agendamentos"; 

// =================================================================
// 1. CONEXÃO COM O BANCO DE DADOS
// =================================================================

// Cria a conexão
$conn = new mysqli($servername, $username, $password, $dbname);

// Verifica a conexão
if ($conn->connect_error) {
    // Em produção, você logaria o erro e mostraria uma mensagem amigável
    $status_conexao = "Falha na Conexão com o Banco de Dados: " . $conn->connect_error;
    $status_cor = "red";
    $historico = []; // Sem dados em caso de falha de conexão
} else {
    // Conexão bem-sucedida
    $conn->set_charset("utf8");
    $status_conexao = "Conexão com o Banco de Dados bem-sucedida!";
    $status_cor = "green";
    
    // =================================================================
    // 2. FUNÇÃO PARA BUSCAR O HISTÓRICO DE AGENDAMENTOS
    // =================================================================

    /**
     * Busca o histórico de agendamentos do usuário no banco de dados.
     * Em um cenário real, esta função usaria o ID do usuário logado.
     * @param mysqli $conn A conexão ativa com o banco de dados.
     * @param string $tableName O nome da tabela de agendamentos.
     * @return array Um array de objetos com os resultados.
     */
    function buscarHistoricoAgendamentos($conn, $tableName) {
        // Exemplo de consulta: buscando os 5 agendamentos mais recentes
        $sql = "SELECT medico, tipo_exame, ubs, DATE_FORMAT(data_agendamento, '%d/%m/%Y') AS data FROM $tableName ORDER BY data_agendamento DESC LIMIT 5";
        
        $result = $conn->query($sql);
        $agendamentos = [];

        if ($result && $result->num_rows > 0) {
            while ($row = $result->fetch_object()) {
                $agendamentos[] = $row;
            }
        }
        return $agendamentos;
    }
    
    // Tentativa de buscar os dados
    $historico = [];
    try {
        $historico = buscarHistoricoAgendamentos($conn, $table_name);
    } catch (Exception $e) {
        // Loga o erro, mas continua a execução
        error_log("Erro ao buscar dados: " . $e->getMessage());
        $status_conexao = "Conexão OK, mas houve erro ao buscar dados.";
        $status_cor = "orange";
    }

    // Fecha a conexão com o banco de dados
    $conn->close();
}


// Se a busca falhou ou a conexão falhou, preenche com dados fictícios para demonstração.
if (empty($historico)) {
    $historico[] = (object)['medico' => 'Dr. Ricardo Borges (DADOS FICTÍCIOS)', 'tipo_exame' => 'Urina', 'ubs' => 'UBS Itapark - Mauá SP', 'data' => '11/06/2025'];
    $historico[] = (object)['medico' => 'Dra. Alice Ferreira (DADOS FICTÍCIOS)', 'tipo_exame' => 'Sangue', 'ubs' => 'UBS Vila Magini - Mauá SP', 'data' => '26/06/2025'];
}
?>