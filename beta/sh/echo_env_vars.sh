
# - - - - - - - - - - - - - - - - - - - - - - - -
echo_env_vars()
{
  local -r root_dir="$(git rev-parse --show-toplevel)"
  # Strip comments from .env file so env-vars can be exported
  grep -o '^[^#]*' ${root_dir}/.env
}
