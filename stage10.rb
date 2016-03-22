
module Stage10
    class Stage10Runner
        def blep(foo)
            puts "Stage 10: #{foo}\n"
            bar = "[Stage10: #{foo}]"
            puts "Return value[10]: #{bar}\n"
            return bar
        end
    end
end

if __FILE__ == $0
    s10 = Stage10::Stage10Runner.new
    puts s10.blep(ARGV.join(" "))
end
