# frozen_string_literal: true

module Tzispa
  module Commands
    module Helpers
      module Repository

        REPO_STRUCTURE = %w(helpers model entity command).freeze

        MODEL_TEMPLATE = <<-MODTPL
# frozen_string_literal: true

require 'tzispa/data/entity'

module %s
  module Model
    class %s < Sequel::Model(:%s)
      include Tzispa::Data::Entity
      plugin :validation_helpers

      def validate
        true
      end
    end
  end
end
        MODTPL

        ENTITY_TEMPLATE = <<-ENTTTPL
# frozen_string_literal: true

require 'tzispa_utils'

module %s
  module Entity
    class %s < Tzispa::Utils::Decorator

    end
  end
end
        ENTTTPL

      end
    end
  end
end
