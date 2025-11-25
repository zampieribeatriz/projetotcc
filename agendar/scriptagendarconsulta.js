document.addEventListener("DOMContentLoaded", () => {
  const botoes = document.querySelectorAll(".btn-outline-primary");
  
  botoes.forEach(btn => {
    btn.addEventListener("click", () => {
      alert(`Você selecionou: ${btn.innerText}`);
    });
  });
});