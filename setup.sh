#!/usr/bin/env bash

set -Eeuo pipefail

# =========================================================
# Debian XFCE Setup
# =========================================================

TITLE="Debian XFCE Setup"
CURRENT_TASK="Preparação"

# Idioma mantido somente em memória; mensagens iniciais são bilíngues.
UI_LANG=""

msg_pt_br() {
    case "$1" in
        error_task) printf '\nERRO: %s falhou na linha %s (código %s). Setup interrompido.\n' "${@:2}" ;;
        dialog_error) printf 'Erro no whiptail (código %s): %s\n' "${@:2}" ;;
        sudo_missing) printf '%s\n' 'sudo não está disponível. Solicite sua configuração ao administrador.' ;;
        root_forbidden) printf '%s\n' 'Não execute este script como root.' ;;
        normal_user) printf '%s\n' 'Execute como usuário normal:' ;;
        os_unknown) printf '%s\n' 'Não foi possível identificar o sistema.' ;;
        debian_only) printf '%s\n' 'Este script foi feito para Debian.' ;;
        whiptail_install) printf '%s\n' 'whiptail não está disponível. Instalando dependência da interface...' ;;
        terminal_required) printf '%s\n' 'Execute em um terminal interativo com TERM configurado.' ;;
        apt_update) printf '%s\n' '==> Atualizando lista de pacotes...' ;;
        chicago_progress) printf '%s\n' '==> Chicago95...' ;;
        chicago_present) printf '%s\n' 'Chicago95 já está instalado.' ;;
        chicago_cancelled) printf '%s\n' 'Instalação Chicago95 cancelada.' ;;
        chicago_environment) printf '%s\n' 'ERRO: não foi possível validar o ambiente do instalador Chicago95 (veja o diagnóstico acima).' ;;
        chicago_invalid) printf '%s\n' 'ERRO: o instalador terminou, mas uma instalação válida do Chicago95 não foi localizada.' ;;
        helvetica_integrity) printf '%s\n' 'AVISO: arquivos Helvetica personalizados foram preservados; a cópia gerenciada não está íntegra.' ;;
        sound_session) printf '%s\n' 'Arquivos de sons instalados; aplique a preferência Chicago95 numa sessão XFCE.' ;;
        update_progress) printf '%s\n' '==> Atualizando Debian...' ;;
        java_progress) printf '%s\n' '==> Instalando Java...' ;;
        maven_progress) printf '%s\n' '==> Instalando Maven...' ;;
        git_progress) printf '%s\n' '==> Instalando Git...' ;;
        vscode_progress) printf '%s\n' '==> Instalando Visual Studio Code...' ;;
        vscode_present) printf '%s\n' 'VS Code já está instalado.' ;;
        intellij_progress) printf '%s\n' '==> Instalando IntelliJ IDEA...' ;;
        intellij_present) printf '%s\n' 'IntelliJ IDEA já está instalado.' ;;
        intellij_download) printf '%s\n' 'Baixando IntelliJ IDEA...' ;;
        intellij_invalid) printf '%s\n' 'O arquivo baixado não contém uma instalação válida do IntelliJ.' ;;
        intellij_target) printf '%s\n' 'Instalando em /opt/intellij...' ;;
        intellij_publish) printf '%s\n' 'Falha ao publicar a instalação do IntelliJ.' ;;
        intellij_done) printf '%s\n' 'IntelliJ IDEA instalado. Execute com: idea' ;;
        docker_progress) printf '%s\n' '==> Docker...' ;;
        docker_present) printf '%s\n' 'Docker já está instalado.' ;;
        docker_conflict_abort) printf '%s\n' 'Nenhum pacote foi removido. A tarefa Docker foi interrompida.' ;;
        docker_codename) printf '%s\n' 'ERRO: VERSION_CODENAME ausente em /etc/os-release.' ;;
        docker_done) printf '%s\n' 'Docker instalado. Se o acesso ao daemon exigir privilégios, use sudo docker.' ;;
        keyboard_login) printf '%s\n' 'Configuração persistida; será aplicada no próximo login compatível com X11/XFCE.' ;;
        keyboard_applied) printf '%s\n' 'Configuração do teclado já está aplicada nesta sessão.' ;;
        keyboard_done) printf '%s\n' 'Teclado configurado e aplicado nesta sessão X11.' ;;
        keyboard_invalid) printf '%s\n' 'ERRO: não foi possível validar o keycode 77 como backslash bar após a aplicação.' ;;
        keyboard_cancelled) printf '%s\n' 'Configuração do teclado cancelada.' ;;
        keyboard_target) printf '%s\n' 'ERRO: destino do teclado é um link ou não é um arquivo regular; preservado.' ;;
        keyboard_present) printf '%s\n' 'A configuração do teclado já existe.' ;;
        keyboard_migrated) printf '%s\n' 'Configuração legada migrada para os arquivos exclusivos do projeto.' ;;
        keepass_progress) printf '%s\n' '==> Instalando KeePassXC...' ;;
        zsh_progress) printf '%s\n' '==> Instalando Zsh + Oh My Zsh...' ;;
        zsh_incomplete) printf '%s\n' 'Instalação incompleta em ~/.oh-my-zsh. Preserve ou mova esse conteúdo antes de tentar novamente.' ;;
        omz_progress) printf '%s\n' 'Instalando Oh My Zsh...' ;;
        omz_empty) printf '%s\n' 'O instalador do Oh My Zsh está vazio.' ;;
        omz_failed) printf '%s\n' 'Oh My Zsh não foi instalado corretamente.' ;;
        omz_present) printf '%s\n' 'Oh My Zsh já está instalado.' ;;
        zsh_default) printf '%s\n' 'Alterando shell padrão para Zsh...' ;;
        zsh_login) printf '%s\n' 'Faça logout e login depois para usar o Zsh.' ;;
        font_progress) printf '%s\n' '==> Instalando/disponibilizando fonte Inter...' ;;
        font_present) printf '%s\n' 'Inter já está disponível no sistema.' ;;
        font_failed) printf '%s\n' 'ERRO: o pacote fonts-inter não ficou instalado.' ;;
        font_done) printf '%s\n' 'Inter disponível no sistema. A escolha da fonte da interface fica com você.' ;;
        time_progress) printf '%s\n' '==> Configurando timezone e sincronização...' ;;
        time_unavailable) printf '%s\n' 'Timezone não configurado: systemd/timedatectl ausentes ou inacessíveis.' ;;
        sudo_password) printf '%s\n' 'O instalador pode solicitar sua senha.' ;;
        docker_failed) printf '%s\n' 'ERRO: tarefa Docker falhou; continuando as demais tarefas.' ;;
        vscode_arch) printf 'Arquitetura não suportada pelo VS Code: %s\n' "${@:2}" ;;
        intellij_arch) printf 'Arquitetura não suportada pelo IntelliJ: %s\n' "${@:2}" ;;
        intellij_backup) printf 'Instalação anterior preservada em: %s\n' "${@:2}" ;;
        zshrc_preserved) printf 'Aviso: %s foi preservado, mas não foi identificado o carregamento de Oh My Zsh.\n' "${@:2}" ;;
        shell_unknown) printf 'Não foi possível consultar o shell cadastrado de %s.\n' "${@:2}" ;;
        zshrc_instruction) printf '%s\n' 'Confira se ele define ZSH e executa: source "$ZSH/oh-my-zsh.sh"' ;;
        docker_conflicts) printf 'ERRO: pacotes conflitantes com Docker: %s\n' "${@:2}" ;;
        chicago_help) printf '%s\n' 'Automático: tema pelo instalador oficial (se ausente), arquivos do tema de sons,
som de inicialização e autostart exclusivo do projeto.
A preferência de sons é aplicada quando a sessão XFCE estiver acessível.

A Helvetica fornecida pelo Chicago95 é uma fonte bitmap legada.
A Helvetica foi baixada, mas NÃO foi instalada.
Arquivos preservados em:
~/.local/share/debian-xfce-setup/chicago95-fonts/cronyx-cyrillic

Fontes bitmap podem causar problemas de renderização em aplicativos modernos,
como o Visual Studio Code/Electron/Chromium: textos de menus e outros elementos
da interface podem deixar de ser renderizados corretamente.
Por isso o Debian XFCE Setup não habilita nem instala Helvetica automaticamente.

Se quiser instalar Helvetica manualmente, consulte a documentação oficial,
ciente de que habilitar fontes bitmap pode afetar aplicativos modernos:
https://github.com/grassmunk/Chicago95/blob/master/INSTALL.md
https://github.com/grassmunk/Chicago95/blob/master/Extras/post_install.txt

Botão Start (manual): Configurações -> Painel -> Itens -> Whisker Menu ou
Applications Menu -> Propriedades -> Ícone. Imagens: ~/.themes/Chicago95/misc
Use painel com pelo menos aproximadamente 24 px para evitar problemas de escala.
Fundo clássico recomendado (manual): #008080.
Wallpapers no repositório: Extras/Backgrounds/Wallpaper e
Extras/Backgrounds/Patterns. Não foram copiados nem configurados.

Contingência opcional, SOMENTE se instalar Helvetica manualmente e o VS Code
apresentar problemas. Os comandos abaixo são orientação copiável; não executados:

cat > /tmp/vscode-fontconfig.conf <<'"'"'EOF'"'"'
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
EOF
FONTCONFIG_FILE=/tmp/vscode-fontconfig.conf \
FONTCONFIG_PATH=/etc/fonts \
code

Isso não remove Helvetica, não altera a fonte global do XFCE nem /etc/fonts,
não desabilita Chicago95. Inicia apenas aquele processo do VS Code com
fontconfig privado; pedidos por Helvetica são redirecionados para Noto Sans.
Ao iniciar VS Code normalmente, o override não será usado.
O arquivo em /tmp é temporário e pode desaparecer após reinicialização.' ;;
        chicago_confirm) printf '%s\n' 'Será aberto o instalador oficial do Chicago95.
Escolha os componentes desejados e conclua a instalação.
Fontes, fundo, painel e personalizações do shell/terminal serão bloqueados
nesta integração; Helvetica será apenas preservada como dados.
Ao fechar o instalador, o Debian XFCE Setup verificará se o tema foi
instalado corretamente.' ;;
        chicago_existing_done) printf '%s\n' 'Chicago95 já estava instalado; componentes gerenciados configurados.' ;;
        chicago_done) printf '%s\n' 'Chicago95 instalado/configurado.' ;;
        keyboard_preserve) printf '%s\n' 'Arquivos antigos não reconhecidos serão preservados.' ;;
        keyboard_legacy) printf '%s\n' 'Legado reconhecido: ~/.Xmodmap e autostart/xmodmap.desktop
serão removidos e substituídos pela configuração isolada.' ;;
        keyboard_help) printf '%s\n' 'Alguns teclados/layouts no X11/XFCE não permitem digitar
barra invertida (\) e pipe (|) corretamente. Esta configuração
corrige esse problema reaproveitando Num Lock (keycode 77).
Enquanto ativa, você perde a função normal da tecla Num Lock:
  Num Lock -> \    Shift + Num Lock -> |
Ela deixa de funcionar como Num Lock. O autostart mantém
esta alteração entre logins. Arquivos criados/atualizados:
~/.config/debian-xfce-setup/keycode77.xmodmap
~/.config/autostart/debian-xfce-setup-keyboard.desktop
Para desfazer, execute:
rm ~/.config/debian-xfce-setup/keycode77.xmodmap
rm ~/.config/autostart/debian-xfce-setup-keyboard.desktop
Depois faça logout/login.
No próximo login, esta alteração deixará de ser aplicada.' ;;
        keyboard_confirm) printf '%s\n' 'Deseja aplicar esta configuração?' ;;
        keyboard_title) printf '%s\n' 'Teclado X11 / XFCE' ;;
        audio_available) printf '%s\n' 'alsamixer está disponível.' ;;
        audio_missing) printf '%s\n' 'alsamixer não está instalado. Ele vem do pacote alsa-utils; instale-o quando desejar.' ;;
        audio_title) printf '%s\n' 'Áudio e microfone' ;;
        audio_help) printf '%s\n' 'Áudio e microfone podem ser
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
clipado.' ;;
        menu_help) printf '%s\n' 'Use ESPAÇO para marcar/desmarcar.
Use TAB para ir até OK.

O estado atual aparece ao lado:' ;;
        menu_all) printf '%s\n' 'Instalar/configurar tudo' ;;
        menu_update) printf '%s\n' 'Atualizar todos os pacotes' ;;
        menu_font) printf '%s\n' 'Fonte Inter' ;;
        menu_keyboard) printf '%s\n' 'Corrigir \ e | usando Num Lock (keycode 77)' ;;
        menu_audio) printf '%s\n' 'Mostrar configuração de áudio/microfone' ;;
        nothing_selected) printf '%s\n' 'Nenhuma opção foi selecionada.' ;;
        confirm) printf '%s\n' 'Deseja iniciar a instalação/configuração selecionada?' ;;
        final_done) printf '%s\n' 'Setup concluído.' ;;
        final_docker_error) printf '%s\n' 'Setup concluído com erro na tarefa Docker.' ;;
        final_help) printf '%s\n' 'Você pode executar este script
novamente quando quiser e marcar
somente outras opções.

Se instalou o Zsh ou alterou
configurações do XFCE, é recomendável
fazer logout e login novamente.' ;;
        copy_target) printf '%s\n' 'ERRO: destino estranho preservado: {}' ;;
        manifest_invalid) printf '%s\n' 'manifesto inválido' ;;
        manifest_path) printf '%s\n' 'caminho inválido no manifesto' ;;
        manifest_hash) printf '%s\n' 'hash inválido no manifesto' ;;
        manifest_target) printf '%s\n' 'ERRO: manifesto estranho preservado: {}' ;;
        manifest_legacy_target) printf '%s\n' 'manifesto legado estranho' ;;
        manifest_legacy_invalid) printf '%s\n' 'manifesto legado inválido' ;;
        manifest_preserved) printf '%s\n' 'ERRO: manifesto preservado: {}: {}' ;;
        copy_empty) printf '%s\n' 'ERRO: origem vazia: {}' ;;
        copy_link) printf '%s\n' 'ERRO: link inesperado na origem: {}' ;;
        copy_custom) printf '%s\n' 'AVISO: arquivo personalizado/preexistente preservado: {}' ;;
        copy_different) printf '%s\n' 'ERRO: arquivo diferente preservado: {}' ;;
        installer_structure) printf '%s\n' 'ERRO: estrutura do instalador oficial mudou; instalação interrompida.' ;;
        installer_flags) printf '%s\n' 'ERRO: estrutura do instalador oficial mudou; flags esperadas ausentes: {}; instalação interrompida.' ;;
        gtk_dependencies) printf '%s\n' 'ERRO: dependências PyGObject/GTK3 indisponíveis: {}' ;;
        gtk_session) printf '%s\n' 'ERRO: sessão gráfica GTK3 indisponível para o instalador Chicago95.' ;;
        button_ok) printf '%s\n' OK ;;
        button_cancel) printf '%s\n' Cancelar ;;
        button_yes) printf '%s\n' Sim ;;
        button_no) printf '%s\n' 'Não' ;;
        task_preparation) printf '%s\n' 'Preparação' ;;
        task_final) printf '%s\n' 'Mensagem final' ;;
        status_installed) printf '%s\n' '[INSTALADO]' ;;
        status_absent) printf '%s\n' '[NÃO INSTALADO]' ;;
        status_configured) printf '%s\n' '[CONFIGURADO]' ;;
        status_pending) printf '%s\n' '[PENDENTE]' ;;
        status_partial) printf '%s\n' '[PARCIAL]' ;;
        status_unavailable) printf '%s\n' '[INDISPONÍVEL]' ;;
        invalid_language) printf '%s\n' 'ERRO: idioma interno inválido.' ;;
        *) printf 'ERRO / ERROR: chave de tradução inválida / invalid translation key: %s\n' "$1" >&2; return 1 ;;
    esac
}

msg_en() {
    case "$1" in
        error_task) printf '\nERROR: %s failed at line %s (code %s). Setup aborted.\n' "${@:2}" ;;
        dialog_error) printf 'whiptail error (code %s): %s\n' "${@:2}" ;;
        sudo_missing) printf '%s\n' 'sudo is unavailable. Ask your administrator to configure it.' ;;
        root_forbidden) printf '%s\n' 'Do not run this script as root.' ;;
        normal_user) printf '%s\n' 'Run as a normal user:' ;;
        os_unknown) printf '%s\n' 'Could not identify the operating system.' ;;
        debian_only) printf '%s\n' 'This script is intended for Debian.' ;;
        whiptail_install) printf '%s\n' 'whiptail is unavailable. Installing the interface dependency...' ;;
        terminal_required) printf '%s\n' 'Run in an interactive terminal with TERM configured.' ;;
        apt_update) printf '%s\n' '==> Updating package lists...' ;;
        chicago_progress) printf '%s\n' '==> Chicago95...' ;;
        chicago_present) printf '%s\n' 'Chicago95 is already installed.' ;;
        chicago_cancelled) printf '%s\n' 'Chicago95 installation cancelled.' ;;
        chicago_environment) printf '%s\n' 'ERROR: could not validate the Chicago95 installer environment (see the diagnostic above).' ;;
        chicago_invalid) printf '%s\n' 'ERROR: the installer finished, but a valid Chicago95 installation was not found.' ;;
        helvetica_integrity) printf '%s\n' 'WARNING: customized Helvetica files were preserved; the managed copy failed integrity verification.' ;;
        sound_session) printf '%s\n' 'Sound files installed; apply the Chicago95 preference in an XFCE session.' ;;
        update_progress) printf '%s\n' '==> Updating Debian...' ;;
        java_progress) printf '%s\n' '==> Installing Java...' ;;
        maven_progress) printf '%s\n' '==> Installing Maven...' ;;
        git_progress) printf '%s\n' '==> Installing Git...' ;;
        vscode_progress) printf '%s\n' '==> Installing Visual Studio Code...' ;;
        vscode_present) printf '%s\n' 'VS Code is already installed.' ;;
        intellij_progress) printf '%s\n' '==> Installing IntelliJ IDEA...' ;;
        intellij_present) printf '%s\n' 'IntelliJ IDEA is already installed.' ;;
        intellij_download) printf '%s\n' 'Downloading IntelliJ IDEA...' ;;
        intellij_invalid) printf '%s\n' 'The downloaded archive does not contain a valid IntelliJ installation.' ;;
        intellij_target) printf '%s\n' 'Installing in /opt/intellij...' ;;
        intellij_publish) printf '%s\n' 'Failed to publish the IntelliJ installation.' ;;
        intellij_done) printf '%s\n' 'IntelliJ IDEA installed. Run with: idea' ;;
        docker_progress) printf '%s\n' '==> Docker...' ;;
        docker_present) printf '%s\n' 'Docker is already installed.' ;;
        docker_conflict_abort) printf '%s\n' 'No packages were removed. The Docker task was aborted.' ;;
        docker_codename) printf '%s\n' 'ERROR: VERSION_CODENAME is missing from /etc/os-release.' ;;
        docker_done) printf '%s\n' 'Docker installed. If daemon access requires privileges, use sudo docker.' ;;
        keyboard_login) printf '%s\n' 'Configuration saved; it will be applied at the next compatible X11/XFCE login.' ;;
        keyboard_applied) printf '%s\n' 'Keyboard configuration is already applied in this session.' ;;
        keyboard_done) printf '%s\n' 'Keyboard configured and applied in this X11 session.' ;;
        keyboard_invalid) printf '%s\n' 'ERROR: could not validate keycode 77 as backslash bar after applying the configuration.' ;;
        keyboard_cancelled) printf '%s\n' 'Keyboard configuration cancelled.' ;;
        keyboard_target) printf '%s\n' 'ERROR: the keyboard destination is a link or is not a regular file; preserved.' ;;
        keyboard_present) printf '%s\n' 'The keyboard configuration already exists.' ;;
        keyboard_migrated) printf '%s\n' 'Legacy configuration migrated to the project-specific files.' ;;
        keepass_progress) printf '%s\n' '==> Installing KeePassXC...' ;;
        zsh_progress) printf '%s\n' '==> Installing Zsh + Oh My Zsh...' ;;
        zsh_incomplete) printf '%s\n' 'Incomplete installation in ~/.oh-my-zsh. Preserve or move its contents before trying again.' ;;
        omz_progress) printf '%s\n' 'Installing Oh My Zsh...' ;;
        omz_empty) printf '%s\n' 'The Oh My Zsh installer is empty.' ;;
        omz_failed) printf '%s\n' 'Oh My Zsh was not installed correctly.' ;;
        omz_present) printf '%s\n' 'Oh My Zsh is already installed.' ;;
        zsh_default) printf '%s\n' 'Changing the default shell to Zsh...' ;;
        zsh_login) printf '%s\n' 'Log out and back in afterwards to use Zsh.' ;;
        font_progress) printf '%s\n' '==> Installing/making Inter font available...' ;;
        font_present) printf '%s\n' 'Inter is already available on the system.' ;;
        font_failed) printf '%s\n' 'ERROR: the fonts-inter package was not installed.' ;;
        font_done) printf '%s\n' 'Inter is available on the system. Interface font selection is left to you.' ;;
        time_progress) printf '%s\n' '==> Configuring timezone and synchronization...' ;;
        time_unavailable) printf '%s\n' 'Timezone not configured: systemd/timedatectl are missing or inaccessible.' ;;
        sudo_password) printf '%s\n' 'The installer may ask for your password.' ;;
        docker_failed) printf '%s\n' 'ERROR: the Docker task failed; continuing with the remaining tasks.' ;;
        vscode_arch) printf 'Architecture unsupported by VS Code: %s\n' "${@:2}" ;;
        intellij_arch) printf 'Architecture unsupported by IntelliJ: %s\n' "${@:2}" ;;
        intellij_backup) printf 'Previous installation preserved in: %s\n' "${@:2}" ;;
        zshrc_preserved) printf 'Warning: %s was preserved, but loading Oh My Zsh was not detected.\n' "${@:2}" ;;
        shell_unknown) printf 'Could not query the registered shell for %s.\n' "${@:2}" ;;
        zshrc_instruction) printf '%s\n' 'Check that it defines ZSH and runs: source "$ZSH/oh-my-zsh.sh"' ;;
        docker_conflicts) printf 'ERROR: conflicting Docker packages: %s\n' "${@:2}" ;;
        chicago_help) printf '%s\n' 'Automatic: theme via the official installer (if absent), sound theme files,
startup sound and project-specific autostart.
The sound preference is applied when the XFCE session is accessible.

The Helvetica supplied by Chicago95 is a legacy bitmap font.
Helvetica was downloaded, but was NOT installed.
Files preserved in:
~/.local/share/debian-xfce-setup/chicago95-fonts/cronyx-cyrillic

Bitmap fonts may cause rendering problems in modern applications,
such as Visual Studio Code/Electron/Chromium: menu text and other interface
elements may fail to render correctly.
Therefore Debian XFCE Setup does not enable or install Helvetica automatically.

To install Helvetica manually, consult the official documentation,
aware that enabling bitmap fonts may affect modern applications:
https://github.com/grassmunk/Chicago95/blob/master/INSTALL.md
https://github.com/grassmunk/Chicago95/blob/master/Extras/post_install.txt

Start button (manual): Settings -> Panel -> Items -> Whisker Menu or
Applications Menu -> Properties -> Icon. Images: ~/.themes/Chicago95/misc
Use a panel of at least approximately 24 px to avoid scaling problems.
Recommended classic background (manual): #008080.
Wallpapers in the repository: Extras/Backgrounds/Wallpaper and
Extras/Backgrounds/Patterns. They were not copied or configured.

Optional workaround, ONLY if you install Helvetica manually and VS Code
has problems. The commands below are copyable guidance; they are not executed:

cat > /tmp/vscode-fontconfig.conf <<'"'"'EOF'"'"'
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
EOF
FONTCONFIG_FILE=/tmp/vscode-fontconfig.conf \
FONTCONFIG_PATH=/etc/fonts \
code

This does not remove Helvetica, change the global XFCE font or /etc/fonts,
or disable Chicago95. It starts only that VS Code process with private
fontconfig; requests for Helvetica are redirected to Noto Sans.
Starting VS Code normally will not use the override.
The file in /tmp is temporary and may disappear after a reboot.' ;;
        chicago_confirm) printf '%s\n' 'The official Chicago95 installer will open.
Choose the desired components and complete the installation.
Fonts, background, panel and shell/terminal customizations will be blocked
in this integration; Helvetica will only be preserved as data.
After you close the installer, Debian XFCE Setup will verify that the theme
was installed correctly.' ;;
        chicago_existing_done) printf '%s\n' 'Chicago95 was already installed; managed components configured.' ;;
        chicago_done) printf '%s\n' 'Chicago95 installed/configured.' ;;
        keyboard_preserve) printf '%s\n' 'Unrecognized old files will be preserved.' ;;
        keyboard_legacy) printf '%s\n' 'Recognized legacy configuration: ~/.Xmodmap and autostart/xmodmap.desktop
will be removed and replaced by the isolated configuration.' ;;
        keyboard_help) printf '%s\n' 'Some keyboards/layouts in X11/XFCE cannot type
backslash (\) and pipe (|) correctly. This configuration
fixes the problem by repurposing Num Lock (keycode 77).
While active, you lose the normal function of the Num Lock key:
  Num Lock -> \    Shift + Num Lock -> |
It no longer works as Num Lock. Autostart keeps
this change between logins. Files created/updated:
~/.config/debian-xfce-setup/keycode77.xmodmap
~/.config/autostart/debian-xfce-setup-keyboard.desktop
To undo, run:
rm ~/.config/debian-xfce-setup/keycode77.xmodmap
rm ~/.config/autostart/debian-xfce-setup-keyboard.desktop
Then log out and back in.
At the next login, this change will no longer be applied.' ;;
        keyboard_confirm) printf '%s\n' 'Apply this configuration?' ;;
        keyboard_title) printf '%s\n' 'X11 / XFCE keyboard' ;;
        audio_available) printf '%s\n' 'alsamixer is available.' ;;
        audio_missing) printf '%s\n' 'alsamixer is not installed. It is provided by the alsa-utils package; install it whenever you wish.' ;;
        audio_title) printf '%s\n' 'Audio and microphone' ;;
        audio_help) printf '%s\n' 'Audio and microphone can be
configured with the same program:

    alsamixer


SHORTCUTS

F3  Audio output

F4  Input / microphone / Capture

F6  Select audio device

Esc Exit


DISTORTED/CLIPPING MICROPHONE

Switch to F4.

Look mainly for:

Capture
Mic Boost
Internal Mic Boost

If the microphone is distorting,
reduce Capture or Mic Boost first.

Simply lowering the volume afterwards
will not help if the incoming signal
is already clipping.' ;;
        menu_help) printf '%s\n' 'Use SPACE to select/deselect.
Use TAB to move to OK.

The current status appears alongside:' ;;
        menu_all) printf '%s\n' 'Install/configure everything' ;;
        menu_update) printf '%s\n' 'Update all packages' ;;
        menu_font) printf '%s\n' 'Inter font' ;;
        menu_keyboard) printf '%s\n' 'Fix \ and | using Num Lock (keycode 77)' ;;
        menu_audio) printf '%s\n' 'Show audio/microphone configuration' ;;
        nothing_selected) printf '%s\n' 'No options were selected.' ;;
        confirm) printf '%s\n' 'Start the selected installation/configuration?' ;;
        final_done) printf '%s\n' 'Setup completed.' ;;
        final_docker_error) printf '%s\n' 'Setup completed with an error in the Docker task.' ;;
        final_help) printf '%s\n' 'You can run this script again
whenever you want and select
only the other options.

If you installed Zsh or changed
XFCE settings, logging out and
back in is recommended.' ;;
        copy_target) printf '%s\n' 'ERROR: unexpected destination preserved: {}' ;;
        manifest_invalid) printf '%s\n' 'invalid manifest' ;;
        manifest_path) printf '%s\n' 'invalid path in manifest' ;;
        manifest_hash) printf '%s\n' 'invalid hash in manifest' ;;
        manifest_target) printf '%s\n' 'ERROR: unexpected manifest preserved: {}' ;;
        manifest_legacy_target) printf '%s\n' 'unexpected legacy manifest' ;;
        manifest_legacy_invalid) printf '%s\n' 'invalid legacy manifest' ;;
        manifest_preserved) printf '%s\n' 'ERROR: manifest preserved: {}: {}' ;;
        copy_empty) printf '%s\n' 'ERROR: empty source: {}' ;;
        copy_link) printf '%s\n' 'ERROR: unexpected link in source: {}' ;;
        copy_custom) printf '%s\n' 'WARNING: customized/pre-existing file preserved: {}' ;;
        copy_different) printf '%s\n' 'ERROR: different file preserved: {}' ;;
        installer_structure) printf '%s\n' 'ERROR: the official installer structure changed; installation aborted.' ;;
        installer_flags) printf '%s\n' 'ERROR: the official installer structure changed; expected flags missing: {}; installation aborted.' ;;
        gtk_dependencies) printf '%s\n' 'ERROR: PyGObject/GTK3 dependencies unavailable: {}' ;;
        gtk_session) printf '%s\n' 'ERROR: GTK3 graphical session unavailable for the Chicago95 installer.' ;;
        button_ok) printf '%s\n' OK ;;
        button_cancel) printf '%s\n' Cancel ;;
        button_yes) printf '%s\n' Yes ;;
        button_no) printf '%s\n' No ;;
        task_preparation) printf '%s\n' Preparation ;;
        task_final) printf '%s\n' 'Final message' ;;
        status_installed) printf '%s\n' '[INSTALLED]' ;;
        status_absent) printf '%s\n' '[NOT INSTALLED]' ;;
        status_configured) printf '%s\n' '[CONFIGURED]' ;;
        status_pending) printf '%s\n' '[PENDING]' ;;
        status_partial) printf '%s\n' '[PARTIAL]' ;;
        status_unavailable) printf '%s\n' '[UNAVAILABLE]' ;;
        invalid_language) printf '%s\n' 'ERROR: invalid internal language.' ;;
        *) printf 'ERRO / ERROR: chave de tradução inválida / invalid translation key: %s\n' "$1" >&2; return 1 ;;
    esac
}

msg() {
    case "$UI_LANG" in
        pt-BR) msg_pt_br "$@" ;;
        en) msg_en "$@" ;;
        "") msg_pt_br "$@"; msg_en "$@" ;;
        *) printf 'ERRO / ERROR: idioma interno inválido / invalid internal language\n' >&2; return 1 ;;
    esac
}

localized_status() {
    case "$1" in
        '[INSTALADO]') msg status_installed ;;
        '[NÃO INSTALADO]') msg status_absent ;;
        '[CONFIGURADO]') msg status_configured ;;
        '[PENDENTE]') msg status_pending ;;
        '[PARCIAL]') msg status_partial ;;
        '[INDISPONÍVEL]') msg status_unavailable ;;
        *) printf '%s\n' "$1" ;;
    esac
}

localized_task() {
    case "$CURRENT_TASK" in
        'Preparação')
            if [[ -z "$UI_LANG" ]]; then
                printf '%s\n' 'Preparação / Preparation'
            else
                msg task_preparation
            fi
            ;;
        'Mensagem final') msg task_final ;;
        UPDATE) msg menu_update ;;
        FONT) msg menu_font ;;
        KEYBOARD) msg keyboard_title ;;
        AUDIO) msg audio_title ;;
        JAVA) printf '%s\n' Java ;;
        MAVEN) printf '%s\n' 'Apache Maven' ;;
        GIT) printf '%s\n' Git ;;
        VSCODE) printf '%s\n' 'Visual Studio Code' ;;
        INTELLIJ) printf '%s\n' 'IntelliJ IDEA' ;;
        KEEPASSXC) printf '%s\n' KeePassXC ;;
        ZSH) printf '%s\n' 'Zsh + Oh My Zsh' ;;
        *) printf '%s\n' "$CURRENT_TASK" ;;
    esac
}

ui_dialog() {
    whiptail --ok-button "$(msg button_ok)" --cancel-button "$(msg button_cancel)" \
        --yes-button "$(msg button_yes)" --no-button "$(msg button_no)" "$@"
}

report_error() {
    local code="$1" line="$2"
    trap - ERR
    msg error_task "$(localized_task)" "$line" "$code" >&2
    exit "$code"
}
trap 'report_error "$?" "$LINENO"' ERR

require_sudo() {
    if ! command -v sudo >/dev/null 2>&1; then
        msg sudo_missing >&2
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
    msg dialog_error "$code" "$diagnostic" >&2
    exit "$code"
}

# ---------------------------------------------------------
# Verificações iniciais
# ---------------------------------------------------------

if [[ $EUID -eq 0 ]]; then
    msg root_forbidden
    msg normal_user
    echo
    echo "    ./setup.sh"
    exit 1
fi

if [[ ! -f /etc/os-release ]]; then
    msg os_unknown
    exit 1
fi

# shellcheck disable=SC1091
source /etc/os-release

if [[ "${ID:-}" != "debian" ]]; then
    msg debian_only
    exit 1
fi


# =========================================================
# Interface
# =========================================================

if ! command -v whiptail >/dev/null 2>&1; then
    msg whiptail_install
    require_sudo
    sudo apt update
    sudo apt install -y whiptail
fi


if [[ ! -t 0 || ! -t 1 || ! -t 2 || -z "${TERM:-}" || "${TERM:-}" == dumb ]]; then
    msg terminal_required >&2
    exit 1
fi

# Escolha explícita a cada execução; não consulta nem persiste locale.
UI_LANGUAGE_OUTPUT="$(
    whiptail --title "Language / Idioma" \
        --ok-button "OK" --cancel-button "Cancelar / Cancel" \
        --menu "Escolha o idioma / Choose the language" 12 60 2 \
        "pt-BR" "Português (Brasil)" \
        "en" "English" 3>&1 1>&2 2>&3
)" || handle_dialog_exit "$?" "$UI_LANGUAGE_OUTPUT"
UI_LANG="$UI_LANGUAGE_OUTPUT"
case "$UI_LANG" in
    pt-BR|en) ;;
    *) msg invalid_language >&2; exit 1 ;;
esac

# =========================================================
# Controle do APT
# =========================================================

APT_UPDATED=false

apt_update_once() {
    if [[ "$APT_UPDATED" == false ]]; then
        echo
        msg apt_update
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


docker_installed() {
    command -v docker >/dev/null 2>&1 \
        && command -v dockerd >/dev/null 2>&1 \
        && docker --version >/dev/null 2>&1 \
        && docker compose version >/dev/null 2>&1 \
        && docker buildx version >/dev/null 2>&1
}

status_docker() {
    if docker_installed; then
        echo "[INSTALADO]"
    elif command -v docker >/dev/null 2>&1 || command -v dockerd >/dev/null 2>&1; then
        echo "[PARCIAL]"
    else
        echo "[NÃO INSTALADO]"
    fi
}

keyboard_block() {
    printf '%s\n' 'remove mod2 = Num_Lock' 'keycode 77 = backslash bar'
}

keyboard_autostart() {
    # Desktop Entry não expande $HOME: o shell faz essa expansão no login.
    cat <<'EOF'
[Desktop Entry]
Type=Application
Name=Debian XFCE Setup - Keycode 77
Exec=sh -c "xmodmap \\"\\$HOME/.config/debian-xfce-setup/keycode77.xmodmap\\""
OnlyShowIn=XFCE;
Terminal=false
X-GNOME-Autostart-enabled=true
X-debian-xfce-setup=keycode-77
EOF
}

status_keyboard() {
    local map="$HOME/.config/debian-xfce-setup/keycode77.xmodmap"
    local desktop="$HOME/.config/autostart/debian-xfce-setup-keyboard.desktop"
    if [[ -f "$map" && -f "$desktop" ]] \
        && cmp -s <(keyboard_block) "$map" \
        && cmp -s <(keyboard_autostart) "$desktop"; then
        echo "[CONFIGURADO]"
    else
        echo "[PENDENTE]"
    fi
}

keyboard_legacy_pair() {
    local map="$HOME/.Xmodmap" desktop="$HOME/.config/autostart/xmodmap.desktop"
    local execution candidate
    [[ -f "$map" && ! -L "$map" && -f "$desktop" && ! -L "$desktop" ]] || return 1
    # Remove somente o par reconhecido. Um mapa personalizado precisa de seu
    # autostart antigo, mesmo quando o comando de carregamento é conhecido.
    cmp -s <(keyboard_block) <(awk '
        /^[[:space:]]*([#!]|$)/ { next }
        { sub(/^[[:space:]]+/, ""); sub(/[[:space:]]+$/, ""); print }
    ' "$map") || return 1
    execution="$(awk '
        /^\[/ { section=$0 }
        /^Exec=/ {
            if (section != "[Desktop Entry]") bad=1
            count++; sub(/^Exec=/, ""); print
        }
        END { if (count != 1 || bad) exit 1 }
    ' "$desktop")" || return 1
    # Lista estrita: nunca avalia comandos de um arquivo do usuário.
    while IFS= read -r candidate; do
        if [[ "$execution" == "$candidate" ]]; then
            return 0
        fi
    done <<'EOF'
sh -c "xmodmap \\"\\$HOME/.Xmodmap\\""
sh -c 'xmodmap "$HOME/.Xmodmap"'
sh -c 'xmodmap ~/.Xmodmap'
sh -c "xmodmap ~/.Xmodmap"
EOF
    [[ "$execution" == "xmodmap \"$HOME/.Xmodmap\"" ]] && return 0
    # Caminho sem aspas só é inequívoco sem metacaracteres de Desktop Entry.
    if [[ "$HOME" =~ ^/[a-zA-Z0-9_./-]+$ && "$execution" == "xmodmap $HOME/.Xmodmap" ]]; then
        return 0
    fi
    return 1
}


chicago95_installed() {
    local theme="$HOME/.themes/Chicago95"
    [[ -f "$theme/gtk-2.0/gtkrc" && -s "$theme/gtk-2.0/gtkrc" \
        && -f "$theme/xfwm4/themerc" && -s "$theme/xfwm4/themerc" \
        && -f "$theme/gtk-3.0/gtk.css" && -s "$theme/gtk-3.0/gtk.css" ]]
}

status_chicago95() {
    if chicago95_installed; then
        echo "[INSTALADO]"
    else
        echo "[NÃO INSTALADO]"
    fi
}

chicago95_missing_packages() {
    local package
    local -a packages=(git python3 gnome-session-canberra sox libcanberra-gtk3-module)
    if ! chicago95_installed; then
        packages+=(xfce4-panel-profiles gtk2-engines-pixbuf python3-gi gir1.2-gtk-3.0)
    fi
    for package in "${packages[@]}"; do
        if [[ "$(dpkg-query -W -f='${Status}' "$package" 2>/dev/null || true)" != 'install ok installed' ]]; then
            printf '%s\n' "$package"
        fi
    done
}

chicago95_needs_sudo() {
    [[ -n "$(chicago95_missing_packages)" ]]
}

chicago95_helvetica_downloaded() {
    local directory="$HOME/.local/share/debian-xfce-setup/chicago95-fonts/cronyx-cyrillic"
    python3 - "$directory" <<'PY'
import hashlib
import json
import pathlib
import re
import sys
directory = pathlib.Path(sys.argv[1])
manifest = directory / '.debian-xfce-setup-files.json'
try:
    for parent in (directory, *directory.parents):
        if parent.is_symlink() or not parent.is_dir():
            raise ValueError('diretório inválido')
    if manifest.is_symlink() or not manifest.is_file():
        raise ValueError('manifesto ausente')
    records = json.loads(manifest.read_text())
    if not isinstance(records, dict) or not records:
        raise ValueError('manifesto vazio/inválido')
    has_font = False
    for name, expected in records.items():
        relative = pathlib.PurePosixPath(name)
        if not name or relative.is_absolute() or '..' in relative.parts:
            raise ValueError('caminho inválido')
        if not isinstance(expected, str) or not re.fullmatch(r'[0-9a-f]{64}', expected):
            raise ValueError('hash inválido')
        target = directory / relative
        if any(parent.is_symlink() for parent in (target, *target.parents)):
            raise ValueError('link inesperado')
        if not target.is_file() or not target.stat().st_size:
            raise ValueError('arquivo ausente/vazio')
        if hashlib.sha256(target.read_bytes()).hexdigest() != expected:
            raise ValueError('hash diferente')
        has_font |= target.suffix == '.otb'
    if not has_font:
        raise ValueError('nenhuma fonte registrada')
except (OSError, ValueError, TypeError):
    raise SystemExit(1)
PY
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
    if [[ "$(dpkg-query -W -f='${Status}' fonts-inter 2>/dev/null || true)" == "install ok installed" ]]; then
        echo "[INSTALADO]"
    else
        echo "[NÃO INSTALADO]"
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

chicago95_startup_entry() {
    cat <<'EOF'
[Desktop Entry]
Type=Application
Name=Debian XFCE Setup - Chicago95 Startup
Exec=sh -c "sleep 3; /usr/bin/play \\"\\$HOME/.local/share/sounds/Chicago95/startup.ogg\\""
OnlyShowIn=XFCE;
Terminal=false
X-GNOME-Autostart-enabled=true
X-debian-xfce-setup=chicago95-startup
EOF
}

chicago95_copy_files() {
    # Não segue links no destino, inclusive nos seus diretórios ancestrais.
    # O manifesto permite atualizar versões antigas sem perder customizações.
    python3 - "$1" "$2" "${3:-}" \
        "$(msg copy_target)" \
        "$(msg manifest_invalid)" \
        "$(msg manifest_path)" \
        "$(msg manifest_hash)" \
        "$(msg manifest_target)" \
        "$(msg manifest_legacy_target)" \
        "$(msg manifest_legacy_invalid)" \
        "$(msg manifest_preserved)" \
        "$(msg copy_empty)" \
        "$(msg copy_link)" \
        "$(msg copy_custom)" \
        "$(msg copy_different)" <<'PY'
import hashlib
import json
import os
import pathlib
import re
import shutil
import sys
import tempfile
messages = dict(zip(('copy_target', 'manifest_invalid', 'manifest_path', 'manifest_hash', 'manifest_target', 'manifest_legacy_target', 'manifest_legacy_invalid', 'manifest_preserved', 'copy_empty', 'copy_link', 'copy_custom', 'copy_different'), sys.argv[4:]))
source, destination = map(pathlib.Path, sys.argv[1:3])
managed = sys.argv[3] == 'managed'
autostart = sys.argv[3] == 'autostart'
manifest = destination / '.debian-xfce-setup-files.json'
previous = {}
records = {}
def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()
def safe_directory(path):
    for parent in reversed((path, *path.parents)):
        if parent.is_symlink() or (parent.exists() and not parent.is_dir()):
            raise SystemExit(messages['copy_target'].format(parent))
    path.mkdir(parents=True, exist_ok=True)
def valid_records(value):
    if not isinstance(value, dict):
        raise ValueError(messages['manifest_invalid'])
    for name, checksum in value.items():
        relative = pathlib.PurePosixPath(name)
        if not name or relative.is_absolute() or '..' in relative.parts:
            raise ValueError(messages['manifest_path'])
        if not isinstance(checksum, str) or not re.fullmatch(r'[0-9a-f]{64}', checksum):
            raise ValueError(messages['manifest_hash'])
    return value
if managed:
    safe_directory(destination)
    if manifest.is_symlink() or (manifest.exists() and not manifest.is_file()):
        raise SystemExit(messages['manifest_target'].format(manifest))
    try:
        if manifest.exists():
            previous = valid_records(json.loads(manifest.read_text()))
        else:
            # Migra ownership da versão anterior, sem executar o manifesto.
            legacy = destination / '.debian-xfce-setup.sha256'
            if legacy.is_symlink() or (legacy.exists() and not legacy.is_file()):
                raise ValueError(messages['manifest_legacy_target'])
            if legacy.exists():
                for line in legacy.read_text().splitlines():
                    match = re.fullmatch(r'([0-9a-f]{64})  ([^/]+\.otb)', line)
                    if not match:
                        raise ValueError(messages['manifest_legacy_invalid'])
                    previous[match[2]] = match[1]
                valid_records(previous)
    except (ValueError, OSError, TypeError) as error:
        raise SystemExit(messages['manifest_preserved'].format(destination, error))
files = [source] if source.is_file() else sorted(source.rglob('*'))
if not files:
    raise SystemExit(messages['copy_empty'].format(source))
for item in files:
    if item.is_symlink():
        raise SystemExit(messages['copy_link'].format(item))
    target = destination if source.is_file() else destination / item.relative_to(source)
    if item.is_dir():
        safe_directory(target)
    elif item.is_file():
        safe_directory(target.parent)
        if target.is_symlink() or (target.exists() and not target.is_file()):
            raise SystemExit(messages['copy_target'].format(target))
        relative = str(item.relative_to(source)) if managed else ''
        if target.exists() and target.read_bytes() != item.read_bytes():
            if managed and previous.get(relative) == digest(target):
                shutil.copyfile(item, target)
            elif managed:
                print(messages['copy_custom'].format(target), file=sys.stderr)
                # Estado oficial esperado, mesmo quando o arquivo é preservado.
                records[relative] = digest(item)
                continue
            elif not (autostart and b'X-debian-xfce-setup=chicago95-startup' in target.read_bytes().splitlines()):
                raise SystemExit(messages['copy_different'].format(target))
        if autostart and (not target.exists() or target.read_bytes() != item.read_bytes()):
            # Publicação atômica no mesmo diretório; não segue o destino.
            temporary = None
            try:
                with tempfile.NamedTemporaryFile(dir=target.parent, prefix='.chicago95-startup-', delete=False) as output:
                    temporary = pathlib.Path(output.name)
                    output.write(item.read_bytes())
                temporary.chmod(0o644)
                os.replace(temporary, target)
            finally:
                if temporary is not None and temporary.exists():
                    temporary.unlink()
        elif not target.exists():
            shutil.copyfile(item, target)
        if managed:
            records[relative] = digest(item)
if managed:
    contents = json.dumps(records, sort_keys=True, indent=2) + '\n'
    if not manifest.exists() or manifest.read_text() != contents:
        manifest.write_text(contents)
PY
}

chicago95_prepare_installer() {
    # Restringe somente o clone descartável do instalador oficial. Os componentes
    # proibidos são bloqueados mesmo se marcados na interface gráfica.
    python3 - "$1/installer.py" "$(msg installer_structure)" "$(msg installer_flags)" <<'PY'
import ast
import pathlib
import sys
path = pathlib.Path(sys.argv[1])
text = path.read_text()
needle = '\tdef install_chicago95(self):\n'
if text.count(needle) != 1:
    raise SystemExit(sys.argv[2])
flags = ('install_sounds', 'install_fonts', 'install_background', 'panel', 'bash', 'zsh', 'terminal_colors', 'thunar')
tree = ast.parse(text)
# Confirma todas as flags no código original antes de inserir as restrições.
existing_flags = {
    node.attr for node in ast.walk(tree)
    if isinstance(node, ast.Attribute)
    and isinstance(node.value, ast.Name) and node.value.id == 'self'
}
missing_flags = [flag for flag in flags if flag not in existing_flags]
if missing_flags:
    raise SystemExit(sys.argv[3].format(', '.join(missing_flags)))
restriction = ''.join(f'\t\tself.{flag} = False\n' for flag in flags)
restriction += (
    '\t\toriginal_xfconf_query = self.xfconf_query\n'
    '\t\tself.xfconf_query = lambda channel, property, *args: None '
    'if "font" in property.lower() else original_xfconf_query(channel, property, *args)\n'
)
text = text.replace(needle, needle + restriction)
ast.parse(text)
path.write_text(text)
PY
}

show_chicago95_help() {
    local summary="$1" notice
    notice="$(msg chicago_help)"
    printf '\n%s\n%s\n' "$summary" "$notice"
    ui_dialog --title "Chicago95" --scrolltext --msgbox "$summary

$notice" 24 78
}

install_chicago95() {
    echo
    msg chicago_progress
    local installed=false diagnostic code package
    local -a missing=()
    if chicago95_installed; then
        installed=true
        msg chicago_present
    else
        if diagnostic="$(ui_dialog --title "Chicago95" --defaultno --yesno \
"$(msg chicago_confirm)" 14 78 3>&1 1>&2 2>&3)"; then
            :
        else
            code="$?"
            if [[ ( "$code" == 1 || "$code" == 255 ) && -z "$diagnostic" ]]; then
                msg chicago_cancelled
                return 0
            fi
            handle_dialog_exit "$code" "$diagnostic"
        fi
    fi
    while IFS= read -r package; do
        [[ -z "$package" ]] || missing+=("$package")
    done < <(chicago95_missing_packages)
    if (( ${#missing[@]} )); then
        apt_install "${missing[@]}"
    fi
    if [[ "$installed" == false ]] && ! python3 - "$(msg gtk_dependencies)" "$(msg gtk_session)" <<'PY'
import sys
try:
    import gi
    gi.require_version('Gtk', '3.0')
    from gi.repository import Gtk
except (ImportError, ValueError) as error:
    print(sys.argv[1].format(error), file=sys.stderr)
    raise SystemExit(1)
if not Gtk.init_check()[0]:
    print(sys.argv[2], file=sys.stderr)
    raise SystemExit(1)
PY
    then
        msg chicago_environment >&2
        return 1
    fi
    (
        local tmp_dir repo fonts desktop
        tmp_dir="$(mktemp -d)"
        trap 'rm -rf -- "$tmp_dir"' EXIT
        trap 'exit 130' INT
        trap 'exit 143' TERM
        repo="$tmp_dir/Chicago95"
        git clone --depth 1 https://github.com/grassmunk/Chicago95.git "$repo"
        if [[ "$installed" == false ]]; then
            chicago95_prepare_installer "$repo"
            (cd "$repo" && python3 installer.py)
            if ! chicago95_installed; then
                msg chicago_invalid >&2
                exit 1
            fi
        fi
        # Reúne os arquivos oficiais somente no temporário para gerenciar também
        # atualizações do som de login sem sobrescrever personalizações.
        cp -a -- "$repo/sounds/Chicago95" "$tmp_dir/sounds"
        cp -- "$repo/Extras/Microsoft Windows 95 Startup Sound.ogg" "$tmp_dir/sounds/startup.ogg"
        chicago95_copy_files "$tmp_dir/sounds" "$HOME/.local/share/sounds/Chicago95" managed
        desktop="$HOME/.config/autostart/debian-xfce-setup-chicago95-startup.desktop"
        chicago95_startup_entry > "$tmp_dir/startup.desktop"
        chicago95_copy_files "$tmp_dir/startup.desktop" "$desktop" autostart
        fonts="$HOME/.local/share/debian-xfce-setup/chicago95-fonts/cronyx-cyrillic"
        chicago95_copy_files "$repo/Fonts/bitmap/cronyx-cyrillic" "$fonts" managed
        if ! chicago95_helvetica_downloaded; then
            msg helvetica_integrity >&2
        fi
        if command -v xfconf-query >/dev/null 2>&1 \
            && xfconf-query -c xsettings -l >/dev/null 2>&1; then
            if xfconf-query -c xsettings -p /Net/SoundThemeName >/dev/null 2>&1; then
                xfconf-query -c xsettings -p /Net/SoundThemeName -s Chicago95
            else
                xfconf-query -c xsettings -p /Net/SoundThemeName --create --type string --set Chicago95
            fi
        else
            msg sound_session
        fi
    )
    if [[ "$installed" == true ]]; then
        show_chicago95_help "$(msg chicago_existing_done)"
    else
        show_chicago95_help "$(msg chicago_done)"
    fi
}


update_system() {
    echo
    msg update_progress

    apt_update_once
    sudo apt upgrade -y
}


install_java() {
    echo
    msg java_progress

    apt_install default-jdk

    java -version
}


install_maven() {
    echo
    msg maven_progress

    apt_install maven

    mvn --version
}


install_git() {
    echo
    msg git_progress

    apt_install git

    git --version
}


install_vscode() {
    echo
    msg vscode_progress

    if command -v code >/dev/null 2>&1; then
        msg vscode_present
        return
    fi

    local architecture
    architecture="$(dpkg --print-architecture)"
    case "$architecture" in
        amd64|arm64|armhf) ;;
        *) msg vscode_arch "$architecture" >&2; return 1 ;;
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
    msg intellij_progress

    if intellij_installed; then
        msg intellij_present
        return
    fi

    local architecture distribution
    architecture="$(dpkg --print-architecture)"
    case "$architecture" in
        amd64) distribution=linux ;;
        arm64) distribution=linuxARM64 ;;
        *) msg intellij_arch "$architecture" >&2; return 1 ;;
    esac

    apt_install curl ca-certificates

    # O subshell limita o trap à instalação e limpa também em caso de erro.
    (
        tmp_dir="$(mktemp -d)"
        stage_dir=""
        trap 'rm -rf -- "$tmp_dir"; if [[ -n "$stage_dir" ]]; then sudo rm -rf -- "$stage_dir"; fi' EXIT
        trap 'exit 130' INT
        trap 'exit 143' TERM

        msg intellij_download
        curl -fL \
            "https://download.jetbrains.com/product?code=IIU&latest&distribution=$distribution" \
            -o "$tmp_dir/intellij.tar.gz"

        mkdir -m 755 "$tmp_dir/new"
        tar -xzf "$tmp_dir/intellij.tar.gz" -C "$tmp_dir/new" \
            --strip-components=1 --no-same-owner --same-permissions
        if [[ ! -x "$tmp_dir/new/bin/idea.sh" \
            || ! -x "$tmp_dir/new/jbr/bin/java" || ! -d "$tmp_dir/new/lib" ]]; then
            msg intellij_invalid >&2
            exit 1
        fi

        msg intellij_target
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
            msg intellij_publish >&2
            exit 1
        fi

        sudo ln -sfnT /opt/intellij/bin/idea.sh /usr/local/bin/idea
        if [[ -n "$backup_dir" ]]; then
            msg intellij_backup "$backup_dir/installation"
        fi
        msg intellij_done
    )
}


install_docker() {
    echo
    msg docker_progress
    if docker_installed; then
        msg docker_present
        docker --version || return "$?"
        docker compose version || return "$?"
        docker buildx version || return "$?"
        return 0
    fi

    local package state architecture
    local -a conflicts=()
    for package in docker.io docker-compose docker-doc docker-buildx podman-docker containerd runc; do
        state="$(dpkg-query -W -f='${db:Status-Status}' "$package" 2>/dev/null || true)"
        if [[ "$state" == installed ]]; then
            conflicts+=("$package")
        fi
    done
    if (( ${#conflicts[@]} )); then
        msg docker_conflicts "${conflicts[*]}" >&2
        msg docker_conflict_abort >&2
        return 1
    fi
    if [[ -z "${VERSION_CODENAME:-}" ]]; then
        msg docker_codename >&2
        return 1
    fi
    architecture="$(dpkg --print-architecture)" || return "$?"

    # Retornos explícitos: esta tarefa é chamada em uma condição para isolar erros.
    if [[ "$APT_UPDATED" == false ]]; then
        sudo apt update || return "$?"
        APT_UPDATED=true
    fi
    sudo apt install -y --no-remove ca-certificates curl || return "$?"
    sudo install -m 0755 -d /etc/apt/keyrings || return "$?"
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg \
        -o /etc/apt/keyrings/docker.asc || return "$?"
    sudo chmod a+r /etc/apt/keyrings/docker.asc || return "$?"
    sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF || return "$?"
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $VERSION_CODENAME
Components: stable
Architectures: $architecture
Signed-By: /etc/apt/keyrings/docker.asc
EOF
    sudo apt update || return "$?"
    APT_UPDATED=true
    sudo apt install -y --no-remove docker-ce docker-ce-cli containerd.io \
        docker-buildx-plugin docker-compose-plugin || return "$?"
    docker --version || return "$?"
    docker compose version || return "$?"
    docker buildx version || return "$?"
    if command -v systemctl >/dev/null 2>&1 && [[ -d /run/systemd/system ]]; then
        sudo systemctl enable --now docker || return "$?"
        sudo systemctl is-active --quiet docker || return "$?"
    fi
    msg docker_done
    return 0
}

keyboard_runtime_correct() {
    # Os dois primeiros keysyms são os níveis sem Shift e com Shift.
    # X11 pode listar níveis/grupos adicionais (inclusive pares repetidos).
    awk '
        $1 == "keycode" && $2 == 77 && $3 == "=" {
            found=1
            correct=($4 == "backslash" && $5 == "bar")
        }
        END { exit !(found && correct) }
    ' <<< "$1"
}

apply_keyboard_runtime() {
    local map="$1" current diagnostic
    if [[ -z "${DISPLAY:-}" || "${XDG_SESSION_TYPE:-x11}" != x11 \
        || -n "${WAYLAND_DISPLAY:-}" ]] \
        || ! current="$(xmodmap -pke 2>/dev/null)"; then
        msg keyboard_login
        return 0
    fi
    if keyboard_runtime_correct "$current"; then
        msg keyboard_applied
        return 0
    fi

    # Uma operação intermediária pode falhar mesmo com o keycode correto.
    # Só a consulta final decide o resultado da aplicação nesta sessão.
    diagnostic="$(xmodmap "$map" 2>&1)" || true
    if current="$(xmodmap -pke 2>/dev/null)" \
        && keyboard_runtime_correct "$current"; then
        msg keyboard_done
        return 0
    fi
    msg keyboard_invalid >&2
    if [[ -n "$diagnostic" ]]; then
        printf '%s\n' "$diagnostic" >&2
    fi
    return 1
}

configure_keyboard() {
    local notice diagnostic code migrate=false
    local map="$HOME/.config/debian-xfce-setup/keycode77.xmodmap"
    local desktop="$HOME/.config/autostart/debian-xfce-setup-keyboard.desktop"
    local migration_notice
    migration_notice="$(msg keyboard_preserve)"
    if keyboard_legacy_pair; then
        migrate=true
        migration_notice="$(msg keyboard_legacy)"
    fi
    notice="$(msg keyboard_help)"
    notice+=$'\n'"$migration_notice"$'\n\n'"$(msg keyboard_confirm)"
    if diagnostic="$(ui_dialog --title "$(msg keyboard_title)" --defaultno \
        --yesno "$notice" 23 78 3>&1 1>&2 2>&3)"; then
        :
    else
        code="$?"
        if [[ ( "$code" == 1 || "$code" == 255 ) && -z "$diagnostic" ]]; then
            msg keyboard_cancelled
            return 0
        fi
        handle_dialog_exit "$code" "$diagnostic"
    fi

    if [[ -L "$map" || ( -e "$map" && ! -f "$map" ) \
        || -L "$desktop" || ( -e "$desktop" && ! -f "$desktop" ) ]]; then
        msg keyboard_target >&2
        return 1
    fi
    if ! command -v xmodmap >/dev/null 2>&1; then
        require_sudo
        sudo -v
        apt_install x11-xserver-utils
    fi

    if [[ "$(status_keyboard)" == '[CONFIGURADO]' ]]; then
        msg keyboard_present
    else
        mkdir -p -- "$HOME/.config/debian-xfce-setup" "$HOME/.config/autostart"
        if ! cmp -s <(keyboard_block) "$map"; then
            keyboard_block > "$map"
        fi
        if ! cmp -s <(keyboard_autostart) "$desktop"; then
            keyboard_autostart > "$desktop"
        fi
    fi

    # Revalida após a confirmação; só remove o legado após persistir os novos arquivos.
    if [[ "$migrate" == true ]] && keyboard_legacy_pair; then
        rm -- "$HOME/.config/autostart/xmodmap.desktop" "$HOME/.Xmodmap"
        msg keyboard_migrated
    fi

    apply_keyboard_runtime "$map"
}


install_keepassxc() {
    echo
    msg keepass_progress

    apt_install keepassxc
}


install_zsh() {
    echo
    msg zsh_progress

    apt_install zsh curl git

    local installer zsh_path passwd_entry registered_shell username
    if [[ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then
        # Uma pasta vazia pode ser removida; conteúdo incompleto é preservado.
        if [[ -e "$HOME/.oh-my-zsh" || -L "$HOME/.oh-my-zsh" ]]; then
            if ! rmdir -- "$HOME/.oh-my-zsh"; then
                msg zsh_incomplete >&2
                return 1
            fi
        fi
        msg omz_progress
        installer="$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        if [[ -z "$installer" ]]; then
            msg omz_empty >&2
            return 1
        fi
        ZSH="$HOME/.oh-my-zsh" RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$installer"
        if [[ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then
            msg omz_failed >&2
            return 1
        fi
    else
        msg omz_present
    fi

    local zshrc="${ZDOTDIR:-$HOME}/.zshrc"
    if [[ ! -f "$zshrc" ]] || ! grep -Eq '^[[:space:]]*(source|\.)[[:space:]]+[^#;]*oh-my-zsh\.sh' "$zshrc"; then
        msg zshrc_preserved "$zshrc"
        msg zshrc_instruction
    fi

    zsh_path="$(command -v zsh)"
    username="$(id -un)"
    passwd_entry="$(getent passwd "$username")"
    registered_shell="${passwd_entry##*:}"
    if [[ -z "$passwd_entry" || -z "$registered_shell" ]]; then
        msg shell_unknown "$username" >&2
        return 1
    fi
    if [[ "$(readlink -f -- "$registered_shell")" != "$(readlink -f -- "$zsh_path")" ]]; then
        msg zsh_default
        chsh -s "$zsh_path"
        msg zsh_login
    fi
}

configure_font() {
    echo
    msg font_progress
    if [[ "$(status_font)" == '[INSTALADO]' ]]; then
        msg font_present
        return 0
    fi

    apt_install fonts-inter
    if [[ "$(status_font)" != '[INSTALADO]' ]]; then
        msg font_failed >&2
        return 1
    fi
    msg font_done
}


configure_time() {
    echo
    msg time_progress

    if ! systemd_available; then
        msg time_unavailable >&2
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
    local audio_notice="$(msg audio_available)"
    if ! command -v alsamixer >/dev/null 2>&1; then
        audio_notice="$(msg audio_missing)"
    fi
    ui_dialog \
        --title "$(msg audio_title)" \
        --scrolltext \
        --msgbox \
"$audio_notice

$(msg audio_help)" \
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
DOCKER_STATUS="$(status_docker)"
KEYBOARD_STATUS="$(status_keyboard)"
CHICAGO95_STATUS="$(status_chicago95)"


# =========================================================
# MENU
# =========================================================

OPTIONS="$(
    ui_dialog \
        --title "$TITLE" \
        --separate-output \
        --checklist \
        "$(msg menu_help)" \
        22 78 10 \
        "ALL"       "$(msg menu_all)"                    OFF \
        "UPDATE"    "$(msg menu_update)"                  OFF \
        "JAVA"      "Java $(localized_status "$JAVA_STATUS")"                           OFF \
        "MAVEN"     "Apache Maven $(localized_status "$MAVEN_STATUS")"                  OFF \
        "GIT"       "Git $(localized_status "$GIT_STATUS")"                             OFF \
        "VSCODE"    "Visual Studio Code $(localized_status "$VSCODE_STATUS")"           OFF \
        "INTELLIJ"  "IntelliJ IDEA $(localized_status "$INTELLIJ_STATUS")"              OFF \
        "KEEPASSXC" "KeePassXC $(localized_status "$KEEPASSXC_STATUS")"                 OFF \
        "ZSH"       "Zsh + Oh My Zsh $(localized_status "$ZSH_STATUS")"                 OFF \
        "FONT"      "$(msg menu_font) $(localized_status "$FONT_STATUS")"                    OFF \
        "TIME"      "Timezone + NTP $(localized_status "$TIME_STATUS")"                 OFF \
        "DOCKER"    "Docker $(localized_status "$DOCKER_STATUS")"                       OFF \
        "KEYBOARD"  "$(msg menu_keyboard) $(localized_status "$KEYBOARD_STATUS")" OFF \
        "CHICAGO95" "Chicago95 $(localized_status "$CHICAGO95_STATUS")"                  OFF \
        "AUDIO"     "$(msg menu_audio)"     OFF \
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
DOCKER
KEYBOARD
CHICAGO95
AUDIO
"
fi


# =========================================================
# CONFIRMAÇÃO
# =========================================================

if [[ -z "${OPTIONS//[[:space:]]/}" ]]; then
    ui_dialog \
        --title "$TITLE" \
        --msgbox \
        "$(msg nothing_selected)" \
        8 45

    exit 0
fi


CONFIRM_OUTPUT="$(
    ui_dialog \
        --title "$TITLE" \
        --yesno \
        "$(msg confirm)" \
        10 60 3>&1 1>&2 2>&3
)" || handle_dialog_exit "$?" "$CONFIRM_OUTPUT"


# =========================================================
# AUTENTICAÇÃO SUDO
# =========================================================

NEEDS_SUDO=false
for option in UPDATE JAVA MAVEN GIT VSCODE INTELLIJ KEEPASSXC ZSH FONT TIME DOCKER CHICAGO95; do
    if selected "$option"; then
        # Estas instalações não fazem alterações quando já estão presentes.
        if [[ "$option" == VSCODE ]] && command -v code >/dev/null 2>&1; then
            continue
        fi
        if [[ "$option" == INTELLIJ ]] && intellij_installed; then
            continue
        fi
        if [[ "$option" == DOCKER ]] && docker_installed; then
            continue
        fi
        if [[ "$option" == FONT && "$(status_font)" == '[INSTALADO]' ]]; then
            continue
        fi
        if [[ "$option" == CHICAGO95 ]] && ! chicago95_needs_sudo; then
            continue
        fi
        NEEDS_SUDO=true
        break
    fi
done
if [[ "$NEEDS_SUDO" == true ]]; then
    require_sudo
    echo
    msg sudo_password
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
DOCKER_FAILED=false
if selected DOCKER; then
    CURRENT_TASK=DOCKER
    if install_docker; then
        :
    else
        DOCKER_FAILED=true
        msg docker_failed >&2
    fi
fi
if selected KEYBOARD; then
    CURRENT_TASK=KEYBOARD
    # O sudo desta tarefa só é solicitado após a confirmação específica.
    configure_keyboard
fi
if selected CHICAGO95; then
    CURRENT_TASK=CHICAGO95
    install_chicago95
fi
if selected AUDIO; then
    CURRENT_TASK=AUDIO
    show_audio_help
fi


# =========================================================
# FINAL
# =========================================================

FINAL_STATUS="$(msg final_done)"
if [[ "$DOCKER_FAILED" == true ]]; then
    FINAL_STATUS="$(msg final_docker_error)"
fi
CURRENT_TASK="Mensagem final"
ui_dialog \
    --title "$TITLE" \
    --msgbox \
"$FINAL_STATUS

$(msg final_help)" \
    15 60


echo
echo "======================================"
echo " $FINAL_STATUS"
echo "======================================"

if [[ "$DOCKER_FAILED" == true ]]; then
    exit 1
fi
