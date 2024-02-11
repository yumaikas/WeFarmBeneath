(import spork/sh)
(import spork/path)
(import spork/regex)

(defn file-to-doc [file-path]
    (print)
    (print "# " (path/basename file-path))

    (with [f (file/open file-path)]
        (each l (file/lines f)
            (when
                (regex/find "class_name|class|func" l)
                (print (string/trimr l))
                )
            )
    )
    (print)
)

(defn main [&] 
    (def res @[])
    (sh/scan-directory "." 
        (fn [l] 
            (when (string/has-suffix? ".gd" l)
                (array/push res (let [p (path/parts l)] [(length p) l]))
        )))
    (sort res)
    (each [_ l] res
        (file-to-doc l))
    )