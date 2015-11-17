module Tzispa
  module Controller
    module Error

      class ControllerError < StandardError; end;
      class Http < ControllerError; end;
      class Http_404 < Http; end;
      class InvalidSign < ControllerError; end;

    end
  end
end
