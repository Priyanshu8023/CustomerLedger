class RestoreMissingMigration < ActiveRecord::Migration[8.1]
  # The original file for this applied migration is missing from the repo.
  # Keep it as a no-op so the migration history stays consistent.
  def change; end
end
