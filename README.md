# Debian XFCE Setup

[![Bash](https://img.shields.io/badge/Bash-5%2B-4EAA25?logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Debian](https://img.shields.io/badge/Debian-XFCE-A81D33?logo=debian&logoColor=white)](https://www.debian.org/)
![Status](https://img.shields.io/badge/status-active-success)
![Type](https://img.shields.io/badge/type-shell%20script-blue)

> **Idioma:** Português | [English](README.en.md)

Script interativo para preparar e configurar um ambiente Debian com XFCE de forma simples, repetível e revisável.

O projeto usa `whiptail` para apresentar um menu no terminal e permite escolher exatamente quais ferramentas ou configurações serão aplicadas.

---

## Sumário

- [1. Objetivo](#1-objetivo)
- [2. Recursos](#2-recursos)
- [3. Requisitos](#3-requisitos)
- [4. Instalação e execução](#4-instalação-e-execução)
- [5. Como usar](#5-como-usar)
- [6. Opções disponíveis](#6-opções-disponíveis)
- [7. Detecção de software e configurações](#7-detecção-de-software-e-configurações)
- [8. Comportamentos importantes](#8-comportamentos-importantes)
- [9. Estrutura do projeto](#9-estrutura-do-projeto)
- [10. Validação](#10-validação)
- [11. Limitações conhecidas](#11-limitações-conhecidas)
- [12. Segurança](#12-segurança)

---

## 1. Objetivo

O `Debian XFCE Setup` automatiza tarefas comuns após uma instalação do Debian com XFCE.

A proposta é substituir uma sequência de comandos manuais por um único script capaz de cuidar de:

- atualização do sistema;
- instalação de ferramentas de desenvolvimento;
- instalação de aplicativos;
- instalação e verificação do Docker;
- configuração de Zsh e Oh My Zsh;
- configuração da fonte Inter no XFCE;
- configuração de timezone e NTP;
- correção opcional para teclados que não produzem corretamente `\` e `|` no X11/XFCE;
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
- instalação automática do `whiptail` quando necessário;
- detecção de IntelliJ instalado pelo JetBrains Toolbox;
- instalação do Docker pelo repositório oficial da Docker;
- configuração persistente e reversível do keycode 77 para `\` e `|` no X11/XFCE;
- preservação do tamanho atual da fonte quando o XFCE já usa Inter;
- mensagens com rolagem para instruções maiores;
- menu utilizável em terminais de aproximadamente `80x24`.

### 2.1 Ferramentas instaladas ou gerenciadas

[![Java](https://img.shields.io/badge/Java-default--jdk-ED8B00?logo=openjdk&logoColor=white)](https://openjdk.org/)
[![Maven](https://img.shields.io/badge/Apache_Maven-APT-C71A36?logo=apachemaven&logoColor=white)](https://maven.apache.org/)
[![Git](https://img.shields.io/badge/Git-APT-F05032?logo=git&logoColor=white)](https://git-scm.com/)
[![VS Code](https://img.shields.io/badge/Visual_Studio_Code-Microsoft-007ACC?logo=visualstudiocode&logoColor=white)](https://code.visualstudio.com/)
[![IntelliJ IDEA](https://img.shields.io/badge/IntelliJ_IDEA-JetBrains-000000?logo=intellijidea&logoColor=white)](https://www.jetbrains.com/idea/)
[![KeePassXC](https://img.shields.io/badge/KeePassXC-APT-6CAC4D?logo=keepassxc&logoColor=white)](https://keepassxc.org/)
[![Zsh](https://img.shields.io/badge/Zsh-Shell-F15A24?logo=zsh&logoColor=white)](https://www.zsh.org/)
[![Oh My Zsh](https://img.shields.io/badge/Oh_My_Zsh-Framework-1A2C34)](https://ohmyz.sh/)
[![Docker](https://img.shields.io/badge/Docker-Engine-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Docker Compose](https://img.shields.io/badge/Docker_Compose-Plugin-2496ED?logo=docker&logoColor=white)](https://docs.docker.com/compose/)
[![Docker Buildx](https://img.shields.io/badge/Docker_Buildx-Plugin-2496ED?logo=docker&logoColor=white)](https://docs.docker.com/build/buildx/)
[![Whiptail](https://img.shields.io/badge/whiptail-Terminal_UI-4EAA25?logo=gnubash&logoColor=white)](https://packages.debian.org/search?keywords=whiptail)

### 2.2 Configurações e suporte do ambiente

[![XFCE](https://img.shields.io/badge/XFCE-Desktop-2284F2?logo=xfce&logoColor=white)](https://www.xfce.org/)
[![Inter](https://img.shields.io/badge/Inter-Font-111111)](https://rsms.me/inter/)
[![systemd](https://img.shields.io/badge/systemd-timesyncd-000000?logo=systemd&logoColor=white)](https://systemd.io/)
[![Timezone](https://img.shields.io/badge/Timezone-America%2FSao__Paulo-555555)](#66-timezone-e-ntp)
[![X11](https://img.shields.io/badge/X11-xmodmap-F28834)](#68-teclado-barra-invertida-e-pipe)
[![Keycode 77](https://img.shields.io/badge/Keycode_77-Num_Lock_%E2%86%92_%5C_%7C-555555)](#68-teclado-barra-invertida-e-pipe)
[![ALSA](https://img.shields.io/badge/ALSA-alsamixer-6A5ACD)](#69-áudio-e-microfone)

Os badges são apenas uma visão rápida. O comportamento de cada opção está documentado em texto nas seções abaixo.

---

## 3. Requisitos

O script espera:

- Debian;
- sessão de terminal interativa;
- Bash;
- acesso à internet para downloads e instalação de pacotes;
- `sudo` configurado para tarefas administrativas;
- XFCE para as configurações específicas do desktop;
- X11/XFCE para a correção opcional de teclado com `xmodmap`;
- `systemd`/`timedatectl` para configuração de timezone e NTP.

> **Observação:** execute o script como usuário normal. Não use `sudo ./setup.sh`.

---

## 4. Instalação e execução

Na pasta do projeto, torne o script executável:

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
| `DOCKER` | Detecta ou instala Docker Engine pelo repositório oficial da Docker |
| `KEYBOARD` | Corrige barra invertida e pipe usando Num Lock (keycode 77) no X11/XFCE |
| `AUDIO` | Mostra instruções para configuração de áudio e microfone |

### 6.1 Java

O status de Java usa a presença de `javac`.

Ao selecionar `JAVA`, o script garante que o pacote Debian `default-jdk` esteja instalado e mostra a versão final com:

```bash
java -version
```

Se um JDK já existir por outro método, o APT pode apenas instalar os pacotes-meta do Debian ou informar que `default-jdk` já está na versão mais recente.

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

e instala Oh My Zsh quando necessário.

Uma instalação válida exige:

```text
~/.oh-my-zsh/oh-my-zsh.sh
```

O `.zshrc` existente é preservado. Caso ele não pareça carregar Oh My Zsh, o script mostra um aviso em vez de sobrescrever o arquivo.

O shell padrão é consultado através de `getent passwd` antes de executar `chsh`.

### 6.5 Fonte Inter

O status considera a fonte configurada quando:

- o pacote `fonts-inter` está instalado;
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

### 6.7 Docker

A opção `DOCKER` considera Docker instalado quando o comando `docker` está disponível no `PATH`.

Se Docker já estiver instalado, o script não reinstala o software: mostra `docker --version` e, quando disponível, `docker compose version`.

Se Docker ainda não estiver instalado, o script usa o **repositório APT oficial da Docker para Debian** e instala:

```text
docker-ce
docker-ce-cli
containerd.io
docker-buildx-plugin
docker-compose-plugin
```

Antes da instalação, o script verifica pacotes conhecidos por entrarem em conflito com os pacotes oficiais. Se algum conflito for encontrado, a tarefa Docker é interrompida sem remover nada automaticamente.

A instalação também:

- detecta a arquitetura com `dpkg --print-architecture`;
- usa `/etc/apt/keyrings/docker.asc`;
- cria `/etc/apt/sources.list.d/docker.sources`;
- habilita e inicia o serviço `docker` quando `systemd` está disponível;
- valida `docker --version` e `docker compose version`;
- não executa `docker run hello-world`;
- **não adiciona automaticamente o usuário ao grupo `docker`**.

Se o acesso ao daemon exigir privilégios, use `sudo docker ...`.

### 6.8 Teclado: barra invertida e pipe

Alguns teclados ou layouts no X11/XFCE podem não permitir digitar corretamente:

```text
\  barra invertida
|  pipe
```

A opção `KEYBOARD` oferece uma correção específica para esse caso reaproveitando a tecla **Num Lock**, correspondente ao **keycode 77**.

Enquanto a configuração estiver ativa:

```text
Num Lock          -> \
Shift + Num Lock  -> |
```

> **Importante:** a tecla Num Lock deixa de funcionar como Num Lock enquanto essa configuração estiver ativa.

A alteração é persistida em arquivos exclusivos do projeto:

```text
~/.config/debian-xfce-setup/keycode77.xmodmap
~/.config/autostart/debian-xfce-setup-keyboard.desktop
```

O autostart reaplica a configuração em novos logins do XFCE. Na sessão atual, o script consulta o mapa X11 antes de reaplicar a alteração: se o keycode 77 já estiver correto, a tarefa termina com sucesso sem repetir uma operação desnecessária.

Se `xmodmap` não estiver instalado, a opção pode instalar o pacote Debian:

```text
x11-xserver-utils
```

Nesse caso, e somente nesse caso dentro da tarefa `KEYBOARD`, é necessário `sudo`.

Antes da alteração, o script exibe uma confirmação explicando o efeito sobre Num Lock, os arquivos criados e como desfazer.

Para remover manualmente a configuração:

```bash
rm ~/.config/debian-xfce-setup/keycode77.xmodmap
rm ~/.config/autostart/debian-xfce-setup-keyboard.desktop
```

Depois faça logout/login. No próximo login, essa alteração deixará de ser aplicada.

> **Limite:** essa correção é específica para X11/XFCE. O script não tenta adaptar esse remapeamento para Wayland.

### 6.9 Áudio e microfone

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

## 7. Detecção de software e configurações

Os estados exibidos no menu são informativos e calculados antes da seleção das tarefas.

Algumas opções possuem detecção explícita para evitar trabalho desnecessário:

- Java verifica `javac`;
- VS Code verifica `code`;
- IntelliJ reconhece JetBrains Toolbox, `idea` no `PATH` e `/opt/intellij`;
- Docker verifica `docker` no `PATH`;
- Zsh verifica Zsh e a instalação do Oh My Zsh;
- fonte verifica o pacote Inter e a propriedade atual do XFCE;
- timezone verifica `America/Sao_Paulo` e NTP;
- teclado verifica os dois arquivos persistentes gerenciados pelo projeto.

A opção `ALL` inclui todas as tarefas, mesmo quando algumas já aparecem como instaladas ou configuradas. Cada tarefa mantém sua própria lógica para reaplicação ou instalação.

---

## 8. Comportamentos importantes

### `sudo`

O script não deve ser iniciado como root.

Ele solicita `sudo` apenas quando uma tarefa selecionada exige alteração administrativa.

Alguns casos importantes:

- `AUDIO` não exige `sudo`;
- `DOCKER` não pede `sudo` apenas para mostrar versões quando Docker já está instalado;
- `KEYBOARD` só precisa de `sudo` se `xmodmap` precisar ser instalado através de `x11-xserver-utils`.

### Erros

O script usa:

```bash
set -Eeuo pipefail
```

e mantém o nome da tarefa atual.

Quando ocorre uma falha real, a execução normalmente é interrompida e uma mensagem semelhante é exibida:

```text
ERRO: NOME_DA_TAREFA falhou na linha X (código Y). Setup interrompido.
```

A tarefa `DOCKER` é tratada de forma isolada: se ela falhar, o script registra a falha, continua as demais tarefas selecionadas e encerra com status de erro ao final.

Na configuração de teclado, o estado final do keycode 77 é validado. Um comando intermediário não é tratado como falha definitiva quando a sessão já chegou ao estado desejado.

### Whiptail

Se `whiptail` não estiver instalado, o script tenta instalá-lo automaticamente:

```bash
sudo apt update
sudo apt install -y whiptail
```

---

## 9. Estrutura do projeto

Estrutura mínima:

```text
debian-xfce-setup/
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

Antes de publicar alterações no script:

```bash
bash -n setup.sh
```

Se `shellcheck` já estiver instalado:

```bash
shellcheck setup.sh
```

Também é útil testar individualmente:

```text
AUDIO
JAVA
FONT
INTELLIJ
DOCKER
KEYBOARD
ALL
```

Ao testar o menu, lembre que uma opção apenas destacada ainda não está marcada: é necessário pressionar `ESPAÇO`.

---

## 11. Limitações conhecidas

- o projeto é específico para Debian;
- a configuração de fonte depende de uma sessão XFCE funcional;
- o timezone está definido atualmente como `America/Sao_Paulo`;
- IntelliJ possui suporte explícito para `amd64` e `arm64`;
- VS Code possui suporte explícito para `amd64`, `arm64` e `armhf`;
- a correção `KEYBOARD` é específica para X11/XFCE e não é aplicada em Wayland;
- `KEYBOARD` reaproveita a tecla Num Lock, que perde sua função normal enquanto a configuração estiver ativa;
- a instalação oficial do Docker é interrompida quando pacotes conflitantes conhecidos são encontrados; eles não são removidos automaticamente;
- `AUDIO` apenas apresenta instruções e não configura automaticamente dispositivos de áudio;
- algumas tarefas podem executar `apt update` mesmo quando o pacote solicitado já está instalado.

---

## 12. Segurança

O script:

- usa `sudo` para modificar pacotes e configurações do sistema;
- adiciona o repositório oficial da Microsoft para instalar VS Code;
- adiciona o repositório oficial da Docker quando precisa instalar Docker Engine;
- baixa IntelliJ diretamente da JetBrains;
- baixa o instalador oficial do Oh My Zsh;
- pode alterar o shell padrão quando Zsh é selecionado;
- pode modificar configurações do XFCE e timezone;
- pode criar um autostart do XFCE e um mapa `xmodmap` próprio para a correção opcional do keycode 77;
- não remove automaticamente pacotes conflitantes encontrados pela tarefa Docker;
- não adiciona automaticamente o usuário ao grupo `docker`.

> **Recomendação:** leia `setup.sh` antes de executá-lo, especialmente em máquinas de produção ou ambientes que já possuem configuração personalizada.

---

`Debian XFCE Setup` foi criado para tornar uma instalação Debian XFCE mais rápida, previsível e reproduzível sem esconder do usuário o que está sendo feito.
