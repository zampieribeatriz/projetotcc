document.getElementById('cadastroForm').addEventListener('submit', function(event) {
    event.preventDefault();

    // Objeto para armazenar os dados
    const dados = {};

    // Coleta os valores do formulário
    const formulario = new FormData(event.target);
    for (let [chave, valor] of formulario.entries()) {
        dados[chave] = valor;
    }

    // Validações
    let isValid = true;
    let mensagem = '';

    // Valida E-mail
    if (dados.email !== dados.confirmarEmail) {
        isValid = false;
        mensagem += 'Os e-mails não coincidem.\n';
    }

    // Valida Senha
    if (dados.senha !== dados.confirmarSenha) {
        isValid = false;
        mensagem += 'As senhas não coincidem.\n';
    }

    if (isValid) {
        // Remove os campos de confirmação antes de salvar
        delete dados.confirmarEmail;
        delete dados.confirmarSenha;
        
        // Simula o salvamento em arquivo JSON local
        const jsonDados = JSON.stringify(dados, null, 2);
        const blob = new Blob([jsonDados], { type: 'application/json' });
        const url = URL.createObjectURL(blob);
        
        const a = document.createElement('a');
        a.href = url;
        a.download = 'cadastro_cliente.json';
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
        
        alert('Cadastro realizado com sucesso! Os dados foram salvos em um arquivo JSON.');
        this.reset();
    } else {
        alert('Erro no formulário:\n' + mensagem);
    }
});