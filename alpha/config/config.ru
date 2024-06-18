# frozen_string_literal: true

$stdout.sync = true
$stderr.sync = true

require 'rack'
use Rack::Deflater, if: ->(_, _, _, body) { body.any? && body[0].length > 512 }

require_relative '../code/alpha'
run Alpha.new
