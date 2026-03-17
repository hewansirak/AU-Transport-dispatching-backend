module Api
  module V1
    class BaseController < ApplicationController
      # All V1 controllers inherit from here.
      # Add V1-specific behaviour here later (versioned serializers, etc.)
    end
  end
end