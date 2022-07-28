# Note Taking from the command line, optionally rendered by Mkdocs
#!/bin/sh
BASEDIR=$HOME/medgedocs
NOTES_DIR=$BASEDIR/docs

usage() {
  echo "Usage: note CMD ARGS"
  echo "  cd - change directory to the notes base dir"
  echo "  today - Create and open a daily note named with the YYYY-MM-DD.md convention"
  echo "  new [NAME] - Create a new note with a given name"
  echo "  mkdir [NAME] - Create a new directory within the notes base dir"
  echo "  cat [NAME] - cat the contents of the given / current day's note"
  echo "  open [NAME] - open the contents of the given / current day's note in the shell EDITOR"
  echo "  ls - list notes in the Notes directory"
  echo "  del [NAME] - delete the given / current day's note"
  echo "  graphify [NAME] - Render any mermaidjs segments within the given note. Can be injected into the note as [Render any mermaidjs segments within the given note. Can be injected into the note as [](./NAME.md.svg)"
  echo " "
  echo "Utility functions:"
  echo "  opennotes - open and render notes with a Mkdocs container"
}

# CLI entrypoint
note() {
  DATE=$(date '+%Y-%m-%d')
  NOTE_NAME=${2:-$DATE}

  # Override behavior for `note mkdir`
  if [ "$1" = "mkdir" ]; then
    mkdir -p $NOTES_DIR/$2
    exit 0
  fi

  # Add extension if missing
  case "$NOTE_NAME" in
    *.md) ;;
    *) NOTE_NAME=$NOTE_NAME.md
  esac

  NOTE_PATH=$NOTES_DIR/$NOTE_NAME

  case $1 in
    cd)
      cd $NOTES_DIR
      ;;
    today)
      $EDITOR $NOTES_DIR/$DATE.md
      ;;
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
    graphify|g)
      npx -p @mermaid-js/mermaid-cli mmdc -i $NOTE_PATH -t dark -o $NOTE_PATH.svg
      ;;
    *)
      usage | echo
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
      COMPREPLY+=("cd")
      COMPREPLY+=("new")
      COMPREPLY+=("today")
      COMPREPLY+=("mkdir")
      COMPREPLY+=("cat")
      COMPREPLY+=("open")
      COMPREPLY+=("list")
      COMPREPLY+=("del")
      COMPREPLY+=("graphify")
      ;;
    2)
      # Complete subcommands with ls of notes directory
      notes=$(command find $NOTES_DIR | grep .md | sed -e "s|$NOTES_DIR/||g")
      COMPREPLY=($(compgen -W "${notes}" -- ${cur}))
      ;;
    *)
      COMPREPLY=()
      ;;
  esac
}

complete -F _note_completions note

# Start the Mkdocs app and open the UI in a browser
opennotes() {
  base=$(pwd)
  cd $BASEDIR
  make up
  cd ${orig}
  open http://localhost:8000
}

