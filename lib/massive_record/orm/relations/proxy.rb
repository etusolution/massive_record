module MassiveRecord
  module ORM
    module Relations
      
      #
      # Parent class for all proxies sitting between records
      #
      class Proxy
        instance_methods.each { |m| undef_method m unless m.to_s =~ /^(?:nil\?|send|object_id|to_a|inspect|to_s|extend|)$|^__|^respond_to|^should|^instance_variable_/ }

        attr_writer :target
        attr_accessor :owner, :metadata



        def target
          @target ||= find_target if find_target?
        end



        def loaded?
          !!@loaded
        end

        def loaded!
          @loaded = true
        end

        def reset
          @loaded = @target = nil
        end


        def respond_to?(*args)
          super || (target && target.respond_to?(*args))
        end

        def method_missing(method, *args, &block)
          return target.send(method, *args, &block) if target && target.respond_to?(method)
          super
        rescue NoMethodError => e
          raise e, e.message.sub(/ for #<.*$/, " via proxy for #{target}")
        end
      

        

        protected

        #
        # Abstract method used to find target for the proxy.
        #
        def find_target
          raise "Needs implementation!"
        end

        def find_target?
          !loaded?
        end
      end
    end
  end
end
