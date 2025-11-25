document.addEventListener('DOMContentLoaded', () => {
    const specialityButtons = document.querySelectorAll('.btn-especialidade');
    const btnAvancar = document.getElementById('btnAvancar');
    
    // Variável para rastrear a especialidade que foi CLICADA
    let selectedSpeciality = null;

    // --- Lógica de Seleção de Especialidade ---
    specialityButtons.forEach(button => {
        button.addEventListener('click', (event) => {
            // Previne a navegação do link (que está como href="#")
            event.preventDefault(); 
            
            // 1. Remove a classe de destaque de todos os botões
            specialityButtons.forEach(btn => {
                btn.classList.remove('btn-especialidade-active');
            });

            // 2. Adiciona a classe de destaque ao botão clicado
            button.classList.add('btn-especialidade-active');
            
            // 3. Captura e armazena a especialidade usando o data-name
            selectedSpeciality = button.getAttribute('data-name');
            console.log('Especialidade selecionada:', selectedSpeciality);
        });
    });

    // --- Lógica do Botão "Avançar" ---
    btnAvancar.addEventListener('click', () => {
        if (selectedSpeciality) {
            // Se uma especialidade foi selecionada:
            
            // A melhor forma de passar esse dado é pela URL (Query String)
            // ou usando o localStorage se for um SPA (Single Page Application).
            
            // Opção 1: Passar pela URL (Mais simples)
            // Isso irá para 'especialidade.html?especialidade=Cl%C3%ADnico%20Geral'
            const encodedSpeciality = encodeURIComponent(selectedSpeciality);
            window.location.href = `especialidade.html?especialidade=${encodedSpeciality}`;
            
            // Opção 2: Salvar no armazenamento local (Se precisar ser lido em várias páginas)
            // localStorage.setItem('especialidadeSelecionada', selectedSpeciality);
            // window.location.href = 'especialidade.html';
            
        } else {
            // Se nenhuma especialidade foi selecionada:
            alert('Por favor, selecione uma especialidade antes de avançar.');
        }
    });
});