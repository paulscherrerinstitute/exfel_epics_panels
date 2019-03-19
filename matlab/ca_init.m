
% Import the library
% TODO: Remember to copy the ca_matlab library into the directory containing this file
if not(exist('java_classpath_set', 'var'))
    javaaddpath('ca_matlab-1.0.0.jar')
    java_classpath_set = 1;
end

import ch.psi.jcae.*

% Use of SLS configuration
properties = java.util.Properties();
properties.setProperty('EPICS_CA_ADDR_LIST', '129.129.130.25');
properties.setProperty('EPICS_CA_MAX_ARRAY_BYTES', '131072');
properties.setProperty('EPICS_CA_SERVER_PORT', '5064');

context = Context(properties);

ibfb = ca_ibfb(context);
