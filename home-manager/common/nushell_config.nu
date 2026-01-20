let carapace_completer = {|spans|
    load-env {
        CARAPACE_SHELL_BUILTINS: (help commands | where category != "" | get name | each { split row " " | first } | uniq  | str join "\n")
        CARAPACE_SHELL_FUNCTIONS: (help commands | where category == "" | get name | each { split row " " | first } | uniq  | str join "\n")
    }

    # if the current command is an alias, get it's expansion
    let expanded_alias = (scope aliases | where name == $spans.0 | $in.0?.expansion?)

    # overwrite
    let spans = (if $expanded_alias != null  {
        # put the first word of the expanded alias first in the span
        $spans | skip 1 | prepend ($expanded_alias | split row " " | take 1)
    } else { $spans })

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

# Nix run package
def --wrapped nrpkg [
    package: string,     # The Nix package name
    --impure (-i),        # Whether to add the --impure flag
    --unstable (-u),      # Whether to use nixpkgs-unstable instead of nixpkgs
    ...args: string      # Remaining arguments to pass to the command
] {
  let flake_ref = if $unstable { "nixpkgs-unstable" } else { "nixpkgs" }
  if $impure {
    $env.NIXPKGS_ALLOW_UNFREE = 1
  }
  ^nix run --inputs-from /nix/conf ...(
    []
    | (if $impure { append "--impure" })
    | append $"($flake_ref)#($package)"
    | append "--"
    | append $args
  )
}

# Nix shell package
def --wrapped nspkg [
    --impure (-i),        # Whether to add the --impure flag
    --unstable (-u),      # Whether to use nixpkgs-unstable instead of nixpkgs
    ...packages: string  # List of Nix package names
] {
  let flake_ref = if $unstable { "nixpkgs-unstable" } else { "nixpkgs" }
  if $impure {
    $env.NIXPKGS_ALLOW_UNFREE = 1
  }
  ^nix shell --inputs-from /nix/conf ...(
    []
    | (if $impure { append "--impure" })
    | append (
        $packages
        | each { |pkg| $"($flake_ref)#($pkg)" }
    )
  )
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
      let cwd = ($entries | group-by cwd --to-table | sort-by { get items | length } | last | get cwd)
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
  } -q (commandline) |
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
          cmd: "commandline edit --replace (skim-history)"
      }
  }
)

def nopts-sk [] {
  let db_location = $"($env.HOME)/.local/share/optinix/options.db"
  let options = open $db_location | get options | sk --format {get option_name} --preview {}
  let option_id = ($options | get id)
  let source_id = (open $db_location | get source_options | where option_id == $option_id | first | get source_id)
  let source_url = (open $db_location | get sources | where id == $source_id | first | get url)
  ($options | insert url $source_url)
}

def _npkgs_sk_internal [
    flake_ref: string,      # The Nix flake reference (e.g., "nixpkgs" or "nixpkgs-unstable")
    cache_file_name: string # The path to the cache file
] {
  if not ($cache_file_name | path exists) {
      ^nix search --json --inputs-from /nix/conf $flake_ref "" | from json | transpose name desc | save $cache_file_name
  }
  open $cache_file_name | sk --format {get name | str replace 'legacyPackages.x86_64-linux.' ""} --preview {get desc}
}

def npkgs-sk [] {
  const nix_search_packages_file = "/tmp/nix_search_packages.json"
  _npkgs_sk_internal "nixpkgs" $nix_search_packages_file
}

def npkgsu-sk [] {
  const nix_search_packages_unstable_file = "/tmp/nix_search_packages_unstable.json"
  _npkgs_sk_internal "nixpkgs-unstable" $nix_search_packages_unstable_file
}

# Load git aliases
overlay use ($nu.default-config-dir | path join "git-aliases.nu")

$env.config.hooks.pre_execution = $env.config.hooks.pre_execution | append {
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

# Redefine watch to a bash equivalent (only with -n option)
def --wrapped watch [ --interval (-n) = 2: int, ...command: string] {
    loop { clear -k; run-external ...$command; sleep ($interval * 1sec) }
}
