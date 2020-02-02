# frozen_string_literal: true

# Profilers
# gem 'stackprof'         https://github.com/tmm1/stackprof
# gem 'ruby-prof'         https://ruby-prof.github.io/
# gem 'benchmark-ips'
# gem 'meta_request'
# gem 'memory_profiler'   https://github.com/SamSaffron/memory_profiler

# Performance.new(Class.new, :method, true).run_in(:stackprof)


class Performance
  PARAMS = ''


  STACKPROF_MODE = :wall
  UTILS = [:ruby_prof, :stackprof, :realtime, :memory_profiler]

  def initialize(object, method, gc_off = false)
    @object = object
    @method = method
    @gc_off = gc_off
    RubyProf.measure_mode = RubyProf::WALL_TIME
  end

  def run_in(util)
    raise 'Undefine method' unless UTILS.include?(util)

    send util
  end

  private

  def call_process
    GC.disable if gc_off?
    @object.send(@method, PARAMS)
  end

  def realtime
    time = Benchmark.realtime do
      call_process
    end
    puts "FINISHED IN #{time}"
  end

  # open in the kcachegrind
  def ruby_prof
    result = RubyProf.profile do
      call_process
    end

    printer = RubyProf::CallTreePrinter.new(result)
    printer.print(:path => "tmp/", :profile => "profile")
  end

  def stackprof
    StackProf.run(mode: STACKPROF_MODE, raw: true, out: 'tmp/stackprof.dump', interval: 1000) do
      call_process
    end
  end

  def memory_profiler
    report = MemoryProfiler.report do
      call_process
    end

    report.pretty_print(file: 'tmp/memory_profile')
  end

  def gc_off?
    @gc_off
  end
end
