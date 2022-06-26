Read from file: "../data/derived/topo-egg.wav"
noprogress To PointProcess (periodic, peaks): 75, 600, "yes", "no"
Read from file: "../data/derived/topo-degg.wav"
noprogress To PointProcess (periodic, peaks): 75, 600, "yes", "no"


result_file$ = "../data/derived/topo.csv"
writeFileLine: result_file$, "period_dur,egg_min_1,degg_max,degg_min,egg_min_2,degg_max_rel,degg_min_rel"

selectObject: "PointProcess topo-egg"
egg_points = Get number of points
mean_period = Get mean period: 0, 0, 0.0001, 0.02, 1.3

for point to egg_points - 2
  selectObject: "PointProcess topo-egg"
  point_1 = Get time from index: point
  point_2 = Get time from index: point + 1
  point_3 = Get time from index: point + 2

  selectObject: "Sound topo-egg"
  egg_minimum_1 = Get time of minimum: point_1, point_2, "Sinc70"
  egg_minimum_2 = Get time of minimum: point_2, point_3, "Sinc70"
  period = egg_minimum_2 - egg_minimum_1

  if period <= mean_period * 2
    selectObject: "PointProcess topo-degg"
    pp_degg_points = Get number of points

    if pp_degg_points != 0
      degg_maximum_point_1 = Get nearest index: egg_minimum_1
      degg_maximum = Get time from index: degg_maximum_point_1

      if degg_maximum <= egg_minimum_1
        degg_maximum = Get time from index: degg_maximum_point_1 + 1
      endif

      if degg_maximum != undefined
        selectObject: "Sound topo-degg"
        degg_minimum = Get time of minimum: degg_maximum, egg_minimum_2, "Sinc70"

        degg_maximum_rel = (degg_maximum - egg_minimum_1) / period
        degg_minimum_rel = (degg_minimum - egg_minimum_1) / period

        period = period * 1000
        result_line$ = "'period','egg_minimum_1','degg_maximum','degg_minimum','egg_minimum_2','degg_maximum_rel','degg_minimum_rel'"

        appendFileLine: result_file$, result_line$
      endif
    endif
  endif

endfor
