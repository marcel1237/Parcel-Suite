# Diretriz de Auto-Documentação de Respostas — Angel OS

**Propósito**: Instruir qualquer agente de IA ou assistente que leia este arquivo a persistir automaticamente as respostas importantes das conversas em arquivos `.md` na pasta `docs/`, seguindo o mesmo procedimento realizado com `ANGEL_OS_BUILD_SUCCESS.md`.

---

## 📋 Regra Operacional para a IA

Sempre que o usuário interagir com a IA e receber uma resposta relevante (análise técnica, relatório de build, especificação, passo a passo ou conclusão arquitetural):

1. **Capturar o Conteúdo**: O texto principal da resposta fornecida ao usuário deve ser preservado.
2. **Definir Nome do Arquivo**: Escolher um nome descritivo em letras maiúsculas com sufixo `.md` (ex: `DOC_RELATORIO_TECNICO.md` ou `ANGEL_OS_TOPICO_X.md`).
3. **Gravar na Pasta `docs/`**: Salvar o arquivo no diretório absoluto `docs/` do projeto.
4. **Atualizar o Índice (`docs/README.md`)**: Adicionar o link para o novo arquivo `.md` na lista de documentação oficial do repositório.
