# Debian XFCE Setup

[![Bash](https://img.shields.io/badge/Bash-5%2B-4EAA25?logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Debian](https://img.shields.io/badge/Debian-XFCE-A81D33?logo=debian&logoColor=white)](https://www.debian.org/)
[![Status](https://img.shields.io/badge/status-active-success)](#)
[![Shell](https://img.shields.io/badge/type-shell%20script-blue)](#)

> **Idioma:** Português | [English](README.en.md)

Script interativo para preparar e configurar um ambiente Debian com XFCE, com foco em uma instalação simples, repetível e fácil de revisar.

O projeto usa `whiptail` para apresentar um menu no terminal e permite escolher exatamente quais ferramentas ou configurações serão aplicadas.

---

## Sumário

- [1. Objetivo](#1-objetivo)
- [2. Recursos](#2-recursos)
- [3. Requisitos](#3-requisitos)
- [4. Instalação e execução](#4-instalação-e-execução)
- [5. Como usar](#5-como-usar)
- [6. Opções disponíveis](#6-opções-disponíveis)
- [7. Detecção de software já instalado](#7-detecção-de-software-já-instalado)
- [8. Comportamentos importantes](#8-comportamentos-importantes)
- [9. Estrutura do projeto](#9-estrutura-do-projeto)
- [10. Validação](#10-validação)
- [11. Limitações conhecidas](#11-limitações-conhecidas)
- [12. Segurança](#12-segurança)

---

## 1. Objetivo

O `Debian XFCE Setup` automatiza tarefas comuns após uma instalação do Debian com XFCE.

A proposta é evitar uma sequência longa de comandos manuais e concentrar em um único script:

- atualização do sistema;
- instalação de ferramentas de desenvolvimento;
- instalação de aplicativos;
- configuração de Zsh e Oh My Zsh;
- configuração da fonte Inter no XFCE;
- configuração de timezone e NTP;
- orientação para ajuste de áudio e microfone.

O script foi feito especificamente para **Debian** e encerra a execução em outras distribuições.

---

## 2. Recursos

- interface interativa com `whiptail`;
- seleção individual de tarefas;
- opção `ALL` para executar todas as tarefas;
- exibição do estado atual de ferramentas e configurações;
- tratamento de erros com identificação da tarefa que falhou;
- autenticação `sudo` apenas quando uma tarefa realmente exige privilégios administrativos;
- instalação automática do `whiptail` caso ele ainda não esteja disponível;
- detecção de IntelliJ instalado pelo JetBrains Toolbox;
- preservação do tamanho atual da fonte quando o XFCE já usa Inter;
- mensagens com rolagem para instruções maiores;
- suporte a terminal de aproximadamente `80x24`.

---

## 3. Requisitos

O script espera:

- Debian;
- sessão de terminal interativa;
- Bash;
- acesso à internet para instalações;
- `sudo` configurado para tarefas administrativas;
- XFCE para as configurações específicas de fonte;
- `systemd`/`timedatectl` para configuração de timezone e NTP.

> **Observação:** o script deve ser executado como usuário normal. Não execute com `sudo ./setup.sh`.

---

## 4. Instalação e execução

Entre na pasta do projeto e torne o script executável:

```bash
chmod +x setup.sh
```

Depois execute:

```bash
./setup.sh
```

Para validar apenas a sintaxe Bash sem executar o setup:

```bash
bash -n setup.sh
```

---

## 5. Como usar

O menu usa uma checklist do `whiptail`.

- use as setas para navegar;
- pressione `ESPAÇO` para marcar ou desmarcar uma opção;
- uma opção selecionada aparece como `[*]`;
- use `TAB` para chegar ao botão `OK`;
- pressione `Enter` para confirmar.

> **Importante:** apenas deixar uma linha destacada não significa que ela foi selecionada. É necessário marcar com `ESPAÇO`.

O menu também mostra estados como:

```text
[INSTALADO]
[NÃO INSTALADO]
[CONFIGURADO]
[PENDENTE]
[INDISPONÍVEL]
```

---

## 6. Opções disponíveis

| Opção | Função |
|---|---|
| `ALL` | Executa todas as tarefas disponíveis |
| `UPDATE` | Atualiza a lista de pacotes e os pacotes instalados |
| `JAVA` | Instala o `default-jdk` do Debian |
| `MAVEN` | Instala Apache Maven |
| `GIT` | Instala Git |
| `VSCODE` | Instala Visual Studio Code pelo repositório oficial da Microsoft |
| `INTELLIJ` | Detecta ou instala IntelliJ IDEA |
| `KEEPASSXC` | Instala KeePassXC |
| `ZSH` | Instala Zsh e Oh My Zsh |
| `FONT` | Instala e configura a fonte Inter no XFCE |
| `TIME` | Configura timezone e sincronização NTP |
| `AUDIO` | Mostra instruções para configuração de áudio e microfone |

### 6.1 Java

O status de Java usa a presença de `javac`.

Ao selecionar `JAVA`, o script garante que o pacote Debian `default-jdk` esteja instalado e mostra a versão final com:

```bash
java -version
```

Se o JDK já existir por outro método, o APT pode apenas instalar os pacotes-meta do Debian ou informar que `default-jdk` já está na versão mais recente.

### 6.2 Visual Studio Code

O VS Code é instalado usando o repositório oficial da Microsoft.

Arquiteturas tratadas pelo script:

- `amd64`;
- `arm64`;
- `armhf`.

Se `code` já estiver disponível no `PATH`, a instalação é ignorada.

### 6.3 IntelliJ IDEA

O script considera IntelliJ instalado quando encontra uma destas opções:

```text
~/.local/share/JetBrains/Toolbox/apps/intellij-idea/bin/idea
idea no PATH
/opt/intellij/bin/idea.sh
```

Isso permite reconhecer instalações feitas pelo **JetBrains Toolbox** e evita criar uma segunda instalação desnecessária.

Se o IntelliJ não for encontrado, o script pode instalar uma cópia em:

```text
/opt/intellij
```

e criar:

```text
/usr/local/bin/idea
```

Arquiteturas tratadas:

- `amd64`;
- `arm64`.

### 6.4 Zsh e Oh My Zsh

O script instala:

```text
zsh
curl
git
```

e depois instala Oh My Zsh quando necessário.

Uma instalação válida exige:

```text
~/.oh-my-zsh/oh-my-zsh.sh
```

O `.zshrc` existente é preservado. Caso ele não pareça carregar Oh My Zsh, o script mostra um aviso em vez de sobrescrever o arquivo.

O shell padrão é consultado através de `getent passwd` antes de executar `chsh`.

### 6.5 Fonte Inter

O status considera a fonte configurada quando:

- o pacote `fonts-inter` está realmente instalado;
- o XFCE está usando uma fonte cujo nome começa com `Inter`.

Exemplos aceitos:

```text
Inter 11
Inter 12
Inter 13
```

Ao executar a configuração:

- se a fonte atual já for Inter, o tamanho atual é preservado;
- caso contrário, o padrão aplicado é `Inter 11`.

A propriedade usada no XFCE é:

```text
/Gtk/FontName
```

### 6.6 Timezone e NTP

O setup configura:

```text
America/Sao_Paulo
```

e usa:

```text
systemd-timesyncd
```

para sincronização de horário.

### 6.7 Áudio e microfone

A opção `AUDIO` não altera o sistema e não exige `sudo`.

Ela apresenta instruções para uso do:

```bash
alsamixer
```

Atalhos principais:

```text
F3  Saída de áudio
F4  Entrada / microfone / Capture
F6  Selecionar placa de áudio
Esc Sair
```

Se `alsamixer` não estiver disponível, o script informa que ele pertence ao pacote `alsa-utils`.

---

## 7. Detecção de software já instalado

Os estados exibidos no menu são informativos.

Algumas tarefas possuem detecção explícita e são ignoradas quando o software já existe, como:

- VS Code;
- IntelliJ IDEA.

Outras usam o APT normalmente. Nesse caso, selecionar novamente um pacote já instalado é seguro: o Debian apenas informa que ele já está na versão mais recente.

A opção `ALL` inclui todas as tarefas, mesmo quando algumas aparecem como instaladas ou configuradas.

---

## 8. Comportamentos importantes

### `sudo`

O script não deve ser iniciado como root.

Ele solicita `sudo` apenas quando alguma tarefa selecionada exige alteração administrativa.

A opção `AUDIO`, quando usada sozinha, não deve pedir senha administrativa.

### Erros

O script usa:

```bash
set -Eeuo pipefail
```

e mantém o nome da tarefa atual.

Quando ocorre uma falha real, a execução é interrompida e uma mensagem semelhante é exibida:

```text
ERRO: NOME_DA_TAREFA falhou na linha X (código Y). Setup interrompido.
```

### Whiptail

Se `whiptail` não estiver instalado, o script tenta instalar automaticamente:

```bash
sudo apt update
sudo apt install -y whiptail
```

---

## 9. Estrutura do projeto

Estrutura mínima:

```text
script-debian-xfce/
├── setup.sh
├── README.md
└── README.en.md
```

O arquivo principal é:

```text
setup.sh
```

---

## 10. Validação

Antes de publicar alterações no script, recomenda-se executar:

```bash
bash -n setup.sh
```

Se `shellcheck` já estiver instalado:

```bash
shellcheck setup.sh
```

Também é recomendável testar individualmente:

```text
AUDIO
JAVA
FONT
INTELLIJ
ALL
```

sem assumir que uma opção destacada no menu já esteja marcada.

---

## 11. Limitações conhecidas

- o projeto é específico para Debian;
- a configuração de fonte depende de uma sessão XFCE funcional;
- timezone está definido atualmente como `America/Sao_Paulo`;
- IntelliJ possui suporte explícito apenas para `amd64` e `arm64`;
- VS Code possui suporte explícito para `amd64`, `arm64` e `armhf`;
- a opção `AUDIO` apenas apresenta instruções; ela não instala nem configura automaticamente dispositivos de áudio;
- algumas tarefas podem executar `apt update` mesmo quando o pacote solicitado já está instalado.

---

## 12. Segurança

O script:

- usa `sudo` para modificar pacotes e configurações do sistema;
- adiciona o repositório oficial da Microsoft para instalar VS Code;
- baixa IntelliJ diretamente da JetBrains;
- baixa o instalador oficial do Oh My Zsh;
- modifica o shell padrão quando Zsh é selecionado;
- pode modificar configurações do XFCE e timezone.

> **Recomendação:** leia o `setup.sh` antes de executá-lo, especialmente em máquinas de produção ou ambientes que já possuem configuração personalizada.

---

`Debian XFCE Setup` foi criado para tornar uma instalação Debian XFCE mais rápida, previsível e reproduzível sem esconder do usuário o que está sendo feito.
