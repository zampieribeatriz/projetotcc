<?php
// Arquivo: cadastro1processandooforms.php
session_start(); // Inicia a sessão para armazenar mensagens
require_once 'cadastro1conexao.php'; // Certifique-se de que este caminho está correto

// 1. Garante que só será executado via POST
if ($_SERVER["REQUEST_METHOD"] == "POST") {

    // 2. Define as variáveis e inicializa
    $errors = []; 

    // 3. Recebe os dados e filtra/valida

    // Dados Pessoais e Limpeza
    $idcartao = filter_input(INPUT_POST, 'idcartao', FILTER_SANITIZE_STRING);
    // Remove caracteres não-numéricos do CPF
    $cpf = preg_replace('/[^0-9]/', '', $_POST['cpf'] ?? ''); 
    $nome = trim(htmlspecialchars($_POST['nome'] ?? '')); 
    // Remove caracteres não-numéricos do Celular (Variável $celular será usada na coluna 'telefone' do banco)
    $celular = preg_replace('/[^0-9]/', '', $_POST['celular'] ?? '');

    // E-mail e Confirmação
    $email = filter_input(INPUT_POST, 'email', FILTER_VALIDATE_EMAIL);
    $confirmarEmail = filter_input(INPUT_POST, 'confirmarEmail', FILTER_VALIDATE_EMAIL);
    
    // Senha e Confirmação
    $senha_bruta = $_POST['senha'] ?? ''; 
    $confirmarSenha = $_POST['confirmarSenha'] ?? '';

    // Dados de Endereço
    $logradouro = trim(htmlspecialchars($_POST['logradouro'] ?? ''));
    $numero = filter_input(INPUT_POST, 'numero', FILTER_SANITIZE_STRING);
    $complemento = trim(htmlspecialchars($_POST['complemento'] ?? ''));
    $bairro = trim(htmlspecialchars($_POST['bairro'] ?? ''));
    $cidade = trim(htmlspecialchars($_POST['cidade'] ?? ''));
    $estado = filter_input(INPUT_POST, 'estado', FILTER_SANITIZE_STRING);
    // Remove caracteres não-numéricos do CEP
    $cep = preg_replace('/[^0-9]/', '', $_POST['cep'] ?? '');

    // Validação (mantida a sua lógica original)
    if (empty($idcartao)) $errors[] = "ID Cartão SUS é obrigatório.";
    if (strlen($cpf) != 11) $errors[] = "CPF inválido (deve ter 11 dígitos).";
    if (empty($nome)) $errors[] = "Nome completo é obrigatório.";
    if (empty($celular)) $errors[] = "Celular é obrigatório.";
    
    if ($email === false) $errors[] = "E-mail inválido.";
    if ($confirmarEmail === false) $errors[] = "Confirmação de E-mail inválida.";
    if ($email !== $confirmarEmail) $errors[] = "Os e-mails fornecidos não coincidem."; 
    
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

    // 4. Se não há erros de validação, tenta a inserção no banco
    if (empty($errors)) {
        
        $senha_hash = password_hash($senha_bruta, PASSWORD_DEFAULT); 
        $conexao->begin_transaction();
        $success = true;
        
        // --- 4.1. Inserir na tabela USUARIO (Login) ---
        // CORREÇÃO: Usando a coluna 'login' e adicionando 'tipo_usuario'
        $sql_usuario = "INSERT INTO usuario (login, senha_hash, tipo_usuario) VALUES (?, ?, 'PACIENTE')"; 
        
        if ($stmt_usuario = $conexao->prepare($sql_usuario)) {
            $stmt_usuario->bind_param("ss", $email, $senha_hash);
            
            if (!$stmt_usuario->execute()) {
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

        // --- 4.2. Inserir na tabela PACIENTE (Dados completos) ---
        if ($success) {
            // CORREÇÃO: Usando as colunas corretas (idusuario, nome, cpf, telefone, email)
            $sql_paciente = "INSERT INTO paciente 
                (idusuario, idcartao, nome, cpf, telefone, email, logradouro, numero, complemento, bairro, cidade, estado, cep) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            
            if ($stmt_paciente = $conexao->prepare($sql_paciente)) {
                
                // Tipos: 1 inteiro (i) e 12 strings (s)
                $stmt_paciente->bind_param("issssssssssss", 
                    $id_usuario,        // 1. idusuario (i)
                    $idcartao,          // 2. idcartao (s)
                    $nome,              // 3. nome (s)
                    $cpf,               // 4. cpf (s)
                    $celular,           // 5. telefone (a variável $celular está sendo mapeada para a coluna 'telefone')
                    $email,             // 6. email (s)
                    $logradouro,        // 7. logradouro (s)
                    $numero,            // 8. numero (s)
                    $complemento,       // 9. complemento (s)
                    $bairro,            // 10. bairro (s)
                    $cidade,            // 11. cidade (s)
                    $estado,            // 12. estado (s)
                    $cep                // 13. cep (s)
                );
                
                if (!$stmt_paciente->execute()) {
                    if ($conexao->errno == 1062) {
                        $errors[] = "O CPF ou ID Cartão SUS já está em uso.";
                    } else {
                        $errors[] = "Erro ao inserir dados do paciente: " . $stmt_paciente->error . " (Código: " . $conexao->errno . ")"; 
                    }
                    $success = false;
                }
                $stmt_paciente->close();
            } else {
                $errors[] = "Erro de preparação SQL (Paciente): " . $conexao->error;
                $success = false;
            }
        }
        
        // 5. Commit ou Rollback
        if ($success && empty($errors)) {
            $conexao->commit();
            // Armazena a mensagem de sucesso e redireciona para a tela de login
            $_SESSION['mensagem'] = "Cadastro realizado com sucesso! Faça login para continuar.";
            $_SESSION['tipo_mensagem'] = "success";
            header("Location: cadastro1.html"); 
            exit;
        } else {
            $conexao->rollback();
            // Armazena os erros e redireciona para o formulário
            $_SESSION['erros'] = $errors;
            $_SESSION['tipo_mensagem'] = "error";
            header("Location: " . $_SERVER['HTTP_REFERER']); // Volta para a página de formulário
            exit;
        }

    } else {
        // Erros de validação inicial
        $_SESSION['erros'] = $errors;
        $_SESSION['tipo_mensagem'] = "error";
        header("Location: " . $_SERVER['HTTP_REFERER']); // Volta para a página de formulário
        exit;
    }

} else {
    // Redireciona se o acesso for direto sem POST
    header("Location: cadastro1.html");
    exit;
}
?>