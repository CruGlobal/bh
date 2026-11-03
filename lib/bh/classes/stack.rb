module Bh
  module Classes
    # Must stay fiber-local (Thread.current[], not thread_variable_get): views
    # rendering at the same time, on other threads or in other fibers of this
    # thread (streamed layouts, fiber-per-request servers), must never see each
    # other's helpers.
    class Stack
      def self.with(item)
        stack.unshift item
        yield
      ensure
        stack.shift if stack.first.equal? item
      end

      def self.find(helper_class)
        stack.find{|helper| helper.is_a? helper_class}
      end

      def self.stack
        Thread.current[:bh_stack] ||= []
      end
      private_class_method :stack
    end
  end
end
