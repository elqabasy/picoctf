# Main functionality dispatcher
COPY="false"
for arg in "$@"; do
    if [[ "$arg" == "--copy" ]]; then
        COPY="true"
        break
    fi
done

if [[ "$1" == "--help" || -z "$1" ]]; then
    show_help
    exit 0
fi

command=$1
shift

case $command in
    flag)
        picoflag "$@"
        ;;
    find)
        picofind "$@"
        ;;
    format)
        picoformat "$@"
        ;;
    *)
        echo "Invalid command: $command"
        echo "Use '--help' to see the available commands."
        exit 1
        ;;
esac
