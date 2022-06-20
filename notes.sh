# Note Taking, hosted by Mkdocs
NOTES_DIR=$CODE_DIR/medgedocs/docs

# Start the Mkdocs app and open the UI in a browser
opennotes() {
  base=$(pwd)
  cd $NOTES_DIR
  cd ../
  make up
  cd ${orig}
  open http://localhost:8000
}

alias todos="$EDITOR $NOTES_DIR/index.md"
alias cdnotes="cd $NOTES_DIR"

# CLI for interacting with note files
# Usage: note CMD [NAME]
#    if no NAME, it will generate a YYYY-MM-DD.md name
note() {
  DATE=$(date '+%Y-%m-%d')
  NOTE_NAME=${2:-$DATE}

  # Override behavior for `note mkdir`
  if [ "$1" = "mkdir" ]; then
    mkdir -p $NOTES_DIR/$2
  fi

  # Add extension if missing
  case "$NOTE_NAME" in
    *.md) ;;
    *) NOTE_NAME=$NOTE_NAME.md
  esac

  NOTE_PATH=$NOTES_DIR/$NOTE_NAME

  case $1 in
    new|n)
      $EDITOR $NOTE_PATH
      ;;
    cat|c)
      cat $NOTE_PATH
      ;;
    ls|l)
      ls $NOTES_DIR
      ;;
    open|o)
      $EDITOR $NOTE_PATH
      ;;
    del|d)
      rm $NOTE_PATH
      ;;
    *)
      echo "Usage: note CMD ARGS"
      echo "  new [NAME] - Create a new note, optionally with a given name"
      echo "  mkdir [NAME] - Create a new directory within the notes base dir"
      echo "  cat [NAME] - cat the contents of the given / current day's note"
      echo "  open [NAME] - open the contents of the given / current day's note in the shell EDITOR"
      echo "  list [NAME] - list notes in the Notes directory"
      echo "  del [NAME] - delete the given / current day's note"
      ;;
  esac
}

# Notes Shell Completion
_note_completions() {
  local cur prev notes
  cur=${COMP_WORDS[COMP_CWORD]}
  prev=${COMP_WORDS[COMP_CWORD-1]}

  case ${COMP_CWORD} in
    1)
      # Complete `note` with subcommands
      COMPREPLY+=("new")
      COMPREPLY+=("mkdir")
      COMPREPLY+=("cat")
      COMPREPLY+=("open")
      COMPREPLY+=("list")
      COMPREPLY+=("del")
      ;;
    2)
      # Complete subcommands with ls of notes directory
      notes=$(command ls $NOTES_DIR)
      COMPREPLY=($(compgen -W "${notes}" -- ${cur}))
      ;;
    *)
      COMPREPLY=()
      ;;
  esac
}

complete -F _note_completions note
