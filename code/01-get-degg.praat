Read from file: "../data/raw/topo.wav"

selectObject: "Sound topo"
Multiply: -1

selectObject: "Sound topo"
Extract one channel: 2

# Pass-band filter
selectObject: "Sound topo_ch2"
Filter (pass Hann band): 40, 10000, 100

# Smoothing filter
smooth_width = 11
@smoothing: smooth_width

# Smoothing shifts the signal
# So let's shift it back
sampling_period = Get sampling period
time_lag = (smooth_width - 1) / 2 * sampling_period
Shift times by: time_lag

Save as 32-bit WAV file: "../data/derived/topo-egg.wav"


# Make a copy
selectObject: "Sound topo_ch2_band"
Copy: "topo_ch2_band_d"

# Calculate first derivative
Formula: "self [col + 1] - self [col]"

Save as 32-bit WAV file: "../data/derived/topo-degg.wav"



# Smoothing procedure
procedure smoothing : .width
    .weight = .width / 2 + 0.5

    .formula$ = "( "

    for .w to .weight - 1
        .formula$ = .formula$ + string$(.w) + " * (self [col - " + string$(.w) + "] +
            ...self [col - " + string$(.w) + "]) + "
    endfor

    .formula$ = .formula$ + string$(.weight) + " * (self [col]) ) / " +
        ...string$(.weight ^ 2)

    Formula: .formula$
endproc