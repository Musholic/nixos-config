let carapace_completer = {|spans|
    carapace $spans.0 nushell ...$spans | from json
}
$env.config = {
  show_banner: false,
  completions: {
      case_sensitive: false # case-sensitive completions
      quick: true           # set to false to prevent auto-selecting completions
      partial: true         # set to false to prevent partial filling of the prompt
      algorithm: "fuzzy"    # prefix or fuzzy
      external: {
      # set to false to prevent nushell looking into $env.PATH to find more suggestions
      enable: true
      # set to lower can improve completion performance at the cost of omitting some options
      max_results: 100
      completer: $carapace_completer
      }
  }
}
$env.config.hooks.command_not_found = {
  |command_name|
  print (command-not-found $command_name | str trim)
}

# Functions for nrpkg (nix run package)
def --wrapped nrpkg [package: string, ...args] {
  if ($package | is-empty) {
    echo "Usage: nrpkg <package> <args>"
    return 1
  }

  if ($args | length) > 0 {
    nix run $"nixpkgs#($package)" -- ...$args
  } else {
    nix run $"nixpkgs#($package)"
  }
}

# Function for nspkg (nix shell package)
def --wrapped nspkg [...packages] {
  if ($packages | is-empty) {
    echo "Usage: nspkg <package1> [<package2> ...]"
    return 1
  }

  let pkg_list = ($packages | each { |pkg| $"nixpkgs#($pkg)" })
  nix shell ...$pkg_list
}

$env.config.history = {
  file_format: sqlite
  max_size: 1_000_000
  sync_on_enter: true
  isolation: true
}

# Skim integration for interactive command history search
def skim-history [] {
  # Get command history and group by command
  history |
  group-by command |
  items {|cmd, entries|
      # Calculate statistics for each command
      let count = ($entries | length)
      let last_entry = ($entries | last)
      # The most used directory
      let cwd = ($entries | group-by cwd --to-table | sort-by { get items | length } | last | get group)
      let is_current_dir = ($count > 2 and $cwd == $env.PWD)

      # Create record with command information
      {
          "command": $cmd,
          "count": $count,
          "cwd": $cwd,
          "is_current_dir": $is_current_dir,
          "last_time": ($last_entry | get start_timestamp)
      }
  } |
  # Sort first by current directory, then by count, then by last time
  sort-by is_current_dir count last_time --reverse |
  # Format for display with skim and return selected command
  sk --format {
      $"(ansi green_bold)($in.command) (ansi yellow)\(($in.last_time | date humanize)\) (ansi blue)x($in.count)(ansi reset)"
  } |
  $in.command? |
  default ""
}

# Add Ctrl+r keybinding for history search using skim
$env.config.keybindings = (
  $env.config.keybindings |
  append {
      name: skim_history
      modifier: control
      keycode: char_r
      mode: [emacs, vi_normal, vi_insert]
      event: {
          send: executehostcommand
          cmd: "commandline edit --insert (skim-history)"
      }
  }
)

def nhupdate [] {
    nrpkg home-manager switch
}

def nopts-sk [] {
  open ~/.local/share/optinix/options.db | get options | sk --format {get option_name} --preview {}
}
def npkgs-sk [] {
  const nix_search_packages_file = "/tmp/nix_search_packages.json"
  if not ($nix_search_packages_file | path exists) {
      nix search --json --inputs-from /nix/conf nixpkgs ^ | from json | transpose name desc | save $nix_search_packages_file
  }
  open $nix_search_packages_file | sk --format {get name | str replace 'legacyPackages.x86_64-linux.' ""} --preview {get desc}
}

# Load git aliases
overlay use ($nu.default-config-dir | path join "git-aliases.nu")

$env.config.hooks.pre_execution = {
  let last_cmd = (history | last | get command)

  # Skip if command is empty or very short
  if ($last_cmd | is-empty) or ($last_cmd | str length) < 4 {
    return
  }

  # Check for command prefixes that could use aliases
  let prefix_matches = (scope aliases | where { |alias|
    $last_cmd | str starts-with $alias.expansion
  })

  if (not ($prefix_matches | is-empty)) {
    # Get best match (longest expansion)
    let best_match = ($prefix_matches | sort-by { |a| $a.expansion | str length } | last)
    let remaining = ($last_cmd | str substring ($best_match.expansion | str length)..)

    print $"(ansi yellow_bold)Alias tip:(ansi reset) Use (ansi green_bold)($best_match.name)($remaining)(ansi reset)"
  }
}
