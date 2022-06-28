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

# Make a copy
selectObject: "Sound cmn_ch1_band"
Copy: "cmn_ch1_band_d"

# Calculate first derivative
selectObject: "Sound cmn_ch1_band_d"
Formula: "self [col + 1] - self [col]"

result_file$ = "../data/derived/cmn.csv"
writeFileLine: result_file$, "word,int_duration,int_start,int_end,period_dur,egg_min_1,degg_max,degg_min,egg_min_2,degg_max_rel,degg_min_rel"
Read from file: "../data/raw/cmn.TextGrid"
n_int = Get number of intervals: 1

for int from 1 to n_int
  selectObject: "TextGrid cmn"
  int_lab$ = Get label of interval: 1, int

  if int_lab$ != ""
    int_start = Get start time of interval: 1, int
    int_end = Get end time of interval: 1, int
    int_dur = int_end - int_start

    selectObject: "Sound cmn_ch1_band"
    Extract part: int_start - 0.05, int_end + 0.05, "rectangular", 1, "yes"

    selectObject: "Sound cmn_ch1_band_part"
    noprogress To PointProcess (periodic, peaks): 75, 600, "yes", "no"

    selectObject: "Sound cmn_ch1_band_d"
    Extract part: int_start - 0.05, int_end + 0.05, "rectangular", 1, "yes"

    selectObject: "Sound cmn_ch1_band_d_part"
    noprogress To PointProcess (periodic, peaks): 75, 600, "yes", "no"

    selectObject: "PointProcess cmn_ch1_band_part"
    egg_points = Get number of points
    mean_period = Get mean period: 0, 0, 0.0001, 0.02, 1.3

    for point to egg_points - 2
      selectObject: "PointProcess cmn_ch1_band_part"
      point_1 = Get time from index: point
      point_2 = Get time from index: point + 1
      point_3 = Get time from index: point + 2

      selectObject: "Sound cmn_ch1_band_part"
      egg_minimum_1 = Get time of minimum: point_1, point_2, "Sinc70"
      egg_minimum_2 = Get time of minimum: point_2, point_3, "Sinc70"
      period = egg_minimum_2 - egg_minimum_1

      if period <= mean_period * 2
        selectObject: "PointProcess cmn_ch1_band_d_part"
        pp_degg_points = Get number of points

        if pp_degg_points != 0
          degg_maximum_point_1 = Get nearest index: egg_minimum_1
          degg_maximum = Get time from index: degg_maximum_point_1

          if degg_maximum <= egg_minimum_1
            degg_maximum = Get time from index: degg_maximum_point_1 + 1
          endif

          if degg_maximum != undefined
            selectObject: "Sound cmn_ch1_band_d_part"
            degg_minimum = Get time of minimum: degg_maximum, egg_minimum_2, "Sinc70"

            degg_maximum_rel = (degg_maximum - egg_minimum_1) / period
            degg_minimum_rel = (degg_minimum - egg_minimum_1) / period

            period = period * 1000
            result_line$ = "'int_lab$','int_dur','int_start','int_end','period','egg_minimum_1','degg_maximum','degg_minimum','egg_minimum_2','degg_maximum_rel','degg_minimum_rel'"

            appendFileLine: result_file$, result_line$
          endif
        endif
      endif

    endfor

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
