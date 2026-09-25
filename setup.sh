#!/usr/bin/env bash

set -Eeuo pipefail

# =========================================================
# Debian XFCE Setup
# =========================================================

TITLE="Debian XFCE Setup"
CURRENT_TASK="Preparação"

report_error() {
    local code="$1" line="$2"
    trap - ERR
    printf '\nERRO: %s falhou na linha %s (código %s). Setup interrompido.\n' \
        "$CURRENT_TASK" "$line" "$code" >&2
    exit "$code"
}
trap 'report_error "$?" "$LINENO"' ERR

require_sudo() {
    if ! command -v sudo >/dev/null 2>&1; then
        echo "sudo não está disponível. Solicite sua configuração ao administrador." >&2
        return 1
    fi
}

# whiptail usa 1 para Cancelar/Não e 255 para Esc ou erro.
# Diagnósticos capturados permitem reconhecer erros com a mesma saída 255.
handle_dialog_exit() {
    local code="$1" diagnostic="$2"
    if [[ ( "$code" == 1 || "$code" == 255 ) && -z "$diagnostic" ]]; then
        exit 0
    fi
    printf 'Erro no whiptail (código %s): %s\n' "$code" "$diagnostic" >&2
    exit "$code"
}

# ---------------------------------------------------------
# Verificações iniciais
# ---------------------------------------------------------

if [[ $EUID -eq 0 ]]; then
    echo "Não execute este script como root."
    echo "Execute como usuário normal:"
    echo
    echo "    ./setup.sh"
    exit 1
fi

if [[ ! -f /etc/os-release ]]; then
    echo "Não foi possível identificar o sistema."
    exit 1
fi

# shellcheck disable=SC1091
source /etc/os-release

if [[ "${ID:-}" != "debian" ]]; then
    echo "Este script foi feito para Debian."
    exit 1
fi


# =========================================================
# Interface
# =========================================================

if ! command -v whiptail >/dev/null 2>&1; then
    echo "whiptail não está disponível. Instalando dependência da interface..."
    require_sudo
    sudo apt update
    sudo apt install -y whiptail
fi


if [[ ! -t 0 || ! -t 1 || ! -t 2 || -z "${TERM:-}" || "${TERM:-}" == dumb ]]; then
    echo "Execute em um terminal interativo com TERM configurado." >&2
    exit 1
fi

# =========================================================
# Controle do APT
# =========================================================

APT_UPDATED=false

apt_update_once() {
    if [[ "$APT_UPDATED" == false ]]; then
        echo
        echo "==> Atualizando lista de pacotes..."
        sudo apt update
        APT_UPDATED=true
    fi
}

apt_install() {
    apt_update_once
    sudo apt install -y "$@"
}


# =========================================================
# FUNÇÕES DE STATUS
# =========================================================

status_command() {
    if command -v "$1" >/dev/null 2>&1; then
        echo "[INSTALADO]"
    else
        echo "[NÃO INSTALADO]"
    fi
}


status_java() {
    if command -v javac >/dev/null 2>&1; then
        echo "[INSTALADO]"
    else
        echo "[NÃO INSTALADO]"
    fi
}


intellij_installed() {
    [[ -x "$HOME/.local/share/JetBrains/Toolbox/apps/intellij-idea/bin/idea" ]] \
        || command -v idea >/dev/null 2>&1 \
        || [[ -x /opt/intellij/bin/idea.sh ]]
}

status_intellij() {
    if intellij_installed; then

        echo "[INSTALADO]"
    else
        echo "[NÃO INSTALADO]"
    fi
}


status_zsh() {
    if command -v zsh >/dev/null 2>&1 \
        && [[ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then

        echo "[INSTALADO]"
    else
        echo "[NÃO INSTALADO]"
    fi
}


status_font() {
    local current_font=""

    if command -v xfconf-query >/dev/null 2>&1; then
        current_font="$(
            xfconf-query \
                -c xsettings \
                -p /Gtk/FontName \
                2>/dev/null || true
        )"
    fi

    if [[ "$(dpkg-query -W -f='${Status}' fonts-inter 2>/dev/null || true)" == "install ok installed" ]] \
        && [[ "$current_font" =~ ^Inter([[:space:]]|$) ]]; then

        echo "[CONFIGURADO]"
    else
        echo "[PENDENTE]"
    fi
}


systemd_available() {
    command -v systemctl >/dev/null 2>&1 \
        && command -v timedatectl >/dev/null 2>&1 \
        && [[ -d /run/systemd/system ]] \
        && timedatectl show >/dev/null 2>&1
}

status_time() {
    if ! systemd_available; then
        echo "[INDISPONÍVEL]"
        return
    fi
    local timezone=""
    local ntp=""

    timezone="$(
        timedatectl show \
            -p Timezone \
            --value \
            2>/dev/null || true
    )"

    ntp="$(
        timedatectl show \
            -p NTP \
            --value \
            2>/dev/null || true
    )"

    if [[ "$timezone" == "America/Sao_Paulo" \
        && "$ntp" == "yes" ]]; then

        echo "[CONFIGURADO]"
    else
        echo "[PENDENTE]"
    fi
}


# =========================================================
# FUNÇÕES DE INSTALAÇÃO
# =========================================================

update_system() {
    echo
    echo "==> Atualizando Debian..."

    apt_update_once
    sudo apt upgrade -y
}


install_java() {
    echo
    echo "==> Instalando Java..."

    apt_install default-jdk

    java -version
}


install_maven() {
    echo
    echo "==> Instalando Maven..."

    apt_install maven

    mvn --version
}


install_git() {
    echo
    echo "==> Instalando Git..."

    apt_install git

    git --version
}


install_vscode() {
    echo
    echo "==> Instalando Visual Studio Code..."

    if command -v code >/dev/null 2>&1; then
        echo "VS Code já está instalado."
        return
    fi

    local architecture
    architecture="$(dpkg --print-architecture)"
    case "$architecture" in
        amd64|arm64|armhf) ;;
        *) echo "Arquitetura não suportada pelo VS Code: $architecture" >&2; return 1 ;;
    esac

    apt_install wget gpg ca-certificates

    sudo mkdir -p /usr/share/keyrings

    wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
        | gpg --dearmor \
        | sudo tee /usr/share/keyrings/microsoft.gpg >/dev/null

    sudo chmod 644 /usr/share/keyrings/microsoft.gpg

    sudo tee /etc/apt/sources.list.d/vscode.sources >/dev/null <<EOF
Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: $architecture
Signed-By: /usr/share/keyrings/microsoft.gpg
EOF

    sudo apt update
    APT_UPDATED=true

    sudo apt install -y code
}


install_intellij() {
    echo
    echo "==> Instalando IntelliJ IDEA..."

    if intellij_installed; then
        echo "IntelliJ IDEA já está instalado."
        return
    fi

    local architecture distribution
    architecture="$(dpkg --print-architecture)"
    case "$architecture" in
        amd64) distribution=linux ;;
        arm64) distribution=linuxARM64 ;;
        *) echo "Arquitetura não suportada pelo IntelliJ: $architecture" >&2; return 1 ;;
    esac

    apt_install curl ca-certificates

    # O subshell limita o trap à instalação e limpa também em caso de erro.
    (
        tmp_dir="$(mktemp -d)"
        stage_dir=""
        trap 'rm -rf -- "$tmp_dir"; if [[ -n "$stage_dir" ]]; then sudo rm -rf -- "$stage_dir"; fi' EXIT
        trap 'exit 130' INT
        trap 'exit 143' TERM

        echo "Baixando IntelliJ IDEA..."
        curl -fL \
            "https://download.jetbrains.com/product?code=IIU&latest&distribution=$distribution" \
            -o "$tmp_dir/intellij.tar.gz"

        mkdir -m 755 "$tmp_dir/new"
        tar -xzf "$tmp_dir/intellij.tar.gz" -C "$tmp_dir/new" \
            --strip-components=1 --no-same-owner --same-permissions
        if [[ ! -x "$tmp_dir/new/bin/idea.sh" \
            || ! -x "$tmp_dir/new/jbr/bin/java" || ! -d "$tmp_dir/new/lib" ]]; then
            echo "O arquivo baixado não contém uma instalação válida do IntelliJ." >&2
            exit 1
        fi

        echo "Instalando em /opt/intellij..."
        sudo mkdir -p /opt /usr/local/bin
        stage_dir="$(sudo mktemp -d /opt/.intellij.XXXXXX)"
        sudo cp -a -- "$tmp_dir/new" "$stage_dir/new"
        sudo chown -R root:root "$stage_dir/new"

        backup_dir=""
        if [[ -e /opt/intellij || -L /opt/intellij ]]; then
            backup_dir="$(sudo mktemp -d /opt/intellij.backup.XXXXXX)"
            sudo mv -T -- /opt/intellij "$backup_dir/installation"
        fi
        if ! sudo mv -T -- "$stage_dir/new" /opt/intellij; then
            if [[ -n "$backup_dir" ]]; then
                sudo mv -T -- "$backup_dir/installation" /opt/intellij
                sudo rmdir -- "$backup_dir"
            fi
            echo "Falha ao publicar a instalação do IntelliJ." >&2
            exit 1
        fi

        sudo ln -sfnT /opt/intellij/bin/idea.sh /usr/local/bin/idea
        if [[ -n "$backup_dir" ]]; then
            echo "Instalação anterior preservada em: $backup_dir/installation"
        fi
        echo "IntelliJ IDEA instalado. Execute com: idea"
    )
}


install_keepassxc() {
    echo
    echo "==> Instalando KeePassXC..."

    apt_install keepassxc
}


install_zsh() {
    echo
    echo "==> Instalando Zsh + Oh My Zsh..."

    apt_install zsh curl git

    local installer zsh_path passwd_entry registered_shell username
    if [[ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then
        # Uma pasta vazia pode ser removida; conteúdo incompleto é preservado.
        if [[ -e "$HOME/.oh-my-zsh" || -L "$HOME/.oh-my-zsh" ]]; then
            if ! rmdir -- "$HOME/.oh-my-zsh"; then
                echo "Instalação incompleta em ~/.oh-my-zsh. Preserve ou mova esse conteúdo antes de tentar novamente." >&2
                return 1
            fi
        fi
        echo "Instalando Oh My Zsh..."
        installer="$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        if [[ -z "$installer" ]]; then
            echo "O instalador do Oh My Zsh está vazio." >&2
            return 1
        fi
        ZSH="$HOME/.oh-my-zsh" RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$installer"
        if [[ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then
            echo "Oh My Zsh não foi instalado corretamente." >&2
            return 1
        fi
    else
        echo "Oh My Zsh já está instalado."
    fi

    local zshrc="${ZDOTDIR:-$HOME}/.zshrc"
    if [[ ! -f "$zshrc" ]] || ! grep -Eq '^[[:space:]]*(source|\.)[[:space:]]+[^#;]*oh-my-zsh\.sh' "$zshrc"; then
        echo "Aviso: $zshrc foi preservado, mas não foi identificado o carregamento de Oh My Zsh."
        echo 'Confira se ele define ZSH e executa: source "$ZSH/oh-my-zsh.sh"'
    fi

    zsh_path="$(command -v zsh)"
    username="$(id -un)"
    passwd_entry="$(getent passwd "$username")"
    registered_shell="${passwd_entry##*:}"
    if [[ -z "$passwd_entry" || -z "$registered_shell" ]]; then
        echo "Não foi possível consultar o shell cadastrado de $username." >&2
        return 1
    fi
    if [[ "$(readlink -f -- "$registered_shell")" != "$(readlink -f -- "$zsh_path")" ]]; then
        echo "Alterando shell padrão para Zsh..."
        chsh -s "$zsh_path"
        echo "Faça logout e login depois para usar o Zsh."
    fi
}

configure_font() {
    echo
    echo "==> Instalando e configurando fonte Inter..."

    if ! command -v xfconf-query >/dev/null 2>&1; then
        echo "Não foi possível configurar a fonte: xfconf-query/XFCE ausente." >&2
        return 1
    fi
    if ! xfconf-query -c xsettings -l >/dev/null 2>&1; then
        echo "Não foi possível acessar o XFCE. Execute dentro da sessão gráfica do usuário." >&2
        return 1
    fi

    local current_font chosen_font="Inter 11" font_exists=false
    if current_font="$(xfconf-query -c xsettings -p /Gtk/FontName 2>/dev/null)"; then
        font_exists=true
        if [[ "$current_font" =~ ^Inter([[:space:]]|$) ]]; then
            chosen_font="$current_font"
        fi
    fi

    apt_install fonts-inter fontconfig
    fc-cache -f

    if [[ "$font_exists" == true ]]; then
        xfconf-query -c xsettings -p /Gtk/FontName -s "$chosen_font"
    else
        xfconf-query -c xsettings -p /Gtk/FontName --create --type string --set "$chosen_font"
    fi
    if [[ "$(xfconf-query -c xsettings -p /Gtk/FontName)" != "$chosen_font" ]]; then
        echo "A configuração da fonte Inter não foi aplicada." >&2
        return 1
    fi

    echo
    echo "Fonte configurada:"

    xfconf-query \
        -c xsettings \
        -p /Gtk/FontName

    whiptail \
        --title "Fonte Inter" \
        --scrolltext \
        --msgbox \
"A fonte do XFCE foi definida como:

$chosen_font

Observação:

Em alguns casos, depois de alterar
resolução ou monitor no XFCE, a tela

Configurações > Aparência > Fontes

pode deixar de aplicar alterações
corretamente.

O comando usado diretamente é:

xfconf-query -c xsettings \
-p /Gtk/FontName \
-s \"$chosen_font\"

Se isso acontecer, aplicar a fonte
pelo terminal costuma destravar
novamente a configuração gráfica." \
        20 72
}


configure_time() {
    echo
    echo "==> Configurando timezone e sincronização..."

    if ! systemd_available; then
        echo "Timezone não configurado: systemd/timedatectl ausentes ou inacessíveis." >&2
        return 1
    fi

    apt_install systemd-timesyncd

    sudo timedatectl \
        set-timezone America/Sao_Paulo

    sudo systemctl \
        enable --now systemd-timesyncd

    sudo timedatectl set-ntp true

    echo
    timedatectl
}


show_audio_help() {
    local audio_notice="alsamixer está disponível."
    if ! command -v alsamixer >/dev/null 2>&1; then
        audio_notice="alsamixer não está instalado. Ele vem do pacote alsa-utils; instale-o quando desejar."
    fi
    whiptail \
        --title "Áudio e microfone" \
        --scrolltext \
        --msgbox \
"$audio_notice

Áudio e microfone podem ser
configurados pelo mesmo programa:

    alsamixer


ATALHOS

F3  Saída de áudio

F4  Entrada / microfone / Capture

F6  Selecionar placa de áudio

Esc Sair


MICROFONE ESTOURANDO

Entre em F4.

Procure principalmente:

Capture
Mic Boost
Internal Mic Boost

Se o microfone estiver distorcendo,
reduza primeiro Capture ou Mic Boost.

Não adianta apenas diminuir o volume
depois se o sinal já estiver entrando
clipado." \
        20 72
}


# =========================================================
# VERIFICAR ESTADO ATUAL
# =========================================================

JAVA_STATUS="$(status_java)"
MAVEN_STATUS="$(status_command mvn)"
GIT_STATUS="$(status_command git)"
VSCODE_STATUS="$(status_command code)"
INTELLIJ_STATUS="$(status_intellij)"
KEEPASSXC_STATUS="$(status_command keepassxc)"
ZSH_STATUS="$(status_zsh)"
FONT_STATUS="$(status_font)"
TIME_STATUS="$(status_time)"


# =========================================================
# MENU
# =========================================================

OPTIONS="$(
    whiptail \
        --title "$TITLE" \
        --separate-output \
        --checklist \
        "Use ESPAÇO para marcar/desmarcar.
Use TAB para ir até OK.

O estado atual aparece ao lado:" \
        22 78 10 \
        "ALL"       "Instalar/configurar tudo"                    OFF \
        "UPDATE"    "Atualizar todos os pacotes"                  OFF \
        "JAVA"      "Java $JAVA_STATUS"                           OFF \
        "MAVEN"     "Apache Maven $MAVEN_STATUS"                  OFF \
        "GIT"       "Git $GIT_STATUS"                             OFF \
        "VSCODE"    "Visual Studio Code $VSCODE_STATUS"           OFF \
        "INTELLIJ"  "IntelliJ IDEA $INTELLIJ_STATUS"              OFF \
        "KEEPASSXC" "KeePassXC $KEEPASSXC_STATUS"                 OFF \
        "ZSH"       "Zsh + Oh My Zsh $ZSH_STATUS"                 OFF \
        "FONT"      "Fonte Inter no XFCE $FONT_STATUS"            OFF \
        "TIME"      "Timezone + NTP $TIME_STATUS"                 OFF \
        "AUDIO"     "Mostrar configuração de áudio/microfone"     OFF \
        3>&1 1>&2 2>&3
)" || handle_dialog_exit "$?" "$OPTIONS"


# =========================================================
# VERIFICAR SE FOI SELECIONADO
# =========================================================

selected() {
    printf '%s\n' "$OPTIONS" | grep -Fxq "$1"
}


# =========================================================
# OPÇÃO "TUDO"
# =========================================================

if selected ALL; then
    OPTIONS="
UPDATE
JAVA
MAVEN
GIT
VSCODE
INTELLIJ
KEEPASSXC
ZSH
FONT
TIME
AUDIO
"
fi


# =========================================================
# CONFIRMAÇÃO
# =========================================================

if [[ -z "${OPTIONS//[[:space:]]/}" ]]; then
    whiptail \
        --title "$TITLE" \
        --msgbox \
        "Nenhuma opção foi selecionada." \
        8 45

    exit 0
fi


CONFIRM_OUTPUT="$(
    whiptail \
        --title "$TITLE" \
        --yesno \
        "Deseja iniciar a instalação/configuração selecionada?" \
        10 60 3>&1 1>&2 2>&3
)" || handle_dialog_exit "$?" "$CONFIRM_OUTPUT"


# =========================================================
# AUTENTICAÇÃO SUDO
# =========================================================

NEEDS_SUDO=false
for option in UPDATE JAVA MAVEN GIT VSCODE INTELLIJ KEEPASSXC ZSH FONT TIME; do
    if selected "$option"; then
        # Estas instalações não fazem alterações quando já estão presentes.
        if [[ "$option" == VSCODE ]] && command -v code >/dev/null 2>&1; then
            continue
        fi
        if [[ "$option" == INTELLIJ ]] && intellij_installed; then
            continue
        fi
        NEEDS_SUDO=true
        break
    fi
done
if [[ "$NEEDS_SUDO" == true ]]; then
    require_sudo
    echo
    echo "O instalador pode solicitar sua senha."
    sudo -v
fi


# =========================================================
# EXECUÇÃO
# =========================================================

if selected UPDATE; then
    CURRENT_TASK=UPDATE
    update_system
fi
if selected JAVA; then
    CURRENT_TASK=JAVA
    install_java
fi
if selected MAVEN; then
    CURRENT_TASK=MAVEN
    install_maven
fi
if selected GIT; then
    CURRENT_TASK=GIT
    install_git
fi
if selected VSCODE; then
    CURRENT_TASK=VSCODE
    install_vscode
fi
if selected INTELLIJ; then
    CURRENT_TASK=INTELLIJ
    install_intellij
fi
if selected KEEPASSXC; then
    CURRENT_TASK=KEEPASSXC
    install_keepassxc
fi
if selected ZSH; then
    CURRENT_TASK=ZSH
    install_zsh
fi
if selected FONT; then
    CURRENT_TASK=FONT
    configure_font
fi
if selected TIME; then
    CURRENT_TASK=TIME
    configure_time
fi
if selected AUDIO; then
    CURRENT_TASK=AUDIO
    show_audio_help
fi


# =========================================================
# FINAL
# =========================================================

CURRENT_TASK="Mensagem final"
whiptail \
    --title "$TITLE" \
    --msgbox \
"Setup concluído.

Você pode executar este script
novamente quando quiser e marcar
somente outras opções.

Se instalou o Zsh ou alterou
configurações do XFCE, é recomendável
fazer logout e login novamente." \
    15 60


echo
echo "======================================"
echo " Setup concluído"
echo "======================================"
