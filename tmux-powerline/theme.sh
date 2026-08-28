# Custom tmux-powerline theme without hostname, IP, battery, or weather segments.

# Grayscale, HEX. Each segment uses foreground then background color.
GRAY_50="#fafafa"
GRAY_100="#f5f5f5"
GRAY_200="#e5e5e5"
GRAY_300="#d4d4d4"
GRAY_400="#a3a3a3"
GRAY_500="#737373"
GRAY_600="#525252"
GRAY_700="#404040"
GRAY_800="#262626"
GRAY_900="#171717"
GRAY_950="#0a0a0a"
WHITE="#ffffff"


# https://github.com/erikw/tmux-powerline/blob/main/themes/default.sh
TMUX_POWERLINE_LEFT_STATUS_SEGMENTS=(
	"tmux_session_info $GRAY_800 $WHITE"
	"pwd $GRAY_700 $WHITE"
	"vcs_branch $GRAY_600 $WHITE"
)



source "${TMUX_POWERLINE_DIR_THEMES}/default.sh"
TMUX_POWERLINE_STATUS_JUSTIFICATION="right"
TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS=()
