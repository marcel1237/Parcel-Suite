# Project Wizard

> Desktop Project Generator desenvolvido em Java 17, JavaFX e AtlantaFX.

O **Project Wizard** é uma aplicação desktop cujo objetivo é facilitar a criação de novos projetos através de uma interface gráfica moderna, inspirada em IDEs como IntelliJ IDEA, Rider e Visual Studio.

O projeto está sendo desenvolvido de forma incremental, utilizando pequenas etapas ("one-shot scripts") para permitir testes e validação contínua.

---

# Objetivos

O Project Wizard pretende se tornar uma plataforma para geração de projetos, inicialmente para o ecossistema Java e posteriormente para outras tecnologias.

Tecnologias planejadas:

- Java
- JavaFX
- Spring Boot
- Maven
- Gradle
- Jakarta EE
- Quarkus
- Micronaut
- Kotlin
- Android
- .NET (planejado)

---

# Tecnologias Utilizadas

- Java 17
- JavaFX 17
- Maven
- AtlantaFX 2.0.1
- CSS
- Git

---

# Interface

Atualmente o projeto possui:

- Tema AtlantaFX
- Primer Dark
- Menu Principal
- Toolbar
- Sidebar
- Workspace
- Dashboard
- Barra de Status
- Sistema de Navegação
- Wizard de Novo Projeto (em desenvolvimento)

---

# Estrutura do Projeto

```
src/main/java/com/projectwizard

core/
    ApplicationContext
    Constants
    Version

core/navigation/
    NavigationController
    NavigationTarget

service/
    DialogService
    FileSystemService
    ProjectService
    SettingsService

theme/
    ThemeManager
    ThemeType

view/
    MainWindow
    WorkspacePane
    NavigationPane
    StatusBar
    MainToolBar

view/dashboard/
view/newproject/
view/templates/
view/git/
view/github/
view/settings/
view/about/
```

---

# Recursos Atuais

## Dashboard

Tela inicial da aplicação.

---

## Sidebar

Permite acessar:

- Dashboard
- New Project
- Open Project
- Templates
- Git
- GitHub
- Settings
- About

---

## Workspace

Área principal onde as telas são carregadas dinamamente.

---

## Sistema de Temas

O projeto utiliza AtlantaFX.

Tema atual:

- Primer Dark

Temas planejados:

- Dracula
- Primer Light
- Nord Dark
- Nord Light
- Cupertino

---

# Wizard de Projetos

Em desenvolvimento.

Fluxo planejado:

```
Project

↓

Language

↓

Framework

↓

Dependencies

↓

Git

↓

Summary
```

---

# Templates Planejados

## Java

- Java Console
- Java Library

## JavaFX

- Desktop Application
- MVVM
- MVP

## Spring Boot

- REST API
- MVC
- CRUD
- Clean Architecture

## Maven

- Empty Project

## Gradle

- Empty Project

---

# Git

Planejado:

- git init
- git clone
- git status
- git commit
- git push

---

# GitHub

Planejado:

- Login
- Criar Repositório
- Publicar Projeto
- Clonar
- Abrir Pull Requests

---

# Arquitetura

O projeto está migrando para uma arquitetura organizada por módulos.

```
core/

theme/

service/

view/

generator/

template/

wizard/

git/

github/
```

---

# Roadmap

## Fase 1

- Interface
- Tema
- Sidebar
- Workspace

✔ Concluído

---

## Fase 2

- Navegação
- Wizard
- Templates

Em desenvolvimento

---

## Fase 3

- Engine de geração

Planejado

---

## Fase 4

- Integração Git

Planejado

---

## Fase 5

- Integração GitHub

Planejado

---

## Fase 6

- Marketplace de Templates

Planejado

---

# Requisitos

- Java 17
- Maven 3.9+

Verificar versões:

```bash
java -version
mvn -version
```

---

# Executando

```bash
mvn clean javafx:run
```

---

# Build

```bash
mvn clean package
```

---

# Limpeza

```bash
mvn clean
```

---

# Estado Atual

O projeto encontra-se em desenvolvimento ativo.

As funcionalidades são implementadas incrementalmente através de scripts "one-shot", permitindo evolução gradual da arquitetura e testes frequentes.

---

# Licença

Consulte o diretório `license/`.
