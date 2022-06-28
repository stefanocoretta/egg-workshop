Read from file: "../data/raw/cmn.wav"

selectObject: "Sound cmn"
Extract one channel: 1

# Pass-band filter
selectObject: "Sound cmn_ch1"
Filter (pass Hann band): 40, 10000, 100

# Smoothing filter
selectObject: "Sound cmn_ch1_band"
smooth_width = 5
@smoothing: smooth_width

# Smoothing shifts the signal
# So let's shift it back
sampling_period = Get sampling period
time_lag = (smooth_width - 1) / 2 * sampling_period
Shift times by: time_lag

noprogress To PointProcess (periodic, peaks): 75, 600, "yes", "no"

# Make a copy
selectObject: "Sound cmn_ch1_band"
Copy: "cmn_ch1_band_d"

# Calculate first derivative
selectObject: "Sound cmn_ch1_band_d"
Formula: "self [col + 1] - self [col]"

noprogress To PointProcess (periodic, peaks): 75, 600, "yes", "no"

result_file$ = "../data/derived/cmn.csv"
writeFileLine: result_file$, "word,period_dur,egg_min_1,degg_max,degg_min,egg_min_2,degg_max_rel,degg_min_rel"
Read from file: "../data/raw/cmn.TextGrid"

selectObject: "PointProcess cmn_ch1_band"
egg_points = Get number of points
mean_period = Get mean period: 0, 0, 0.0001, 0.02, 1.3

for point to egg_points - 2
  selectObject: "PointProcess cmn_ch1_band"
  point_1 = Get time from index: point
  point_2 = Get time from index: point + 1
  point_3 = Get time from index: point + 2

  selectObject: "Sound cmn_ch1_band"
  egg_minimum_1 = Get time of minimum: point_1, point_2, "Sinc70"
  egg_minimum_2 = Get time of minimum: point_2, point_3, "Sinc70"
  period = egg_minimum_2 - egg_minimum_1

  selectObject: "TextGrid cmn"
  int_id = Get interval at time: 1, egg_minimum_1
  int_lab$ = Get label of interval: 1, int_id

  if period <= mean_period * 2
    selectObject: "PointProcess cmn_ch1_band_d"
    pp_degg_points = Get number of points

    if pp_degg_points != 0
      degg_maximum_point_1 = Get nearest index: egg_minimum_1
      degg_maximum = Get time from index: degg_maximum_point_1

      if degg_maximum <= egg_minimum_1
        degg_maximum = Get time from index: degg_maximum_point_1 + 1
      endif

      if degg_maximum != undefined
        selectObject: "Sound cmn_ch1_band_d"
        degg_minimum = Get time of minimum: degg_maximum, egg_minimum_2, "Sinc70"

        degg_maximum_rel = (degg_maximum - egg_minimum_1) / period
        degg_minimum_rel = (degg_minimum - egg_minimum_1) / period

        period = period * 1000
        result_line$ = "'int_lab$','period','egg_minimum_1','degg_maximum','degg_minimum','egg_minimum_2','degg_maximum_rel','degg_minimum_rel'"

        appendFileLine: result_file$, result_line$
      endif
    endif
  endif

endfor




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
