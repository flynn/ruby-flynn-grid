# Since both Celluloid and Minitest use at_exit hooks, we need to ensure
# that the Minitest hook runs before the Celluloid one (so Celluloid has
# not shutdown when the tests run), so we need to require Minitest *after*
# Celluloid (as at_exit hooks are called in reverse order)
require "flynn/grid"
require "minitest/autorun"

require "support/grid_integration_test"
require "support/rpcplus_mock_client"

# Only log Celluloid errors
Celluloid.logger.level = Logger::ERROR
