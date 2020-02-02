# Profiler
Adapter for profilers



##  Setting  
Setup PARAMS

## How use
modes = ruby_prof, :stackprof, :realtime, :memory_profiler

Performance.new(object, :method).run_in(:realtime)  
Performance.new(object, :method, true).run_in(:ruby_prof)  

report to tmp/
