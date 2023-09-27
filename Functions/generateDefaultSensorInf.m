function sensorInf = generateDefaultSensorInf(sensor, n_band, ratio)
interplator = 'tap23';
sampling_opts = get_sampling_pars(ratio, interplator);
sensorInf.sensor = sensor;
[sensorInf.PSF_G, ~] = Blur_Kernel(n_band, sensor, ratio);
sensorInf.upsampling = sampling_opts.up;
sensorInf.upsampling.interplator = interplator;
sensorInf.downsampling = sampling_opts.down;
