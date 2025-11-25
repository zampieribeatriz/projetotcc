<?php
require_once 'cadastro1conexao.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    // 3. Define as variáveis e inicializa com NULL
    $idcartao = $cpf = $nome = $celular = $email = $senha_bruta = $confirmarEmail = $confirmarSenha = null;
    $logradouro = $numero = $complemento = $bairro = $cidade = $estado = $cep = null;
    $errors = []; 

    // 4. Recebe os dados e filtra/valida

    // Dados Pessoais
    $idcartao = filter_input(INPUT_POST, 'idcartao', FILTER_SANITIZE_STRING);
    // Limpando CPF e Celular (mantendo apenas números)
    $cpf = preg_replace('/[^0-9]/', '', $_POST['cpf']); 
    $nome = trim(htmlspecialchars($_POST['nome'])); 
    $celular = preg_replace('/[^0-9]/', '', $_POST['celular']);

    // E-mail e Confirmação
    $email = filter_input(INPUT_POST, 'email', FILTER_VALIDATE_EMAIL);
    $confirmarEmail = filter_input(INPUT_POST, 'confirmarEmail', FILTER_VALIDATE_EMAIL);
    
    // Senha e Confirmação
    $senha_bruta = $_POST['senha'] ?? ''; 
    $confirmarSenha = $_POST['confirmarSenha'] ?? '';

    // Dados de Endereço
    $logradouro = trim(htmlspecialchars($_POST['logradouro']));
    $numero = filter_input(INPUT_POST, 'numero', FILTER_SANITIZE_STRING); // Número pode ser string (ex: 120-A)
    $complemento = trim(htmlspecialchars($_POST['complemento'])); // Opcional
    $bairro = trim(htmlspecialchars($_POST['bairro']));
    $cidade = trim(htmlspecialchars($_POST['cidade']));
    $estado = filter_input(INPUT_POST, 'estado', FILTER_SANITIZE_STRING); // UF
    $cep = preg_replace('/[^0-9]/', '', $_POST['cep']); // Limpando CEP (mantendo apenas números)

    // Validação de campos obrigatórios
    if (!$idcartao) $errors[] = "ID Cartão SUS inválido.";
    if (strlen($cpf) != 11) $errors[] = "CPF inválido (deve ter 11 dígitos).";
    if (empty($nome)) $errors[] = "Nome completo é obrigatório.";
    if (empty($celular)) $errors[] = "Celular é obrigatório.";
    if ($email === false) $errors[] = "E-mail inválido.";
    if ($email !== $confirmarEmail) $errors[] = "E-mails não coincidem.";
    if (empty($senha_bruta) || empty($confirmarSenha)) $errors[] = "As senhas são obrigatórias.";
    if ($senha_bruta !== $confirmarSenha) $errors[] = "As senhas não coincidem.";
    if (strlen($senha_bruta) < 6) $errors[] = "A senha deve ter pelo menos 6 caracteres.";
    
    // Validação de Endereço
    if (empty($logradouro)) $errors[] = "Logradouro é obrigatório.";
    if (empty($numero)) $errors[] = "Número é obrigatório.";
    if (empty($bairro)) $errors[] = "Bairro é obrigatório.";
    if (empty($cidade)) $errors[] = "Cidade é obrigatória.";
    if (strlen($estado) != 2) $errors[] = "Estado (UF) deve ter 2 caracteres.";
    if (strlen($cep) != 8) $errors[] = "CEP inválido (deve ter 8 dígitos).";

    // 5. Verifica se há erros de validação
    if (empty($errors)) {
        
        // 6. 🔐 Hash seguro da senha
        $senha_hash = password_hash($senha_bruta, PASSWORD_DEFAULT); 

        // 7. Inicia a transação
        $conexao->begin_transaction();
        $success = true;
        
        // --- 7.1. Inserir na tabela USUARIO ---
        $sql_usuario = "INSERT INTO usuario (email, senha_hash) VALUES (?, ?)";
        if ($stmt_usuario = $conexao->prepare($sql_usuario)) {
            $stmt_usuario->bind_param("ss", $email, $senha_hash);
            
            if (!$stmt_usuario->execute()) {
                // Erro comum: Email duplicado
                if ($conexao->errno == 1062) {
                    $errors[] = "Este e-mail já está cadastrado.";
                } else {
                    $errors[] = "Erro ao inserir login do usuário: " . $stmt_usuario->error;
                }
                $success = false;
            } else {
                $id_usuario = $conexao->insert_id;
            }
            $stmt_usuario->close();
        } else {
            $errors[] = "Erro de preparação SQL (Usuário): " . $conexao->error;
            $success = false;
        }

        // --- 7.2. Inserir na tabela PACIENTE (agora com o endereço) ---
        if ($success) {
            $sql_paciente = "INSERT INTO paciente 
                (id_usuario, id_cartao_sus, cpf, nome_completo, celular, logradouro, numero, complemento, bairro, cidade, estado, cep) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            
            if ($stmt_paciente = $conexao->prepare($sql_paciente)) {
                
                // Tipos: i (integer para id_usuario), s...s (11 strings para os outros 11 campos)
                $stmt_paciente->bind_param("isssssssssss", 
                    $id_usuario, $idcartao, $cpf, $nome, $celular, 
                    $logradouro, $numero, $complemento, $bairro, $cidade, $estado, $cep
                );
                
                if (!$stmt_paciente->execute()) {
                    // Erro comum: CPF ou Cartão SUS duplicado (UNIQUE)
                    if ($conexao->errno == 1062) {
                        $errors[] = "O CPF ou ID Cartão SUS já está em uso.";
                    } else {
                        $errors[] = "Erro ao inserir dados do paciente: " . $stmt_paciente->error;
                    }
                    $success = false;
                }
                $stmt_paciente->close();
            } else {
                $errors[] = "Erro de preparação SQL (Paciente): " . $conexao->error;
                $success = false;
            }
        }
        
        // 8. Commit ou Rollback da transação
        if ($success && empty($errors)) {
            $conexao->commit();
            echo "
                <div class='container' style='max-width: 400px; text-align: center; margin-top: 100px;'>
                    <p style='color: green; font-weight: bold;'>Cadastro realizado com sucesso! ✅</p>
                    <p>Você será redirecionado para a tela de login em 3 segundos.</p>
                </div>
            ";
            // Redirecionamento após 3 segundos
            header("refresh:3; url=login.html"); 
            
        } else {
            $conexao->rollback();
            echo "
                <div class='container' style='max-width: 400px; margin-top: 100px;'>
                    <h3 style='color: red;'>❌ Falha no cadastro.</h3>
                    <p>Erros encontrados:</p>
                    <ul>";
            foreach ($errors as $error) {
                echo "<li>" . $error . "</li>";
            }
            echo "</ul></div>";
        }

    } else {
        // Exibe os erros de validação inicial
        echo "
            <div class='container' style='max-width: 400px; margin-top: 100px;'>
                <h3 style='color: red;'>❌ Erros de Validação.</h3>
                <p>Corrija os campos a seguir:</p>
                <ul>";
        foreach ($errors as $error) {
            echo "<li>" . $error . "</li>";
        }
        echo "</ul></div>";
    }

    // 9. Fecha a conexão
    // Esta linha deve estar fora do bloco if (para não fechar se a conexão estiver no topo)
    // Se a sua conexão estiver neste arquivo: $conexao->close();

} else {
    // Acesso direto
    echo "Acesso inválido. O formulário deve ser submetido via POST.";
}
?>