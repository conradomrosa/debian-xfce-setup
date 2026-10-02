# Debian XFCE Setup — documentação

> **Idioma:** Português | [English](DOCS-en.md)

Este documento descreve o comportamento técnico atual do `setup.sh` do projeto **Debian XFCE Setup**. Ele é documentação de referência do script, não o README de apresentação do projeto.

O setup usa `whiptail` para oferecer uma interface interativa no terminal, permite escolher tarefas individualmente e possui interface completa em `pt-BR` e `en`.

---

## Sumário

- [1. Objetivo e escopo](#1-objetivo-e-escopo)
- [2. Requisitos](#2-requisitos)
- [3. Execução e idioma](#3-execução-e-idioma)
- [4. Interface e estados](#4-interface-e-estados)
- [5. Opções disponíveis](#5-opções-disponíveis)
- [6. Comportamento das tarefas](#6-comportamento-das-tarefas)
- [7. Detecção e idempotência](#7-detecção-e-idempotência)
- [8. `sudo` e tratamento de erros](#8-sudo-e-tratamento-de-erros)
- [9. Arquivos e integrações gerenciadas](#9-arquivos-e-integrações-gerenciadas)
- [10. Validação](#10-validação)
- [11. Limitações conhecidas](#11-limitações-conhecidas)
- [12. Segurança](#12-segurança)

---

## 1. Objetivo e escopo

O `Debian XFCE Setup` automatiza tarefas comuns de preparação de um ambiente Debian com XFCE.

O script reúne em uma única interface:

- atualização do sistema;
- instalação de Java, Maven e Git;
- instalação de Visual Studio Code e IntelliJ IDEA;
- instalação de KeePassXC;
- instalação de Zsh e Oh My Zsh;
- disponibilização da fonte Inter;
- configuração de timezone e NTP;
- instalação e verificação do Docker Engine, Docker Compose e Buildx;
- correção opcional de teclado para `\` e `|` no X11/XFCE;
- integração opcional com o tema Chicago95;
- orientação para áudio e microfone via `alsamixer`.

O script é específico para **Debian**. Se `/etc/os-release` indicar outra distribuição, a execução é encerrada.

---

## 2. Requisitos

O setup espera:

- Debian;
- Bash;
- um terminal interativo;
- acesso à internet para downloads e instalação de pacotes;
- `sudo` configurado para tarefas administrativas;
- XFCE para integrações específicas do desktop;
- X11/XFCE para a correção opcional de teclado com `xmodmap`;
- `systemd` e `timedatectl` para configuração de timezone e NTP;
- uma sessão gráfica GTK3 funcional para a instalação inicial do Chicago95.

> **Observação:** execute como usuário normal. Não use `sudo ./setup.sh`.

O próprio script tenta instalar `whiptail` quando ele não está disponível.

---

## 3. Execução e idioma

Torne o script executável:

```bash
chmod +x setup.sh
```

Execute:

```bash
./setup.sh
```

### 3.1 Seleção de idioma

Em toda execução, depois das verificações iniciais e da disponibilidade do `whiptail`, o script mostra uma seleção manual:

```text
pt-BR  Português (Brasil)
en     English
```

A seleção possui estas características:

- não usa `LANG`, `LANGUAGE`, `LC_ALL` ou outro locale para escolher o idioma;
- não detecta o idioma automaticamente;
- não salva a escolha entre execuções;
- a escolha fica somente em memória durante a execução atual;
- cancelar ou sair da tela de idioma encerra o setup sem executar tarefas.

Mensagens que podem aparecer antes dessa escolha, como erro de distribuição ou ausência de `whiptail`, são exibidas de forma bilíngue.

---

## 4. Interface e estados

O menu principal usa uma checklist do `whiptail`.

- use as setas para navegar;
- pressione `ESPAÇO` para marcar ou desmarcar uma opção;
- uma opção selecionada aparece como `[*]`;
- use `TAB` para chegar aos botões;
- pressione `Enter` para confirmar.

> **Observação:** destacar uma linha não a seleciona. É necessário marcá-la com `ESPAÇO`.

### 4.1 Estados apresentados

Internamente, o script mantém estados estáveis em português para não misturar apresentação com lógica. A interface os localiza conforme o idioma escolhido.

| Estado interno | `pt-BR` | `en` |
|---|---|---|
| `[INSTALADO]` | `[INSTALADO]` | `[INSTALLED]` |
| `[NÃO INSTALADO]` | `[NÃO INSTALADO]` | `[NOT INSTALLED]` |
| `[CONFIGURADO]` | `[CONFIGURADO]` | `[CONFIGURED]` |
| `[PENDENTE]` | `[PENDENTE]` | `[PENDING]` |
| `[PARCIAL]` | `[PARCIAL]` | `[PARTIAL]` |
| `[INDISPONÍVEL]` | `[INDISPONÍVEL]` | `[UNAVAILABLE]` |

Essa tradução afeta apenas a exibição. Comparações internas, como as usadas em `status_font()` e `status_keyboard()`, permanecem independentes do idioma escolhido.

---

## 5. Opções disponíveis

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
| `FONT` | Instala/disponibiliza o pacote `fonts-inter` |
| `TIME` | Configura timezone e sincronização NTP |
| `DOCKER` | Detecta ou instala Docker Engine, Compose e Buildx |
| `KEYBOARD` | Corrige `\` e `|` usando Num Lock (`keycode 77`) no X11/XFCE |
| `CHICAGO95` | Instala ou integra o tema Chicago95 com restrições controladas pelo projeto |
| `AUDIO` | Mostra orientação para configuração de áudio e microfone |

A opção `ALL` expande para todas as opções acima, incluindo `UPDATE`, `CHICAGO95` e `AUDIO`.

---

## 6. Comportamento das tarefas

### 6.1 `UPDATE`

Executa:

```bash
sudo apt update
sudo apt upgrade -y
```

O script mantém um controle interno para evitar repetir `apt update` desnecessariamente dentro da mesma execução quando tarefas usam a função compartilhada de APT.

### 6.2 `JAVA`

O status de Java usa a presença de `javac`.

A tarefa instala:

```text
default-jdk
```

Depois exibe:

```bash
java -version
```

### 6.3 `MAVEN`

Instala o pacote Debian:

```text
maven
```

Depois exibe:

```bash
mvn --version
```

### 6.4 `GIT`

Instala o pacote Debian:

```text
git
```

Depois exibe:

```bash
git --version
```

### 6.5 `VSCODE`

Se `code` já estiver disponível no `PATH`, a tarefa termina sem reinstalar o VS Code.

Arquiteturas aceitas:

- `amd64`;
- `arm64`;
- `armhf`.

Quando necessário, o script:

1. instala `wget`, `gpg` e `ca-certificates`;
2. adiciona a chave oficial da Microsoft em `/usr/share/keyrings/microsoft.gpg`;
3. cria `/etc/apt/sources.list.d/vscode.sources`;
4. instala o pacote `code` pelo repositório oficial da Microsoft.

### 6.6 `INTELLIJ`

O IntelliJ é considerado instalado quando existe uma destas formas:

```text
~/.local/share/JetBrains/Toolbox/apps/intellij-idea/bin/idea
idea no PATH
/opt/intellij/bin/idea.sh
```

Arquiteturas suportadas pela instalação automatizada:

- `amd64`;
- `arm64`.

Se necessário, o script baixa o IntelliJ IDEA Ultimate diretamente da JetBrains, valida a estrutura extraída e publica a instalação em:

```text
/opt/intellij
```

Também cria:

```text
/usr/local/bin/idea
```

Caso exista algo em `/opt/intellij` durante a publicação de uma nova instalação, o conteúdo anterior é preservado em um diretório de backup sob `/opt`.

### 6.7 `KEEPASSXC`

Instala o pacote Debian:

```text
keepassxc
```

### 6.8 `ZSH`

Instala:

```text
zsh
curl
git
```

O Oh My Zsh é instalado somente quando `~/.oh-my-zsh/oh-my-zsh.sh` não existe.

A instalação usa o instalador oficial do projeto com:

```text
RUNZSH=no
CHSH=no
KEEP_ZSHRC=yes
```

Regras importantes:

- um diretório `~/.oh-my-zsh` vazio pode ser removido para permitir a instalação;
- conteúdo incompleto não vazio é preservado e a tarefa é interrompida;
- `.zshrc` não é sobrescrito;
- se o script não identificar carregamento do Oh My Zsh no `.zshrc`, apenas mostra um aviso;
- o shell cadastrado é consultado com `getent passwd` antes de usar `chsh`;
- quando necessário, o shell padrão é alterado para o caminho real do Zsh.

### 6.9 `FONT`

A tarefa `FONT` tem uma função deliberadamente simples: disponibilizar a fonte Inter pelo pacote Debian.

O status verifica apenas se:

```text
fonts-inter
```

está instalado.

Se já estiver instalado, a tarefa não executa APT novamente. Caso contrário, instala o pacote e confirma o estado final.

O setup **não**:

- escolhe Inter como fonte da interface;
- altera `/Gtk/FontName`;
- altera tamanho de fonte;
- executa `fc-cache` manualmente;
- grava fontes em `~/.fonts`, `~/.local/share/fonts` ou `/usr/share/fonts`;
- modifica `/etc/fonts`.

A escolha da fonte da interface fica com o usuário.

### 6.10 `TIME`

A tarefa exige uma sessão em que `systemctl` e `timedatectl` estejam disponíveis e funcionais.

Ela instala:

```text
systemd-timesyncd
```

E configura:

```text
Timezone: America/Sao_Paulo
NTP: true
```

Também habilita e inicia `systemd-timesyncd`.

### 6.11 `DOCKER`

O Docker só recebe estado `[INSTALADO]` quando todos estes testes passam:

- `docker` existe no `PATH`;
- `dockerd` existe no `PATH`;
- `docker --version` funciona;
- `docker compose version` funciona;
- `docker buildx version` funciona.

Se `docker` ou `dockerd` existir, mas o conjunto não estiver completo, o menu mostra `[PARCIAL]`.

Quando a instalação já está completa, a tarefa apenas mostra as versões de Docker, Compose e Buildx e não precisa de `sudo` para reinstalar componentes.

Antes de instalar a versão oficial da Docker, o script procura estes pacotes conflitantes:

```text
docker.io
docker-compose
docker-doc
docker-buildx
podman-docker
containerd
runc
```

Se algum estiver instalado, a tarefa é interrompida e **nenhum pacote é removido automaticamente**.

Quando a instalação pode prosseguir, o script:

1. usa o repositório APT oficial da Docker para Debian;
2. armazena a chave em `/etc/apt/keyrings/docker.asc`;
3. cria `/etc/apt/sources.list.d/docker.sources`;
4. instala:

```text
docker-ce
docker-ce-cli
containerd.io
docker-buildx-plugin
docker-compose-plugin
```

5. valida Docker, Compose e Buildx;
6. quando `systemd` está disponível, habilita e inicia o serviço `docker` e verifica se ele ficou ativo.

O script:

- não executa `docker run hello-world`;
- não adiciona automaticamente o usuário ao grupo `docker`.

Se o acesso ao daemon exigir privilégios, use `sudo docker ...`.

### 6.12 `KEYBOARD`

Essa opção trata um caso específico de teclados/layouts X11/XFCE que não produzem corretamente:

```text
\  barra invertida
|  pipe
```

A correção reaproveita o **Num Lock**, `keycode 77`:

```text
Num Lock          -> \
Shift + Num Lock  -> |
```

> **Restrição:** enquanto a configuração estiver ativa, a tecla Num Lock deixa de exercer sua função normal.

Arquivos gerenciados:

```text
~/.config/debian-xfce-setup/keycode77.xmodmap
~/.config/autostart/debian-xfce-setup-keyboard.desktop
```

O autostart reaplica o mapa em logins XFCE. Na sessão atual, o script valida o mapa X11 antes e depois da aplicação.

Se `xmodmap` não existir, a tarefa pode instalar:

```text
x11-xserver-utils
```

Somente nesse caso a tarefa `KEYBOARD` precisa de `sudo`.

O script também reconhece um par legado específico formado por:

```text
~/.Xmodmap
~/.config/autostart/xmodmap.desktop
```

Quando esse par corresponde exatamente ao formato conhecido, ele pode ser migrado para os arquivos exclusivos do projeto. Arquivos antigos não reconhecidos são preservados.

Para remover manualmente a configuração atual:

```bash
rm ~/.config/debian-xfce-setup/keycode77.xmodmap
rm ~/.config/autostart/debian-xfce-setup-keyboard.desktop
```

Depois faça logout e login novamente.

### 6.13 `CHICAGO95`

A opção integra o projeto oficial **Chicago95** sem permitir que o instalador upstream controle componentes que o Debian XFCE Setup decidiu gerenciar ou deixar manuais.

#### Detecção

O tema é considerado instalado quando estes arquivos existem e não estão vazios:

```text
~/.themes/Chicago95/gtk-2.0/gtkrc
~/.themes/Chicago95/xfwm4/themerc
~/.themes/Chicago95/gtk-3.0/gtk.css
```

#### Dependências

As dependências de integração incluem:

```text
git
python3
gnome-session-canberra
sox
libcanberra-gtk3-module
```

Quando o tema ainda não está instalado, também podem ser necessários:

```text
xfce4-panel-profiles
gtk2-engines-pixbuf
python3-gi
gir1.2-gtk-3.0
```

#### Instalador oficial e restrições

Quando o tema não está instalado, o script clona temporariamente:

```text
https://github.com/grassmunk/Chicago95.git
```

Antes de executar `installer.py`, o setup analisa o arquivo com a AST do Python e exige que todas estas flags existam:

```text
install_sounds
install_fonts
install_background
panel
bash
zsh
terminal_colors
thunar
```

Se qualquer flag esperada estiver ausente, a instalação é interrompida. Essa validação é **fail-closed**: uma mudança estrutural do instalador upstream não é ignorada.

Com a estrutura reconhecida, todas essas flags são forçadas para `False` antes da execução. Chamadas do instalador para propriedades `xfconf` cujo nome contenha `font` também são bloqueadas.

Assim, o instalador oficial não recebe permissão do projeto para instalar ou configurar automaticamente fontes, sons, fundo, painel ou customizações de shell/terminal gerenciadas por essas flags.

#### Sons

Os sons são copiados separadamente para:

```text
~/.local/share/sounds/Chicago95
```

O projeto mantém um manifesto com hashes para poder atualizar arquivos que ainda correspondem à versão anteriormente gerenciada sem sobrescrever customizações do usuário.

O som de inicialização clássico é salvo como:

```text
~/.local/share/sounds/Chicago95/startup.ogg
```

E o projeto cria o autostart:

```text
~/.config/autostart/debian-xfce-setup-chicago95-startup.desktop
```

Esse autostart aguarda alguns segundos e reproduz o som com `/usr/bin/play`.

Quando `xfconf-query` está disponível em uma sessão XFCE acessível, o setup define:

```text
/Net/SoundThemeName = Chicago95
```

#### Helvetica

A Helvetica bitmap fornecida pelo Chicago95 é **baixada como dado, mas não instalada**.

Os arquivos ficam em:

```text
~/.local/share/debian-xfce-setup/chicago95-fonts/cronyx-cyrillic
```

O diretório usa manifesto e SHA-256 para verificar a integridade da cópia gerenciada. Arquivos preexistentes ou personalizados diferentes do conteúdo oficial são preservados e fazem a verificação de integridade sinalizar diferença.

A fonte não é copiada para diretórios de fontes do usuário ou do sistema e o setup não habilita fontes bitmap automaticamente.

> **Observação:** fontes bitmap legadas podem causar problemas de renderização em aplicativos modernos, inclusive Electron/Chromium e Visual Studio Code.

O próprio script apresenta um workaround opcional, somente para uma execução específica do VS Code, caso o usuário tenha instalado Helvetica manualmente e encontre problemas:

```bash
cat > /tmp/vscode-fontconfig.conf <<'EOF_FONTCONFIG'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
<fontconfig>
  <include ignore_missing="no">/etc/fonts/fonts.conf</include>
  <match target="pattern">
    <test name="family" compare="eq">
      <string>Helvetica</string>
    </test>
    <edit name="family" mode="assign_replace" binding="strong">
      <string>Noto Sans</string>
    </edit>
  </match>
</fontconfig>
EOF_FONTCONFIG

FONTCONFIG_FILE=/tmp/vscode-fontconfig.conf \
FONTCONFIG_PATH=/etc/fonts \
code
```

Esse workaround não é executado automaticamente pelo setup e não modifica `/etc/fonts`.

#### Itens manuais

O setup não configura automaticamente:

- botão Start/ícone do menu;
- wallpaper;
- instalação da Helvetica.

O tema instalado contém recursos em `~/.themes/Chicago95/misc`, e o repositório oficial possui wallpapers em `Extras/Backgrounds`.

### 6.14 `AUDIO`

A opção `AUDIO` não modifica o sistema e não exige `sudo`.

Ela mostra orientação para:

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

Para microfone distorcendo ou clipando, a orientação destaca controles como:

```text
Capture
Mic Boost
Internal Mic Boost
```

Se `alsamixer` não estiver instalado, o script informa que ele é fornecido pelo pacote `alsa-utils`; a opção não instala esse pacote automaticamente.

---

## 7. Detecção e idempotência

Os estados do menu são calculados antes da escolha das tarefas.

Detecções principais:

- Java: presença de `javac`;
- Maven: presença de `mvn`;
- Git: presença de `git`;
- VS Code: presença de `code`;
- IntelliJ: JetBrains Toolbox, `idea` no `PATH` ou `/opt/intellij/bin/idea.sh`;
- KeePassXC: presença de `keepassxc`;
- Zsh: presença de `zsh` e de `~/.oh-my-zsh/oh-my-zsh.sh`;
- Inter: estado do pacote `fonts-inter`;
- timezone: `America/Sao_Paulo` e NTP ativo;
- Docker: CLI, `dockerd`, Compose e Buildx funcionais;
- teclado: conteúdo exato dos dois arquivos persistentes do projeto;
- Chicago95: arquivos essenciais do tema em `~/.themes/Chicago95`.

A opção `ALL` continua incluindo tarefas que já aparecem como instaladas ou configuradas. Cada tarefa aplica sua própria lógica de retorno rápido, reaplicação ou validação.

---

## 8. `sudo` e tratamento de erros

### 8.1 `sudo`

O setup não pode ser iniciado como root.

Depois da seleção das tarefas, ele calcula se alguma delas exige `sudo` e só então pede autenticação administrativa.

Exceções e detalhes:

- a instalação inicial de `whiptail`, se necessária, ocorre antes do menu e pode exigir `sudo`;
- `AUDIO` não exige `sudo`;
- `KEYBOARD` só solicita `sudo` quando precisa instalar `x11-xserver-utils`;
- `FONT` já instalada não solicita APT nem `sudo` por essa tarefa;
- `DOCKER` já completo não exige reinstalação nem autenticação apenas para mostrar versões;
- `CHICAGO95` só precisa de `sudo` quando há pacotes Debian de integração ausentes.

### 8.2 Erros

O script inicia com:

```bash
set -Eeuo pipefail
```

E mantém a tarefa atual em `CURRENT_TASK`.

Falhas normais são reportadas no idioma escolhido, com formato equivalente a:

```text
ERRO: TAREFA falhou na linha X (código Y). Setup interrompido.
```

ou:

```text
ERROR: TASK failed at line X (code Y). Setup aborted.
```

Cancelamentos normais de caixas `whiptail` continuam sendo tratados separadamente de erros reais.

A tarefa `DOCKER` é isolada: se falhar, o erro é registrado, as demais tarefas selecionadas continuam e o processo termina com código diferente de zero ao final.

---

## 9. Arquivos e integrações gerenciadas

Arquivos centrais documentados aqui:

```text
debian-xfce-setup/
├── setup.sh
├── DOCS.md
└── DOCS-en.md
```

O README do repositório é um artefato separado e não é substituído por estes documentos técnicos.

Arquivos criados ou gerenciados pelo setup podem incluir:

```text
/etc/apt/sources.list.d/vscode.sources
/usr/share/keyrings/microsoft.gpg
/etc/apt/sources.list.d/docker.sources
/etc/apt/keyrings/docker.asc
/opt/intellij
/usr/local/bin/idea
~/.config/debian-xfce-setup/keycode77.xmodmap
~/.config/autostart/debian-xfce-setup-keyboard.desktop
~/.local/share/sounds/Chicago95
~/.config/autostart/debian-xfce-setup-chicago95-startup.desktop
~/.local/share/debian-xfce-setup/chicago95-fonts/cronyx-cyrillic
```

Nem todos esses caminhos são criados em toda execução; dependem das opções escolhidas e do estado atual do sistema.

---

## 10. Validação

Para validar apenas a sintaxe Bash:

```bash
bash -n setup.sh
```

Para verificar whitespace e conflitos de patch antes de um commit:

```bash
git diff --check
```

Se `shellcheck` já estiver instalado:

```bash
shellcheck setup.sh
```

Testes manuais úteis incluem:

- abrir o seletor e testar `pt-BR`;
- abrir o seletor e testar `en`;
- cancelar o seletor de idioma;
- verificar a localização dos estados do menu;
- selecionar uma tarefa já instalada e confirmar o retorno idempotente;
- testar `FONT` sem mudança automática da interface;
- testar `DOCKER` completo e parcial;
- testar `KEYBOARD` em X11/XFCE;
- testar `CHICAGO95` em sessão gráfica XFCE;
- testar `AUDIO` sem alterações no sistema;
- conferir a expansão de `ALL`.

> **Observação:** testes automatizados do script devem evitar executar instalações reais, `sudo`, APT, clones ou alterações na configuração do usuário quando o objetivo for apenas validar lógica.

---

## 11. Limitações conhecidas

- o projeto é específico para Debian;
- a escolha de idioma é manual em toda execução e não é persistida;
- o timezone é definido como `America/Sao_Paulo`;
- IntelliJ possui instalação automatizada apenas para `amd64` e `arm64`;
- VS Code aceita `amd64`, `arm64` e `armhf`;
- `KEYBOARD` é específico para X11/XFCE e não adapta o remapeamento para Wayland;
- `KEYBOARD` reaproveita Num Lock, que perde sua função normal enquanto o mapeamento estiver ativo;
- `CHICAGO95` depende da estrutura conhecida do instalador upstream e aborta de forma segura quando as flags esperadas deixam de existir;
- a instalação inicial do Chicago95 exige uma sessão gráfica GTK3 funcional;
- Helvetica do Chicago95 é apenas preservada como dado, não instalada;
- wallpapers e botão Start do Chicago95 permanecem manuais;
- `DOCKER` é interrompido se pacotes conflitantes conhecidos forem encontrados;
- `AUDIO` oferece orientação, mas não configura dispositivos nem instala `alsa-utils`;
- algumas tarefas de instalação podem atualizar os índices do APT antes de instalar pacotes.

---

## 12. Segurança

O script executa operações administrativas e downloads externos. Antes de usar em uma máquina importante, revise `setup.sh` e as opções selecionadas.

Principais comportamentos de segurança e impacto:

- recusa execução como root;
- usa `sudo` apenas nas etapas que precisam de privilégios, além da possível instalação inicial de `whiptail`;
- adiciona o repositório oficial da Microsoft para instalar VS Code;
- adiciona o repositório oficial da Docker para instalar Docker Engine;
- baixa IntelliJ diretamente da JetBrains;
- baixa e executa o instalador oficial do Oh My Zsh;
- clona e executa o instalador oficial do Chicago95 em um diretório temporário, após aplicar e validar as restrições do projeto;
- não remove automaticamente pacotes conflitantes detectados pela tarefa Docker;
- não adiciona o usuário ao grupo `docker`;
- preserva arquivos personalizados encontrados nos diretórios gerenciados do Chicago95 em vez de sobrescrevê-los silenciosamente;
- rejeita links simbólicos ou destinos inesperados nos fluxos gerenciados de cópia do Chicago95;
- preserva `.zshrc` e conteúdo incompleto do Oh My Zsh em vez de sobrescrevê-los;
- não instala Helvetica nem modifica a configuração global de fontes.

---

`Debian XFCE Setup` busca tornar a preparação de um Debian XFCE repetível e inspecionável sem esconder as ações administrativas, os arquivos gerenciados ou os limites de cada integração.
