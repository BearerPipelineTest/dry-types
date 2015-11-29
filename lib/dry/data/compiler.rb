module Dry
  module Data
    class Compiler
      attr_reader :registry

      def initialize(registry)
        @registry = registry
      end

      def call(ast)
        visit(ast)
      end

      def visit(node, *args)
        send(:"visit_#{node[0]}", node[1], *args)
      end

      def visit_type(node)
        type, args = node

        if respond_to?(:"visit_#{type}")
          send(:"visit_#{type}", args)
        else
          registry[type]
        end
      end

      def visit_sum_type(types)
        types.map { |name| registry[name] }.reduce(:|)
      end

      def visit_hash(node)
        constructor, schema = node
        registry['hash'].public_send(constructor, schema.map { |key| visit(key) }.reduce(:merge))
      end

      def visit_key(node)
        name, types = node
        { name => visit(types) }
      end
    end
  end
end
