require "test_helper"

class DoorCheck::PackagingTest < ActiveSupport::TestCase
  test "the packaged gem carries the three the_local agents" do
    gemspec = Gem::Specification.load(File.expand_path("../../door_check.gemspec", __dir__))
    agents = %w[info install develop].map { |facet| "the_local/agents/door_check-#{facet}.md" }

    assert_empty agents - gemspec.files
  end
end
