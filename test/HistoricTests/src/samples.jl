module Samples

import Historic

Historic.@define Default
Default.isrecording() = true

Historic.@define Custom
Custom.isrecording() = true
Custom.defaultdata() = (; foo = :bar)
Custom.prefix() = "custom prefix"

default_simple() = Default.@record(:simple)
default_withdata(v) = Default.@record(:withdata, k = v)

custom_simple() = Custom.@record(:simple)
custom_withdata(v) = Custom.@record(:withdata, k = v)

end  # module
