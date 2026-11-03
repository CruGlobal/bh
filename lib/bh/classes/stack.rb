module Bh
  module Classes
    # Must stay per thread: with one shared stack, a view on one thread sees
    # the helpers another thread is rendering (e.g. a mailer's link_to finds a
    # web request's nav and calls current_page?, which needs a request).
    class Stack
      def self.unshift(item)
        stack.unshift item
      end

      def self.shift
        stack.shift
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
