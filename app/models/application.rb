class Application < ApplicationRecord
  enum environment: [:staging, :production]
end
