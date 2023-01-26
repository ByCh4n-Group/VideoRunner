#!/bin/bash
STARTFILE="$@"

notify-send -u critical "Linux Video Viewer 1.0" "Welcome $USER"

savesettingsfunc () {
    echo "MPVARGS="\"$MPVARGS\""" > ~/.config/mhykol/mhykol.conf
}

bychan () {
    yad --html --window-icon="bychan.png" --title="Bychan" --width=600 --height=400 --uri="https://github.com/ByCh4n-Group" --button=Ok:0
    mpvfile "$STARTFILE"
}

if ! type mpv &>/dev/null;then
    DLG=$(yad --form --window-icon="mhykol.png" \
        --borders=10 \
        --text="MPV not found\n\n  Install it first and run the script again" --button="OK" \
        --title="Linux Video Viewer 1.0" --center --undecorated \
    )
    exit
fi

mpvfile () {
    . ~/.config/mhykol/mhykol.conf
    MPVFILE="$(yad --form --window-icon="mhykol.png" --title="Linux Video Viewer 1.0" \
    --width=600 \
    --height=400 \
    --button=Close:1 \
    --button=Bychan:2 \
    --button=Ok:0 \
    --separator="," \
    --item-separator=" " \
    --text="Linux Video Viewer\n\nInput the arguments you would like to run mpv with.\nThen select the files you would like to play or input a url to play.\n\n\n" \
    --field="Mpv Arguments" "$MPVARGS" \
    --field="File(s)":MFL "" \
    --field="URL(s)" "$STARTFILE")"
    case $? in
        0)
            MPVARGS="${MPVARGS##,*}"
            if [[ "${MPVARGS::1}" != " " ]]; then
                MPVARGS=" $MPVARGS"
            fi
            savesettingsfunc
            MPVFILE="$(echo "$MPVFILE" | tr ',' ' ')"
            mpvrun
            ;;
        1)
            exit 0
            ;;
        2)
            bychan
            ;;
    esac
}

mpvrun () {
    mpv$MPVFILE
    case $? in
        0)
            if [ ! -f ~/.config/mpv/mpv.conf ]; then
                yad --question --title="Linux Video Viewer" --text="Would you like to make a mpv.conf file with the arguments you just used?"
                if [ $? -eq 0 ]; then
                    if [ ! -d ~/.config/mpv ]; then
                        mkdir ~/.config/mpv
                    fi
                    echo " $MPVARGS" | sed -e 's: --:\n:g' > ~/.config/mpv/mpv.conf && yad --window-icon="mhykol.png" --info --title="Linux Video Viewer" --width=400 --height=200 --text="Config file written to ~/.config/mpv/mpv.conf"
                fi
            fi
            mpvfile
            ;;
        *)
            yad --error --window-icon="mhykol.png" --title="Linux Video Viewer" --width=400 --height=200 --button=Ok:0 --text="Mpv closed unexpectedly!"
            mpvfile
            ;;
    esac
}

if [ ! -d ~/.config/mhykol ]; then
    mkdir ~/.config/mhykol
fi
if [ ! -f ~/.config/mhykol/mhykol.conf ]; then
    MPVARGS=" --border=no --vo=gpu --hwdec=vaapi"
    savesettingsfunc
fi
mpvfile "$STARTFILE"
