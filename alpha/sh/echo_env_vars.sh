
# - - - - - - - - - - - - - - - - - - - - - - - -
echo_env_vars()
{
  local -r root_dir="$(git rev-parse --show-toplevel)"
  cat "${root_dir}/.env"
}
