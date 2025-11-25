// Obtendo o elemento input e o container para imagens
const inputFile = document.getElementById('input-file');
const imageContainer = document.getElementById('image-container');

// Adiciona um "ouvinte" de evento para quando o usuário selecionar um arquivo
inputFile.addEventListener('change', (event) => {
    // Limpar as imagens anteriores, se houver
    imageContainer.innerHTML = '';

    // Loop para todas as imagens selecionadas
    const files = event.target.files;
    for (let i = 0; i < files.length; i++) {
        const file = files[i];
        
        // Crie um objeto FileReader para ler o conteúdo do arquivo
        const reader = new FileReader();

        // Quando o arquivo for carregado, esta função é chamada
        reader.onload = function(e) {
            // Cria um novo elemento <img>
            const imgElement = document.createElement('img');
            
            // Define a fonte da imagem como a URL do arquivo lido
            imgElement.src = e.target.result;
            
            // Adiciona a nova imagem ao container
            imageContainer.appendChild(imgElement);
        };

        // Lê o arquivo como uma URL de dados (Data URL)
        reader.readAsDataURL(file);
    }
});